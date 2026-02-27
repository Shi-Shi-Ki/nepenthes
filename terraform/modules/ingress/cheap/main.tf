# --- Security Group ---
resource "aws_security_group" "nat_proxy" {
  name        = "smart_in-nat-proxy-sg-${var.env}"
  description = "Security group for NAT and Reverse Proxy"
  vpc_id      = var.vpc_id

  # 1. インターネットからのHTTP/HTTPS許可 (Webサーバー用)
  ingress {
    description = "Allow HTTP from Anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from Anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 2. VPC内部からの全通信許可 (NAT機能用)
  # プライベートサブネットのECS/Lambdaがここを通って外に出るため
  ingress {
    description = "Allow all traffic from VPC (for NAT)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  # 3. アウトバウンド全許可
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "nat-proxy-sg-${var.env}" }
}

# --- IAM Role for SSM (SSHの代わり) ---
resource "aws_iam_role" "ssm_role" {
  name = "smart_in-ssm-role-${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "smart_in-ssm-profile-${var.env}"
  role = aws_iam_role.ssm_role.name
}

# --- AMI (Amazon Linux 2023 ARM64) ---
data "aws_ami" "al2023_arm" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-arm64"]
  }
}

# --- EC2 Instance (NAT & Proxy) ---
resource "aws_instance" "nat_proxy" {
  ami           = data.aws_ami.al2023_arm.id
  instance_type = "t4g.nano"
  subnet_id     = var.public_subnet_id

  # NATとして動作するために必須 (送信元/送信先チェックを無効化)
  source_dest_check = false

  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.nat_proxy.id]

  # 固定IPを付与しないとDNS設定が面倒なのでEIPを使う前提
  # (実際の割り当ては aws_eip リソースで行う)

  user_data = <<-EOF
    #!/bin/bash
    # 1. NAT設定 (IPマスカレード)
    dnf install -y iptables-services
    sysctl -w net.ipv4.ip_forward=1
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
    service iptables save
    systemctl enable --now iptables

    # 2. Nginx And Certbot install
    dnf install -y nginx
    dnf install -y augeas-libs
    python3 -m venv /opt/certbot/
    /opt/certbot/bin/pip install --upgrade pip
    /opt/certbot/bin/pip install certbot certbot-nginx
    ln -s /opt/certbot/bin/certbot /usr/bin/certbot

    # 3. Nginx設定 (Cloud Mapの名前解決を含むリバースプロキシ)
    cat <<EOC > /etc/nginx/conf.d/app.conf
    server {
        listen 80;
        server_name ${var.domain_name};
        
        # VPC DNS Resolver (AWSの予約IP: x.x.x.2)
        resolver 10.1.0.2 valid=10s;

        set \$backend_url "http://${var.app_service_discovery_name}:${var.app_port}";

        location / {
            proxy_pass \$backend_url;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
    EOC
    systemctl enable --now nginx

    # --- ★ここに追加: 証明書の取得コマンド ---
    # Nginxプラグインを使って証明書を取得し、設定を自動書き換えさせる
    # ※ EIPとドメインの紐付けが完了していないと失敗するため、リトライ機構を入れるか、手動実行を想定する場合もある
    
    # 実際にはDNS浸透待ちが必要なため、ここには「コマンドの例」として記載するか、
    # あるいは失敗しても良いように実行コマンドを置いておきます。
    /usr/bin/certbot --nginx \
      -d ${var.domain_name} \
      -m ${var.email} \
      --agree-tos \
      --non-interactive \
      --redirect
  EOF

  tags = { Name = "nat-proxy-${var.env}" }
}

# --- Elastic IP ---
resource "aws_eip" "nat" {
  instance = aws_instance.nat_proxy.id
  domain   = "vpc"
  tags     = { Name = "nat-eip-${var.env}" }
}

# --- Route (Private Subnet -> NAT Instance) ---
# 検証環境のみ、このルートを追加する
resource "aws_route" "private_nat" {
  route_table_id         = var.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat_proxy.primary_network_interface_id
}

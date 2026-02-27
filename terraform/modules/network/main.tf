# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-${var.env}"
  }
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-${var.env}"
  }
}

# --- Subnets ---

# 1. Public Subnets (ALB, NAT)
resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "public-${var.env}-${count.index + 1}"
    Type = "Public"
  }
}

# 2. Private App Subnets (ECS, Lambda)
resource "aws_subnet" "private_app" {
  count             = length(var.private_app_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "private-app-${var.env}-${count.index + 1}"
    Type = "App"
  }
}

# 3. Private Data Subnets (RDS, ElastiCache)
resource "aws_subnet" "private_data" {
  count             = length(var.private_data_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_data_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "private-data-${var.env}-${count.index + 1}"
    Type = "Data"
  }
}

# --- Route Tables ---

# Public Route Table (IGWへ向く)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "public-rt-${var.env}" }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private App Route Table
# (NAT GWがある場合はここでルート追加。ない場合は空っぽにしておき、検証用モジュールで後から追加する)
resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "private-app-rt-${var.env}" }
}

resource "aws_route_table_association" "private_app" {
  count          = length(var.private_app_subnets)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app.id
}

# Private Data Route Table
# (基本的にインターネットには出さないのでローカルルートのみ)
resource "aws_route_table" "private_data" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "private-data-rt-${var.env}" }
}

resource "aws_route_table_association" "private_data" {
  count          = length(var.private_data_subnets)
  subnet_id      = aws_subnet.private_data[count.index].id
  route_table_id = aws_route_table.private_data.id
}

# --- NAT Gateway (Conditional) ---
# var.enable_nat_gateway が true の時だけ作成 (本番用)

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  tags   = { Name = "nat-eip-${var.env}" }
}

resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id # コスト削減のため1つだけ作成

  tags = { Name = "nat-${var.env}" }

  depends_on = [aws_internet_gateway.main]
}

# NAT Gatewayへのルート (Private App -> NAT GW)
resource "aws_route" "private_nat_gateway" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private_app.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[0].id
}

# --- VPC Endpoints (Gateway Type) ---
# S3とDynamoDBへの通信はNATを通らず無料・高速にする

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.ap-northeast-1.s3"

  # 全ルートテーブルに関連付け
  route_table_ids = concat(
    [aws_route_table.public.id, aws_route_table.private_app.id, aws_route_table.private_data.id]
  )
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.ap-northeast-1.dynamodb"

  # Appルートテーブルに関連付け (Lambda/ECSがアクセスするため)
  route_table_ids = [aws_route_table.private_app.id]
}

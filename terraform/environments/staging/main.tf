terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "smart-in-tfstate-730335481619"
    key     = "staging/terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "administrator_access-730335481619" # SSOプロファイル名
    encrypt = true
  }
}

provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      Project     = "smart_in"
      Environment = "staging"
      ManagedBy   = "terraform"
      Repository  = "github.com/your-org/smart_in-monorepo"
      Owner       = "development-team"
      CreatedAt   = "2024-02-08"
    }
  }
}

# VPC
module "network" {
  source = "../../modules/network"

  env                = "staging"
  vpc_cidr           = "10.1.0.0/16"
  enable_nat_gateway = false # 検証環境ではnat gatewayは作成しない

  public_subnets       = ["10.1.1.0/24", "10.1.2.0/24"]
  private_app_subnets  = ["10.1.11.0/24", "10.1.12.0/24"]
  private_data_subnets = ["10.1.21.0/24", "10.1.22.0/24"]
}

# natインスタンスおよびプロキシーサーバー
module "ingress" {
  source = "../../modules/ingress/cheap"

  env      = "staging"
  vpc_id   = module.network.vpc_id
  vpc_cidr = module.network.vpc_cidr_block

  # EC2は1つのサブネットに配置 (AZ-aを選択)
  public_subnet_id = module.network.public_subnets[0]

  # Private SubnetのルートテーブルにNATへのルートを追加するために渡す
  private_route_table_id = module.network.private_app_route_table_id

  # ドメイン設定 (検証用)
  domain_name = "stg-api.smart_in.com"

  # Certbot用のemail
  email = "hogehoge@test.com"

  # 内部DNS解決の設定 (ECS側で設定する予定の名前)
  app_service_discovery_name = "api.smart_in.local"
}

# Google連携 (APIGW -> SNS -> SQS)
module "google_integration" {
  source = "../../modules/integration/google"
  env    = "prod"

  waf_acl_arn = module.security.waf_acl_arn # API Gatewayにも同じWAFを適用
}

# Compute (Lambdaなど)
module "compute" {
  source = "../../modules/compute"
  env    = "prod"

  # LambdaがSQSをトリガーにするためにARNを渡す
  webhook_sqs_arn = module.google_integration.sqs_queue_arn

  # ... 他の変数
}

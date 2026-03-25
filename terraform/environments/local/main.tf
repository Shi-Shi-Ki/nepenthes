# ---------------------------------------------------------
# LocalStack用のプロバイダ設定
# ---------------------------------------------------------
provider "aws" {
  region                      = "ap-northeast-1"
  access_key                  = "dummy"
  secret_key                  = "dummy"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    s3             = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    iam            = "http://localhost:4566"
    events         = "http://localhost:4566"
    scheduler      = "http://localhost:4566"
    apigatewayv2   = "http://localhost:4566"
    cloudwatchlogs = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}

# ---------------------------------------------------------
# 構築フラグ（LocalStackだけで構築するものを絞る）
# ---------------------------------------------------------
locals {
  # ローカルでは構築しないもの
  enable_network     = false
  enable_ingress     = false
  enable_security    = false
  enable_integration = false

  # ローカルで構築するもの
  enable_serverless = true
  enable_database   = true
}

# ---------------------------------------------------------
# 既存モジュールの呼び出し（フラグで制御）
# ---------------------------------------------------------
module "network" {
  source = "../../modules/network"
  count  = local.enable_network ? 1 : 0
  env    = "local"
}

module "database" {
  source = "../../modules/database"
  count  = local.enable_database ? 1 : 0
}

module "ingress" {
  source = "../../modules/ingress"
  count  = local.enable_ingress ? 1 : 0
}

module "security" {
  source      = "../../modules/security"
  count       = local.enable_security ? 1 : 0
  env         = "local"
  domain_name = "local"
  zone_id     = "local"
}

module "integration" {
  source = "../../modules/integration"
  count  = local.enable_integration ? 1 : 0
}

# ---------------------------------------------------------
# ローカル用のサーバーレス環境呼び出し
# ---------------------------------------------------------
module "local_serverless" {
  source = "../../modules/serverless/local"
  count  = local.enable_serverless ? 1 : 0
}

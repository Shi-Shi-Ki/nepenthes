# セキュリティ (WAF/ACM)
module "security" {
  source = "../../modules/security"
  env    = "prod"

  domain_name = "api.smartin.com"
  zone_id     = "Z0123456789ABCDEF" # Route53のZoneID
}

# ネットワーク
module "network" {
  source             = "../../modules/network"
  env                = "prod"
  enable_nat_gateway = true
  # ...
}

# 本番用ALB (Secure Ingress)
module "ingress" {
  source = "../../modules/ingress/secure"
  env    = "prod"

  vpc_id              = module.network.vpc_id
  public_subnets      = module.network.public_subnets
  acm_certificate_arn = module.security.acm_certificate_arn # 作ったACMを渡す
  waf_acl_arn         = module.security.waf_acl_arn         # 作ったWAFを渡す
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

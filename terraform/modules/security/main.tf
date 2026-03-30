# --- 1. ACM (SSL証明書) ---
resource "aws_acm_certificate" "main" {
  count = var.env == "local" ? 0 : 1

  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = { Name = "cert-${var.env}" }

  lifecycle {
    create_before_destroy = true
  }
}

# DNS検証用レコードの作成
resource "aws_route53_record" "cert_validation" {
  for_each = var.env == "local" ? {} : {
    for dvo in aws_acm_certificate.main[0].domain_validation_options : dvo.domain_name => dvo
  }

  allow_overwrite = true
  name            = each.value.resource_record_name
  records         = [each.value.resource_record_value]
  ttl             = 60
  type            = each.value.resource_record_type
  zone_id         = var.zone_id
}

# 検証の待機
resource "aws_acm_certificate_validation" "main" {
  count = var.env == "local" ? 0 : 1

  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# --- 2. WAFv2 (Web ACL) ---
resource "aws_wafv2_web_acl" "main" {
  count = var.env == "local" ? 0 : 1

  name        = "smart_in-waf-${var.env}"
  description = "WAF for ALB and API Gateway"
  scope       = "REGIONAL" # CloudFrontの場合はCLOUDFRONT

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "smart_in-waf-${var.env}"
    sampled_requests_enabled   = true
  }

  # AWSマネージドルール (一般的な攻撃対策)
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 10

    # 修正: ブロックを展開して記述
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # SQLインジェクション対策
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 20

    # 修正: ブロックを展開して記述
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }
}

# ==============================================================================
# KMS (Key Management Service) : DBカラム暗号化用
# ==============================================================================
resource "aws_kms_key" "db_encryption_key" {
  description             = "KMS key for RDS/MySQL column encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "db_encryption_key_alias" {
  name          = "alias/meeting-room-reservation-system_db-column-encryption-key"
  target_key_id = aws_kms_key.db_encryption_key.key_id
}

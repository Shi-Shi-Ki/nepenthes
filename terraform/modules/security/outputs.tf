output "acm_certificate_arn" {
  value = aws_acm_certificate.main.arn
}

output "waf_acl_arn" {
  value = aws_wafv2_web_acl.main.arn
}

output "acm_certificate_arn" {
  value = try(aws_acm_certificate.main[0].arn, "")
}

output "waf_acl_arn" {
  value = try(aws_wafv2_web_acl.main[0].arn, "")
}

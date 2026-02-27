variable "env" { type = string }
variable "vpc_id" { type = string }

# ALBは最低2つのサブネットが必要
variable "public_subnets" { type = list(string) }

# ACM証明書のARN (事前に作成済みである前提、または別途作成)
variable "acm_certificate_arn" { type = string }

variable "waf_acl_arn" {
  description = "WAF Web ACL ARN"
  type        = string
}

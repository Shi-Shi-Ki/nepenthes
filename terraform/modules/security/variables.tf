variable "env" {
  type        = string
  description = "デプロイする環境名 (local, staging, production)"
}

variable "domain_name" {
  type = string
}

variable "zone_id" {
  type = string # Route53のホストゾーンID
}

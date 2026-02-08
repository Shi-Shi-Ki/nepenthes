variable "env" { type = string }
variable "vpc_id" { type = string }
variable "vpc_cidr" { type = string }

# 配置場所 (1つだけ受け取る)
variable "public_subnet_id" { type = string }

# NATのルートを追加するルートテーブルID
variable "private_route_table_id" { type = string }

# アプリケーションのドメイン (例: stg-api.smart_in.com)
variable "domain_name" { type = string }

# 転送先ECSのサービス検出名 (例: api.smart_in.local)
variable "app_service_discovery_name" {
  type    = string
  default = "api.smart_in.local"
}

# 転送先ポート
variable "app_port" {
  type    = number
  default = 3000
}

variable "email" {
  description = "Certbot用メールアドレス"
  type        = string
}

variable "ecs_service_name" {
  description = "転送先のECSサービス名"
  type        = string
  default     = "api"
}

variable "cloudmap_namespace" {
  description = "CloudMapの名前空間"
  type        = string
  default     = "smartin.local"
}

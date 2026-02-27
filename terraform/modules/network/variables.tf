variable "env" {
  description = "環境名 (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC全体のCIDRブロック"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "利用するアベイラビリティゾーンのリスト"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

# --- サブネット構成 (各2つずつ作成想定) ---
variable "public_subnets" {
  description = "パブリックサブネットのCIDRリスト"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnets" {
  description = "アプリ用プライベートサブネットのCIDRリスト (ECS, Lambda)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_data_subnets" {
  description = "データ用プライベートサブネットのCIDRリスト (RDS, ElastiCache)"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

# --- 機能フラグ ---
variable "enable_nat_gateway" {
  description = "NAT Gatewayを作成するか (true: 作成, false: 作成しない)"
  type        = bool
  default     = true
}

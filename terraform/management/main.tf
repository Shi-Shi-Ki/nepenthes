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
    key     = "management/terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "administrator_access-730335481619" # SSOプロファイル名
    encrypt = true
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "administrator_access-730335481619"

  default_tags {
    tags = {
      Project     = "smart_in"
      Environment = "management"
      ManagedBy   = "terraform"
      Description = "Terraform State Store"
    }
  }
}

# アカウントIDを取得（バケット名をユニークにするため）
data "aws_caller_identity" "current" {}

# --- tfstate保存用S3バケット ---
resource "aws_s3_bucket" "tfstate" {
  # バケット名
  bucket = "smart-in-tfstate-${data.aws_caller_identity.current.account_id}"

  # 誤削除防止
  lifecycle {
    prevent_destroy = true
  }
}

# バージョニングの有効化（必須級：誤ってstateを壊しても戻せるようにする）
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 暗号化（デフォルト）
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# パブリックアクセスブロック（セキュリティ）
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# バケット名を出力（後でコピペして使うため）
output "tfstate_bucket_name" {
  value = aws_s3_bucket.tfstate.bucket
}

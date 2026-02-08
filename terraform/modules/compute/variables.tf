variable "env" {
  description = "環境名"
  type        = string
}

variable "webhook_sqs_arn" {
  description = "Googleカレンダー連携用SQSのARN"
  type        = string
  default     = "" # 検証環境など、使わない場合のために空文字をデフォルトに
}

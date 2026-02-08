output "sqs_queue_arn" {
  description = "Lambdaトリガー用のSQS ARN"
  value       = aws_sqs_queue.webhook_queue.arn
}

output "webhook_url" {
  description = "Googleカレンダーに登録するWebhook URL"
  value       = "${aws_api_gateway_stage.main.invoke_url}/webhook"
}

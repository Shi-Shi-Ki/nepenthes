output "api_server_secret_arn" {
  description = "APIサーバー用シークレットのARN"
  value       = aws_secretsmanager_secret.api_server_key.arn
}

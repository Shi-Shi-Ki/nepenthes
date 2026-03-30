# ==============================================================================
# Secrets Manager
# ==============================================================================
# APIサーバー連携用のAPIキー
resource "aws_secretsmanager_secret" "api_server_key" {
  name        = "api-server/internal-api-key"
  description = "API key for Lambda to access the API server"

  # 強制削除の設定（開発環境などでTerraform destroy時にエラーになるのを防ぐ）
  force_overwrite_replica_secret = true
  recovery_window_in_days        = var.env == "local" ? 0 : 30
}

resource "aws_secretsmanager_secret_version" "api_server_key_version" {
  secret_id = aws_secretsmanager_secret.api_server_key.id
  secret_string = jsonencode({
    API_KEY = "dummy-api-key-1234567890" # TODO
  })
}

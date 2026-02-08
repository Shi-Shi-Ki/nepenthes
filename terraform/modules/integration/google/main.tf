variable "env" { type = string }
variable "waf_acl_arn" { type = string } # 作成したWAFを紐付ける

# --- 1. SQS (Lambdaへのバッファ) ---
resource "aws_sqs_queue" "webhook_dlq" {
  name = "smart_in-webhook-dlq-${var.env}"
}

resource "aws_sqs_queue" "webhook_queue" {
  name = "smart_in-webhook-queue-${var.env}"

  # エラー時のDLQ転送設定
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.webhook_dlq.arn
    maxReceiveCount     = 3
  })
}

# --- 2. SNS (APIGWとSQSの仲介) ---
resource "aws_sns_topic" "webhook_topic" {
  name = "smart_in-google-calendar-topic-${var.env}"
}

# SNS -> SQS サブスクリプション
resource "aws_sns_topic_subscription" "webhook_sqs_target" {
  topic_arn = aws_sns_topic.webhook_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.webhook_queue.arn
}

# SQSポリシー (SNSからの書き込み許可)
resource "aws_sqs_queue_policy" "webhook_queue_policy" {
  queue_url = aws_sqs_queue.webhook_queue.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.webhook_queue.arn
      Condition = {
        ArnEquals = { "aws:SourceArn" = aws_sns_topic.webhook_topic.arn }
      }
    }]
  })
}

# --- 3. API Gateway (REST API) ---
resource "aws_api_gateway_rest_api" "main" {
  name        = "smart_in-webhook-api-${var.env}"
  description = "Google Calendar Webhook Receiver"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "webhook" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "webhook"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.webhook.id
  http_method   = "POST"
  authorization = "NONE" # Googleからの通知は認証なし(ヘッダ検証のみ)
}

# APIGWがSNSにPublishするためのIAMロール
resource "aws_iam_role" "apigw_sns" {
  name = "smart_in-apigw-sns-role-${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = { Service = "apigateway.amazonaws.com" }
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_role_policy" "apigw_sns" {
  name = "smart_in-apigw-sns-policy-${var.env}"
  role = aws_iam_role.apigw_sns.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "sns:Publish"
      Effect   = "Allow"
      Resource = aws_sns_topic.webhook_topic.arn
    }]
  })
}

# Integration: APIGW -> SNS
resource "aws_api_gateway_integration" "sns" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.webhook.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:ap-northeast-1:sns:path//"
  credentials             = aws_iam_role.apigw_sns.arn

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  # BodyをSNSのMessageにマッピング
  request_templates = {
    "application/json" = "Action=Publish&TopicArn=$util.urlEncode('${aws_sns_topic.webhook_topic.arn}')&Message=$util.urlEncode($input.body)"
  }
}

# Response 200 OK
resource "aws_api_gateway_method_response" "ok" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.webhook.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "ok" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.webhook.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = aws_api_gateway_method_response.ok.status_code
  depends_on  = [aws_api_gateway_integration.sns]
}

# Deployment & Stage
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  depends_on  = [aws_api_gateway_integration.sns]

  # 再デプロイのトリガー
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_integration.sns))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.env
}

# --- 4. WAF Association for API Gateway ---
resource "aws_wafv2_web_acl_association" "apigw" {
  resource_arn = aws_api_gateway_stage.main.arn
  web_acl_arn  = var.waf_acl_arn
}

# ---------------------------------------------------------
# IAM Role: LocalStack用の権限
# ---------------------------------------------------------
resource "aws_iam_role" "api_gateway_role" {
  name = "local-stack-apigateway-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "apigateway.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apigateway_basic_execution" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "lambda_worker_role" {
  name = "local-stack-lambda-worker-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_sqs_policy" {
  name = "lambda-sqs-execution-policy"
  role = aws_iam_role.lambda_worker_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy" "apigw_sqs_policy" {
  name = "apigateway-sqs-policy"
  role = aws_iam_role.api_gateway_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sqs:SendMessage"
      Resource = aws_sqs_queue.webhook_queue.arn
    }]
  })
}

# ---------------------------------------------------------
# APIGateway: HTTP API
# ---------------------------------------------------------
data "aws_caller_identity" "current" {}

resource "aws_api_gateway_rest_api" "webhook_api" {
  name = "webhook-api"
}

resource "aws_api_gateway_resource" "webhook_resource" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  parent_id   = aws_api_gateway_rest_api.webhook_api.root_resource_id
  path_part   = "webhook"
}

resource "aws_api_gateway_method" "webhook_method" {
  rest_api_id   = aws_api_gateway_rest_api.webhook_api.id
  resource_id   = aws_api_gateway_resource.webhook_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  resource_id = aws_api_gateway_resource.webhook_resource.id
  http_method = aws_api_gateway_method.webhook_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_deployment" "webhook_deployment" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.webhook_resource.id,
      aws_api_gateway_method.webhook_method.id,
      aws_api_gateway_integration.sqs_integration.id,
      aws_api_gateway_integration_response.integration_response_200.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.sqs_integration,
  ]
}

resource "aws_api_gateway_stage" "webhook_stage" {
  deployment_id = aws_api_gateway_deployment.webhook_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.webhook_api.id
  stage_name    = "default"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw_log.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      sourceIp       = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      integrationErr = "$context.integrationErrorMessage"
    })
  }
}

resource "aws_api_gateway_integration_response" "integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  resource_id = aws_api_gateway_resource.webhook_resource.id
  http_method = aws_api_gateway_method.webhook_method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  response_templates = {
    "application/json" = "{\"message\": \"Webhook received and queued successfully.\"}"
  }

  depends_on = [aws_api_gateway_integration.sqs_integration]
}

resource "aws_api_gateway_integration" "sqs_integration" {
  rest_api_id             = aws_api_gateway_rest_api.webhook_api.id
  resource_id             = aws_api_gateway_resource.webhook_resource.id
  http_method             = aws_api_gateway_method.webhook_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  credentials             = aws_iam_role.api_gateway_role.arn

  # 送信先のSQSをパス形式で指定します
  uri = "arn:aws:apigateway:ap-northeast-1:sqs:path/${data.aws_caller_identity.current.account_id}/${aws_sqs_queue.webhook_queue.name}"

  # SQSのAPIは "application/x-www-form-urlencoded" しか受け付けないため、ヘッダーを上書きします
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  # 受け取ったJSONボディをURLエンコードして、SQSの "MessageBody" パラメータとして渡します
  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$util.urlEncode($input.body)"
  }
}

resource "aws_cloudwatch_log_group" "apigw_log" {
  name              = "/aws/apigateway/webhook-api-logs"
  retention_in_days = 3
}

# ---------------------------------------------------------
# SQS & DLQ: APIGatewayからのリクエストをキューイング
# ---------------------------------------------------------
resource "aws_sqs_queue" "webhook_dlq" {
  name = "webhook-dlq"
}

resource "aws_sqs_queue" "webhook_queue" {
  name = "webhook-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.webhook_dlq.arn
    maxReceiveCount     = 3 # 3回失敗でDLQへ
  })
}

# ---------------------------------------------------------
# Lambda: SQSのキューイングをトリガーに実行
# ---------------------------------------------------------
data "archive_file" "calendar_webhook_source" {
  type        = "zip"
  source_dir  = "${path.module}/../../../../apps/workers/dist"
  output_path = "${path.module}/.terraform/archive/calendar_webhook.zip"
}

resource "aws_lambda_function" "calendar_webhook_trigger" {
  filename         = data.archive_file.calendar_webhook_source.output_path
  function_name    = "GoogleCalendarWebhook"
  handler          = "google-calendar-webhook-handler.handler"
  runtime          = "nodejs24.x"
  role             = aws_iam_role.lambda_worker_role.arn
  source_code_hash = data.archive_file.calendar_webhook_source.output_base64sha256
  environment {
    variables = {
      API_URL = "http://host.docker.internal:3001"
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.webhook_queue.arn
  function_name    = aws_lambda_function.calendar_webhook_trigger.arn
}

resource "aws_cloudwatch_log_group" "lambda_webhook_trigger_log" {
  name              = "/aws/lambda/${aws_lambda_function.calendar_webhook_trigger.function_name}"
  retention_in_days = 3
}

# ---------------------------------------------------------
# EventBridge: webhookのトリガー処理に失敗した時のDLQを定期チェックする
# ---------------------------------------------------------
resource "aws_cloudwatch_event_rule" "dlq_checker" {
  name                = "dlq-checker-schedule"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "dlq_checker_target" {
  rule      = aws_cloudwatch_event_rule.dlq_checker.name
  target_id = "TriggerDLQCheckerLambda"
  arn       = aws_lambda_function.calendar_webhook_dlq_checker.arn
}

resource "aws_lambda_permission" "allow_event_bridge_to_call_dlq_checker" {
  statement_id  = "AllowExecutionFromEventBridge_CalendarWebhookDlqChecker"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.calendar_webhook_dlq_checker.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.dlq_checker.arn
}

# ---------------------------------------------------------
# Lambda: DLQ（calendar webhook）のキューイングをトリガーに実行
# ---------------------------------------------------------
resource "aws_lambda_function" "calendar_webhook_dlq_checker" {
  filename         = data.archive_file.calendar_webhook_source.output_path
  function_name    = "CalendarWebhookDlqChecker"
  handler          = "google-calendar-webhook-dlq-checker-handler.handler"
  runtime          = "nodejs24.x"
  role             = aws_iam_role.lambda_worker_role.arn
  source_code_hash = data.archive_file.calendar_webhook_source.output_base64sha256
  environment {
    variables = {
      API_URL = "http://host.docker.internal:3001"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_dlq_checker_log" {
  name              = "/aws/lambda/${aws_lambda_function.calendar_webhook_dlq_checker.function_name}"
  retention_in_days = 3
}

# ---------------------------------------------------------
# EventBridge: 15分ごとの定期処理バッチ
# ---------------------------------------------------------
resource "aws_cloudwatch_event_rule" "cron_regular_monitoring_of_reservation" {
  name                = "cron-15m"
  schedule_expression = "rate(15 minutes)"
}

resource "aws_cloudwatch_event_target" "cron_regular_monitoring_of_reservation_target" {
  rule      = aws_cloudwatch_event_rule.cron_regular_monitoring_of_reservation.name
  target_id = "CallNestJSSync"
  arn       = aws_lambda_function.cron_regular_monitoring_of_reservation.arn
}

resource "aws_lambda_permission" "allow_event_bridge_to_call_regular_monitoring" {
  statement_id  = "AllowExecutionFromEventBridge_RegularMonitoring"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cron_regular_monitoring_of_reservation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cron_regular_monitoring_of_reservation.arn
}

# ---------------------------------------------------------
# Lambda: 予約情報（DynamoDB）の定期状況確認
# ---------------------------------------------------------
resource "aws_lambda_function" "cron_regular_monitoring_of_reservation" {
  filename         = data.archive_file.calendar_webhook_source.output_path
  function_name    = "CronRegularMonitoringOfReservation"
  handler          = "cron-regular-monitoring-of-reservation-handler.handler"
  runtime          = "nodejs24.x"
  role             = aws_iam_role.lambda_worker_role.arn
  source_code_hash = data.archive_file.calendar_webhook_source.output_base64sha256
  environment {
    variables = {
      API_URL = "http://host.docker.internal:3001"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_cron_regular_monitoring_of_reservation_log" {
  name              = "/aws/lambda/${aws_lambda_function.cron_regular_monitoring_of_reservation.function_name}"
  retention_in_days = 3
}

# ---------------------------------------------------------
# EventBridge: 1日1回のバッチ処理（翌日のカレンダー予約を取得）
# ---------------------------------------------------------
resource "aws_cloudwatch_event_rule" "cron_daily_create_reservation" {
  name                = "cron-daily"
  schedule_expression = "cron(0 15 * * ? *)"
}

resource "aws_cloudwatch_event_target" "cron_daily_create_reservation_target" {
  rule      = aws_cloudwatch_event_rule.cron_daily_create_reservation.name
  target_id = "CallNestJSBatch"
  arn       = aws_lambda_function.cron_daily_create_reservation.arn
}

resource "aws_lambda_permission" "allow_event_bridge_to_cron_daily_create_reservation" {
  statement_id  = "AllowExecutionFromEventBridge_DailyCreateReservation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cron_daily_create_reservation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cron_daily_create_reservation.arn
}

# ---------------------------------------------------------
# Lambda: カレンダーの予約情報の作成
# ---------------------------------------------------------
resource "aws_lambda_function" "cron_daily_create_reservation" {
  filename      = data.archive_file.calendar_webhook_source.output_path
  function_name = "CronDailyCreateReservation"
  handler       = "cron-daily-create-reservation-handler.handler"
  runtime       = "nodejs24.x"
  role          = aws_iam_role.lambda_worker_role.arn
  environment {
    variables = {
      API_URL = "http://host.docker.internal:3001"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_cron_daily_create_reservation_log" {
  name              = "/aws/lambda/${aws_lambda_function.cron_daily_create_reservation.function_name}"
  retention_in_days = 3
}

# ---------------------------------------------------------
# Lambda: 予約の自動解放を行う関数（schedulerはサーバー側から作成する）
# ---------------------------------------------------------
resource "aws_lambda_function" "reservation_auto_release" {
  filename      = data.archive_file.calendar_webhook_source.output_path
  function_name = "ReservationAutoRelease"
  handler       = "reservation-auto-release-handler.handler"
  runtime       = "nodejs24.x"
  role          = aws_iam_role.lambda_worker_role.arn
  environment {
    variables = {
      API_URL = "http://host.docker.internal:3001"
    }
  }
}

# ---------------------------------------------------------
# IAM Role: EventBridge SchedulerがLambdaを実行するためのIAMロール
# ---------------------------------------------------------
resource "aws_iam_role" "scheduler_role" {
  name = "event-bridge-scheduler-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "scheduler.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "scheduler_invoke_lambda" {
  name = "scheduler-invoke-lambda-policy"
  role = aws_iam_role.scheduler_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "lambda:InvokeFunction"
      Effect   = "Allow"
      Resource = aws_lambda_function.reservation_auto_release.arn
    }]
  })
}

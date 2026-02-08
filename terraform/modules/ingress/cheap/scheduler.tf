# --- IAM Role for EventBridge Scheduler ---
# スケジューラがEC2を操作するための権限
resource "aws_iam_role" "scheduler" {
  name = "smart_in-ec2-scheduler-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# EC2の起動・停止だけを許可するポリシー
resource "aws_iam_role_policy" "scheduler_ec2_policy" {
  name = "smart_in-ec2-scheduler-policy-${var.env}"
  role = aws_iam_role.scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        # 対象をNATインスタンスだけに絞る
        Resource = [aws_instance.nat_proxy.arn]
      }
    ]
  })
}

# --- Schedule: 自動起動 (平日 朝07:00) ---
resource "aws_scheduler_schedule" "ec2_start" {
  name       = "smart_in-ec2-start-${var.env}"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  # 平日(月-金)の朝 07:00 JST に実行
  schedule_expression          = "cron(0 7 ? * MON-FRI *)"
  schedule_expression_timezone = "Asia/Tokyo"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.scheduler.arn

    input = jsonencode({
      InstanceIds = [aws_instance.nat_proxy.id]
    })
  }
}

# --- Schedule: 自動停止 (毎日 深夜00:00) ---
resource "aws_scheduler_schedule" "ec2_stop" {
  name       = "smart_in-ec2-stop-${var.env}"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  # 毎日 深夜 00:00 JST に実行
  # (土日の深夜も実行されるが、既に止まっているのでエラーにはならず無害)
  schedule_expression          = "cron(0 0 * * ? *)"
  schedule_expression_timezone = "Asia/Tokyo"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.scheduler.arn

    input = jsonencode({
      InstanceIds = [aws_instance.nat_proxy.id]
    })
  }
}

# ---------------------------------------------------------
# DynamoDB: 会議室予約情報テーブル
# ---------------------------------------------------------
resource "aws_dynamodb_table" "that_day_meeting_room_reservation" {
  name           = "that_day_meeting_room_reservation"
  billing_mode   = "PROVISIONED"
  read_capacity  = 30
  write_capacity = 20
  hash_key       = "resource_id"    # partition_key
  range_key      = "start_datetime" # sort_key

  attribute {
    name = "event_id"
    type = "S"
  }
  attribute {
    name = "resource_id"
    type = "S"
  }
  attribute {
    name = "location_id"
    type = "N"
  }
  attribute {
    name = "start_datetime" # ISO_8601形式の日付で保存
    type = "S"
  }

  # イベントIDをキーとしたindex
  # カレンダー変更時の更新や削除を行うために使用する
  global_secondary_index {
    name            = "RESERVATIONS_IDX"
    projection_type = "ALL"
    read_capacity   = 30
    write_capacity  = 20
    key_schema {
      attribute_name = "event_id"
      key_type       = "HASH"
    }
  }

  # 拠点IDと開始日時をキーにしたindex
  # ユーザーページからの検索に用いる
  global_secondary_index {
    name            = "LOCATIONS_IDX"
    projection_type = "ALL"
    read_capacity   = 30
    write_capacity  = 20
    key_schema {
      attribute_name = "location_id"
      key_type       = "HASH"
    }
    key_schema {
      attribute_name = "start_datetime"
      key_type       = "RANGE"
    }
  }

  ttl {
    attribute_name = "ExpiryDate"
    enabled        = true
  }
}

# ---------------------------------------------------------
# DynamoDB: タブレット死活監視テーブル
# ---------------------------------------------------------
resource "aws_dynamodb_table" "tablets_monitoring" {
  name           = "tablets_monitoring"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "tablet_id"
  range_key      = "latest_checked_datetime"

  attribute {
    name = "tablet_id"
    type = "S"
  }
  attribute {
    name = "latest_checked_datetime" # ISO_8601形式の日付で保存
    type = "S"
  }

  ttl {
    attribute_name = "ExpiryDate"
    enabled        = true
  }
}

# ---------------------------------------------------------
# オートスケーリングの対象（ターゲット）を一括定義
# ---------------------------------------------------------
locals {
  dynamodb_asg_targets = {
    # 会議室予約情報テーブル
    reservation_table_read = {
      id     = "table/${aws_dynamodb_table.that_day_meeting_room_reservation.name}",
      dim    = "dynamodb:table:ReadCapacityUnits",
      min    = 30,
      metric = "DynamoDBReadCapacityUtilization"
    }
    reservation_table_write = {
      id     = "table/${aws_dynamodb_table.that_day_meeting_room_reservation.name}",
      dim    = "dynamodb:table:WriteCapacityUnits",
      min    = 20,
      metric = "DynamoDBWriteCapacityUtilization"
    }

    # GSI_1: 拠点検索用
    reservation_gsi1_read = {
      id     = "table/${aws_dynamodb_table.that_day_meeting_room_reservation.name}/index/LocationIndex",
      dim    = "dynamodb:index:ReadCapacityUnits",
      min    = 30,
      metric = "DynamoDBReadCapacityUtilization"
    }
    reservation_gsi1_write = {
      id     = "table/${aws_dynamodb_table.that_day_meeting_room_reservation.name}/index/LocationIndex",
      dim    = "dynamodb:index:WriteCapacityUnits",
      min    = 20,
      metric = "DynamoDBWriteCapacityUtilization"
    }

    # GSI_2: EventID検索用
    reservation_gsi2_read = {
      id     = "table/${aws_dynamodb_table.that_day_meeting_room_reservation.name}/index/EventIdIndex",
      dim    = "dynamodb:index:ReadCapacityUnits",
      min    = 30,
      metric = "DynamoDBReadCapacityUtilization"
    }
    reservation_gsi2_write = {
      id     = "table/${aws_dynamodb_table.that_day_meeting_room_reservation.name}/index/EventIdIndex",
      dim    = "dynamodb:index:WriteCapacityUnits",
      min    = 20,
      metric = "DynamoDBWriteCapacityUtilization"
    }

    # タブレット死活監視テーブル
    monitoring_table_read = {
      id     = "table/${aws_dynamodb_table.tablets_monitoring.name}",
      dim    = "dynamodb:table:ReadCapacityUnits",
      min    = 10,
      metric = "DynamoDBReadCapacityUtilization"
    }
    monitoring_table_write = {
      id     = "table/${aws_dynamodb_table.tablets_monitoring.name}",
      dim    = "dynamodb:table:WriteCapacityUnits",
      min    = 10,
      metric = "DynamoDBWriteCapacityUtilization"
    }
  }
}

resource "aws_appautoscaling_target" "dynamodb_target" {
  for_each = var.env == "local" ? {} : local.dynamodb_asg_targets # for_eachとcountは併用不可

  max_capacity       = 100 # 最大どこまで拡張するか（1000人規模なら100〜200で十分）
  min_capacity       = each.value.min
  resource_id        = each.value.id
  scalable_dimension = each.value.dim
  service_namespace  = "dynamodb"
}

# ---------------------------------------------------------
# オートスケーリングのルール（ポリシー）を一括適用
# ---------------------------------------------------------
resource "aws_appautoscaling_policy" "dynamodb_policy" {
  for_each = var.env == "local" ? {} : local.dynamodb_asg_targets # for_eachとcountは併用不可

  name               = "AutoScalingPolicy-${each.key}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_target[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_target[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = each.value.metric
    }
    target_value = 70.0
  }
}

# ---------------------------------------------------------
# アラート通知先
# ---------------------------------------------------------
resource "aws_sns_topic" "dynamodb_alerts" {
  count = var.env == "local" ? 0 : 1

  name = "dynamodb-capacity-alerts"
}

resource "aws_sns_topic_subscription" "dynamodb_alerts_topic" {
  count = var.env == "local" ? 0 : 1

  topic_arn = aws_sns_topic.dynamodb_alerts[0].arn # countを定義すると配列変数になる
  protocol  = "email"
  endpoint  = "" # todo
}

# ---------------------------------------------------------
# CloudWatch アラーム：読み込みスロットリング検知
# ---------------------------------------------------------
locals {
  monitored_tables = [
    aws_dynamodb_table.that_day_meeting_room_reservation.name,
    aws_dynamodb_table.tablets_monitoring.name
  ]
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_read_throttle" {
  for_each = var.env == "local" ? toset([]) : toset(local.monitored_tables)

  alarm_name          = "DynamoDB-Read-Throttle-Alert"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1" # 1分間でも超えたら
  metric_name         = "ReadThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = "60" # 60秒間隔でチェック
  statistic           = "Sum"
  threshold           = "0" # 0回より大きければ（＝1回でも発生したら）発報

  dimensions = {
    TableName = each.key
  }

  alarm_description = "DynamoDB（${each.key}）の読み込みキャパシティが不足し、スロットリングが発生しています。"
  alarm_actions     = [aws_sns_topic.dynamodb_alerts[0].arn] # countを定義すると配列変数になる
}

# ---------------------------------------------------------
# CloudWatch アラーム：書き込みスロットリング検知
# ---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dynamodb_write_throttle" {
  for_each = var.env == "local" ? toset([]) : toset(local.monitored_tables)

  alarm_name          = "DynamoDB-Write-Throttle-Alert"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1" # 1分間でも超えたら
  metric_name         = "WriteThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = "60" # 60秒間隔でチェック
  statistic           = "Sum"
  threshold           = "0" # 0回より大きければ（＝1回でも発生したら）発報

  dimensions = {
    TableName = each.key
  }

  alarm_description = "DynamoDB（${each.key}）の書き込みキャパシティが不足し、スロットリングが発生しています。"
  alarm_actions     = [aws_sns_topic.dynamodb_alerts[0].arn] # countを定義すると配列変数になる
}

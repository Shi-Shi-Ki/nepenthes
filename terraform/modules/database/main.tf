resource "aws_dynamodb_table" "that_day_calendar_reservation" {
  name           = "that_day_calendar_reservation"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "event_id"       # partition_key
  range_key      = "start_datetime" # sort_key

  attribute {
    name = "event_id"
    type = "S"
  }
  attribute {
    name = "start_datetime"
    type = "S"
  }

  global_secondary_index {
    name            = "resource_id"
    projection_type = "ALL"
    key_schema {
      attribute_name = "event_id"
      key_type       = "HASH"
    }
  }

  global_secondary_index {
    name            = "location_id"
    projection_type = "ALL"
    key_schema {
      attribute_name = "event_id"
      key_type       = "HASH"
    }
  }

  ttl {
    attribute_name = "ExpiryDate"
    enabled        = true
  }
}

resource "aws_dynamodb_table_item" "that_day_calendar_reservation_item" {
  table_name = aws_dynamodb_table.that_day_calendar_reservation.name
  hash_key   = aws_dynamodb_table.that_day_calendar_reservation.hash_key
  item = jsonencode({
    "event_id" : { "S" : "" },
    "resource_id" : { "S" : "" },
    "location_id" : { "S" : "" },
    "title" : { "S" : "" },
    "description" : { "S" : "" },
    "start_datetime" : { "S" : "" },
    "end_datetime" : { "S" : "" },
    "status" : { "S" : "" },
    "is_all_day_use" : { "N" : "0" },
    "reservation_type" : { "S" : "" },
    "visibility" : { "S" : "" },
  })
}

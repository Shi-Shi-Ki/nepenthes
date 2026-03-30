# ローカルのインフラ環境

## LocalStackのリソース確認

```shell
% curl -s http://localhost:4566/_localstack/health | jq .
{
  "services": {
    "acm": "disabled",
    "apigateway": "available",
    "cloudformation": "disabled",
    "cloudwatch": "disabled",
    "config": "disabled",
    "dynamodb": "available",
    "dynamodbstreams": "available",
    "ec2": "disabled",
    "es": "disabled",
    "events": "available",
    "firehose": "disabled",
    "iam": "available",
    "kinesis": "available",
    "kms": "available",
    "lambda": "available",
    "logs": "available",
    "opensearch": "disabled",
    "redshift": "disabled",
    "resource-groups": "disabled",
    "resourcegroupstaggingapi": "disabled",
    "route53": "disabled",
    "route53resolver": "disabled",
    "s3": "available",
    "s3control": "disabled",
    "scheduler": "available",
    "secretsmanager": "available",
    "ses": "disabled",
    "sns": "available",
    "sqs": "available",
    "ssm": "disabled",
    "stepfunctions": "disabled",
    "sts": "available",
    "support": "disabled",
    "swf": "disabled",
    "transcribe": "disabled"
  },
  "edition": "community",
  "version": "4.14.0"
}
```

## 各種のリソース確認

### API Gateway

```shell
% awslocal apigateway get-rest-apis

{
    "items": [
        {
            "id": "27fmwgdvwe",    # API_ID
            "name": "webhook-api",
            ...
        }
    ]
}
```

```shell
% awslocal apigateway get-resources --rest-api-id 27fmwgdvwe
{
    "items": [
        {
            "id": "pdx63ugf4x",
            "parentId": "yggeictbfh",
            "pathPart": "webhook",
            "path": "/webhook",
            "resourceMethods": {
                "POST": {
                    "httpMethod": "POST",
                    "authorizationType": "NONE",
                    "apiKeyRequired": false,
                    "methodResponses": {
                        "200": {
                            "statusCode": "200"
                        }
                    },
                    "methodIntegration": {
                        "type": "AWS",
                        "httpMethod": "POST",
                        "uri": "arn:aws:apigateway:ap-northeast-1:sqs:path/000000000000/webhook-queue",
                        "connectionType": "INTERNET",
                        "credentials": "arn:aws:iam::000000000000:role/local-stack-apigateway-role",
                        "requestParameters": {
                            "integration.request.header.Content-Type": "'application/x-www-form-urlencoded'"
                        },
                        "requestTemplates": {
                            "application/json": "Action=SendMessage&MessageBody=$util.urlEncode($input.body)"
                        },
                        "passthroughBehavior": "WHEN_NO_MATCH",
                        "timeoutInMillis": 29000,
                        "cacheNamespace": "pdx63ugf4x",
                        "cacheKeyParameters": [],
                        "integrationResponses": {
                            "200": {
                                "statusCode": "200",
                                "responseTemplates": {
                                    "application/json": "{\"message\": \"Webhook received and queued successfully.\"}"
                                }
                            }
                        }
                    }
                }
            }
        }
    ]
}
```

```shell
% awslocal apigateway get-stages --rest-api-id 27fmwgdvwe
{
    "item": [
        {
            "deploymentId": "revmjahfni",
            "stageName": "default",       # ステージ名（リクエストの際に使用する）
            "cacheClusterEnabled": false,
            "cacheClusterStatus": "NOT_AVAILABLE",
            "methodSettings": {},
            "accessLogSettings": {
                "format": "{\"httpMethod\":\"$context.httpMethod\",\"integrationErr\":\"$context.integrationErrorMessage\",\"requestId\":\"$context.requestId\",\"requestTime\":\"$context.requestTime\",\"resourcePath\":\"$context.resourcePath\",\"sourceIp\":\"$context.identity.sourceIp\",\"status\":\"$context.status\"}",
                "destinationArn": "arn:aws:logs:ap-northeast-1:000000000000:log-group:/aws/apigateway/webhook-api-logs"
            },
            "tracingEnabled": false,
            "createdDate": "2026-03-29T00:07:22+09:00",
            "lastUpdatedDate": "2026-03-29T00:07:22+09:00"
        }
    ]
}
```

### SQS

```shell
% awslocal sqs list-queues
{
    "QueueUrls": [
        "http://sqs.ap-northeast-1.localhost.localstack.cloud:4566/000000000000/webhook-dlq",
        "http://sqs.ap-northeast-1.localhost.localstack.cloud:4566/000000000000/webhook-queue"
    ]
}
```

### EventBridge

```shell
% awslocal events list-rules
{
    "Rules": [
        {
            "Name": "cron-15m",
            "Arn": "arn:aws:events:ap-northeast-1:000000000000:rule/cron-15m",
            "State": "ENABLED",
            "ScheduleExpression": "rate(15 minutes)",
            "EventBusName": "default"
        },
        {
            "Name": "cron-daily",
            "Arn": "arn:aws:events:ap-northeast-1:000000000000:rule/cron-daily",
            "State": "ENABLED",
            "ScheduleExpression": "cron(0 15 * * ? *)",
            "EventBusName": "default"
        },
        {
            "Name": "dlq-checker-schedule",
            "Arn": "arn:aws:events:ap-northeast-1:000000000000:rule/dlq-checker-schedule",
            "State": "ENABLED",
            "ScheduleExpression": "rate(5 minutes)",
            "EventBusName": "default"
        }
    ]
}
```

```shell
% awslocal events list-targets-by-rule --rule "cron-15m"
{
    "Targets": [
        {
            "Id": "CallNestJSSync",
            "Arn": "arn:aws:lambda:ap-northeast-1:000000000000:function:CronRegularMonitoringOfReservation"
        }
    ]
}
```

### SecretsManager

```shell
% awslocal secretsmanager get-secret-value --secret-id "api-server/internal-api-key"
{
    "ARN": "arn:aws:secretsmanager:ap-northeast-1:000000000000:secret:api-server/internal-api-key-DOuIEU",
    "Name": "api-server/internal-api-key",
    "VersionId": "terraform-20260330071159319200000002",
    "SecretString": "{\"API_KEY\":\"dummy-api-key-1234567890\"}",
    "VersionStages": [
        "AWSCURRENT"
    ],
    "CreatedDate": "2026-03-30T16:11:59+09:00"
}
```

### Lambda

```shell
% awslocal lambda list-functions
{
    "Functions": [
        ...
        {
            "FunctionName": "GoogleCalendarWebhook",
            "FunctionArn": "arn:aws:lambda:ap-northeast-1:000000000000:function:GoogleCalendarWebhook",
            "Runtime": "nodejs24.x",
            "Role": "arn:aws:iam::000000000000:role/local-stack-lambda-worker-role",
            "Handler": "google-calendar-webhook-handler.handler",
            "CodeSize": 16375,
            "Description": "",
            "Timeout": 3,
            "MemorySize": 128,
            "LastModified": "2026-03-28T15:06:42.686379+0000",
            "CodeSha256": "lZzd2UE6bJNtjihFL86uefN9/gOOiHyoVFz84RE6Chk=",
            "Version": "$LATEST",
            "Environment": {
                "Variables": {
                    "API_URL": "http://host.docker.internal:3001"
                }
            },
            "TracingConfig": {
                "Mode": "PassThrough"
            },
            "RevisionId": "805aa297-da09-4b69-ada5-3ecb98c00c19",
            "PackageType": "Zip",
            "Architectures": [
                "x86_64"
            ],
            "EphemeralStorage": {
                "Size": 512
            },
            "SnapStart": {
                "ApplyOn": "None",
                "OptimizationStatus": "Off"
            }
        }
        ...
    ]
}
```

```shell
% awslocal lambda list-event-source-mappings --function-name GoogleCalendarWebhook
{
    "EventSourceMappings": [
        {
            "UUID": "ea09453c-6412-4803-8484-2a0af633bac2",
            "BatchSize": 10,
            "MaximumBatchingWindowInSeconds": 0,
            "EventSourceArn": "arn:aws:sqs:ap-northeast-1:000000000000:webhook-queue",
            "FunctionArn": "arn:aws:lambda:ap-northeast-1:000000000000:function:GoogleCalendarWebhook",
            "LastModified": "2026-03-29T00:07:22.358263+09:00",
            "State": "Enabled",
            "StateTransitionReason": "USER_INITIATED",
            "FunctionResponseTypes": []
        }
    ]
}
```

### DynamoDB

```shell
% awslocal dynamodb list-tables
{
    "TableNames": [
        "tablets_monitoring",
        "that_day_meeting_room_reservation"
    ]
}
```

```shell
% awslocal dynamodb describe-table --table-name that_day_meeting_room_reservation
{
    "Table": {
        "AttributeDefinitions": [
            {
                "AttributeName": "event_id",
                "AttributeType": "S"
            },
            {
                "AttributeName": "location_id",
                "AttributeType": "N"
            },
            {
                "AttributeName": "start_datetime",
                "AttributeType": "S"
            },
            {
                "AttributeName": "resource_id",
                "AttributeType": "S"
            }
        ],
        "TableName": "that_day_meeting_room_reservation",
        "KeySchema": [
            {
                "AttributeName": "resource_id",
                "KeyType": "HASH"
            },
            {
                "AttributeName": "start_datetime",
                "KeyType": "RANGE"
            }
        ],
        "TableStatus": "ACTIVE",
        "CreationDateTime": "2026-03-29T00:06:32.427000+09:00",
        "ProvisionedThroughput": {
            "LastIncreaseDateTime": "1970-01-01T09:00:00+09:00",
            "LastDecreaseDateTime": "1970-01-01T09:00:00+09:00",
            "NumberOfDecreasesToday": 0,
            "ReadCapacityUnits": 30,
            "WriteCapacityUnits": 20
        },
        "TableSizeBytes": 0,
        "ItemCount": 0,
        "TableArn": "arn:aws:dynamodb:ap-northeast-1:000000000000:table/that_day_meeting_room_reservation",
        "TableId": "d8676420-0e45-42af-9fc3-06b2a87356be",
        "GlobalSecondaryIndexes": [
            {
                "IndexName": "RESERVATIONS_IDX",
                "KeySchema": [
                    {
                        "AttributeName": "event_id",
                        "KeyType": "HASH"
                    }
                ],
                "Projection": {
                    "ProjectionType": "ALL"
                },
                "IndexStatus": "ACTIVE",
                "ProvisionedThroughput": {
                    "NumberOfDecreasesToday": 0,
                    "ReadCapacityUnits": 30,
                    "WriteCapacityUnits": 20
                },
                "IndexSizeBytes": 0,
                "ItemCount": 0,
                "IndexArn": "arn:aws:dynamodb:ap-northeast-1:000000000000:table/that_day_meeting_room_reservation/index/RESERVA
TIONS_IDX"
            },
            {
                "IndexName": "LOCATIONS_IDX",
                "KeySchema": [
                    {
                        "AttributeName": "location_id",
                        "KeyType": "HASH"
                    },
                    {
                        "AttributeName": "start_datetime",
                        "KeyType": "RANGE"
                    }
                ],
                "Projection": {
                    "ProjectionType": "ALL"
                },
                "IndexStatus": "ACTIVE",
                "ProvisionedThroughput": {
                    "NumberOfDecreasesToday": 0,
                    "ReadCapacityUnits": 30,
                    "WriteCapacityUnits": 20
                },
                "IndexSizeBytes": 0,
                "ItemCount": 0,
                "IndexArn": "arn:aws:dynamodb:ap-northeast-1:000000000000:table/that_day_meeting_room_reservation/index/LOCATIO
NS_IDX"
            }
        ],
        "DeletionProtectionEnabled": false
    }
}
```

```shell
% awslocal dynamodb scan --table-name that_day_meeting_room_reservation
{
    "Items": [],
    "Count": 0,
    "ScannedCount": 0,
    "ConsumedCapacity": null
}
```

### KMS

```shell
% awslocal kms list-aliases
{
    "Aliases": [
        {
            "AliasName": "alias/meeting-room-reservation-system_db-column-encryption-key",
            "AliasArn": "arn:aws:kms:ap-northeast-1:000000000000:alias/meeting-room-reservation-system_db-column-encryption-key",
            "TargetKeyId": "113e3638-9ad3-4546-bb8a-6f6d41d4258a",
            "CreationDate": "2026-03-30T16:30:08.711872+09:00"
        }
    ]
}

% awslocal kms describe-key --key-id "alias/meeting-room-reservation-system_db-column-encryption-key"
{
    "KeyMetadata": {
        "AWSAccountId": "000000000000",
        "KeyId": "113e3638-9ad3-4546-bb8a-6f6d41d4258a",
        "Arn": "arn:aws:kms:ap-northeast-1:000000000000:key/113e3638-9ad3-4546-bb8a-6f6d41d4258a",
        "CreationDate": "2026-03-30T16:30:04.633561+09:00",
        "Enabled": true,
        "Description": "KMS key for RDS/MySQL column encryption",
        "KeyUsage": "ENCRYPT_DECRYPT",
        "KeyState": "Enabled",
        "Origin": "AWS_KMS",
        "KeyManager": "CUSTOMER",
        "CustomerMasterKeySpec": "SYMMETRIC_DEFAULT",
        "KeySpec": "SYMMETRIC_DEFAULT",
        "EncryptionAlgorithms": [
            "SYMMETRIC_DEFAULT"
        ],
        "MultiRegion": false
    }
}
```

### IAM Role

```shell
% awslocal iam get-role-policy \
  --role-name "local-stack-lambda-worker-role" \
  --policy-name "SecretsAccessOnlyPolicy"
{
    "RoleName": "local-stack-lambda-worker-role",
    "PolicyName": "SecretsAccessOnlyPolicy",
    "PolicyDocument": {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "secretsmanager:GetSecretValue",
                "Effect": "Allow",
                "Resource": "arn:aws:secretsmanager:ap-northeast-1:000000000000:secret:api-server/internal-api-key-DOuIEU"
            }
        ]
    }
}
```

## APIGatewayへの送信と確認

### リクエストの送信

```shell
% curl -X POST http://127.0.0.1:4566/restapis/27fmwgdvwe/default/_user_request_/webhook \
-H "Content-Type: application/json" \
-d '{"message": "Hello from LocalStack!", "event_id": "dummy-123"}'
```

### CloudwatchLogs

```shell
% awslocal logs filter-log-events --log-group-name "/aws/lambda/GoogleCalendarWebhook"
{
    "events": [
        {
            "logStreamName": "2026/03/29/[$LATEST]981e72a33315c9da2a7501a3792b5fbe",
            "timestamp": 1774757799289,
            "message": "2026-03-29T04:16:39.259Z\tb2c54fd7-8457-47c4-bd53-edeff3e4666e\tINFO\t{\r  \"Records\": [\r    {\r     
 \"messageId\": \"db11e9ea-1845-4ef0-a71f-7241483d869b\",\r      \"receiptHandle\": \"OTgzYWJiM2ItNzg2ZC00NmFkLWI3NGMtODM0M2NmO
WYzNmJmIGFybjphd3M6c3FzOmFwLW5vcnRoZWFzdC0xOjAwMDAwMDAwMDAwMDp3ZWJob29rLXF1ZXVlIGRiMTFlOWVhLTE4NDUtNGVmMC1hNzFmLTcyNDE0ODNkODY5
YiAxNzc0NzU3Nzk4LjI1NTI1OA==\",\r      \"body\": \"{\\\"message\\\": \\\"Hello from LocalStack!\\\", \\\"event_id\\\": \\\"dumm
y-123\\\"}\",\r      \"attributes\": {\r        \"SenderId\": \"000000000000\",\r        \"SentTimestamp\": \"1774757793434\",\
r        \"ApproximateReceiveCount\": \"1\",\r        \"ApproximateFirstReceiveTimestamp\": \"1774757798255\"\r      },\r      
\"messageAttributes\": {},\r      \"md5OfBody\": \"94e6269b317037cd4b8b7c9591ee52d7\",\r      \"eventSourceARN\": \"arn:aws:sqs
:ap-northeast-1:000000000000:webhook-queue\",\r      \"eventSource\": \"aws:sqs\",\r      \"awsRegion\": \"ap-northeast-1\"\r  
  }\r  ]\r}\n",
            "ingestionTime": 1774757799299,
            "eventId": "1062"
        },
    ]
}
```

# nepenthes

### Infra (terraform)

##### S3の作成（tfstate保存用）

```shell
% cd terraform/management

% terraform init

% terraform apply
```

##### アプリケーションインフラの作成

```shell
% cd terraform/environments/[stating|production]

% terraform init

% terraform apply
```

### FrontEnd (Next.js)

##### build

```shell
% path/to/nepenthes

% pnpm run build:web
```

##### run

```shell
% path/to/nepenthes

% pnpm run dev:web
```

### BackEnd (NestJS)

##### build

```shell
% path/to/nepenthes

% pnpm run build:api
```

##### run

```shell
% path/to/nepenthes

% pnpm run dev:api
```

##### test

```shell
% path/to/nepenthes

% pnpm --filter @nepenthes/api exec jest apps/api/src/common/utils/timezone.spec.ts
```

##### docs

```shell
% path/to/nepenthes

% pnpm run docs
```

### LocalStack

```shell
% curl -s http://localhost:4566/_localstack/health | jq .
{
  "services": {
    ...
    "apigateway": "available",
    ...
    "dynamodb": "available",
    "dynamodbstreams": "available",
    ...
    "events": "available",
    ...
    "kinesis": "available",
    ...
    "lambda": "available",
    ...
    "s3": "available",
    ...
    "sns": "available",
    "sqs": "available",
    ...
    "sts": "available",
    ...
  },
  "edition": "community",
  "version": "4.14.0"
}
```

```shell
% cat ~/.aws/config
[profile localstack]
region = us-east-1
output = json

% cat ~/.aws/credentials
[localstack]
aws_access_key_id = dummy
aws_secret_access_key = dummy
```

```shell
% pip install awscli-local

% awslocal dynamodb list-tables
{
    "TableNames": []
}
```

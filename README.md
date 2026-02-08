# nepenthes

### Infra (terraform)

##### S3の作成（tfstate保存用）

```
% cd terraform/management

% terraform init

% terraform apply
```

##### アプリケーションインフラの作成

```
cd terraform/environments/[stating|production]

% terraform init

% terraform apply
```

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

### FrontEnd (Next.js)

##### build

```
% path/to/nepenthes

% pnpm run build:web
```

##### run

```
% path/to/nepenthes

% pnpm run dev:web
```

### BackEnd (NestJS)

##### build

```
% path/to/nepenthes

% pnpm run build:api
```

##### run

```
% path/to/nepenthes

% pnpm run dev:api
```

##### test

```
% path/to/nepenthes

% pnpm --filter @nepenthes/api exec jest apps/api/src/common/utils/timezone.spec.ts
```

##### docs

```
% path/to/nepenthes

% pnpm run docs
```

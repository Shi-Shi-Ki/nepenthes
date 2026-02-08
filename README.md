# nepenthes

backend server with hono

```
src/
├── domain/                  # 【中心】エンティティ（型定義、純粋なロジック）
│   └── user.model.ts
│
├── application/             # 【第2層】ユースケース（アプリのやりたいこと）
│   ├── usecase/
│   │   └── create-user.usecase.ts
│   └── ports/               # 【重要】外側へのインターフェース定義
│       └── user.repository.port.ts
│
├── adapter/                 # 【第3層】変換層
│   ├── controller/          # Honoの入出力を受け持つ
│   │   └── user.controller.ts
│   └── gateway/             # リポジトリの実装（SQL等を書く場所）
│       └── user.repository.impl.ts
│
├── infrastructure/          # 【最外層】フレームワーク・ドライバ
│   ├── db.ts                # DB接続
│   └── server.ts            # Honoアプリの組み立て（Main）
│
└── index.ts                 # エントリーポイント
```

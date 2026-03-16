import { defineConfig } from 'drizzle-kit'
import * as dotenv from 'dotenv'

dotenv.config()

const { DB_USER, DB_USER_PASS, DB_HOST, DB_PORT, DB_NAME } = process.env
const databaseUrl = `mysql://${DB_USER}:${DB_USER_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}`

export default defineConfig({
  schema: './database/schema.ts', // スキーマファイルの場所
  out: './database/drizzle', // マイグレーションファイルの出力先
  dialect: 'mysql',
  dbCredentials: {
    url: databaseUrl,
  },
})

import { Module } from '@nestjs/common'
import { drizzle } from 'drizzle-orm/mysql2'
import mysql from 'mysql2/promise'
import { DB_CONNECTION } from '@/common/utils/types'
import * as schema from '~/database/schema'

@Module({
  providers: [
    {
      provide: DB_CONNECTION,
      useFactory: () => {
        const { DB_USER, DB_USER_PASS, DB_HOST, DB_PORT, DB_NAME } = process.env
        const databaseUrl = `mysql://${DB_USER}:${DB_USER_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}`
        const pool = mysql.createPool({
          uri: databaseUrl,
          connectionLimit: 10,
        })
        return drizzle(pool, { schema, mode: 'default' })
      },
    },
  ],
  exports: [DB_CONNECTION],
})
export class MysqlModule {}

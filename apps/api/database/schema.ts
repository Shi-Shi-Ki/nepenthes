import {
  mysqlTable,
  serial,
  varchar,
  timestamp,
  bigint,
} from 'drizzle-orm/mysql-core'

// マスタデータ
export const roles = mysqlTable('roles', {
  id: serial('id').primaryKey(),
  name: varchar('name', { length: 50 }).notNull().unique(),
})

// ユーザーテーブル
export const users = mysqlTable('users', {
  id: serial('id').primaryKey(),
  name: varchar('name', { length: 255 }).notNull(),
  email: varchar('email', { length: 255 }).notNull().unique(),
  roleId: bigint('role_id', { mode: 'number', unsigned: true }).references(
    () => roles.id,
  ),
  createdAt: timestamp('created_at').defaultNow(),
})

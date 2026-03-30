import { DB_CONNECTION } from '@/common/utils/types'
import { UtilsService } from '@/common/utils/utils.service'
import { Inject } from '@nestjs/common'
import { MySql2Database } from 'drizzle-orm/mysql2'
import * as schema from '~/database/schema'

/**
 * MySQL 基底クラス
 */
export abstract class MysqlBaseRepository {
  constructor(
    @Inject(DB_CONNECTION)
    protected readonly db: MySql2Database<typeof schema>,
    protected readonly utilsService: UtilsService,
  ) {}
}

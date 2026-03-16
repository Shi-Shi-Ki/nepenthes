import { Injectable } from '@nestjs/common'
import { MysqlBaseRepository } from './mysql-base.repository'
import {
  IConsumerRepository,
  UserRecode,
  UserSchema,
} from '@/domain/repositories/i-consumer.repository'
import { UtilsService } from '@/common/utils/utils.service'
import { MySql2Database } from 'drizzle-orm/mysql2'
import * as schema from '~/database/schema'
import { eq } from 'drizzle-orm'
import { users } from '~/database/schema'

@Injectable()
export class ConsumerRepositoryService
  extends MysqlBaseRepository
  implements IConsumerRepository
{
  constructor(db: MySql2Database<typeof schema>, utilsService: UtilsService) {
    super(db, utilsService)
  }

  async getUser(id: number): Promise<UserRecode | null> {
    const result = await this.db
      .select({ name: users.name, email: users.email })
      .from(users)
      .where(eq(users.id, id))

    return UserSchema.parse({
      id: id,
      name: result[0].name,
      email: result[0].email,
      role_name: 'hogehoge',
    })
  }
}

import {
  IReservationRepository,
  ReservationRecode,
  ReservationSchema,
} from '@/domain/repositories/i-reservation.repository'
import { Injectable } from '@nestjs/common'
import { DynamodbBaseRepository } from './dynamodb-base.repository'
import { UtilsService } from '@/common/utils/utils.service'

/**
 * カレンダーの予約情報の保持
 */
@Injectable()
export class ReservationRepositoryService
  extends DynamodbBaseRepository
  implements IReservationRepository
{
  constructor(utils: UtilsService) {
    super('Reservation', utils)
  }

  async find(eventId: string): Promise<ReservationRecode | null> {
    return await this.get({ event_id: eventId }, ReservationSchema)
  }

  async make(recode: ReservationRecode): Promise<boolean> {
    return await this.put(recode)
  }

  async update(recode: ReservationRecode): Promise<boolean> {
    return await this.put(recode)
  }

  async cancel(eventId: string): Promise<boolean> {
    return await this.del({ event_id: eventId })
  }
}

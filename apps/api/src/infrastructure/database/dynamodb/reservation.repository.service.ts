import {
  IReservationRepository,
  ReservationRecord,
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
  constructor(utilsService: UtilsService) {
    super('Reservation', utilsService)
  }

  async find(eventId: string): Promise<ReservationRecord | null> {
    return await this.get({ event_id: eventId }, ReservationSchema)
  }

  async make(recode: ReservationRecord): Promise<void> {
    await this.put(recode)
  }

  async update(recode: ReservationRecord): Promise<void> {
    await this.put(recode)
  }

  async cancel(eventId: string): Promise<void> {
    await this.del({ event_id: eventId })
  }
}

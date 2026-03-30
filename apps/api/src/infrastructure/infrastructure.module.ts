import { Module } from '@nestjs/common'
import { GoogleCalendarAdapterService } from './external-api/google-calendar/google-calendar.adapter.service'
import {
  CONSUMER_REPOSITORY_SERVICE,
  GOOGLE_CALENDAR_ADAPTER_SERVICE,
  RESERVATION_REPOSITORY_SERVICE,
} from '@common/utils/types'
import { CommonModule } from '@common/common.module'
import { ReservationRepositoryService } from './database/dynamodb/reservation.repository.service'
import { MysqlModule } from './database/mysql/mysql.module'
import { ConsumerRepositoryService } from './database/mysql/consumer.repository.service'

@Module({
  imports: [CommonModule, MysqlModule],
  providers: [
    {
      provide: GOOGLE_CALENDAR_ADAPTER_SERVICE,
      useClass: GoogleCalendarAdapterService,
    },
    {
      provide: RESERVATION_REPOSITORY_SERVICE,
      useClass: ReservationRepositoryService,
    },
    {
      provide: CONSUMER_REPOSITORY_SERVICE,
      useClass: ConsumerRepositoryService,
    },
  ],
  exports: [
    GOOGLE_CALENDAR_ADAPTER_SERVICE,
    RESERVATION_REPOSITORY_SERVICE,
    CONSUMER_REPOSITORY_SERVICE,
  ],
})
export class InfrastructureModule {}

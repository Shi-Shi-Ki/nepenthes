import { Module } from '@nestjs/common'
import { GoogleCalendarAdapterService } from './external-api/google-calendar/google-calendar.adapter.service'
import {
  GOOGLE_CALENDAR_ADAPTER_SERVICE,
  RESERVATION_REPOSITORY_SERVICE,
} from '@common/utils/types'
import { CommonModule } from '@common/common.module'
import { ReservationRepositoryService } from './database/dynamodb/reservation.repository.service'

@Module({
  imports: [CommonModule],
  providers: [
    {
      provide: GOOGLE_CALENDAR_ADAPTER_SERVICE,
      useClass: GoogleCalendarAdapterService,
    },
    {
      provide: RESERVATION_REPOSITORY_SERVICE,
      useClass: ReservationRepositoryService,
    },
  ],
  exports: [GOOGLE_CALENDAR_ADAPTER_SERVICE, RESERVATION_REPOSITORY_SERVICE],
})
export class InfrastructureModule {}

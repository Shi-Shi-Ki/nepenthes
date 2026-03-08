import { Module } from '@nestjs/common'
import { GoogleCalendarAdapterService } from './external-api/google-calendar/google-calendar.adapter.service'
import { GOOGLE_CALENDAR_ADAPTER_SERVICE } from '@/common/utils/types'
import { CommonModule } from '@/common/common.module'

@Module({
  imports: [CommonModule],
  providers: [
    {
      provide: GOOGLE_CALENDAR_ADAPTER_SERVICE,
      useClass: GoogleCalendarAdapterService,
    },
  ],
  exports: [GOOGLE_CALENDAR_ADAPTER_SERVICE],
})
export class InfrastructureModule {}

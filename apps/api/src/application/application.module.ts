import { Module } from '@nestjs/common'
import { UpsertEventUseCaseService } from '@application/use-case/calendar-sync/upsert-event.use-case.service'
import { DeleteEventUseCaseService } from '@application/use-case/calendar-sync/delete-event.use-case.service'
import { SyncCalendarUseCaseService } from '@application/use-case/calendar-sync/sync-calendar.use-case.service'
import { InfrastructureModule } from '@/infrastructure/infrastructure.module'

@Module({
  providers: [
    UpsertEventUseCaseService,
    DeleteEventUseCaseService,
    SyncCalendarUseCaseService,
  ],
  imports: [InfrastructureModule],
  exports: [
    UpsertEventUseCaseService,
    DeleteEventUseCaseService,
    SyncCalendarUseCaseService,
  ],
})
export class ApplicationModule {}

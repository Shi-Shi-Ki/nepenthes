import { Inject, Injectable } from '@nestjs/common'
import type { ICalendarApi } from '@/application/ports/i-calendar-api.interface'
import { GOOGLE_CALENDAR_ADAPTER_SERVICE } from '@common/utils/types'
import { timezoneSchema } from '@common/utils/timezone'

/**
 * カレンダーイベントの同期 ユースケース
 *
 * 作成・更新・定期予定のID変更ハンドリング
 */
@Injectable()
export class UpsertEventUseCaseService {
  constructor(
    @Inject(GOOGLE_CALENDAR_ADAPTER_SERVICE)
    private readonly calendarApi: ICalendarApi,
  ) {}

  async delegate() {
    // todo
    console.log(
      await this.calendarApi.getListByToday(
        'dummy',
        timezoneSchema.parse('Asia/Tokyo'),
      ),
    )
  }
}

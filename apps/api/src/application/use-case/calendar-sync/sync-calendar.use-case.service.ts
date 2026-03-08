import { type ICalendarApi } from '@/application/ports/i-calendar-api.interface'
import { GOOGLE_CALENDAR_ADAPTER_SERVICE } from '@/common/utils/types'
import { Inject, Injectable } from '@nestjs/common'

/**
 * カレンダーイベントの同期 ユースケース
 *
 * 同期処理のオーケストレーション
 */
@Injectable()
export class SyncCalendarUseCaseService {
  constructor(
    @Inject(GOOGLE_CALENDAR_ADAPTER_SERVICE)
    private readonly calendarApi: ICalendarApi,
  ) {}
  async delegate(channelId: string, channelToken: string) {
    /*
     * [todo]
     * upsert-event.use-case.service
     * delete-event.use-case.service
     * を呼び出す
     */
    //todo
    const result = await this.calendarApi.fetchSyncEvents(
      'tac829@gmail.com',
      'CM_4uqP6-JIDEM_4uqP6-JIDGAQgyvvUnwMoyvvUnwM=',
    )
    console.log(result)

    return result
  }
}

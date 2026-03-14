import { type ICalendarApi } from '@/application/ports/i-calendar-api.interface'
import { type IReservationRepository } from '@/domain/repositories/i-reservation.repository'
import {
  GOOGLE_CALENDAR_ADAPTER_SERVICE,
  RESERVATION_REPOSITORY_SERVICE,
} from '@common/utils/types'
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
    @Inject(RESERVATION_REPOSITORY_SERVICE)
    private readonly reservationRepositoryService: IReservationRepository,
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
    // console.log('-----')
    // const makeRes = await this.reservationRepositoryService.make({
    //   event_id: 'hoge-hoge-hoge',
    //   startTime: '2026-03-14T18:00:00.000Z',
    //   endTime: '2026-03-14T18:30:00.000Z',
    //   visibility: 'PUBLIC',
    //   title: 'dummy_title',
    //   description: 'dummy_description',
    //   isAllDayUse: false,
    //   status: 'PENDING',
    // })
    // console.log(makeRes)
    // console.log('-----')
    // await this.reservationRepositoryService.update({
    //   event_id: 'hoge-hoge-hoge',
    //   startTime: '2026-03-14T19:00:00.000Z',
    //   endTime: '2026-03-14T19:30:00.000Z',
    //   visibility: 'PRIVATE',
    //   title: 'dummy_title_update',
    //   description: 'dummy_description_update',
    //   isAllDayUse: false,
    //   status: 'USED',
    // })
    console.log('-----')
    const cancelRes =
      await this.reservationRepositoryService.cancel('hoge-hoge-hoge')
    console.log(cancelRes)
    console.log('-----')
    const findRes =
      await this.reservationRepositoryService.find('hoge-hoge-hoge')
    console.log(findRes)

    return result
  }
}

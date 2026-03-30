import {
  Author,
  ReservedIdentifiers,
  Visibility,
} from '@/domain/models/reservation.types'
import { IANATimeZone } from '@common/utils/timezone'

/*
 * CleanArchitectureの特性上でGoogleが定義している型をimportしない
 * （Googleが定義した型に"依存"してしまうのを防ぐため）
 * 型定義も本システム内で使用する最適なものを定義する
 */

export type SyncEventType = 'UPSERT' | 'DELETE'

export interface NormalizedCalendarEvent {
  id: string
  status: SyncEventType
  timeZone: IANATimeZone
  created: Date
  updated: Date
  startTime: Date // 予定の開始日時
  endTime: Date // 予定の終了日時
  isAllDayUse: boolean // 終日フラグ
  title: string
  description: string
  visibility: Visibility
  reservationType: ReservedIdentifiers
  createdBy: Author
}

export interface SyncResult {
  events: NormalizedCalendarEvent[]
  nextSyncToken: string
}

/**
 * カレンダー操作API インタフェース
 */
export interface ICalendarApi {
  /**
   * SyncTokenを使ってカレンダーの差分を取得する
   * @param resourceId 会議室ID
   * @param syncToken (option) 前回の同期時に取得したトークン（初回はundefined）
   */
  fetchSyncEvents(resourceId: string, syncToken?: string): Promise<SyncResult>

  /**
   * 今日一日分の予定を取得
   * @param resourceId 会議室ID
   * @param timeZone タイムゾーン
   */
  getListByToday(
    resourceId: string,
    timeZone: IANATimeZone,
  ): Promise<SyncResult>

  /**
   * 定期予定の取得
   * @param resourceId 会議室ID
   * @param eventId 予定ID
   * @param timeZone タイムゾーン
   * @param startDateTime 開始日時
   * @param endDateTime 終了日時
   * @param isShowDeleted (option) 削除済み予定の表示有無
   */
  getRecurringEventInstances(
    resourceId: string,
    eventId: string,
    timeZone: IANATimeZone,
    startDateTime: Date,
    endDateTime: Date,
    isShowDeleted?: boolean,
  ): Promise<NormalizedCalendarEvent[]>
}

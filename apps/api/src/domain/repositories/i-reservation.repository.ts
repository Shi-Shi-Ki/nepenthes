import { z } from 'zod'

export const ReservationSchema = z.object({
  event_id: z.string(),
  status: z.enum(['PENDING', 'USED']),
  startTime: z.iso.datetime(), // 予定の開始日時
  endTime: z.iso.datetime(), // 予定の終了日時
  isAllDayUse: z.boolean(), // 終日フラグ
  title: z.string(),
  description: z.string(),
  visibility: z.enum(['PUBLIC', 'PRIVATE']),
})
export type ReservationRecord = z.infer<typeof ReservationSchema>

/**
 * 会議室予約状況
 */
export interface IReservationRepository {
  /**
   * 予約情報の取得
   * @param eventId イベントID
   */
  find(eventId: string): Promise<ReservationRecord | null>

  /**
   * 予約データの作成
   * @param recode 予約データ
   */
  make(recode: ReservationRecord): Promise<void>

  /**
   * 予約情報の更新
   * @param recode 予約データ
   */
  update(recode: ReservationRecord): Promise<void>

  /**
   * 予約のキャンセル
   * @param eventId イベントID
   */
  cancel(eventId: string): Promise<void>
}

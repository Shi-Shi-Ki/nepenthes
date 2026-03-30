import { z } from 'zod'

// 現在の環境がサポートしているタイムゾーンの配列を取得（UTCは仕様的に含まれていない）
const validTimeZones = new Set(Intl.supportedValuesOf('timeZone'))

export const timezoneSchema = z
  .string()
  .refine(
    (val) => {
      if (val === 'UTC' || validTimeZones.has(val)) {
        return true
      }
      try {
        new Intl.DateTimeFormat(undefined, { timeZone: val })
        return true
      } catch {
        return false
      }
    },
    {
      message: '無効なIANAタイムゾーンフォーマットです',
    },
  )
  .brand<'IANATimeZone'>()

export type IANATimeZone = z.infer<typeof timezoneSchema>

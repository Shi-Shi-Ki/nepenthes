import { timezoneSchema } from './timezone'

describe('TimeZone Test', () => {
  describe('timezoneSchema Test', () => {
    it('有効なタイムゾーン（Asia/Tokyo）をパースできること', () => {
      const result = timezoneSchema.parse('Asia/Tokyo')
      expect(result).toBe('Asia/Tokyo')
    })

    it('有効なタイムゾーン（America/New_York）をパースできること', () => {
      const result = timezoneSchema.parse('America/New_York')
      expect(result).toBe('America/New_York')
    })

    it('有効なタイムゾーン（America/Mexico_City）をパースできること', () => {
      const result = timezoneSchema.parse('America/Mexico_City')
      expect(result).toBe('America/Mexico_City')
    })

    it('有効なタイムゾーン（America/Los_Angeles）をパースできること', () => {
      const result = timezoneSchema.parse('America/Los_Angeles')
      expect(result).toBe('America/Los_Angeles')
    })

    it('有効なタイムゾーン（Asia/Ho_Chi_Minh）をパースできること', () => {
      const result = timezoneSchema.parse('Asia/Ho_Chi_Minh')
      expect(result).toBe('Asia/Ho_Chi_Minh')
    })

    it('有効なタイムゾーン（Asia/Seoul）をパースできること', () => {
      const result = timezoneSchema.parse('Asia/Seoul')
      expect(result).toBe('Asia/Seoul')
    })

    it('有効なタイムゾーン（UTC）をパースできること', () => {
      const result = timezoneSchema.parse('UTC')
      expect(result).toBe('UTC')
    })

    it('有効なタイムゾーン（asia/tokyo）をパースできること', () => {
      const result = timezoneSchema.parse('asia/tokyo')
      expect(result).toBe('asia/tokyo')
    })

    it('有効なタイムゾーン（utc）をパースできること', () => {
      const result = timezoneSchema.parse('utc')
      expect(result).toBe('utc')
    })

    it('無効なタイムゾーン（Invalid/Timezone）が渡された場合、ZodErrorをスローすること', () => {
      expect(() => timezoneSchema.parse('Invalid/Timezone')).toThrow(
        '無効なIANAタイムゾーンフォーマットです',
      )
    })
  })
})

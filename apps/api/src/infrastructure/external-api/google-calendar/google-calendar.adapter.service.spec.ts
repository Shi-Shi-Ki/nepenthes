import { Test, TestingModule } from '@nestjs/testing'
import { GoogleCalendarAdapterService } from './google-calendar.adapter.service'

describe('GoogleCalendarAdapterService', () => {
  let service: GoogleCalendarAdapterService

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [GoogleCalendarAdapterService],
    }).compile()

    service = module.get<GoogleCalendarAdapterService>(
      GoogleCalendarAdapterService,
    )
  })

  it('should be defined', () => {
    expect(service).toBeDefined()
  })
})

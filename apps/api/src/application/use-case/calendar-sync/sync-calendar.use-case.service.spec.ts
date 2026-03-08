import { Test, TestingModule } from '@nestjs/testing'
import { SyncCalendarUseCaseService } from './sync-calendar.use-case.service'

describe('SyncCalendarUseCaseService', () => {
  let service: SyncCalendarUseCaseService

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [SyncCalendarUseCaseService],
    }).compile()

    service = module.get<SyncCalendarUseCaseService>(SyncCalendarUseCaseService)
  })

  it('should be defined', () => {
    expect(service).toBeDefined()
  })
})

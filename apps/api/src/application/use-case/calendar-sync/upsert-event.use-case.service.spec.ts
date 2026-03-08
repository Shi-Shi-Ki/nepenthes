import { Test, TestingModule } from '@nestjs/testing'
import { UpsertEventUseCaseService } from './upsert-event.use-case.service'

describe('SyncEventUseCaseService', () => {
  let service: UpsertEventUseCaseService

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [UpsertEventUseCaseService],
    }).compile()

    service = module.get<UpsertEventUseCaseService>(UpsertEventUseCaseService)
  })

  it('should be defined', () => {
    expect(service).toBeDefined()
  })
})

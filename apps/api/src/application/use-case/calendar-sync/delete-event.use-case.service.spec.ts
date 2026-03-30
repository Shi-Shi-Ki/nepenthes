import { Test, TestingModule } from '@nestjs/testing'
import { DeleteEventUseCaseService } from './delete-event.use-case.service'

describe('DeleteEventUseCaseService', () => {
  let service: DeleteEventUseCaseService

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [DeleteEventUseCaseService],
    }).compile()

    service = module.get<DeleteEventUseCaseService>(DeleteEventUseCaseService)
  })

  it('should be defined', () => {
    expect(service).toBeDefined()
  })
})

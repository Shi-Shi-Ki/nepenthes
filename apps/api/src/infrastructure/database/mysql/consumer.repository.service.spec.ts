import { Test, TestingModule } from '@nestjs/testing'
import { ConsumerRepositoryService } from './consumer.repository.service'

describe('ConsumerRepositoryService', () => {
  let service: ConsumerRepositoryService

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ConsumerRepositoryService],
    }).compile()

    service = module.get<ConsumerRepositoryService>(ConsumerRepositoryService)
  })

  it('should be defined', () => {
    expect(service).toBeDefined()
  })
})

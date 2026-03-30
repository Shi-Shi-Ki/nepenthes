import { Test, TestingModule } from '@nestjs/testing'
import { ReservationRepositoryService } from './reservation.repository.service'

describe('ReservationRepositoryService', () => {
  let service: ReservationRepositoryService

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ReservationRepositoryService],
    }).compile()

    service = module.get<ReservationRepositoryService>(
      ReservationRepositoryService,
    )
  })

  it('should be defined', () => {
    expect(service).toBeDefined()
  })
})

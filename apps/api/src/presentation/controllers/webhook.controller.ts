import { Controller, Post, Headers, UseGuards } from '@nestjs/common'
import { WebhookGuard } from '@presentation/guards/webhook.guard'
import { SyncCalendarUseCaseService } from '@/application/use-case/calendar-sync/sync-calendar.use-case.service'
import { WebhookHandlePayloadDto } from '@/presentation/dtos/webhook/webhook-handle-payload.dto'

/**
 * カレンダーイベント同期 コントローラー
 */
@Controller('webhook')
export class WebhookController {
  constructor(
    private readonly syncCalendarUseCase: SyncCalendarUseCaseService,
  ) {}

  @Post()
  @UseGuards(WebhookGuard)
  async handle(@Headers() headers: WebhookHandlePayloadDto) {
    if (headers.resourceState === 'sync') {
      // hook作成時のイベントはスキップ
      return new WebhookHandlePayloadDto(true, 'skip if status is sync.')
    }

    await this.syncCalendarUseCase.delegate(
      headers.channelId,
      headers.channelToken,
    )

    return new WebhookHandlePayloadDto()
  }
}

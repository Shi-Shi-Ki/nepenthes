import { Module } from '@nestjs/common'
import { WebhookController } from './controllers/webhook.controller'
import { ApplicationModule } from '@/application/application.module'

@Module({
  imports: [ApplicationModule],
  controllers: [WebhookController],
})
export class PresentationModule {}

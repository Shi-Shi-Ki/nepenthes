import { Module } from '@nestjs/common'
import { AppController } from './app.controller'
import { AppService } from './app.service'
import { ApplicationModule } from './application/application.module'
import { InfrastructureModule } from './infrastructure/infrastructure.module'
import { PresentationModule } from './presentation/presentation.module'
import { CommonModule } from './common/common.module'

@Module({
  imports: [
    ApplicationModule,
    InfrastructureModule,
    PresentationModule,
    CommonModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}

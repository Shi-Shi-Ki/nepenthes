import { Module } from '@nestjs/common'
import { UtilsService } from './utils/utils.service'
import { ConfigModule } from '@nestjs/config'

@Module({
  providers: [UtilsService],
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
  ],
  exports: [UtilsService],
})
export class CommonModule {}

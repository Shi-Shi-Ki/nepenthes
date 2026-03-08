import { Expose } from 'class-transformer'
import { IsNotEmpty, IsString } from 'class-validator'

export class WebhookHandlePayloadDto {
  @Expose({ name: 'x-goog-resource-state' })
  @IsNotEmpty()
  @IsString()
  readonly resourceState: string

  @Expose({ name: 'x-goog-channel-id' })
  @IsNotEmpty()
  @IsString()
  readonly channelId: string

  @Expose({ name: 'x-goog-channel-token' })
  @IsNotEmpty()
  @IsString()
  readonly channelToken: string

  readonly success: boolean
  readonly message: string

  constructor(success: boolean = true, errorMessage?: string) {
    this.success = success
    this.message = success ? 'OK' : (errorMessage ?? 'error')
  }
}

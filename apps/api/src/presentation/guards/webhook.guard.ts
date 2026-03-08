import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common'
import { Observable } from 'rxjs'
import { Request } from 'express'

/**
 * カレンダーイベントの同期 ガード
 *
 * リクエストのチェック
 */
@Injectable()
export class WebhookGuard implements CanActivate {
  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    const request = context.switchToHttp().getRequest<Request>()
    const xGoogResourceState = request.headers['x-goog-resource-state']
    const xGoogChannelId = request.headers['x-goog-channel-id']
    const xGoogChannelToken = request.headers['x-goog-channel-token']

    if (!xGoogResourceState || !xGoogChannelId || !xGoogChannelToken) {
      return false
    }
    return true
  }
}

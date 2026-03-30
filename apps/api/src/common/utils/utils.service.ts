import { Injectable } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'

@Injectable()
export class UtilsService {
  constructor(private configService: ConfigService) {}

  /**
   * 環境変数の取得
   * @param key キー名
   * @returns
   */
  getEnvValueOrFail<T extends number | string>(key: string) {
    const env = this.configService.get<T>(key)
    if (!env) {
      throw new Error('undefined environment value.')
    }
    return env
  }

  /**
   * ローカル環境の判定
   * @returns
   */
  isLocal() {
    const env = this.getEnvValueOrFail<string>('NODE_ENV')
    if (env === 'local' || env === 'development') {
      return true
    }

    return false
  }
}

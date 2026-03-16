import { UtilsService } from '@/common/utils/utils.service'
import { DynamoDBClient } from '@aws-sdk/client-dynamodb'
import {
  DynamoDBDocumentClient,
  PutCommand,
  GetCommand,
  DeleteCommand,
  PutCommandInput,
  GetCommandInput,
  DeleteCommandInput,
} from '@aws-sdk/lib-dynamodb'
import { z } from 'zod'

/**
 * DynamoDB 基底クラス
 */
export abstract class DynamodbBaseRepository {
  private client: DynamoDBClient
  private docClient: DynamoDBDocumentClient

  constructor(
    protected readonly tableName: string,
    protected readonly utilsService: UtilsService,
  ) {
    this.client = new DynamoDBClient({
      region: this.utilsService.getEnvValueOrFail<string>('REGION'),
      endpoint: this.getEndpoint(),
    })
    this.docClient = DynamoDBDocumentClient.from(this.client)
  }

  /**
   * レコード取得
   * @param key 条件
   * @returns
   */
  protected async get<T extends z.ZodTypeAny>(
    key: Record<string, any>,
    schema: T,
  ): Promise<z.infer<T> | null> {
    const condition: GetCommandInput = {
      TableName: this.tableName,
      Key: key,
    }
    const command = new GetCommand(condition)

    try {
      const result = await this.docClient.send(command)

      if (!result.Item) {
        return null
      }

      return schema.parse(result.Item)
    } catch {
      return null
    }
  }

  /**
   * レコード保存
   * @param item レコード
   * @returns
   */
  protected async put(item: Record<string, any>) {
    const input: PutCommandInput = {
      TableName: this.tableName,
      Item: item,
    }
    const command = new PutCommand(input)

    try {
      await this.docClient.send(command)

      return true
    } catch (e) {
      console.error(e)
      return false
    }
  }

  /**
   * レコード削除
   * @param key 条件
   * @returns
   */
  protected async del(key: Record<string, any>) {
    const input: DeleteCommandInput = {
      TableName: this.tableName,
      Key: key,
    }
    const command = new DeleteCommand(input)

    try {
      await this.docClient.send(command)

      return true
    } catch {
      return false
    }
  }

  private getEndpoint() {
    const endpoint =
      'http://' +
      this.utilsService.getEnvValueOrFail<string>('DYNAMODB_OUTER_HOST') +
      ':' +
      this.utilsService.getEnvValueOrFail<string>('DYNAMODB_OUTER_PORT')
    return endpoint
  }
}

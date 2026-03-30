import { SQSEvent, SQSHandler } from 'aws-lambda'

/**
 * カレンダーイベントの処理に失敗した時のDLQをトリガー（EventBridgeより）に処理する
 * @param event
 */
export const handler: SQSHandler = async (event: SQSEvent): Promise<void> => {
  console.log(
    '--- [google-calendar-webhook-dlq-checker.handler] from sqs event.',
  )
  console.log(JSON.stringify(event, null, 2))
}

import { SQSEvent, SQSHandler } from 'aws-lambda'

/**
 * カレンダーイベントのwebhook
 * @param event
 */
export const handler: SQSHandler = async (event: SQSEvent): Promise<void> => {
  console.log('--- [google-calendar-webhook.handler] from sqs event.')
  console.log(JSON.stringify(event, null, 2))
}

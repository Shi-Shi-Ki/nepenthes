import { EventBridgeEvent, Handler } from 'aws-lambda'

interface Detail {}

type Event = EventBridgeEvent<'WebhookReceived', Detail>

/**
 * （1日1回の深夜に実行する）その日の予定をDynamoDBに登録する
 * @param event
 */
export const handler: Handler = async (event: Event): Promise<void> => {
  console.log('--- [reservation-auto-release.handler] from event-bridge event.')
  console.log(JSON.stringify(event, null, 2))
}

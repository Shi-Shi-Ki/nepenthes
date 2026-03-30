import { EventBridgeEvent, Handler } from 'aws-lambda'

interface Detail {
  calendarId: string
  status: string
}

type Event = EventBridgeEvent<'WebhookReceived', Detail>

/**
 * 予約情報（DynamoDB）の定期チェック
 * @param event
 */
export const handler: Handler = async (event: Event): Promise<void> => {
  console.log(
    '--- [cron-regular-monitoring-of-reservation.handler] from event-bridge event.',
  )
  console.log(JSON.stringify(event, null, 2))
}

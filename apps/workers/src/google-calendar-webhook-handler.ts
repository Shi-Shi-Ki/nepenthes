import { SQSEvent, SQSHandler } from 'aws-lambda'
import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from '@aws-sdk/client-secrets-manager'

const secretsClient = new SecretsManagerClient({})

/**
 * カレンダーイベントのwebhook
 * @param event
 */
export const handler: SQSHandler = async (event: SQSEvent): Promise<void> => {
  console.log('--- [google-calendar-webhook.handler] from sqs event.')
  console.log(JSON.stringify(event, null, 2))
  try {
    const secretValueCommand = new GetSecretValueCommand({
      SecretId: 'api-server/internal-api-key',
    })
    const apiKeyResponse = await secretsClient.send(secretValueCommand)
    if (!apiKeyResponse.SecretString) {
      throw new Error('invalid api key...')
    }
    const secret = JSON.parse(apiKeyResponse.SecretString)
    console.log(`* api_key: `, secret)
  } catch (e) {
    console.error(e)
  }
}

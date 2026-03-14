import { Injectable } from '@nestjs/common'
import * as path from 'path'
import * as fs from 'fs'
import {
  ICalendarApi,
  NormalizedCalendarEvent,
  SyncResult,
  ReservedIdentifiers,
  Author,
} from '@/application/ports/i-calendar-api.interface'
import { IANATimeZone, timezoneSchema } from '@common/utils/timezone'
import { google, calendar_v3 } from 'googleapis'
import { UtilsService } from '@common/utils/utils.service'
import { GoogleServiceAccountKey } from '@infrastructure/external-api/google-calendar/types/google-credentials.type'

interface PrivateProps {
  reservationType: ReservedIdentifiers
  createdBy: Author
}

/**
 * GoogleカレンダーAPI操作
 */
@Injectable()
export class GoogleCalendarAdapterService implements ICalendarApi {
  private calendarClient: calendar_v3.Calendar

  constructor(private readonly utilsService: UtilsService) {
    this.calendarClient = this.init()
  }

  private init() {
    // todo local/staging/production の切り替え

    // if (this.utilsService.isLocal()) {
    const clientSecrets = fs.readFileSync(
      path.join(process.cwd(), 'config', 'google.credentials.json'),
      'utf8',
    )
    const clientSecretsJson = JSON.parse(
      clientSecrets,
    ) as GoogleServiceAccountKey
    const googlePrivateKey = clientSecretsJson.private_key.replace(/\\n/g, '\n')
    const auth = new google.auth.JWT({
      email: clientSecretsJson.client_email,
      key: googlePrivateKey,
      scopes: [
        'https://www.googleapis.com/auth/calendar',
        'https://www.googleapis.com/auth/calendar.events',
      ],
    })

    return google.calendar({ version: 'v3', auth: auth })
    // }
  }

  async fetchSyncEvents(
    resourceId: string,
    syncToken?: string,
  ): Promise<SyncResult> {
    const param: calendar_v3.Params$Resource$Events$List = {
      calendarId: resourceId,
      ...(syncToken ? { syncToken } : {}),
    }
    const result = await this.calendarClient.events.list(param)

    if (!result.data.items || result.data.items.length < 1) {
      return {
        events: [],
        nextSyncToken: '',
      }
    }

    if (!result.data.timeZone) {
      throw new Error('not found time zone.')
    }

    const events = result.data.items.map((item) => {
      return this.mapToNormalizedCalendarEvent(
        item,
        timezoneSchema.parse(result.data.timeZone),
      )
    })

    return {
      events: events,
      nextSyncToken: result.data.nextSyncToken ?? '',
    }
  }

  getListByToday(
    resourceId: string,
    timeZone: IANATimeZone,
  ): Promise<SyncResult> {
    throw new Error('Method not implemented.')
  }

  getRecurringEventInstances(
    resourceId: string,
    eventId: string,
    timeZone: IANATimeZone,
    startDateTime: Date,
    endDateTime: Date,
    isShowDeleted?: boolean,
  ): Promise<NormalizedCalendarEvent[]> {
    throw new Error('Method not implemented.')
  }

  private mapToNormalizedCalendarEvent(
    event: calendar_v3.Schema$Event,
    timeZone: IANATimeZone,
  ): NormalizedCalendarEvent {
    if (!event.id) {
      throw new Error('not found event id.')
    }

    const createdTimeStr = event.created ?? new Date().toISOString()
    const updatedTimeStr = event.updated ?? new Date().toISOString()
    const startTimeStr =
      event.start?.dateTime ?? event.start?.date ?? new Date().toISOString()
    const endTimeStr =
      event.end?.dateTime ?? event.end?.date ?? new Date().toISOString()
    const visibility = event.visibility === 'PRIVATE' ? 'PRIVATE' : 'PUBLIC'
    const title =
      visibility === 'PRIVATE'
        ? '予定あり (非公開)'
        : (event.summary ?? 'タイトルなし')
    const description =
      visibility === 'PRIVATE' ? '予定あり (非公開)' : (event.description ?? '')
    const privateProps = this.mapToPrivateProps(event)
    const reservationType = privateProps.reservationType
    const createdBy = privateProps.createdBy

    if (event.status === 'cancelled') {
      return {
        id: event.id,
        status: 'DELETE',
        timeZone: timeZone,
        created: new Date(createdTimeStr),
        updated: new Date(updatedTimeStr),
        startTime: new Date(startTimeStr),
        endTime: new Date(endTimeStr),
        isAllDayUse: false,
        title: title,
        description: description,
        visibility: visibility,
        reservationType: reservationType,
        createdBy: createdBy,
      }
    }

    return {
      id: event.id,
      status: 'UPSERT',
      timeZone: timeZone,
      created: new Date(createdTimeStr),
      updated: new Date(updatedTimeStr),
      startTime: new Date(startTimeStr),
      endTime: new Date(endTimeStr),
      isAllDayUse: false,
      title: title,
      description: description,
      visibility: visibility,
      reservationType: reservationType,
      createdBy: createdBy,
    }
  }

  private mapToPrivateProps(property: calendar_v3.Schema$Event): PrivateProps {
    const extendedProperties = property.extendedProperties
    if (!extendedProperties || !extendedProperties.private) {
      return {
        reservationType: 'NONE',
        createdBy: 'SYSTEM',
      }
    }

    return {
      reservationType:
        extendedProperties.private.reservationType === 'ADVANCE'
          ? 'ADVANCE'
          : 'WALK_IN',
      createdBy:
        extendedProperties.private.createdBy === 'USER' ? 'USER' : 'SYSTEM',
    }
  }
}

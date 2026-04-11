import { Domain, NotificationPreference, UserPreferences } from "../../domain/models";
import { DatabaseClient } from "../../data/sqlite/client";
import { decodeJson, encodeJson, entityParams, mapEntityRecord } from "./shared";
import { PreferencesRepository } from "../PreferencesRepository";
import { SQLiteRepository } from "../base";

interface DomainRow {
  id: string;
  key: Domain["key"];
  name: string;
  description: string;
  accent_color: string;
  is_archived: number;
  sort_order: number;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state: Domain["syncState"];
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

interface UserPreferencesRow {
  id: string;
  timezone: string;
  week_starts_on: number;
  default_focus_session_minutes: number;
  default_break_minutes: number;
  planning_cadence: UserPreferences["planningCadence"];
  daily_planning_time: string | null;
  weekly_planning_day: number;
  monthly_planning_day: number;
  allow_weekend_planning: number;
  preferred_deep_work_windows_json: string;
  metadata_json: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state: UserPreferences["syncState"];
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

interface NotificationPreferenceRow {
  id: string;
  channel: NotificationPreference["channel"];
  reminder_type: NotificationPreference["reminderType"];
  enabled: number;
  lead_time_minutes: number;
  quiet_hours_start: string | null;
  quiet_hours_end: string | null;
  metadata_json: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state: NotificationPreference["syncState"];
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

export class SQLitePreferencesRepository
  extends SQLiteRepository
  implements PreferencesRepository
{
  constructor(database: DatabaseClient) {
    super(database);
  }

  async listDomains() {
    const rows = await this.database.getAll<DomainRow>(
      "SELECT * FROM domains WHERE is_archived = 0 ORDER BY sort_order ASC;",
    );
    return rows.map((row) =>
      mapEntityRecord<Domain>(row, {
        key: row.key,
        name: row.name,
        description: row.description,
        accentColor: row.accent_color,
        isArchived: row.is_archived === 1,
        sortOrder: row.sort_order,
      }),
    );
  }

  async getUserPreferences() {
    const row = await this.database.getFirst<UserPreferencesRow>(
      "SELECT * FROM user_preferences LIMIT 1;",
    );

    if (!row) {
      return null;
    }

    return mapEntityRecord<UserPreferences>(row, {
      timezone: row.timezone,
      weekStartsOn: row.week_starts_on,
      defaultFocusSessionMinutes: row.default_focus_session_minutes,
      defaultBreakMinutes: row.default_break_minutes,
      planningCadence: row.planning_cadence,
      dailyPlanningTime: row.daily_planning_time,
      weeklyPlanningDay: row.weekly_planning_day,
      monthlyPlanningDay: row.monthly_planning_day,
      allowWeekendPlanning: row.allow_weekend_planning === 1,
      preferredDeepWorkWindows: decodeJson<string[]>(row.preferred_deep_work_windows_json),
      metadata: decodeJson(row.metadata_json),
    });
  }

  async listNotificationPreferences() {
    const rows = await this.database.getAll<NotificationPreferenceRow>(
      "SELECT * FROM notification_preferences ORDER BY reminder_type ASC;",
    );
    return rows.map((row) =>
      mapEntityRecord<NotificationPreference>(row, {
        channel: row.channel,
        reminderType: row.reminder_type,
        enabled: row.enabled === 1,
        leadTimeMinutes: row.lead_time_minutes,
        quietHoursStart: row.quiet_hours_start,
        quietHoursEnd: row.quiet_hours_end,
        metadata: decodeJson(row.metadata_json),
      }),
    );
  }

  async saveDomains(domains: Domain[]) {
    await this.database.withTransaction(async (client) => {
      for (const domain of domains) {
        await client.run(
          `
            INSERT OR REPLACE INTO domains (
              id, key, name, description, accent_color, is_archived, sort_order,
              owner_user_id, remote_id, sync_state, version, last_synced_at, created_at, updated_at
            ) VALUES (
              $id, $key, $name, $description, $accentColor, $isArchived, $sortOrder,
              $ownerUserId, $remoteId, $syncState, $version, $lastSyncedAt, $createdAt, $updatedAt
            );
          `,
          {
            ...entityParams(domain),
            $key: domain.key,
            $name: domain.name,
            $description: domain.description,
            $accentColor: domain.accentColor,
            $isArchived: domain.isArchived ? 1 : 0,
            $sortOrder: domain.sortOrder,
          },
        );
      }
    });
  }

  async saveUserPreferences(preferences: UserPreferences) {
    await this.database.run(
      `
        INSERT OR REPLACE INTO user_preferences (
          id, timezone, week_starts_on, default_focus_session_minutes, default_break_minutes,
          planning_cadence, daily_planning_time, weekly_planning_day, monthly_planning_day,
          allow_weekend_planning, preferred_deep_work_windows_json, metadata_json, owner_user_id,
          remote_id, sync_state, version, last_synced_at, created_at, updated_at
        ) VALUES (
          $id, $timezone, $weekStartsOn, $defaultFocusSessionMinutes, $defaultBreakMinutes,
          $planningCadence, $dailyPlanningTime, $weeklyPlanningDay, $monthlyPlanningDay,
          $allowWeekendPlanning, $preferredDeepWorkWindowsJson, $metadataJson, $ownerUserId,
          $remoteId, $syncState, $version, $lastSyncedAt, $createdAt, $updatedAt
        );
      `,
      {
        ...entityParams(preferences),
        $timezone: preferences.timezone,
        $weekStartsOn: preferences.weekStartsOn,
        $defaultFocusSessionMinutes: preferences.defaultFocusSessionMinutes,
        $defaultBreakMinutes: preferences.defaultBreakMinutes,
        $planningCadence: preferences.planningCadence,
        $dailyPlanningTime: preferences.dailyPlanningTime,
        $weeklyPlanningDay: preferences.weeklyPlanningDay,
        $monthlyPlanningDay: preferences.monthlyPlanningDay,
        $allowWeekendPlanning: preferences.allowWeekendPlanning ? 1 : 0,
        $preferredDeepWorkWindowsJson: encodeJson(preferences.preferredDeepWorkWindows),
        $metadataJson: encodeJson(preferences.metadata),
      },
    );
  }

  async saveNotificationPreferences(preferences: NotificationPreference[]) {
    await this.database.withTransaction(async (client) => {
      for (const preference of preferences) {
        await client.run(
          `
            INSERT OR REPLACE INTO notification_preferences (
              id, channel, reminder_type, enabled, lead_time_minutes, quiet_hours_start,
              quiet_hours_end, metadata_json, owner_user_id, remote_id, sync_state,
              version, last_synced_at, created_at, updated_at
            ) VALUES (
              $id, $channel, $reminderType, $enabled, $leadTimeMinutes, $quietHoursStart,
              $quietHoursEnd, $metadataJson, $ownerUserId, $remoteId, $syncState,
              $version, $lastSyncedAt, $createdAt, $updatedAt
            );
          `,
          {
            ...entityParams(preference),
            $channel: preference.channel,
            $reminderType: preference.reminderType,
            $enabled: preference.enabled ? 1 : 0,
            $leadTimeMinutes: preference.leadTimeMinutes,
            $quietHoursStart: preference.quietHoursStart,
            $quietHoursEnd: preference.quietHoursEnd,
            $metadataJson: encodeJson(preference.metadata),
          },
        );
      }
    });
  }
}

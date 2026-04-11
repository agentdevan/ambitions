import { CalendarConnectionState, ScheduleConstraint } from "../../domain/models";
import { DatabaseClient } from "../../data/sqlite/client";
import { decodeJson, encodeJson, entityParams, mapEntityRecord } from "./shared";
import { IntegrationRepository } from "../IntegrationRepository";
import { SQLiteRepository } from "../base";

interface CalendarConnectionStateRow {
  id: string;
  permission_state: CalendarConnectionState["permissionState"];
  sync_state: CalendarConnectionState["connectionStatus"];
  selected_calendar_ids_json: string;
  last_successful_sync_at: string | null;
  metadata_json: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state_entity: CalendarConnectionState["syncState"];
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

interface ScheduleConstraintRow {
  id: string;
  source: ScheduleConstraint["source"];
  type: ScheduleConstraint["type"];
  title: string;
  starts_at: string;
  ends_at: string;
  is_all_day: number;
  external_event_id: string | null;
  location: string | null;
  notes: string | null;
  metadata_json: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state: ScheduleConstraint["syncState"];
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

export class SQLiteIntegrationRepository
  extends SQLiteRepository
  implements IntegrationRepository
{
  constructor(database: DatabaseClient) {
    super(database);
  }

  async getCalendarConnectionState() {
    const row = await this.database.getFirst<CalendarConnectionStateRow>(
      "SELECT * FROM calendar_connection_states LIMIT 1;",
    );

    if (!row) {
      return null;
    }

    return mapEntityRecord<CalendarConnectionState>(
      row,
      {
        permissionState: row.permission_state,
        connectionStatus: row.sync_state,
        selectedCalendarIds: decodeJson<string[]>(row.selected_calendar_ids_json),
        lastSuccessfulSyncAt: row.last_successful_sync_at,
        metadata: decodeJson(row.metadata_json),
      },
      { syncField: "sync_state_entity" },
    );
  }

  async listScheduleConstraintsForDate(date: string) {
    const start = `${date}T00:00:00.000Z`;
    const end = `${date}T23:59:59.999Z`;
    const rows = await this.database.getAll<ScheduleConstraintRow>(
      `
        SELECT * FROM schedule_constraints
        WHERE starts_at <= ? AND ends_at >= ?
        ORDER BY starts_at ASC;
      `,
      [end, start],
    );
    return rows.map((row) =>
      mapEntityRecord<ScheduleConstraint>(row, {
        source: row.source,
        type: row.type,
        title: row.title,
        startsAt: row.starts_at,
        endsAt: row.ends_at,
        isAllDay: row.is_all_day === 1,
        externalEventId: row.external_event_id,
        location: row.location,
        notes: row.notes,
        metadata: decodeJson(row.metadata_json),
      }),
    );
  }

  async saveCalendarConnectionState(state: CalendarConnectionState) {
    await this.database.run(
      `
        INSERT OR REPLACE INTO calendar_connection_states (
          id, permission_state, sync_state, selected_calendar_ids_json, last_successful_sync_at,
          metadata_json, owner_user_id, remote_id, sync_state_entity, version, last_synced_at,
          created_at, updated_at
        ) VALUES (
          $id, $permissionState, $syncState, $selectedCalendarIdsJson, $lastSuccessfulSyncAt,
          $metadataJson, $ownerUserId, $remoteId, $entitySyncState, $version, $lastSyncedAt,
          $createdAt, $updatedAt
        );
      `,
      {
        ...entityParams(state, { syncColumn: "$entitySyncState" }),
        $permissionState: state.permissionState,
        $syncState: state.connectionStatus,
        $selectedCalendarIdsJson: encodeJson(state.selectedCalendarIds),
        $lastSuccessfulSyncAt: state.lastSuccessfulSyncAt,
        $metadataJson: encodeJson(state.metadata),
      },
    );
  }

  async saveScheduleConstraints(constraints: ScheduleConstraint[]) {
    await this.database.withTransaction(async (client) => {
      for (const constraint of constraints) {
        await client.run(
          `
            INSERT OR REPLACE INTO schedule_constraints (
              id, source, type, title, starts_at, ends_at, is_all_day, external_event_id,
              location, notes, metadata_json, owner_user_id, remote_id, sync_state, version,
              last_synced_at, created_at, updated_at
            ) VALUES (
              $id, $source, $type, $title, $startsAt, $endsAt, $isAllDay, $externalEventId,
              $location, $notes, $metadataJson, $ownerUserId, $remoteId, $syncState, $version,
              $lastSyncedAt, $createdAt, $updatedAt
            );
          `,
          {
            ...entityParams(constraint),
            $source: constraint.source,
            $type: constraint.type,
            $title: constraint.title,
            $startsAt: constraint.startsAt,
            $endsAt: constraint.endsAt,
            $isAllDay: constraint.isAllDay ? 1 : 0,
            $externalEventId: constraint.externalEventId,
            $location: constraint.location,
            $notes: constraint.notes,
            $metadataJson: encodeJson(constraint.metadata),
          },
        );
      }
    });
  }
}

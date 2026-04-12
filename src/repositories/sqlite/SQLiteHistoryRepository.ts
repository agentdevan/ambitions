import { DatabaseClient } from "../../data/sqlite/client";
import { ActivityEvent } from "../../domain/models";
import { SQLiteRepository } from "../base";
import { HistoryRepository } from "../HistoryRepository";
import { decodeJson, encodeJson, entityParams, mapEntityRecord } from "./shared";

interface ActivityEventRow {
  id: string;
  kind: ActivityEvent["kind"];
  occurred_at: string;
  date: string;
  title: string;
  detail: string | null;
  outcome_label: string | null;
  goal_id: string | null;
  milestone_id: string | null;
  task_id: string | null;
  daily_plan_id: string | null;
  time_block_id: string | null;
  metadata_json: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state: ActivityEvent["syncState"];
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

export class SQLiteHistoryRepository extends SQLiteRepository implements HistoryRepository {
  constructor(database: DatabaseClient) {
    super(database);
  }

  async listActivityEvents(limit = 160) {
    const rows = await this.database.getAll<ActivityEventRow>(
      `
        SELECT * FROM activity_events
        ORDER BY occurred_at DESC, created_at DESC
        LIMIT ?;
      `,
      [limit],
    );

    return rows.map((row) =>
      mapEntityRecord<ActivityEvent>(row, {
        kind: row.kind,
        occurredAt: row.occurred_at,
        date: row.date,
        title: row.title,
        detail: row.detail,
        outcomeLabel: row.outcome_label,
        goalId: row.goal_id,
        milestoneId: row.milestone_id,
        taskId: row.task_id,
        dailyPlanId: row.daily_plan_id,
        timeBlockId: row.time_block_id,
        metadata: decodeJson(row.metadata_json),
      }),
    );
  }

  async saveActivityEvents(events: ActivityEvent[]) {
    if (events.length === 0) {
      return;
    }

    await this.database.withTransaction(async (client) => {
      for (const event of events) {
        await client.run(
          `
            INSERT OR REPLACE INTO activity_events (
              id, kind, occurred_at, date, title, detail, outcome_label, goal_id, milestone_id,
              task_id, daily_plan_id, time_block_id, metadata_json, owner_user_id, remote_id,
              sync_state, version, last_synced_at, created_at, updated_at
            ) VALUES (
              $id, $kind, $occurredAt, $date, $title, $detail, $outcomeLabel, $goalId, $milestoneId,
              $taskId, $dailyPlanId, $timeBlockId, $metadataJson, $ownerUserId, $remoteId,
              $syncState, $version, $lastSyncedAt, $createdAt, $updatedAt
            );
          `,
          {
            ...entityParams(event),
            $kind: event.kind,
            $occurredAt: event.occurredAt,
            $date: event.date,
            $title: event.title,
            $detail: event.detail,
            $outcomeLabel: event.outcomeLabel,
            $goalId: event.goalId,
            $milestoneId: event.milestoneId,
            $taskId: event.taskId,
            $dailyPlanId: event.dailyPlanId,
            $timeBlockId: event.timeBlockId,
            $metadataJson: encodeJson(event.metadata),
          },
        );
      }
    });
  }
}

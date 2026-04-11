import { DailyPlan, TimeBlock } from "../../domain/models";
import { DatabaseClient } from "../../data/sqlite/client";
import { decodeJson, encodeJson, entityParams, mapEntityRecord } from "./shared";
import { PlanRepository } from "../PlanRepository";
import { SQLiteRepository } from "../base";

interface DailyPlanRow {
  id: string;
  date: string;
  status: DailyPlan["status"];
  focus: string;
  planning_notes: string | null;
  total_planned_minutes: number;
  total_committed_minutes: number;
  adaptation_profile_id: string | null;
  metadata_json: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state: DailyPlan["syncState"];
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

interface TimeBlockRow {
  id: string;
  daily_plan_id: string;
  task_id: string | null;
  goal_id: string | null;
  title: string;
  type: TimeBlock["type"];
  state: TimeBlock["state"];
  starts_at: string;
  ends_at: string;
  starts_at_datetime: string;
  ends_at_datetime: string;
  note: string | null;
  energy_label: TimeBlock["energyLabel"];
  source_constraint_id: string | null;
  metadata_json: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state: TimeBlock["syncState"];
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

export class SQLitePlanRepository extends SQLiteRepository implements PlanRepository {
  constructor(database: DatabaseClient) {
    super(database);
  }

  async getDailyPlan(date: string) {
    const row = await this.database.getFirst<DailyPlanRow>(
      "SELECT * FROM daily_plans WHERE date = ? LIMIT 1;",
      [date],
    );

    if (!row) {
      return null;
    }

    return mapDailyPlanRow(row);
  }

  async listTimeBlocksForPlan(dailyPlanId: string) {
    const rows = await this.database.getAll<TimeBlockRow>(
      "SELECT * FROM time_blocks WHERE daily_plan_id = ? ORDER BY starts_at_datetime ASC;",
      [dailyPlanId],
    );
    return rows.map(mapTimeBlockRow);
  }

  async saveDailyPlans(plans: DailyPlan[]) {
    await this.database.withTransaction(async (client) => {
      for (const plan of plans) {
        await client.run(
          `
            INSERT OR REPLACE INTO daily_plans (
              id, date, status, focus, planning_notes, total_planned_minutes, total_committed_minutes,
              adaptation_profile_id, metadata_json, owner_user_id, remote_id, sync_state,
              version, last_synced_at, created_at, updated_at
            ) VALUES (
              $id, $date, $status, $focus, $planningNotes, $totalPlannedMinutes, $totalCommittedMinutes,
              $adaptationProfileId, $metadataJson, $ownerUserId, $remoteId, $syncState,
              $version, $lastSyncedAt, $createdAt, $updatedAt
            );
          `,
          {
            ...entityParams(plan),
            $date: plan.date,
            $status: plan.status,
            $focus: plan.focus,
            $planningNotes: plan.planningNotes,
            $totalPlannedMinutes: plan.totalPlannedMinutes,
            $totalCommittedMinutes: plan.totalCommittedMinutes,
            $adaptationProfileId: plan.adaptationProfileId,
            $metadataJson: encodeJson(plan.metadata),
          },
        );
      }
    });
  }

  async saveTimeBlocks(blocks: TimeBlock[]) {
    await this.database.withTransaction(async (client) => {
      for (const block of blocks) {
        await client.run(
          `
            INSERT OR REPLACE INTO time_blocks (
              id, daily_plan_id, task_id, goal_id, title, type, state, starts_at, ends_at,
              starts_at_datetime, ends_at_datetime, note, energy_label, source_constraint_id,
              metadata_json, owner_user_id, remote_id, sync_state, version, last_synced_at, created_at, updated_at
            ) VALUES (
              $id, $dailyPlanId, $taskId, $goalId, $title, $type, $state, $startsAt, $endsAt,
              $startsAtDateTime, $endsAtDateTime, $note, $energyLabel, $sourceConstraintId,
              $metadataJson, $ownerUserId, $remoteId, $syncState, $version, $lastSyncedAt, $createdAt, $updatedAt
            );
          `,
          {
            ...entityParams(block),
            $dailyPlanId: block.dailyPlanId,
            $taskId: block.taskId,
            $goalId: block.goalId,
            $title: block.title,
            $type: block.type,
            $state: block.state,
            $startsAt: block.startsAt,
            $endsAt: block.endsAt,
            $startsAtDateTime: block.startsAtDateTime,
            $endsAtDateTime: block.endsAtDateTime,
            $note: block.note,
            $energyLabel: block.energyLabel,
            $sourceConstraintId: block.sourceConstraintId,
            $metadataJson: encodeJson(block.metadata),
          },
        );
      }
    });
  }
}

function mapDailyPlanRow(row: DailyPlanRow): DailyPlan {
  return mapEntityRecord<DailyPlan>(row, {
    date: row.date,
    status: row.status,
    focus: row.focus,
    planningNotes: row.planning_notes,
    totalPlannedMinutes: row.total_planned_minutes,
    totalCommittedMinutes: row.total_committed_minutes,
    adaptationProfileId: row.adaptation_profile_id,
    metadata: decodeJson(row.metadata_json),
  });
}

function mapTimeBlockRow(row: TimeBlockRow): TimeBlock {
  return mapEntityRecord<TimeBlock>(row, {
    dailyPlanId: row.daily_plan_id,
    taskId: row.task_id,
    goalId: row.goal_id,
    title: row.title,
    type: row.type,
    state: row.state,
    startsAt: row.starts_at,
    endsAt: row.ends_at,
    startsAtDateTime: row.starts_at_datetime,
    endsAtDateTime: row.ends_at_datetime,
    note: row.note,
    energyLabel: row.energy_label,
    sourceConstraintId: row.source_constraint_id,
    metadata: decodeJson(row.metadata_json),
  });
}

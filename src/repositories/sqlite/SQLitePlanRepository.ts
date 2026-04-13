import { DailyPlan, DailyRitualState, TimeBlock, WeeklyReviewState } from "../../domain/models";
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

interface DailyRitualStateRow {
  id: string;
  date: string;
  opened_at: string | null;
  opening_focus: DailyRitualState["openingFocus"];
  recovery_moments_json: string;
  closed_at: string | null;
  day_load_rating: DailyRitualState["dayLoadRating"];
  energy_rating: DailyRitualState["energyRating"];
  clarity_rating: DailyRitualState["clarityRating"];
  reflection_note: string | null;
  carry_decision_summary_json: string | null;
  metadata_json: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state: DailyRitualState["syncState"];
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

interface WeeklyReviewStateRow {
  id: string;
  week_start_date: string;
  week_end_date: string;
  reviewed_at: string | null;
  next_week_shaped_at: string | null;
  weekly_emphasis: WeeklyReviewState["weeklyEmphasis"];
  target_week_intensity: WeeklyReviewState["targetWeekIntensity"];
  carryover_posture: WeeklyReviewState["carryoverPosture"];
  note: string | null;
  carryover_task_ids_json: string;
  review_task_ids_json: string;
  released_task_ids_json: string;
  summary_json: string | null;
  metadata_json: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state: WeeklyReviewState["syncState"];
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

  async getDailyRitualState(date: string) {
    const row = await this.database.getFirst<DailyRitualStateRow>(
      "SELECT * FROM daily_ritual_states WHERE date = ? LIMIT 1;",
      [date],
    );

    if (!row) {
      return null;
    }

    return mapDailyRitualStateRow(row);
  }

  async listDailyPlans() {
    const rows = await this.database.getAll<DailyPlanRow>(
      "SELECT * FROM daily_plans ORDER BY date ASC;",
    );
    return rows.map(mapDailyPlanRow);
  }

  async listDailyRitualStates() {
    const rows = await this.database.getAll<DailyRitualStateRow>(
      "SELECT * FROM daily_ritual_states ORDER BY date ASC;",
    );
    return rows.map(mapDailyRitualStateRow);
  }

  async getWeeklyReviewState(weekStartDate: string) {
    const row = await this.database.getFirst<WeeklyReviewStateRow>(
      "SELECT * FROM weekly_review_states WHERE week_start_date = ? LIMIT 1;",
      [weekStartDate],
    );

    if (!row) {
      return null;
    }

    return mapWeeklyReviewStateRow(row);
  }

  async listWeeklyReviewStates() {
    const rows = await this.database.getAll<WeeklyReviewStateRow>(
      "SELECT * FROM weekly_review_states ORDER BY week_start_date ASC;",
    );
    return rows.map(mapWeeklyReviewStateRow);
  }

  async listTimeBlocks() {
    const rows = await this.database.getAll<TimeBlockRow>(
      "SELECT * FROM time_blocks ORDER BY starts_at_datetime ASC, created_at ASC;",
    );
    return rows.map(mapTimeBlockRow);
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

  async saveDailyRitualStates(states: DailyRitualState[]) {
    await this.database.withTransaction(async (client) => {
      for (const state of states) {
        await client.run(
          `
            INSERT OR REPLACE INTO daily_ritual_states (
              id, date, opened_at, opening_focus, recovery_moments_json, closed_at,
              day_load_rating, energy_rating, clarity_rating, reflection_note,
              carry_decision_summary_json, metadata_json, owner_user_id, remote_id, sync_state,
              version, last_synced_at, created_at, updated_at
            ) VALUES (
              $id, $date, $openedAt, $openingFocus, $recoveryMomentsJson, $closedAt,
              $dayLoadRating, $energyRating, $clarityRating, $reflectionNote,
              $carryDecisionSummaryJson, $metadataJson, $ownerUserId, $remoteId, $syncState,
              $version, $lastSyncedAt, $createdAt, $updatedAt
            );
          `,
          {
            ...entityParams(state),
            $date: state.date,
            $openedAt: state.openedAt,
            $openingFocus: state.openingFocus,
            $recoveryMomentsJson: encodeJson(state.recoveryMoments),
            $closedAt: state.closedAt,
            $dayLoadRating: state.dayLoadRating,
            $energyRating: state.energyRating,
            $clarityRating: state.clarityRating,
            $reflectionNote: state.reflectionNote,
            $carryDecisionSummaryJson: state.carryDecisionSummary
              ? encodeJson(state.carryDecisionSummary)
              : null,
            $metadataJson: encodeJson(state.metadata),
          },
        );
      }
    });
  }

  async saveWeeklyReviewStates(states: WeeklyReviewState[]) {
    await this.database.withTransaction(async (client) => {
      for (const state of states) {
        await client.run(
          `
            INSERT OR REPLACE INTO weekly_review_states (
              id, week_start_date, week_end_date, reviewed_at, next_week_shaped_at,
              weekly_emphasis, target_week_intensity, carryover_posture, note,
              carryover_task_ids_json, review_task_ids_json, released_task_ids_json,
              summary_json, metadata_json, owner_user_id, remote_id, sync_state,
              version, last_synced_at, created_at, updated_at
            ) VALUES (
              $id, $weekStartDate, $weekEndDate, $reviewedAt, $nextWeekShapedAt,
              $weeklyEmphasis, $targetWeekIntensity, $carryoverPosture, $note,
              $carryoverTaskIdsJson, $reviewTaskIdsJson, $releasedTaskIdsJson,
              $summaryJson, $metadataJson, $ownerUserId, $remoteId, $syncState,
              $version, $lastSyncedAt, $createdAt, $updatedAt
            );
          `,
          {
            ...entityParams(state),
            $weekStartDate: state.weekStartDate,
            $weekEndDate: state.weekEndDate,
            $reviewedAt: state.reviewedAt,
            $nextWeekShapedAt: state.nextWeekShapedAt,
            $weeklyEmphasis: state.weeklyEmphasis,
            $targetWeekIntensity: state.targetWeekIntensity,
            $carryoverPosture: state.carryoverPosture,
            $note: state.note,
            $carryoverTaskIdsJson: encodeJson(state.carryoverTaskIds),
            $reviewTaskIdsJson: encodeJson(state.reviewTaskIds),
            $releasedTaskIdsJson: encodeJson(state.releasedTaskIds),
            $summaryJson: state.summary ? encodeJson(state.summary) : null,
            $metadataJson: encodeJson(state.metadata),
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

function mapDailyRitualStateRow(row: DailyRitualStateRow): DailyRitualState {
  return mapEntityRecord<DailyRitualState>(row, {
    date: row.date,
    openedAt: row.opened_at,
    openingFocus: row.opening_focus,
    recoveryMoments: decodeJson(row.recovery_moments_json),
    closedAt: row.closed_at,
    dayLoadRating: row.day_load_rating,
    energyRating: row.energy_rating,
    clarityRating: row.clarity_rating,
    reflectionNote: row.reflection_note,
    carryDecisionSummary: row.carry_decision_summary_json
      ? decodeJson(row.carry_decision_summary_json)
      : null,
    metadata: decodeJson(row.metadata_json),
  });
}

function mapWeeklyReviewStateRow(row: WeeklyReviewStateRow): WeeklyReviewState {
  return mapEntityRecord<WeeklyReviewState>(row, {
    weekStartDate: row.week_start_date,
    weekEndDate: row.week_end_date,
    reviewedAt: row.reviewed_at,
    nextWeekShapedAt: row.next_week_shaped_at,
    weeklyEmphasis: row.weekly_emphasis,
    targetWeekIntensity: row.target_week_intensity,
    carryoverPosture: row.carryover_posture,
    note: row.note,
    carryoverTaskIds: decodeJson(row.carryover_task_ids_json),
    reviewTaskIds: decodeJson(row.review_task_ids_json),
    releasedTaskIds: decodeJson(row.released_task_ids_json),
    summary: row.summary_json ? decodeJson(row.summary_json) : null,
    metadata: decodeJson(row.metadata_json),
  });
}

import { Ambition, Goal, GoalMilestone } from "../../domain/models";
import { DatabaseClient } from "../../data/sqlite/client";
import { decodeJson, encodeJson, entityParams, mapEntityRecord } from "./shared";
import { GoalRepository } from "../GoalRepository";
import { SQLiteRepository } from "../base";
import {
  canonicalizeAmbitions,
  canonicalizeGoalMilestones,
  canonicalizeGoals,
} from "../../services/goals/portfolioIntegrity";

interface GoalRow {
  id: string;
  ambition_id: string | null;
  title: string;
  summary: string | null;
  domain_key: Goal["domainKey"];
  horizon: Goal["horizon"];
  type: Goal["type"];
  status: Goal["status"];
  parent_goal_id: string | null;
  sort_order: number;
  start_date: string | null;
  target_date: string | null;
  desired_weekly_minutes: number | null;
  estimated_total_minutes: number | null;
  success_metric: string | null;
  notes: string | null;
  tags_json: string;
  metadata_json: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state: Goal["syncState"];
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

interface AmbitionRow {
  id: string;
  title: string;
  thesis: string | null;
  status: Ambition["status"];
  sort_order: number;
  is_visible: number;
  metadata_json: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state: Ambition["syncState"];
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

interface MilestoneRow {
  id: string;
  goal_id: string;
  title: string;
  summary: string | null;
  status: GoalMilestone["status"];
  target_date: string | null;
  completed_at: string | null;
  sort_order: number;
  estimated_minutes: number | null;
  metadata_json: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state: GoalMilestone["syncState"];
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

export class SQLiteGoalRepository extends SQLiteRepository implements GoalRepository {
  constructor(database: DatabaseClient) {
    super(database);
  }

  async listAmbitions() {
    const rows = await this.database.getAll<AmbitionRow>(
      "SELECT * FROM ambitions ORDER BY sort_order ASC, created_at ASC;",
    );
    return canonicalizeAmbitions(
      rows.map((row) =>
        mapEntityRecord<Ambition>(row, {
          title: row.title,
          thesis: row.thesis,
          status: row.status,
          sortOrder: row.sort_order,
          isVisible: row.is_visible === 1,
          metadata: decodeJson(row.metadata_json),
        }),
      ),
    );
  }

  async listGoals() {
    const rows = await this.database.getAll<GoalRow>(
      "SELECT * FROM goals ORDER BY sort_order ASC, created_at ASC;",
    );
    return canonicalizeGoals(
      rows.map((row) =>
        mapEntityRecord<Goal>(row, {
          ambitionId: row.ambition_id,
          title: row.title,
          summary: row.summary,
          domainKey: row.domain_key,
          horizon: row.horizon,
          type: row.type,
          status: row.status,
          parentGoalId: row.parent_goal_id,
          sortOrder: row.sort_order,
          startDate: row.start_date,
          targetDate: row.target_date,
          desiredWeeklyMinutes: row.desired_weekly_minutes,
          estimatedTotalMinutes: row.estimated_total_minutes,
          successMetric: row.success_metric,
          notes: row.notes,
          tags: decodeJson<string[]>(row.tags_json),
          metadata: decodeJson(row.metadata_json),
        }),
      ),
    );
  }

  async listMilestones() {
    const rows = await this.database.getAll<MilestoneRow>(
      "SELECT * FROM goal_milestones ORDER BY goal_id ASC, sort_order ASC;",
    );
    return canonicalizeGoalMilestones(
      rows.map((row) =>
        mapEntityRecord<GoalMilestone>(row, {
          goalId: row.goal_id,
          title: row.title,
          summary: row.summary,
          status: row.status,
          targetDate: row.target_date,
          completedAt: row.completed_at,
          sortOrder: row.sort_order,
          estimatedMinutes: row.estimated_minutes,
          metadata: decodeJson(row.metadata_json),
        }),
      ),
    );
  }

  async saveAmbitions(ambitions: Ambition[]) {
    await this.database.withTransaction(async (client) => {
      for (const ambition of ambitions) {
        await client.run(
          `
            INSERT OR REPLACE INTO ambitions (
              id, title, thesis, status, sort_order, is_visible, metadata_json, owner_user_id,
              remote_id, sync_state, version, last_synced_at, created_at, updated_at
            ) VALUES (
              $id, $title, $thesis, $status, $sortOrder, $isVisible, $metadataJson, $ownerUserId,
              $remoteId, $syncState, $version, $lastSyncedAt, $createdAt, $updatedAt
            );
          `,
          {
            ...entityParams(ambition),
            $title: ambition.title,
            $thesis: ambition.thesis,
            $status: ambition.status,
            $sortOrder: ambition.sortOrder,
            $isVisible: ambition.isVisible ? 1 : 0,
            $metadataJson: encodeJson(ambition.metadata),
          },
        );
      }
    });
  }

  async saveGoals(goals: Goal[]) {
    await this.database.withTransaction(async (client) => {
      for (const goal of goals) {
        await client.run(
          `
            INSERT OR REPLACE INTO goals (
              id, ambition_id, title, summary, domain_key, horizon, type, status, parent_goal_id, sort_order,
              start_date, target_date, desired_weekly_minutes, estimated_total_minutes,
              success_metric, notes, tags_json, metadata_json, owner_user_id, remote_id,
              sync_state, version, last_synced_at, created_at, updated_at
            ) VALUES (
              $id, $ambitionId, $title, $summary, $domainKey, $horizon, $type, $status, $parentGoalId, $sortOrder,
              $startDate, $targetDate, $desiredWeeklyMinutes, $estimatedTotalMinutes,
              $successMetric, $notes, $tagsJson, $metadataJson, $ownerUserId, $remoteId,
              $syncState, $version, $lastSyncedAt, $createdAt, $updatedAt
            );
          `,
          {
            ...entityParams(goal),
            $ambitionId: goal.ambitionId,
            $title: goal.title,
            $summary: goal.summary,
            $domainKey: goal.domainKey,
            $horizon: goal.horizon,
            $type: goal.type,
            $status: goal.status,
            $parentGoalId: goal.parentGoalId,
            $sortOrder: goal.sortOrder,
            $startDate: goal.startDate,
            $targetDate: goal.targetDate,
            $desiredWeeklyMinutes: goal.desiredWeeklyMinutes,
            $estimatedTotalMinutes: goal.estimatedTotalMinutes,
            $successMetric: goal.successMetric,
            $notes: goal.notes,
            $tagsJson: encodeJson(goal.tags),
            $metadataJson: encodeJson(goal.metadata),
          },
        );
      }
    });
  }

  async saveMilestones(milestones: GoalMilestone[]) {
    await this.database.withTransaction(async (client) => {
      for (const milestone of milestones) {
        await client.run(
          `
            INSERT OR REPLACE INTO goal_milestones (
              id, goal_id, title, summary, status, target_date, completed_at, sort_order,
              estimated_minutes, metadata_json, owner_user_id, remote_id, sync_state,
              version, last_synced_at, created_at, updated_at
            ) VALUES (
              $id, $goalId, $title, $summary, $status, $targetDate, $completedAt, $sortOrder,
              $estimatedMinutes, $metadataJson, $ownerUserId, $remoteId, $syncState,
              $version, $lastSyncedAt, $createdAt, $updatedAt
            );
          `,
          {
            ...entityParams(milestone),
            $goalId: milestone.goalId,
            $title: milestone.title,
            $summary: milestone.summary,
            $status: milestone.status,
            $targetDate: milestone.targetDate,
            $completedAt: milestone.completedAt,
            $sortOrder: milestone.sortOrder,
            $estimatedMinutes: milestone.estimatedMinutes,
            $metadataJson: encodeJson(milestone.metadata),
          },
        );
      }
    });
  }
}

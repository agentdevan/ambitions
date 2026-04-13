import { Task } from "../../domain/models";
import { DatabaseClient } from "../../data/sqlite/client";
import { decodeJson, encodeJson, entityParams, mapEntityRecord } from "./shared";
import { SQLiteRepository } from "../base";
import { TaskRepository } from "../TaskRepository";
import { canonicalizeTasks } from "../../services/goals/portfolioIntegrity";

interface TaskRow {
  id: string;
  goal_id: string | null;
  milestone_id: string | null;
  parent_task_id: string | null;
  title: string;
  summary: string | null;
  status: Task["status"];
  scheduling_state: Task["schedulingState"];
  difficulty: Task["difficulty"];
  estimated_minutes: number;
  actual_minutes: number | null;
  effort_points: number | null;
  target_date: string | null;
  scheduled_date: string | null;
  earliest_start_at: string | null;
  latest_finish_at: string | null;
  completed_at: string | null;
  is_recurring_template: number;
  tags_json: string;
  metadata_json: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state: Task["syncState"];
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

export class SQLiteTaskRepository extends SQLiteRepository implements TaskRepository {
  constructor(database: DatabaseClient) {
    super(database);
  }

  async listTasks() {
    const rows = await this.database.getAll<TaskRow>(
      "SELECT * FROM tasks ORDER BY COALESCE(scheduled_date, target_date, created_at) ASC;",
    );
    return canonicalizeTasks(rows.map(mapTaskRow));
  }

  async listTasksForDate(date: string) {
    const rows = await this.database.getAll<TaskRow>(
      `
        SELECT * FROM tasks
        WHERE scheduled_date = ? OR target_date = ?
        ORDER BY COALESCE(earliest_start_at, latest_finish_at, created_at) ASC;
      `,
      [date, date],
    );
    return canonicalizeTasks(rows.map(mapTaskRow));
  }

  async saveTasks(tasks: Task[]) {
    await this.database.withTransaction(async (client) => {
      for (const task of tasks) {
        await client.run(
          `
            INSERT OR REPLACE INTO tasks (
              id, goal_id, milestone_id, parent_task_id, title, summary, status, scheduling_state,
              difficulty, estimated_minutes, actual_minutes, effort_points, target_date, scheduled_date,
              earliest_start_at, latest_finish_at, completed_at, is_recurring_template, tags_json,
              metadata_json, owner_user_id, remote_id, sync_state, version, last_synced_at, created_at, updated_at
            ) VALUES (
              $id, $goalId, $milestoneId, $parentTaskId, $title, $summary, $status, $schedulingState,
              $difficulty, $estimatedMinutes, $actualMinutes, $effortPoints, $targetDate, $scheduledDate,
              $earliestStartAt, $latestFinishAt, $completedAt, $isRecurringTemplate, $tagsJson,
              $metadataJson, $ownerUserId, $remoteId, $syncState, $version, $lastSyncedAt, $createdAt, $updatedAt
            );
          `,
          {
            ...entityParams(task),
            $goalId: task.goalId,
            $milestoneId: task.milestoneId,
            $parentTaskId: task.parentTaskId,
            $title: task.title,
            $summary: task.summary,
            $status: task.status,
            $schedulingState: task.schedulingState,
            $difficulty: task.difficulty,
            $estimatedMinutes: task.estimatedMinutes,
            $actualMinutes: task.actualMinutes,
            $effortPoints: task.effortPoints,
            $targetDate: task.targetDate,
            $scheduledDate: task.scheduledDate,
            $earliestStartAt: task.earliestStartAt,
            $latestFinishAt: task.latestFinishAt,
            $completedAt: task.completedAt,
            $isRecurringTemplate: task.isRecurringTemplate ? 1 : 0,
            $tagsJson: encodeJson(task.tags),
            $metadataJson: encodeJson(task.metadata),
          },
        );
      }
    });
  }
}

function mapTaskRow(row: TaskRow): Task {
  return mapEntityRecord<Task>(row, {
    goalId: row.goal_id,
    milestoneId: row.milestone_id,
    parentTaskId: row.parent_task_id,
    title: row.title,
    summary: row.summary,
    status: row.status,
    schedulingState: row.scheduling_state,
    difficulty: row.difficulty,
    estimatedMinutes: row.estimated_minutes,
    actualMinutes: row.actual_minutes,
    effortPoints: row.effort_points,
    targetDate: row.target_date,
    scheduledDate: row.scheduled_date,
    earliestStartAt: row.earliest_start_at,
    latestFinishAt: row.latest_finish_at,
    completedAt: row.completed_at,
    isRecurringTemplate: row.is_recurring_template === 1,
    tags: decodeJson<string[]>(row.tags_json),
    metadata: decodeJson(row.metadata_json),
  });
}

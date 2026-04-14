import { sqliteClient } from "../../data/sqlite/client";

const userDataTables = [
  "time_blocks",
  "daily_plans",
  "daily_ritual_states",
  "weekly_review_states",
  "monthly_review_states",
  "activity_events",
  "replan_suggestions",
  "tasks",
  "goal_milestones",
  "goals",
  "ambitions",
  "adaptation_profiles",
  "schedule_constraints",
  "calendar_connection_states",
  "notification_preferences",
  "user_preferences",
] as const;

const accountTables = [
  "remote_sync_records",
  "sync_conflicts",
  "sync_operations",
  "sync_state",
  "local_attachment_state",
  "auth_state",
  "accounts",
] as const;

export async function wipeLocalAccountAndUserData() {
  await sqliteClient.withTransaction(async (client) => {
    for (const tableName of userDataTables) {
      await client.run(`DELETE FROM ${tableName};`);
    }

    for (const tableName of accountTables) {
      await client.run(`DELETE FROM ${tableName};`);
    }
  });
}

export interface MigrationDefinition {
  id: number;
  name: string;
  statements: string[];
}

export const schemaMigrations: MigrationDefinition[] = [
  {
    id: 1,
    name: "phase_2_foundation",
    statements: [
      `
        CREATE TABLE IF NOT EXISTS domains (
          id TEXT PRIMARY KEY NOT NULL,
          key TEXT NOT NULL UNIQUE,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          accent_color TEXT NOT NULL,
          is_archived INTEGER NOT NULL DEFAULT 0,
          sort_order INTEGER NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      `,
      `
        CREATE TABLE IF NOT EXISTS user_preferences (
          id TEXT PRIMARY KEY NOT NULL,
          timezone TEXT NOT NULL,
          week_starts_on INTEGER NOT NULL,
          default_focus_session_minutes INTEGER NOT NULL,
          default_break_minutes INTEGER NOT NULL,
          planning_cadence TEXT NOT NULL,
          daily_planning_time TEXT,
          weekly_planning_day INTEGER NOT NULL,
          monthly_planning_day INTEGER NOT NULL,
          allow_weekend_planning INTEGER NOT NULL,
          preferred_deep_work_windows_json TEXT NOT NULL,
          metadata_json TEXT NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      `,
      `
        CREATE TABLE IF NOT EXISTS notification_preferences (
          id TEXT PRIMARY KEY NOT NULL,
          channel TEXT NOT NULL,
          reminder_type TEXT NOT NULL,
          enabled INTEGER NOT NULL,
          lead_time_minutes INTEGER NOT NULL,
          quiet_hours_start TEXT,
          quiet_hours_end TEXT,
          metadata_json TEXT NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      `,
      `
        CREATE TABLE IF NOT EXISTS goals (
          id TEXT PRIMARY KEY NOT NULL,
          title TEXT NOT NULL,
          summary TEXT,
          domain_key TEXT NOT NULL,
          horizon TEXT NOT NULL,
          type TEXT NOT NULL,
          status TEXT NOT NULL,
          parent_goal_id TEXT,
          sort_order INTEGER NOT NULL,
          start_date TEXT,
          target_date TEXT,
          desired_weekly_minutes INTEGER,
          estimated_total_minutes INTEGER,
          success_metric TEXT,
          notes TEXT,
          tags_json TEXT NOT NULL,
          metadata_json TEXT NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY(parent_goal_id) REFERENCES goals(id) ON DELETE SET NULL
        );
      `,
      `CREATE INDEX IF NOT EXISTS idx_goals_parent_goal_id ON goals(parent_goal_id);`,
      `CREATE INDEX IF NOT EXISTS idx_goals_domain_key ON goals(domain_key);`,
      `
        CREATE TABLE IF NOT EXISTS goal_milestones (
          id TEXT PRIMARY KEY NOT NULL,
          goal_id TEXT NOT NULL,
          title TEXT NOT NULL,
          summary TEXT,
          status TEXT NOT NULL,
          target_date TEXT,
          completed_at TEXT,
          sort_order INTEGER NOT NULL,
          estimated_minutes INTEGER,
          metadata_json TEXT NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY(goal_id) REFERENCES goals(id) ON DELETE CASCADE
        );
      `,
      `CREATE INDEX IF NOT EXISTS idx_goal_milestones_goal_id ON goal_milestones(goal_id);`,
      `
        CREATE TABLE IF NOT EXISTS tasks (
          id TEXT PRIMARY KEY NOT NULL,
          goal_id TEXT,
          milestone_id TEXT,
          parent_task_id TEXT,
          title TEXT NOT NULL,
          summary TEXT,
          status TEXT NOT NULL,
          scheduling_state TEXT NOT NULL,
          difficulty TEXT NOT NULL,
          estimated_minutes INTEGER NOT NULL,
          actual_minutes INTEGER,
          effort_points INTEGER,
          target_date TEXT,
          scheduled_date TEXT,
          earliest_start_at TEXT,
          latest_finish_at TEXT,
          completed_at TEXT,
          is_recurring_template INTEGER NOT NULL,
          tags_json TEXT NOT NULL,
          metadata_json TEXT NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY(goal_id) REFERENCES goals(id) ON DELETE SET NULL,
          FOREIGN KEY(milestone_id) REFERENCES goal_milestones(id) ON DELETE SET NULL,
          FOREIGN KEY(parent_task_id) REFERENCES tasks(id) ON DELETE SET NULL
        );
      `,
      `CREATE INDEX IF NOT EXISTS idx_tasks_scheduled_date ON tasks(scheduled_date);`,
      `CREATE INDEX IF NOT EXISTS idx_tasks_goal_id ON tasks(goal_id);`,
      `
        CREATE TABLE IF NOT EXISTS adaptation_profiles (
          id TEXT PRIMARY KEY NOT NULL,
          effective_date TEXT NOT NULL,
          source TEXT NOT NULL,
          capacity_json TEXT NOT NULL,
          completion_json TEXT NOT NULL,
          friction_json TEXT NOT NULL,
          momentum_json TEXT NOT NULL,
          strategy_json TEXT NOT NULL,
          metadata_json TEXT NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      `,
      `
        CREATE TABLE IF NOT EXISTS daily_plans (
          id TEXT PRIMARY KEY NOT NULL,
          date TEXT NOT NULL UNIQUE,
          status TEXT NOT NULL,
          focus TEXT NOT NULL,
          planning_notes TEXT,
          total_planned_minutes INTEGER NOT NULL,
          total_committed_minutes INTEGER NOT NULL,
          adaptation_profile_id TEXT,
          metadata_json TEXT NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY(adaptation_profile_id) REFERENCES adaptation_profiles(id) ON DELETE SET NULL
        );
      `,
      `
        CREATE TABLE IF NOT EXISTS time_blocks (
          id TEXT PRIMARY KEY NOT NULL,
          daily_plan_id TEXT NOT NULL,
          task_id TEXT,
          goal_id TEXT,
          title TEXT NOT NULL,
          type TEXT NOT NULL,
          state TEXT NOT NULL,
          starts_at TEXT NOT NULL,
          ends_at TEXT NOT NULL,
          starts_at_datetime TEXT NOT NULL,
          ends_at_datetime TEXT NOT NULL,
          note TEXT,
          energy_label TEXT NOT NULL,
          source_constraint_id TEXT,
          metadata_json TEXT NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY(daily_plan_id) REFERENCES daily_plans(id) ON DELETE CASCADE,
          FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE SET NULL,
          FOREIGN KEY(goal_id) REFERENCES goals(id) ON DELETE SET NULL
        );
      `,
      `CREATE INDEX IF NOT EXISTS idx_time_blocks_daily_plan_id ON time_blocks(daily_plan_id);`,
      `
        CREATE TABLE IF NOT EXISTS replan_suggestions (
          id TEXT PRIMARY KEY NOT NULL,
          plan_date TEXT NOT NULL,
          type TEXT NOT NULL,
          title TEXT NOT NULL,
          rationale TEXT NOT NULL,
          task_id TEXT,
          time_block_id TEXT,
          confidence REAL NOT NULL,
          suggested_start_at TEXT,
          suggested_end_at TEXT,
          metadata_json TEXT NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      `,
      `CREATE INDEX IF NOT EXISTS idx_replan_suggestions_plan_date ON replan_suggestions(plan_date);`,
      `
        CREATE TABLE IF NOT EXISTS calendar_connection_states (
          id TEXT PRIMARY KEY NOT NULL,
          permission_state TEXT NOT NULL,
          sync_state TEXT NOT NULL,
          selected_calendar_ids_json TEXT NOT NULL,
          last_successful_sync_at TEXT,
          metadata_json TEXT NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state_entity TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      `,
      `
        CREATE TABLE IF NOT EXISTS schedule_constraints (
          id TEXT PRIMARY KEY NOT NULL,
          source TEXT NOT NULL,
          type TEXT NOT NULL,
          title TEXT NOT NULL,
          starts_at TEXT NOT NULL,
          ends_at TEXT NOT NULL,
          is_all_day INTEGER NOT NULL,
          external_event_id TEXT,
          location TEXT,
          notes TEXT,
          metadata_json TEXT NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      `,
      `CREATE INDEX IF NOT EXISTS idx_schedule_constraints_starts_at ON schedule_constraints(starts_at);`,
    ],
  },
  {
    id: 2,
    name: "phase_6_adaptation_profile_expansion",
    statements: [
      `ALTER TABLE adaptation_profiles ADD COLUMN history_json TEXT NOT NULL DEFAULT '{}';`,
      `ALTER TABLE adaptation_profiles ADD COLUMN regression_json TEXT NOT NULL DEFAULT '{}';`,
      `ALTER TABLE adaptation_profiles ADD COLUMN duration_refinements_json TEXT NOT NULL DEFAULT '[]';`,
      `ALTER TABLE adaptation_profiles ADD COLUMN planning_directives_json TEXT NOT NULL DEFAULT '{}';`,
    ],
  },
  {
    id: 3,
    name: "phase_10_accounts_sync_foundation",
    statements: [
      `
        CREATE TABLE IF NOT EXISTS accounts (
          id TEXT PRIMARY KEY NOT NULL,
          provider TEXT NOT NULL,
          provider_subject TEXT NOT NULL,
          email TEXT,
          display_name TEXT,
          metadata_json TEXT NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      `,
      `
        CREATE TABLE IF NOT EXISTS auth_state (
          id TEXT PRIMARY KEY NOT NULL,
          status TEXT NOT NULL,
          signed_in_account_id TEXT,
          primary_provider TEXT NOT NULL,
          available_providers_json TEXT NOT NULL,
          can_attempt_apple_sign_in INTEGER NOT NULL,
          last_authenticated_at TEXT,
          last_error TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      `,
      `
        CREATE TABLE IF NOT EXISTS local_attachment_state (
          id TEXT PRIMARY KEY NOT NULL,
          account_id TEXT,
          status TEXT NOT NULL,
          has_meaningful_local_data INTEGER NOT NULL,
          pending_record_count INTEGER NOT NULL,
          last_attached_at TEXT,
          last_error TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      `,
      `
        CREATE TABLE IF NOT EXISTS sync_state (
          id TEXT PRIMARY KEY NOT NULL,
          account_id TEXT,
          device_id TEXT NOT NULL,
          mode TEXT NOT NULL,
          last_sync_at TEXT,
          pending_push_count INTEGER NOT NULL,
          pending_pull_count INTEGER NOT NULL,
          unresolved_conflict_count INTEGER NOT NULL,
          last_error TEXT,
          metadata_json TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      `,
      `
        CREATE TABLE IF NOT EXISTS sync_operations (
          id TEXT PRIMARY KEY NOT NULL,
          account_id TEXT,
          kind TEXT NOT NULL,
          status TEXT NOT NULL,
          started_at TEXT NOT NULL,
          finished_at TEXT,
          error_message TEXT,
          metadata_json TEXT NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      `,
      `
        CREATE TABLE IF NOT EXISTS sync_conflicts (
          id TEXT PRIMARY KEY NOT NULL,
          account_id TEXT NOT NULL,
          entity_kind TEXT NOT NULL,
          entity_id TEXT NOT NULL,
          local_version INTEGER NOT NULL,
          remote_version INTEGER NOT NULL,
          strategy TEXT NOT NULL,
          status TEXT NOT NULL,
          summary TEXT NOT NULL,
          metadata_json TEXT NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      `,
      `CREATE INDEX IF NOT EXISTS idx_sync_conflicts_account_id ON sync_conflicts(account_id);`,
      `
        CREATE TABLE IF NOT EXISTS remote_sync_records (
          id TEXT PRIMARY KEY NOT NULL,
          account_id TEXT NOT NULL,
          entity_kind TEXT NOT NULL,
          entity_id TEXT NOT NULL,
          remote_id TEXT NOT NULL,
          payload_json TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_writer_device_id TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      `,
      `CREATE INDEX IF NOT EXISTS idx_remote_sync_records_account_id ON remote_sync_records(account_id);`,
    ],
  },
  {
    id: 4,
    name: "phase_12_activity_history",
    statements: [
      `
        CREATE TABLE IF NOT EXISTS activity_events (
          id TEXT PRIMARY KEY NOT NULL,
          kind TEXT NOT NULL,
          occurred_at TEXT NOT NULL,
          date TEXT NOT NULL,
          title TEXT NOT NULL,
          detail TEXT,
          outcome_label TEXT,
          goal_id TEXT,
          milestone_id TEXT,
          task_id TEXT,
          daily_plan_id TEXT,
          time_block_id TEXT,
          metadata_json TEXT NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY(goal_id) REFERENCES goals(id) ON DELETE SET NULL,
          FOREIGN KEY(milestone_id) REFERENCES goal_milestones(id) ON DELETE SET NULL,
          FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE SET NULL,
          FOREIGN KEY(daily_plan_id) REFERENCES daily_plans(id) ON DELETE SET NULL,
          FOREIGN KEY(time_block_id) REFERENCES time_blocks(id) ON DELETE SET NULL
        );
      `,
      `CREATE INDEX IF NOT EXISTS idx_activity_events_occurred_at ON activity_events(occurred_at DESC);`,
      `CREATE INDEX IF NOT EXISTS idx_activity_events_goal_id ON activity_events(goal_id);`,
      `CREATE INDEX IF NOT EXISTS idx_activity_events_task_id ON activity_events(task_id);`,
      `CREATE INDEX IF NOT EXISTS idx_activity_events_date ON activity_events(date DESC);`,
    ],
  },
  {
    id: 5,
    name: "phase_14_auth_session_persistence",
    statements: [
      `
        CREATE TABLE IF NOT EXISTS auth_state_v2 (
          id TEXT PRIMARY KEY NOT NULL,
          status TEXT NOT NULL,
          signed_in_account_id TEXT,
          primary_provider TEXT NOT NULL,
          available_providers_json TEXT NOT NULL,
          session_expires_at TEXT,
          last_authenticated_at TEXT,
          last_error TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      `,
      `
        INSERT OR REPLACE INTO auth_state_v2 (
          id,
          status,
          signed_in_account_id,
          primary_provider,
          available_providers_json,
          session_expires_at,
          last_authenticated_at,
          last_error,
          created_at,
          updated_at
        )
        SELECT
          id,
          status,
          signed_in_account_id,
          primary_provider,
          available_providers_json,
          NULL,
          last_authenticated_at,
          last_error,
          created_at,
          updated_at
        FROM auth_state;
      `,
      `DROP TABLE auth_state;`,
      `ALTER TABLE auth_state_v2 RENAME TO auth_state;`,
    ],
  },
  {
    id: 6,
    name: "phase_17_daily_rituals",
    statements: [
      `
        CREATE TABLE IF NOT EXISTS daily_ritual_states (
          id TEXT PRIMARY KEY NOT NULL,
          date TEXT NOT NULL UNIQUE,
          opened_at TEXT,
          opening_focus TEXT,
          recovery_moments_json TEXT NOT NULL DEFAULT '[]',
          closed_at TEXT,
          day_load_rating TEXT,
          energy_rating TEXT,
          clarity_rating TEXT,
          reflection_note TEXT,
          carry_decision_summary_json TEXT,
          metadata_json TEXT NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      `,
      `CREATE INDEX IF NOT EXISTS idx_daily_ritual_states_date ON daily_ritual_states(date DESC);`,
    ],
  },
  {
    id: 7,
    name: "phase_18_weekly_review",
    statements: [
      `
        CREATE TABLE IF NOT EXISTS weekly_review_states (
          id TEXT PRIMARY KEY NOT NULL,
          week_start_date TEXT NOT NULL UNIQUE,
          week_end_date TEXT NOT NULL,
          reviewed_at TEXT,
          next_week_shaped_at TEXT,
          weekly_emphasis TEXT,
          target_week_intensity TEXT,
          carryover_posture TEXT,
          note TEXT,
          carryover_task_ids_json TEXT NOT NULL DEFAULT '[]',
          review_task_ids_json TEXT NOT NULL DEFAULT '[]',
          released_task_ids_json TEXT NOT NULL DEFAULT '[]',
          summary_json TEXT,
          metadata_json TEXT NOT NULL,
          owner_user_id TEXT,
          remote_id TEXT,
          sync_state TEXT NOT NULL,
          version INTEGER NOT NULL,
          last_synced_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      `,
      `CREATE INDEX IF NOT EXISTS idx_weekly_review_states_week_start_date ON weekly_review_states(week_start_date DESC);`,
    ],
  },
];

export const migrations = [
  `
    CREATE TABLE IF NOT EXISTS goals (
      id TEXT PRIMARY KEY NOT NULL,
      title TEXT NOT NULL,
      horizon TEXT NOT NULL,
      domain TEXT NOT NULL,
      status TEXT NOT NULL,
      summary TEXT,
      parent_goal_id TEXT,
      target_date TEXT
    );
  `,
  `
    CREATE TABLE IF NOT EXISTS plan_blocks (
      id TEXT PRIMARY KEY NOT NULL,
      title TEXT NOT NULL,
      starts_at TEXT NOT NULL,
      ends_at TEXT NOT NULL,
      energy TEXT NOT NULL,
      state TEXT NOT NULL,
      linked_goal_id TEXT,
      note TEXT,
      plan_date TEXT NOT NULL
    );
  `,
  `
    CREATE TABLE IF NOT EXISTS user_profiles (
      id TEXT PRIMARY KEY NOT NULL,
      capacity_profile_json TEXT NOT NULL,
      completion_profile_json TEXT NOT NULL,
      friction_profile_json TEXT NOT NULL,
      momentum_profile_json TEXT NOT NULL,
      strategy_profile_json TEXT NOT NULL
    );
  `,
];

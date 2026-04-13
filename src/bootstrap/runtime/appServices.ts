import {
  seedCalendarConnectionState,
  seedDomains,
  seedNotificationPreferences,
  seedPreferences,
  seedScheduleConstraints,
  seedAdaptationProfile,
} from "../../data/seed/phase8Seed";
import { initializeDatabase, sqliteClient } from "../../data/sqlite/client";
import {
  adaptationEngine,
  executionEngine,
  goalDecompositionEngine,
  replanningEngine,
  schedulingEngine,
  timeCapacityEngine,
} from "../../engines";
import {
  SQLiteAdaptationRepository,
  SQLiteAccountRepository,
  SQLiteGoalRepository,
  SQLiteHistoryRepository,
  SQLiteIntegrationRepository,
  SQLitePlanRepository,
  SQLitePreferencesRepository,
  SQLiteTaskRepository,
} from "../../repositories/sqlite";
import { AccountService } from "../../services/account/AccountService";
import { CalendarService } from "../../services/calendar/CalendarService";
import { NotificationsService } from "../../services/notifications/NotificationsService";
import { resetStartupReady } from "./startupBarrier";

const repositories = {
  account: new SQLiteAccountRepository(sqliteClient),
  goals: new SQLiteGoalRepository(sqliteClient),
  history: new SQLiteHistoryRepository(sqliteClient),
  tasks: new SQLiteTaskRepository(sqliteClient),
  planning: new SQLitePlanRepository(sqliteClient),
  preferences: new SQLitePreferencesRepository(sqliteClient),
  adaptation: new SQLiteAdaptationRepository(sqliteClient),
  integration: new SQLiteIntegrationRepository(sqliteClient),
};

export const appServices = {
  services: {
    calendar: CalendarService,
    notifications: NotificationsService,
    account: new AccountService({
      accountRepository: repositories.account,
      repositories: {
        goals: repositories.goals,
        tasks: repositories.tasks,
        planning: repositories.planning,
        preferences: repositories.preferences,
        adaptation: repositories.adaptation,
        history: repositories.history,
      },
    }),
  },
  engines: {
    decomposition: goalDecompositionEngine,
    capacity: timeCapacityEngine,
    scheduling: schedulingEngine,
    execution: executionEngine,
    replanning: replanningEngine,
    adaptation: adaptationEngine,
  },
  repositories,
};

let initializationPromise: Promise<void> | null = null;
const bootstrapSeedVersion = "phase8-product-foundation";

async function resetSeedData() {
  await sqliteClient.withTransaction(async (client) => {
    await client.run("DELETE FROM time_blocks;");
    await client.run("DELETE FROM daily_plans;");
    await client.run("DELETE FROM daily_ritual_states;");
    await client.run("DELETE FROM weekly_review_states;");
    await client.run("DELETE FROM monthly_review_states;");
    await client.run("DELETE FROM activity_events;");
    await client.run("DELETE FROM replan_suggestions;");
    await client.run("DELETE FROM tasks;");
    await client.run("DELETE FROM goal_milestones;");
    await client.run("DELETE FROM goals;");
    await client.run("DELETE FROM adaptation_profiles;");
    await client.run("DELETE FROM schedule_constraints;");
    await client.run("DELETE FROM calendar_connection_states;");
    await client.run("DELETE FROM notification_preferences;");
    await client.run("DELETE FROM user_preferences;");
    await client.run("DELETE FROM domains;");
    await client.run(
      "INSERT OR REPLACE INTO app_metadata (key, value) VALUES (?, ?);",
      ["bootstrap_seed_version", bootstrapSeedVersion],
    );
  });
}

async function ensureBootstrapMetadata() {
  await sqliteClient.run(
    "INSERT OR REPLACE INTO app_metadata (key, value) VALUES (?, ?);",
    ["bootstrap_seed_version", bootstrapSeedVersion],
  );
}

async function detectInitialSeedNeed() {
  const seedVersion = await sqliteClient.getFirst<{ value: string }>(
    "SELECT value FROM app_metadata WHERE key = ? LIMIT 1;",
    ["bootstrap_seed_version"],
  );
  const goalCount = await sqliteClient.getFirst<{ count: number }>(
    "SELECT COUNT(*) as count FROM goals;",
  );
  const preferencesCount = await sqliteClient.getFirst<{ count: number }>(
    "SELECT COUNT(*) as count FROM user_preferences;",
  );
  const domainCount = await sqliteClient.getFirst<{ count: number }>(
    "SELECT COUNT(*) as count FROM domains;",
  );

  return {
    seedVersion: seedVersion?.value ?? null,
    needsInitialSeed:
      (goalCount?.count ?? 0) === 0 &&
      (preferencesCount?.count ?? 0) === 0 &&
      (domainCount?.count ?? 0) === 0,
  };
}

async function seedInitialData() {
  await resetSeedData();
  await appServices.repositories.preferences.saveDomains(seedDomains);
  await appServices.repositories.preferences.saveUserPreferences(seedPreferences);
  await appServices.repositories.preferences.saveNotificationPreferences(
    seedNotificationPreferences,
  );
  await appServices.repositories.adaptation.saveProfiles([seedAdaptationProfile]);
  await appServices.repositories.integration.saveCalendarConnectionState(
    seedCalendarConnectionState,
  );
  await appServices.repositories.integration.saveScheduleConstraints(seedScheduleConstraints);
  await ensureBootstrapMetadata();
}

async function ensurePhase18Defaults() {
  const [preferences, notificationPreferences] = await Promise.all([
    appServices.repositories.preferences.getUserPreferences(),
    appServices.repositories.preferences.listNotificationPreferences(),
  ]);

  if (
    preferences &&
    (
      preferences.metadata.defaultUnfinishedWorkBehavior === undefined ||
      preferences.metadata.weeklyReviewTime === undefined ||
      preferences.metadata.autoPromptNextWeekShaping === undefined ||
      preferences.metadata.defaultWeeklyCarryoverBehavior === undefined ||
      preferences.metadata.weeklyReviewDay === undefined
    )
  ) {
    await appServices.repositories.preferences.saveUserPreferences({
      ...preferences,
      metadata: {
        ...preferences.metadata,
        defaultUnfinishedWorkBehavior:
          preferences.metadata.defaultUnfinishedWorkBehavior ?? "ask_each_time",
        weeklyReviewDay: preferences.metadata.weeklyReviewDay ?? preferences.weeklyPlanningDay,
        weeklyReviewTime: preferences.metadata.weeklyReviewTime ?? "16:30",
        autoPromptNextWeekShaping:
          preferences.metadata.autoPromptNextWeekShaping ?? true,
        defaultWeeklyCarryoverBehavior:
          preferences.metadata.defaultWeeklyCarryoverBehavior ?? "review_first",
      },
      updatedAt: new Date().toISOString(),
      version: preferences.version + 1,
    });
  }

  const existingTypes = new Set(notificationPreferences.map((preference) => preference.reminderType));
  const missing = seedNotificationPreferences.filter(
    (preference) => !existingTypes.has(preference.reminderType),
  );

  if (missing.length > 0) {
    await appServices.repositories.preferences.saveNotificationPreferences([
      ...notificationPreferences,
      ...missing,
    ]);
  }
}

async function ensurePhase19Defaults() {
  const [preferences, notificationPreferences] = await Promise.all([
    appServices.repositories.preferences.getUserPreferences(),
    appServices.repositories.preferences.listNotificationPreferences(),
  ]);

  if (
    preferences &&
    (
      preferences.metadata.monthlyReviewDay === undefined ||
      preferences.metadata.monthlyReviewTime === undefined ||
      preferences.metadata.autoPromptNextMonthShaping === undefined ||
      preferences.metadata.defaultMonthlyPosture === undefined ||
      preferences.metadata.defaultMonthlyEmphasis === undefined ||
      preferences.metadata.defaultMonthlyPressure === undefined ||
      preferences.metadata.defaultMonthlyCarryoverStance === undefined
    )
  ) {
    await appServices.repositories.preferences.saveUserPreferences({
      ...preferences,
      metadata: {
        ...preferences.metadata,
        monthlyReviewDay: preferences.metadata.monthlyReviewDay ?? preferences.monthlyPlanningDay,
        monthlyReviewTime: preferences.metadata.monthlyReviewTime ?? "09:30",
        autoPromptNextMonthShaping:
          preferences.metadata.autoPromptNextMonthShaping ?? true,
        defaultMonthlyPosture:
          preferences.metadata.defaultMonthlyPosture ?? "stabilize",
        defaultMonthlyEmphasis:
          preferences.metadata.defaultMonthlyEmphasis ?? "protect_essentials",
        defaultMonthlyPressure:
          preferences.metadata.defaultMonthlyPressure ?? "balanced",
        defaultMonthlyCarryoverStance:
          preferences.metadata.defaultMonthlyCarryoverStance ?? "review_before_carrying",
      },
      updatedAt: new Date().toISOString(),
      version: preferences.version + 1,
    });
  }

  const existingTypes = new Set(notificationPreferences.map((preference) => preference.reminderType));
  const missing = seedNotificationPreferences.filter(
    (preference) => !existingTypes.has(preference.reminderType),
  );

  if (missing.length > 0) {
    await appServices.repositories.preferences.saveNotificationPreferences([
      ...notificationPreferences,
      ...missing,
    ]);
  }
}

export async function initializeAppServices() {
  if (!initializationPromise) {
    resetStartupReady();
    initializationPromise = (async () => {
      await initializeDatabase();
      const { seedVersion, needsInitialSeed } = await detectInitialSeedNeed();

      if (needsInitialSeed) {
        await seedInitialData();
      } else if (seedVersion !== bootstrapSeedVersion) {
        await ensureBootstrapMetadata();
      }

      await ensurePhase18Defaults();
      await ensurePhase19Defaults();

      await appServices.services.account.initialize();
    })().catch((error) => {
      initializationPromise = null;
      throw error;
    });
  }

  return initializationPromise;
}

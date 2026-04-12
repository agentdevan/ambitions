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

      await appServices.services.account.initialize();
    })().catch((error) => {
      initializationPromise = null;
      throw error;
    });
  }

  return initializationPromise;
}

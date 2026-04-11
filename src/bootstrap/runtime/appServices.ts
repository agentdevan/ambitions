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
  SQLiteGoalRepository,
  SQLiteIntegrationRepository,
  SQLitePlanRepository,
  SQLitePreferencesRepository,
  SQLiteTaskRepository,
} from "../../repositories/sqlite";
import { CalendarService } from "../../services/calendar/CalendarService";
import { NotificationsService } from "../../services/notifications/NotificationsService";

export const appServices = {
  services: {
    calendar: CalendarService,
    notifications: NotificationsService,
  },
  engines: {
    decomposition: goalDecompositionEngine,
    capacity: timeCapacityEngine,
    scheduling: schedulingEngine,
    execution: executionEngine,
    replanning: replanningEngine,
    adaptation: adaptationEngine,
  },
  repositories: {
    goals: new SQLiteGoalRepository(sqliteClient),
    tasks: new SQLiteTaskRepository(sqliteClient),
    planning: new SQLitePlanRepository(sqliteClient),
    preferences: new SQLitePreferencesRepository(sqliteClient),
    adaptation: new SQLiteAdaptationRepository(sqliteClient),
    integration: new SQLiteIntegrationRepository(sqliteClient),
  },
};

let initializationPromise: Promise<void> | null = null;
const bootstrapSeedVersion = "phase8-product-foundation";

async function resetSeedData() {
  await sqliteClient.withTransaction(async (client) => {
    await client.run("DELETE FROM time_blocks;");
    await client.run("DELETE FROM daily_plans;");
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

export async function initializeAppServices() {
  if (!initializationPromise) {
    initializationPromise = (async () => {
      await initializeDatabase();

      const seedVersion = await sqliteClient.getFirst<{ value: string }>(
        "SELECT value FROM app_metadata WHERE key = ? LIMIT 1;",
        ["bootstrap_seed_version"],
      );
      const [existingGoals, existingPreferences, existingDomains] = await Promise.all([
        appServices.repositories.goals.listGoals(),
        appServices.repositories.preferences.getUserPreferences(),
        appServices.repositories.preferences.listDomains(),
      ]);
      const needsInitialSeed =
        existingGoals.length === 0 &&
        existingDomains.length === 0 &&
        existingPreferences === null;

      if (!needsInitialSeed) {
        if (seedVersion?.value !== bootstrapSeedVersion) {
          await ensureBootstrapMetadata();
        }
        return;
      }

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
    })();
  }

  return initializationPromise;
}

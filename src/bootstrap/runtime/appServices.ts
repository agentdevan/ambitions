import {
  seedAdaptationProfile,
  seedCalendarConnectionState,
  seedDailyPlan,
  seedDomains,
  seedGoals,
  seedMilestones,
  seedNotificationPreferences,
  seedPreferences,
  seedReplanSuggestions,
  seedScheduleConstraints,
  seedTasks,
  seedTimeBlocks,
} from "../../data/seed/phase3Seed";
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
const bootstrapSeedVersion = "phase5-adaptive-execution";

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

export async function initializeAppServices() {
  if (!initializationPromise) {
    initializationPromise = (async () => {
      await initializeDatabase();

      const seedVersion = await sqliteClient.getFirst<{ value: string }>(
        "SELECT value FROM app_metadata WHERE key = ? LIMIT 1;",
        ["bootstrap_seed_version"],
      );
      const existingGoals = await appServices.repositories.goals.listGoals();
      const needsReseed =
        existingGoals.length === 0 || seedVersion?.value !== bootstrapSeedVersion;

      if (!needsReseed) {
        return;
      }

      await resetSeedData();

      await appServices.repositories.preferences.saveDomains(seedDomains);
      await appServices.repositories.preferences.saveUserPreferences(seedPreferences);
      await appServices.repositories.preferences.saveNotificationPreferences(
        seedNotificationPreferences,
      );
      await appServices.repositories.goals.saveGoals(seedGoals);
      await appServices.repositories.goals.saveMilestones(seedMilestones);
      await appServices.repositories.tasks.saveTasks(seedTasks);
      await appServices.repositories.adaptation.saveProfiles([seedAdaptationProfile]);
      await appServices.repositories.planning.saveDailyPlans([seedDailyPlan]);
      await appServices.repositories.planning.saveTimeBlocks(seedTimeBlocks);
      await appServices.repositories.adaptation.saveReplanSuggestions(seedReplanSuggestions);
      await appServices.repositories.integration.saveCalendarConnectionState(
        seedCalendarConnectionState,
      );
      await appServices.repositories.integration.saveScheduleConstraints(seedScheduleConstraints);
    })();
  }

  return initializationPromise;
}

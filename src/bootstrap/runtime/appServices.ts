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
} from "../../data/seed/phase2Seed";
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

export async function initializeAppServices() {
  if (!initializationPromise) {
    initializationPromise = (async () => {
      await initializeDatabase();

      const existingGoals = await appServices.repositories.goals.listGoals();

      if (existingGoals.length > 0) {
        return;
      }

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

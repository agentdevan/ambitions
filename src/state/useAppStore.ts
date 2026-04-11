import { create } from "zustand";

import { initializeAppServices, appServices } from "../bootstrap/runtime/appServices";
import {
  AdaptationProfile,
  CalendarConnectionState,
  DailyPlan,
  Domain,
  Goal,
  GoalMilestone,
  NotificationPreference,
  ReplanSuggestion,
  ScheduleConstraint,
  Task,
  UserPreferences,
} from "../domain/models";
import { NotificationsService } from "../services/notifications/NotificationsService";
import { buildTodayViewModel, TodayViewModel } from "./viewModels/today";

type LoadStatus = "idle" | "loading" | "ready" | "error";

interface AppShellSlice {
  bootstrapped: boolean;
  bootStatus: LoadStatus;
  lastError: string | null;
  bootstrap: () => Promise<void>;
}

interface GoalsSlice {
  domains: Domain[];
  goals: Goal[];
  milestones: GoalMilestone[];
  refreshGoals: () => Promise<void>;
}

interface PlanningSlice {
  planDate: string;
  dailyPlan: DailyPlan | null;
  today: TodayViewModel | null;
  tasksForSelectedDate: Task[];
  refreshPlanning: (date?: string) => Promise<void>;
}

interface PreferencesSlice {
  userPreferences: UserPreferences | null;
  notificationPreferences: NotificationPreference[];
  refreshPreferences: () => Promise<void>;
}

interface AdaptationSlice {
  adaptationProfile: AdaptationProfile | null;
  replanSuggestions: ReplanSuggestion[];
  refreshAdaptation: (date?: string) => Promise<void>;
}

interface IntegrationSlice {
  calendarConnectionState: CalendarConnectionState | null;
  scheduleConstraints: ScheduleConstraint[];
  refreshIntegration: (date?: string) => Promise<void>;
}

type AppState = AppShellSlice &
  GoalsSlice &
  PlanningSlice &
  PreferencesSlice &
  AdaptationSlice &
  IntegrationSlice;

const initialPlanDate = "2026-04-11";

async function loadFoundationSnapshot(date: string) {
  const [
    domains,
    goals,
    milestones,
    preferences,
    notificationPreferences,
    adaptationProfile,
    dailyPlan,
    tasks,
    calendarConnectionState,
    scheduleConstraints,
    replanSuggestions,
  ] = await Promise.all([
    appServices.repositories.preferences.listDomains(),
    appServices.repositories.goals.listGoals(),
    appServices.repositories.goals.listMilestones(),
    appServices.repositories.preferences.getUserPreferences(),
    appServices.repositories.preferences.listNotificationPreferences(),
    appServices.repositories.adaptation.getLatestProfile(),
    appServices.repositories.planning.getDailyPlan(date),
    appServices.repositories.tasks.listTasksForDate(date),
    appServices.repositories.integration.getCalendarConnectionState(),
    appServices.repositories.integration.listScheduleConstraintsForDate(date),
    appServices.repositories.adaptation.listReplanSuggestions(date),
  ]);

  const blocks = dailyPlan
    ? await appServices.repositories.planning.listTimeBlocksForPlan(dailyPlan.id)
    : [];

  return {
    domains,
    goals,
    milestones,
    preferences,
    notificationPreferences,
    adaptationProfile,
    dailyPlan,
    tasks,
    calendarConnectionState,
    scheduleConstraints,
    replanSuggestions,
    today: buildTodayViewModel({
      date,
      dailyPlan,
      blocks,
      profile: adaptationProfile,
      suggestions: replanSuggestions,
      constraints: scheduleConstraints,
      tasks,
    }),
  };
}

export const useAppStore = create<AppState>((set, get) => ({
  bootstrapped: false,
  bootStatus: "idle",
  lastError: null,
  domains: [],
  goals: [],
  milestones: [],
  planDate: initialPlanDate,
  dailyPlan: null,
  today: null,
  tasksForSelectedDate: [],
  userPreferences: null,
  notificationPreferences: [],
  adaptationProfile: null,
  replanSuggestions: [],
  calendarConnectionState: null,
  scheduleConstraints: [],

  bootstrap: async () => {
    if (get().bootStatus === "loading" || get().bootstrapped) {
      return;
    }

    set({ bootStatus: "loading", lastError: null });

    try {
      await initializeAppServices();
      await NotificationsService.configure();
      const snapshot = await loadFoundationSnapshot(get().planDate);

      set({
        bootstrapped: true,
        bootStatus: "ready",
        domains: snapshot.domains,
        goals: snapshot.goals,
        milestones: snapshot.milestones,
        userPreferences: snapshot.preferences,
        notificationPreferences: snapshot.notificationPreferences,
        adaptationProfile: snapshot.adaptationProfile,
        replanSuggestions: snapshot.replanSuggestions,
        dailyPlan: snapshot.dailyPlan,
        today: snapshot.today,
        tasksForSelectedDate: snapshot.tasks,
        calendarConnectionState: snapshot.calendarConnectionState,
        scheduleConstraints: snapshot.scheduleConstraints,
      });
    } catch (error) {
      set({
        bootStatus: "error",
        lastError: error instanceof Error ? error.message : "Unknown bootstrap failure",
      });
    }
  },

  refreshGoals: async () => {
    const [domains, goals, milestones] = await Promise.all([
      appServices.repositories.preferences.listDomains(),
      appServices.repositories.goals.listGoals(),
      appServices.repositories.goals.listMilestones(),
    ]);

    set({ domains, goals, milestones });
  },

  refreshPlanning: async (date) => {
    const planDate = date ?? get().planDate;
    const snapshot = await loadFoundationSnapshot(planDate);

    set({
      planDate,
      dailyPlan: snapshot.dailyPlan,
      today: snapshot.today,
      tasksForSelectedDate: snapshot.tasks,
      replanSuggestions: snapshot.replanSuggestions,
      scheduleConstraints: snapshot.scheduleConstraints,
    });
  },

  refreshPreferences: async () => {
    const [userPreferences, notificationPreferences] = await Promise.all([
      appServices.repositories.preferences.getUserPreferences(),
      appServices.repositories.preferences.listNotificationPreferences(),
    ]);

    set({ userPreferences, notificationPreferences });
  },

  refreshAdaptation: async (date) => {
    const planDate = date ?? get().planDate;
    const [adaptationProfile, replanSuggestions] = await Promise.all([
      appServices.repositories.adaptation.getLatestProfile(),
      appServices.repositories.adaptation.listReplanSuggestions(planDate),
    ]);

    set({ adaptationProfile, replanSuggestions });
  },

  refreshIntegration: async (date) => {
    const planDate = date ?? get().planDate;
    const [calendarConnectionState, scheduleConstraints] = await Promise.all([
      appServices.repositories.integration.getCalendarConnectionState(),
      appServices.repositories.integration.listScheduleConstraintsForDate(planDate),
    ]);

    set({ calendarConnectionState, scheduleConstraints });
  },
}));

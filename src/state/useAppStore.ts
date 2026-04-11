import { create } from "zustand";

import { initializeAppServices, appServices } from "../bootstrap/runtime/appServices";
import { SchedulingOutput } from "../engines";
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
  TaskActionType,
  Task,
  TimeBlock,
  UserPreferences,
} from "../domain/models";
import { selectConstraintsForScheduling, shouldUseLiveCalendar } from "../services/calendar/constraintSelection";
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
  schedule: SchedulingOutput | null;
  today: TodayViewModel | null;
  timeBlocksForSelectedDate: TimeBlock[];
  tasksForSelectedDate: Task[];
  refreshPlanning: (date?: string) => Promise<void>;
  applyTaskAction: (taskId: string, action: TaskActionType) => Promise<void>;
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
  notificationPermissionStatus: string;
  refreshIntegration: (date?: string) => Promise<void>;
  requestCalendarAccess: () => Promise<void>;
  requestNotificationAccess: () => Promise<void>;
}

type AppState = AppShellSlice &
  GoalsSlice &
  PlanningSlice &
  PreferencesSlice &
  AdaptationSlice &
  IntegrationSlice;

const initialPlanDate = "2026-04-11";

async function syncCalendarIntegration(date: string) {
  const existingState = await appServices.repositories.integration.getCalendarConnectionState();
  const result = await appServices.services.calendar.syncDate({
    date,
    existingState,
    selectedCalendarIds: existingState?.selectedCalendarIds,
  });

  await appServices.repositories.integration.saveCalendarConnectionState(result.connectionState);

  if (shouldUseLiveCalendar(result.connectionState)) {
    await appServices.repositories.integration.replaceCalendarConstraintsForDate(date, result.constraints);
  } else {
    await appServices.repositories.integration.replaceCalendarConstraintsForDate(date, []);
  }

  return result.connectionState;
}

async function syncNotificationsForSnapshot(snapshot: Awaited<ReturnType<typeof loadFoundationSnapshot>>) {
  await appServices.services.notifications.syncPlanNotifications({
    date: snapshot.today?.date ?? initialPlanDate,
    schedule: snapshot.schedule,
    timeBlocks: snapshot.blocks,
    tasks: snapshot.tasks,
    preferences: snapshot.notificationPreferences,
  });
}

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
  const effectiveConstraints = selectConstraintsForScheduling(
    scheduleConstraints,
    calendarConnectionState,
  );

  const blocks = dailyPlan
    ? await appServices.repositories.planning.listTimeBlocksForPlan(dailyPlan.id)
    : [];
  const scheduleResult = preferences
    ? await appServices.engines.scheduling.buildSchedule({
        date,
        goals,
        milestones,
        tasks,
        constraints: effectiveConstraints,
        preferences,
        adaptationProfile,
        existingPlan: dailyPlan,
      })
    : null;
  const schedule = scheduleResult?.payload ?? null;
  const derivedReplanSuggestions =
    preferences && dailyPlan
      ? (
          await appServices.engines.replanning.suggestAdjustments({
            date,
            goals,
            milestones,
            tasks,
            constraints: effectiveConstraints,
            preferences,
            adaptationProfile,
            dailyPlan,
            timeBlocks: schedule?.timeBlocks ?? blocks,
          })
        ).payload.suggestions
      : [];
  const mergedReplanSuggestions = [
    ...replanSuggestions,
    ...derivedReplanSuggestions.filter(
      (candidate) =>
        !replanSuggestions.some(
          (existing) =>
            existing.taskId === candidate.taskId && existing.type === candidate.type,
        ),
    ),
  ].sort((left, right) => right.confidence - left.confidence);

  return {
    domains,
    goals,
    milestones,
    preferences,
    notificationPreferences,
    adaptationProfile,
    dailyPlan,
    blocks,
    tasks,
    calendarConnectionState,
    scheduleConstraints: effectiveConstraints,
    replanSuggestions: mergedReplanSuggestions,
    schedule,
    today: buildTodayViewModel({
      date,
      dailyPlan: schedule?.dailyPlan ?? dailyPlan,
      blocks,
      schedule,
      profile: adaptationProfile,
      suggestions: mergedReplanSuggestions,
      constraints: effectiveConstraints,
      tasks,
      calendarConnectionState,
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
  schedule: null,
  today: null,
  tasksForSelectedDate: [],
  timeBlocksForSelectedDate: [],
  userPreferences: null,
  notificationPreferences: [],
  adaptationProfile: null,
  replanSuggestions: [],
  calendarConnectionState: null,
  scheduleConstraints: [],
  notificationPermissionStatus: "undetermined",

  bootstrap: async () => {
    if (get().bootStatus === "loading" || get().bootstrapped) {
      return;
    }

    set({ bootStatus: "loading", lastError: null });

    try {
      await initializeAppServices();
      await appServices.services.notifications.configure();
      await syncCalendarIntegration(get().planDate);
      const snapshot = await loadFoundationSnapshot(get().planDate);
      const notificationPermissionStatus =
        await appServices.services.notifications.getPermissionStatus();
      await syncNotificationsForSnapshot(snapshot);

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
        dailyPlan: snapshot.schedule?.dailyPlan ?? snapshot.dailyPlan,
        schedule: snapshot.schedule,
        today: snapshot.today,
        timeBlocksForSelectedDate: snapshot.blocks,
        tasksForSelectedDate: snapshot.tasks,
        calendarConnectionState: snapshot.calendarConnectionState,
        scheduleConstraints: snapshot.scheduleConstraints,
        notificationPermissionStatus,
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
    await syncCalendarIntegration(planDate);
    const snapshot = await loadFoundationSnapshot(planDate);
    await syncNotificationsForSnapshot(snapshot);

    set({
      planDate,
      dailyPlan: snapshot.schedule?.dailyPlan ?? snapshot.dailyPlan,
      schedule: snapshot.schedule,
      today: snapshot.today,
      timeBlocksForSelectedDate: snapshot.blocks,
      tasksForSelectedDate: snapshot.tasks,
      replanSuggestions: snapshot.replanSuggestions,
      scheduleConstraints: snapshot.scheduleConstraints,
      calendarConnectionState: snapshot.calendarConnectionState,
    });
  },

  applyTaskAction: async (taskId, action) => {
    const state = get();

    if (!state.dailyPlan) {
      throw new Error("No daily plan is loaded for execution.");
    }

    const execution = await appServices.engines.execution.execute({
      date: state.planDate,
      dailyPlan: state.dailyPlan,
      timeBlocks: state.timeBlocksForSelectedDate,
      tasks: state.tasksForSelectedDate,
      adaptationProfile: state.adaptationProfile,
      event: {
        taskId,
        type: action,
        occurredAt: new Date().toISOString(),
      },
    });

    const nextSuggestions = [
      ...state.replanSuggestions.filter((suggestion) => suggestion.taskId !== taskId),
      ...execution.payload.replanSuggestions,
    ].sort((left, right) => right.confidence - left.confidence);

    await Promise.all([
      appServices.repositories.tasks.saveTasks(execution.payload.mutation.tasksToSave),
      appServices.repositories.planning.saveTimeBlocks(execution.payload.mutation.blocksToSave),
      appServices.repositories.planning.saveDailyPlans([execution.payload.mutation.dailyPlan]),
      appServices.repositories.adaptation.replaceReplanSuggestions(state.planDate, nextSuggestions),
    ]);

    const [allTasks, userPreferences] = await Promise.all([
      appServices.repositories.tasks.listTasks(),
      state.userPreferences
        ? Promise.resolve(state.userPreferences)
        : appServices.repositories.preferences.getUserPreferences(),
    ]);

    if (userPreferences) {
      const adaptationResult = await appServices.engines.adaptation.updateProfile({
        date: state.planDate,
        tasks: allTasks,
        priorProfile: state.adaptationProfile,
        preferences: userPreferences,
      });

      await appServices.repositories.adaptation.saveProfiles([adaptationResult.payload.profile]);
    }

    const snapshot = await loadFoundationSnapshot(state.planDate);
    await syncNotificationsForSnapshot(snapshot);

    set({
      dailyPlan: snapshot.schedule?.dailyPlan ?? snapshot.dailyPlan,
      schedule: snapshot.schedule,
      today: snapshot.today,
      timeBlocksForSelectedDate: snapshot.blocks,
      tasksForSelectedDate: snapshot.tasks,
      replanSuggestions: snapshot.replanSuggestions,
      scheduleConstraints: snapshot.scheduleConstraints,
      calendarConnectionState: snapshot.calendarConnectionState,
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
    await syncCalendarIntegration(planDate);
    const snapshot = await loadFoundationSnapshot(planDate);
    const notificationPermissionStatus =
      await appServices.services.notifications.getPermissionStatus();
    await syncNotificationsForSnapshot(snapshot);

    set({
      planDate,
      dailyPlan: snapshot.schedule?.dailyPlan ?? snapshot.dailyPlan,
      schedule: snapshot.schedule,
      today: snapshot.today,
      timeBlocksForSelectedDate: snapshot.blocks,
      tasksForSelectedDate: snapshot.tasks,
      replanSuggestions: snapshot.replanSuggestions,
      calendarConnectionState: snapshot.calendarConnectionState,
      scheduleConstraints: snapshot.scheduleConstraints,
      notificationPermissionStatus,
    });
  },

  requestCalendarAccess: async () => {
    await appServices.services.calendar.requestAccess();
    await get().refreshPlanning(get().planDate);
  },

  requestNotificationAccess: async () => {
    const notificationPermissionStatus =
      await appServices.services.notifications.requestAccess();
    const snapshot = await loadFoundationSnapshot(get().planDate);
    await syncNotificationsForSnapshot(snapshot);

    set({ notificationPermissionStatus });
  },
}));

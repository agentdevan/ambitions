import { appServices } from "../bootstrap/runtime/appServices";
import {
  AdaptationProfile,
  ActivityEvent,
  CalendarConnectionState,
  DailyPlan,
  DailyRitualState,
  Goal,
  GoalMilestone,
  GoalStatus,
  NotificationPreference,
  ReplanSuggestion,
  ScheduleConstraint,
  Task,
  TimeBlock,
  UserPreferences,
} from "../domain/models";
import { SchedulingOutput } from "../engines";
import {
  selectConstraintsForScheduling,
  shouldUseLiveCalendar,
} from "../services/calendar/constraintSelection";
import { getProductPreferences } from "../product/preferences";
import { ProductPreferences } from "../product/types";
import { getCurrentLocalDateString } from "../utils/date";
import { buildTodayViewModel, TodayViewModel } from "./viewModels/today";

export const initialPlanDate = getCurrentLocalDateString();

export interface FoundationSnapshot {
  domains: Awaited<ReturnType<typeof appServices.repositories.preferences.listDomains>>;
  goals: Goal[];
  milestones: GoalMilestone[];
  preferences: UserPreferences | null;
  productPreferences: ProductPreferences;
  notificationPreferences: NotificationPreference[];
  adaptationProfile: AdaptationProfile | null;
  dailyPlan: DailyPlan | null;
  dailyRitual: DailyRitualState | null;
  dailyRitualHistory: DailyRitualState[];
  blocks: TimeBlock[];
  tasks: Task[];
  allTasks: Task[];
  calendarConnectionState: CalendarConnectionState | null;
  scheduleConstraints: ScheduleConstraint[];
  replanSuggestions: ReplanSuggestion[];
  activityEvents: ActivityEvent[];
  schedule: SchedulingOutput | null;
  today: TodayViewModel | null;
}

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

async function syncNotificationsForSnapshot(snapshot: FoundationSnapshot) {
  await appServices.services.notifications.syncPlanNotifications({
    date: snapshot.today?.date ?? initialPlanDate,
    schedule: snapshot.schedule,
    timeBlocks: snapshot.blocks,
    tasks: snapshot.tasks,
    preferences: snapshot.notificationPreferences,
    productPreferences: snapshot.productPreferences,
    dailyRitual: snapshot.dailyRitual,
  });
}

function shouldBuildSchedule(preferences: UserPreferences | null, goals: Goal[], tasks: Task[]) {
  const productPreferences = getProductPreferences(preferences);

  return (
    productPreferences.onboardingCompleted &&
    goals.some((goal) => goal.status === GoalStatus.Active) &&
    tasks.length > 0
  );
}

export async function loadFoundationSnapshot(date: string): Promise<FoundationSnapshot> {
  const [
    domains,
    goals,
    milestones,
    preferences,
    notificationPreferences,
    adaptationProfile,
    dailyPlan,
    dailyRitual,
    dailyRitualHistory,
    tasks,
    allTasks,
    calendarConnectionState,
    scheduleConstraints,
    replanSuggestions,
    activityEvents,
  ] = await Promise.all([
    appServices.repositories.preferences.listDomains(),
    appServices.repositories.goals.listGoals(),
    appServices.repositories.goals.listMilestones(),
    appServices.repositories.preferences.getUserPreferences(),
    appServices.repositories.preferences.listNotificationPreferences(),
    appServices.repositories.adaptation.getLatestProfile(),
    appServices.repositories.planning.getDailyPlan(date),
    appServices.repositories.planning.getDailyRitualState(date),
    appServices.repositories.planning.listDailyRitualStates(),
    appServices.repositories.tasks.listTasksForDate(date),
    appServices.repositories.tasks.listTasks(),
    appServices.repositories.integration.getCalendarConnectionState(),
    appServices.repositories.integration.listScheduleConstraintsForDate(date),
    appServices.repositories.adaptation.listReplanSuggestions(date),
    appServices.repositories.history.listActivityEvents(),
  ]);
  const effectiveConstraints = selectConstraintsForScheduling(
    scheduleConstraints,
    calendarConnectionState,
  );
  const productPreferences = getProductPreferences(preferences);
  const effectiveAdaptationProfile = productPreferences.adaptivePlanningEnabled
    ? adaptationProfile
    : null;
  const persistedBlocks = dailyPlan
    ? await appServices.repositories.planning.listTimeBlocksForPlan(dailyPlan.id)
    : [];
  const scheduleResult = shouldBuildSchedule(preferences, goals, tasks)
    ? await appServices.engines.scheduling.buildSchedule({
        date,
        goals,
        milestones,
        tasks,
        constraints: effectiveConstraints,
        preferences: preferences as UserPreferences,
        adaptationProfile: effectiveAdaptationProfile,
        existingPlan: dailyPlan,
      })
    : null;
  const schedule = scheduleResult?.payload ?? null;
  const blocks = schedule?.timeBlocks ?? persistedBlocks;
  const derivedReplanSuggestions =
    preferences && dailyPlan && tasks.length > 0
      ? (
          await appServices.engines.replanning.suggestAdjustments({
            date,
            goals,
            milestones,
            tasks,
            constraints: effectiveConstraints,
            preferences,
            adaptationProfile: effectiveAdaptationProfile,
            dailyPlan,
            timeBlocks: blocks,
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
    productPreferences,
    notificationPreferences,
    adaptationProfile: effectiveAdaptationProfile,
    dailyPlan,
    dailyRitual,
    dailyRitualHistory,
    blocks,
    tasks,
    allTasks,
    calendarConnectionState,
    scheduleConstraints: effectiveConstraints,
    replanSuggestions: mergedReplanSuggestions,
    activityEvents,
    schedule,
    today:
      productPreferences.onboardingCompleted && (schedule?.dailyPlan ?? dailyPlan)
        ? buildTodayViewModel({
            date,
            dailyPlan: schedule?.dailyPlan ?? dailyPlan,
            goals,
            blocks,
            schedule,
            profile: adaptationProfile,
            suggestions: mergedReplanSuggestions,
            constraints: effectiveConstraints,
            tasks,
            calendarConnectionState,
            adaptiveEnabled: productPreferences.adaptivePlanningEnabled,
            ritualState: dailyRitual,
            activityEvents,
          })
        : null,
  };
}

export async function refreshAllState(date: string) {
  await syncCalendarIntegration(date);
  const snapshot = await loadFoundationSnapshot(date);
  await syncNotificationsForSnapshot(snapshot);
  const notificationPermissionStatus =
    await appServices.services.notifications.getPermissionStatus();

  return {
    planDate: date,
    domains: snapshot.domains,
    goals: snapshot.goals,
    milestones: snapshot.milestones,
    allTasks: snapshot.allTasks,
    userPreferences: snapshot.preferences,
    productPreferences: snapshot.productPreferences,
    notificationPreferences: snapshot.notificationPreferences,
    adaptationProfile: snapshot.adaptationProfile,
    replanSuggestions: snapshot.replanSuggestions,
    activityEvents: snapshot.activityEvents,
    dailyPlan: snapshot.schedule?.dailyPlan ?? snapshot.dailyPlan,
    dailyRitual: snapshot.dailyRitual,
    dailyRitualHistory: snapshot.dailyRitualHistory,
    schedule: snapshot.schedule,
    today: snapshot.today,
    timeBlocksForSelectedDate: snapshot.blocks,
    tasksForSelectedDate: snapshot.tasks,
    calendarConnectionState: snapshot.calendarConnectionState,
    scheduleConstraints: snapshot.scheduleConstraints,
    notificationPermissionStatus,
  };
}

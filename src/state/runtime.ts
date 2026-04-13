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
  MonthlyReviewState,
  NotificationPreference,
  ReplanSuggestion,
  ScheduleConstraint,
  Task,
  TimeBlock,
  UserPreferences,
  WeeklyReviewState,
} from "../domain/models";
import { SchedulingOutput } from "../engines";
import {
  selectConstraintsForScheduling,
  shouldUseLiveCalendar,
} from "../services/calendar/constraintSelection";
import { getProductPreferences } from "../product/preferences";
import { ProductPreferences } from "../product/types";
import { addDays, addMonths, getCurrentLocalDateString, startOfMonth, startOfWeek } from "../utils/date";
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
  currentWeekReview: WeeklyReviewState | null;
  nextWeekReview: WeeklyReviewState | null;
  weeklyReviewHistory: WeeklyReviewState[];
  currentMonthReview: MonthlyReviewState | null;
  nextMonthReview: MonthlyReviewState | null;
  monthlyReviewHistory: MonthlyReviewState[];
  dailyPlans: DailyPlan[];
  blocks: TimeBlock[];
  allTimeBlocks: TimeBlock[];
  tasks: Task[];
  allTasks: Task[];
  calendarConnectionState: CalendarConnectionState | null;
  scheduleConstraints: ScheduleConstraint[];
  weekScheduleConstraints: ScheduleConstraint[];
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
    weeklyReviewState: snapshot.currentWeekReview,
    nextWeekReviewState: snapshot.nextWeekReview,
    monthlyReviewState: snapshot.currentMonthReview,
    nextMonthReviewState: snapshot.nextMonthReview,
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
    weeklyReviewHistory,
    monthlyReviewHistory,
    dailyPlans,
    allTimeBlocks,
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
    appServices.repositories.planning.listWeeklyReviewStates(),
    appServices.repositories.planning.listMonthlyReviewStates(),
    appServices.repositories.planning.listDailyPlans(),
    appServices.repositories.planning.listTimeBlocks(),
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
  const currentWeekStart = startOfWeek(date, preferences?.weekStartsOn ?? 1);
  const nextWeekStart = addDays(currentWeekStart, 7);
  const currentMonthStart = startOfMonth(date);
  const nextMonthStart = addMonths(currentMonthStart, 1);
  const weekConstraintDays = await Promise.all(
    Array.from({ length: 7 }, (_, index) => addDays(currentWeekStart, index)).map((currentDate) =>
      appServices.repositories.integration.listScheduleConstraintsForDate(currentDate),
    ),
  );
  const currentWeekReview =
    weeklyReviewHistory.find((state) => state.weekStartDate === currentWeekStart) ?? null;
  const nextWeekReview =
    weeklyReviewHistory.find((state) => state.weekStartDate === nextWeekStart) ?? null;
  const currentMonthReview =
    monthlyReviewHistory.find((state) => state.monthStartDate === currentMonthStart) ?? null;
  const nextMonthReview =
    monthlyReviewHistory.find((state) => state.monthStartDate === nextMonthStart) ?? null;
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
        weeklyReviewState: currentWeekReview,
        monthlyReviewState: currentMonthReview,
      })
    : null;
  const schedule = scheduleResult?.payload ?? null;
  const blocks = schedule?.timeBlocks ?? persistedBlocks;
  const weekScheduleConstraints = [...weekConstraintDays.flat()].filter(
    (constraint, index, list) => list.findIndex((candidate) => candidate.id === constraint.id) === index,
  );
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
    currentWeekReview,
    nextWeekReview,
    weeklyReviewHistory,
    currentMonthReview,
    nextMonthReview,
    monthlyReviewHistory,
    dailyPlans,
    blocks,
    allTimeBlocks,
    tasks,
    allTasks,
    calendarConnectionState,
    scheduleConstraints: effectiveConstraints,
    weekScheduleConstraints,
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
    currentWeekReview: snapshot.currentWeekReview,
    nextWeekReview: snapshot.nextWeekReview,
    weeklyReviewHistory: snapshot.weeklyReviewHistory,
    currentMonthReview: snapshot.currentMonthReview,
    nextMonthReview: snapshot.nextMonthReview,
    monthlyReviewHistory: snapshot.monthlyReviewHistory,
    schedule: snapshot.schedule,
    today: snapshot.today,
    timeBlocksForSelectedDate: snapshot.blocks,
    tasksForSelectedDate: snapshot.tasks,
    calendarConnectionState: snapshot.calendarConnectionState,
    scheduleConstraints: snapshot.scheduleConstraints,
    notificationPermissionStatus,
  };
}

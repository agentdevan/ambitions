import { create } from "zustand";

import { initializeAppServices, appServices } from "../bootstrap/runtime/appServices";
import { markStartupReady, resetStartupReady } from "../bootstrap/runtime/startupBarrier";
import { sqliteClient } from "../data/sqlite/client";
import { SchedulingOutput } from "../engines";
import {
  AdaptationProfile,
  Ambition,
  AmbitionStatus,
  ActivityEvent,
  AccountIdentity,
  AccountSnapshot,
  AuthStateSnapshot,
  CalendarConnectionState,
  DailyPlan,
  DailyRitualCarryDecision,
  DailyRitualCarryDecisionSummary,
  DailyRitualClarityRating,
  DailyRitualDayLoadRating,
  DailyRitualEnergyRating,
  DailyRitualOpeningFocus,
  DailyRitualRecoveryMode,
  DailyRitualRecoveryMoment,
  DailyRitualState,
  Domain,
  EntitySyncState,
  Goal,
  GoalMilestone,
  GoalStatus,
  LocalAttachmentState,
  MonthlyCarryoverStance,
  MonthlyEmphasis,
  MonthlyPosture,
  MonthlyPressureLevel,
  MonthlyReviewState,
  NotificationPreference,
  ReplanSuggestion,
  ScheduleConstraint,
  SyncConflictRecord,
  SyncOperationKind,
  SyncStateSnapshot,
  Task,
  TaskActionType,
  TaskSchedulingState,
  TaskStatus,
  TimeBlock,
  DailyPlanStatus,
  UserPreferences,
  WeeklyCarryoverPosture,
  WeeklyEmphasis,
  WeeklyIntensity,
  WeeklyReviewState,
} from "../domain/models";
import { createGoalAndFirstPlan } from "../product/planOrchestrator";
import { getProductPreferences, mergeProductPreferences } from "../product/preferences";
import { ProductPreferences, GoalDraftInference } from "../product/types";
import { applyDownstreamHandling } from "../services/goals/downstreamHandlingPolicies";
import { evaluateGoalEditImpact } from "../services/goals/goalEditImpactEvaluator";
import { AuthActionResult } from "../services/account/AccountService";
import {
  GoalDownstreamChoice,
  GoalEditImpactPreview,
  GoalLifecycleHandling,
  getGoalReviewDraft,
  getGoalRollbackSnapshot,
  GoalReviewMode,
  setGoalReviewDraft,
  setGoalRollbackSnapshot,
} from "../services/goals/metadata";
import {
  hasUndoAvailable,
  materializeAcceptedReview,
  prepareGoalReview,
  restoreRollbackSnapshot,
} from "../services/goals/regenerationCoordinator";
import { addDays, endOfWeek, getCurrentLocalDateString, startOfWeek } from "../utils/date";
import {
  buildGoalStatusActivityEvent,
  buildGoalUpdatedActivityEvent,
  buildCarryoverReviewedActivityEvent,
  buildDayClosedActivityEvent,
  buildDayOpenedActivityEvent,
  buildDayRecoveredActivityEvent,
  buildMonthReviewedActivityEvent,
  buildMonthlyCoverageReviewedActivityEvent,
  buildMonthlyRecommitmentUpdatedActivityEvent,
  buildNextWeekShapedActivityEvent,
  buildNextMonthShapedActivityEvent,
  buildPlanReviewAcceptedActivityEvents,
  buildPlanReviewGeneratedActivityEvent,
  buildPlanReviewRevertedActivityEvent,
  buildReflectionLoggedActivityEvent,
  buildTaskActionActivityEvent,
  buildWeekReviewedActivityEvent,
  buildWeeklyCarryoverReviewedActivityEvent,
} from "../services/history/activity";
import { buildActivityFeed } from "../services/history/selectors";
import { buildMonthlyReviewDigest } from "../services/history/monthly";
import { buildWeeklyReviewDigest } from "../services/history/weekly";
import { TodayViewModel } from "./viewModels/today";
import { initialPlanDate, refreshAllState } from "./runtime";
import { addMonths, endOfMonth, startOfMonth } from "../utils/date";

type LoadStatus = "idle" | "loading" | "ready" | "error";

interface AppShellSlice {
  bootstrapped: boolean;
  bootStatus: LoadStatus;
  lastError: string | null;
  bootstrap: () => Promise<void>;
}

interface GoalsSlice {
  domains: Domain[];
  ambitions: Ambition[];
  goals: Goal[];
  milestones: GoalMilestone[];
  allTasks: Task[];
  refreshGoals: () => Promise<void>;
  createAmbition: (input: {
    title: string;
    thesis?: string | null;
    status?: AmbitionStatus;
  }) => Promise<Ambition>;
  updateAmbition: (ambitionId: string, patch: Partial<Ambition>) => Promise<Ambition>;
  createGoal: (inference: GoalDraftInference) => Promise<void>;
  previewGoalEdit: (goalId: string, patch: Partial<Goal>) => Promise<GoalEditImpactPreview>;
  applyGoalEditDecision: (
    goalId: string,
    patch: Partial<Goal>,
    choice: GoalDownstreamChoice,
  ) => Promise<void>;
  updateGoal: (goalId: string, patch: Partial<Goal>) => Promise<void>;
  setGoalStatus: (goalId: string, status: GoalStatus) => Promise<void>;
  setGoalStatusWithHandling: (
    goalId: string,
    status: GoalStatus,
    handling: GoalLifecycleHandling,
  ) => Promise<void>;
  deleteGoals: (goalIds: string[]) => Promise<void>;
  acceptGoalReview: (goalId: string) => Promise<void>;
  regenerateGoalReview: (goalId: string, mode?: GoalReviewMode) => Promise<void>;
  moveReviewTask: (goalId: string, taskId: string, direction: "up" | "down") => Promise<void>;
  removeReviewTask: (goalId: string, taskId: string) => Promise<void>;
  adjustReviewTask: (
    goalId: string,
    taskId: string,
    patch: Partial<Pick<Task, "estimatedMinutes" | "targetDate">>,
  ) => Promise<void>;
  undoGoalRegeneration: (goalId: string) => Promise<void>;
}

interface PlanningSlice {
  planDate: string;
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
  schedule: SchedulingOutput | null;
  today: TodayViewModel | null;
  activityEvents: ActivityEvent[];
  allTimeBlocks: TimeBlock[];
  timeBlocksForSelectedDate: TimeBlock[];
  tasksForSelectedDate: Task[];
  weekScheduleConstraints: ScheduleConstraint[];
  refreshPlanning: (date?: string) => Promise<void>;
  reviewWeek: (input: { note?: string | null }) => Promise<void>;
  reviewWeeklyCarryover: (input: {
    carryTaskIds: string[];
    reviewTaskIds: string[];
    releasedTaskIds: string[];
  }) => Promise<void>;
  shapeNextWeek: (input: {
    intensity: WeeklyIntensity;
    emphasis: WeeklyEmphasis;
    carryoverPosture: WeeklyCarryoverPosture;
    note?: string | null;
  }) => Promise<void>;
  reviewMonth: (input: {
    reviewNote?: string | null;
    recommitGoalIds: string[];
    reduceGoalIds: string[];
    pauseGoalIds: string[];
  }) => Promise<void>;
  shapeNextMonth: (input: {
    posture: MonthlyPosture;
    emphasis: MonthlyEmphasis;
    pressureLevel: MonthlyPressureLevel;
    carryoverStance: MonthlyCarryoverStance;
    note?: string | null;
  }) => Promise<void>;
  openDay: (focus?: DailyRitualOpeningFocus | null) => Promise<void>;
  recoverDay: (mode: DailyRitualRecoveryMode) => Promise<void>;
  closeDay: (input: {
    dayLoadRating: DailyRitualDayLoadRating | null;
    energyRating: DailyRitualEnergyRating | null;
    clarityRating: DailyRitualClarityRating | null;
    reflectionNote: string | null;
    carryDecision: DailyRitualCarryDecision;
  }) => Promise<void>;
  applyTaskAction: (taskId: string, action: TaskActionType) => Promise<void>;
}

interface PreferencesSlice {
  userPreferences: UserPreferences | null;
  productPreferences: ProductPreferences | null;
  notificationPreferences: NotificationPreference[];
  refreshPreferences: () => Promise<void>;
  saveProductPreferences: (productPreferences: ProductPreferences) => Promise<void>;
  updateNotificationPreference: (
    reminderType: NotificationPreference["reminderType"],
    patch: Partial<
      Pick<
        NotificationPreference,
        "enabled" | "leadTimeMinutes" | "quietHoursStart" | "quietHoursEnd"
      >
    >,
  ) => Promise<void>;
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

interface ProductSlice {
  onboardingBusy: boolean;
  createFirstPlan: (params: {
    inference: GoalDraftInference;
    productPreferences: ProductPreferences;
  }) => Promise<void>;
}

interface AccountSlice {
  account: AccountIdentity | null;
  authState: AuthStateSnapshot | null;
  attachmentState: LocalAttachmentState | null;
  syncState: SyncStateSnapshot | null;
  syncConflicts: SyncConflictRecord[];
  refreshAccountState: () => Promise<void>;
  createAccount: (input: {
    email: string;
    password: string;
    displayName?: string;
  }) => Promise<AuthActionResult>;
  signIn: (input: { email: string; password: string }) => Promise<AuthActionResult>;
  clearAuthFeedback: () => Promise<void>;
  signOut: () => Promise<void>;
  deleteAccount: (input: { password: string }) => Promise<void>;
  attachLocalDataToAccount: () => Promise<void>;
  deferLocalDataAttachment: () => Promise<void>;
  syncAccountData: (kind?: SyncOperationKind) => Promise<void>;
}

type AppState = AppShellSlice &
  GoalsSlice &
  PlanningSlice &
  PreferencesSlice &
  AdaptationSlice &
  IntegrationSlice &
  ProductSlice &
  AccountSlice;

function mapAccountSnapshot(snapshot: AccountSnapshot) {
  return {
    account: snapshot.account,
    authState: snapshot.auth,
    attachmentState: snapshot.attachment,
    syncState: snapshot.sync,
    syncConflicts: snapshot.conflicts,
  };
}

function bindRecordToAccount<
  T extends { id: string; ownerUserId: string | null; remoteId: string | null; syncState: string },
>(
  record: T,
  accountId: string | null,
) {
  if (!accountId) {
    return record;
  }

  return {
    ...record,
    ownerUserId: accountId,
    remoteId: record.remoteId,
    syncState: "pending_sync" as const,
  };
}

function bindRecordsToAccount<
  T extends { id: string; ownerUserId: string | null; remoteId: string | null; syncState: string },
>(records: T[], accountId: string | null) {
  return records.map((record) => bindRecordToAccount(record, accountId));
}

function getAttachedAccountId(state: Pick<AppState, "attachmentState" | "authState">) {
  return state.attachmentState?.status === "attached"
    ? state.authState?.signedInAccountId ?? null
    : null;
}

function getEffectiveAdaptationProfile(
  state: Pick<AppState, "adaptationProfile" | "productPreferences">,
) {
  return state.productPreferences?.adaptivePlanningEnabled === false
    ? null
    : state.adaptationProfile;
}

function createAmbitionRecord(params: {
  title: string;
  thesis?: string | null;
  status?: AmbitionStatus;
  sortOrder: number;
  accountId: string | null;
}): Ambition {
  const now = new Date().toISOString();

  return {
    id: `ambition:${Math.random().toString(36).slice(2, 10)}`,
    title: params.title.trim(),
    thesis: params.thesis?.trim() ? params.thesis.trim() : null,
    status: params.status ?? AmbitionStatus.Active,
    sortOrder: params.sortOrder,
    isVisible: true,
    metadata: {},
    ownerUserId: params.accountId,
    remoteId: null,
    syncState: params.accountId ? EntitySyncState.PendingSync : EntitySyncState.LocalOnly,
    version: 1,
    lastSyncedAt: null,
    createdAt: now,
    updatedAt: now,
  };
}

function createDailyRitualState(params: {
  date: string;
  accountId: string | null;
  existing?: DailyRitualState | null;
}): DailyRitualState {
  const now = new Date().toISOString();
  const existing = params.existing;

  return {
    id: existing?.id ?? `ritual:${params.date}`,
    date: params.date,
    openedAt: existing?.openedAt ?? null,
    openingFocus: existing?.openingFocus ?? null,
    recoveryMoments: existing?.recoveryMoments ?? [],
    closedAt: existing?.closedAt ?? null,
    dayLoadRating: existing?.dayLoadRating ?? null,
    energyRating: existing?.energyRating ?? null,
    clarityRating: existing?.clarityRating ?? null,
    reflectionNote: existing?.reflectionNote ?? null,
    carryDecisionSummary: existing?.carryDecisionSummary ?? null,
    metadata: existing?.metadata ?? {},
    ownerUserId: existing?.ownerUserId ?? params.accountId,
    remoteId: existing?.remoteId ?? null,
    syncState:
      existing?.syncState ??
      (params.accountId ? EntitySyncState.PendingSync : EntitySyncState.LocalOnly),
    version: existing?.version ?? 1,
    lastSyncedAt: existing?.lastSyncedAt ?? null,
    createdAt: existing?.createdAt ?? now,
    updatedAt: now,
  };
}

function bindRitualStateToAccount(state: DailyRitualState, accountId: string | null): DailyRitualState {
  if (!accountId) {
    return state;
  }

  return {
    ...state,
    ownerUserId: accountId,
    syncState: EntitySyncState.PendingSync,
  };
}

function createWeeklyReviewState(params: {
  weekStartDate: string;
  weekEndDate: string;
  accountId: string | null;
  existing?: WeeklyReviewState | null;
}): WeeklyReviewState {
  const now = new Date().toISOString();
  const existing = params.existing;

  return {
    id: existing?.id ?? `weekly-review:${params.weekStartDate}`,
    weekStartDate: params.weekStartDate,
    weekEndDate: params.weekEndDate,
    reviewedAt: existing?.reviewedAt ?? null,
    nextWeekShapedAt: existing?.nextWeekShapedAt ?? null,
    weeklyEmphasis: existing?.weeklyEmphasis ?? null,
    targetWeekIntensity: existing?.targetWeekIntensity ?? null,
    carryoverPosture: existing?.carryoverPosture ?? null,
    note: existing?.note ?? null,
    carryoverTaskIds: existing?.carryoverTaskIds ?? [],
    reviewTaskIds: existing?.reviewTaskIds ?? [],
    releasedTaskIds: existing?.releasedTaskIds ?? [],
    summary: existing?.summary ?? null,
    metadata: existing?.metadata ?? {},
    ownerUserId: existing?.ownerUserId ?? params.accountId,
    remoteId: existing?.remoteId ?? null,
    syncState:
      existing?.syncState ??
      (params.accountId ? EntitySyncState.PendingSync : EntitySyncState.LocalOnly),
    version: existing?.version ?? 1,
    lastSyncedAt: existing?.lastSyncedAt ?? null,
    createdAt: existing?.createdAt ?? now,
    updatedAt: now,
  };
}

function bindWeeklyReviewToAccount(
  state: WeeklyReviewState,
  accountId: string | null,
): WeeklyReviewState {
  if (!accountId) {
    return state;
  }

  return {
    ...state,
    ownerUserId: accountId,
    syncState: EntitySyncState.PendingSync,
  };
}

function createMonthlyReviewState(params: {
  monthStartDate: string;
  monthEndDate: string;
  accountId: string | null;
  existing?: MonthlyReviewState | null;
}): MonthlyReviewState {
  const now = new Date().toISOString();
  const existing = params.existing;

  return {
    id: existing?.id ?? `monthly-review:${params.monthStartDate}`,
    monthStartDate: params.monthStartDate,
    monthEndDate: params.monthEndDate,
    reviewedAt: existing?.reviewedAt ?? null,
    strategySetAt: existing?.strategySetAt ?? null,
    monthPosture: existing?.monthPosture ?? null,
    monthlyEmphasis: existing?.monthlyEmphasis ?? null,
    pressureLevel: existing?.pressureLevel ?? null,
    carryoverStance: existing?.carryoverStance ?? null,
    reviewNote: existing?.reviewNote ?? null,
    strategyNote: existing?.strategyNote ?? null,
    recommitGoalIds: existing?.recommitGoalIds ?? [],
    reduceGoalIds: existing?.reduceGoalIds ?? [],
    pauseGoalIds: existing?.pauseGoalIds ?? [],
    goalCoverage: existing?.goalCoverage ?? [],
    summary: existing?.summary ?? null,
    metadata: existing?.metadata ?? {},
    ownerUserId: existing?.ownerUserId ?? params.accountId,
    remoteId: existing?.remoteId ?? null,
    syncState:
      existing?.syncState ??
      (params.accountId ? EntitySyncState.PendingSync : EntitySyncState.LocalOnly),
    version: existing?.version ?? 1,
    lastSyncedAt: existing?.lastSyncedAt ?? null,
    createdAt: existing?.createdAt ?? now,
    updatedAt: now,
  };
}

function bindMonthlyReviewToAccount(
  state: MonthlyReviewState,
  accountId: string | null,
): MonthlyReviewState {
  if (!accountId) {
    return state;
  }

  return {
    ...state,
    ownerUserId: accountId,
    syncState: EntitySyncState.PendingSync,
  };
}

function summarizeRecoveryMode(mode: DailyRitualRecoveryMode, changedTaskCount: number) {
  if (mode === DailyRitualRecoveryMode.SalvageEssentials) {
    return `Held the day to the few pieces that still mattered, moving ${changedTaskCount} tasks out of today's shape.`;
  }

  if (mode === DailyRitualRecoveryMode.LightenRest) {
    return `Reduced the rest of the day so pressure dropped and only the clearest work remained.`;
  }

  return `Rebalanced the remaining day around what could still fit cleanly.`;
}

let accountSnapshotUnsubscribe: (() => void) | null = null;
let accountDrivenRefreshPromise: Promise<void> | null = null;

function shouldRefreshFoundationForAccountChange(
  state: Pick<AppState, "bootstrapped" | "account" | "attachmentState" | "syncState" | "syncConflicts">,
  snapshot: AccountSnapshot,
) {
  if (!state.bootstrapped) {
    return false;
  }

  return (
    state.account?.id !== snapshot.account?.id ||
    state.attachmentState?.status !== snapshot.attachment.status ||
    state.syncState?.mode !== snapshot.sync.mode ||
    state.syncState?.lastSyncAt !== snapshot.sync.lastSyncAt ||
    state.syncConflicts.length !== snapshot.conflicts.length
  );
}

function queueFoundationRefreshFromAccountSnapshot() {
  if (!accountDrivenRefreshPromise) {
    accountDrivenRefreshPromise = (async () => {
      const currentState = useAppStore.getState();
      const [foundationSnapshot, accountSnapshot] = await Promise.all([
        refreshAllState(currentState.planDate),
        appServices.services.account.getSnapshot(),
      ]);

      useAppStore.setState({
        ...foundationSnapshot,
        ...mapAccountSnapshot(accountSnapshot),
      });
    })().finally(() => {
      accountDrivenRefreshPromise = null;
    });
  }

  return accountDrivenRefreshPromise;
}

export const useAppStore = create<AppState>((set, get) => ({
  bootstrapped: false,
  bootStatus: "idle",
  lastError: null,
  domains: [],
  ambitions: [],
  goals: [],
  milestones: [],
  allTasks: [],
  planDate: initialPlanDate,
  dailyPlan: null,
  dailyRitual: null,
  dailyRitualHistory: [],
  currentWeekReview: null,
  nextWeekReview: null,
  weeklyReviewHistory: [],
  currentMonthReview: null,
  nextMonthReview: null,
  monthlyReviewHistory: [],
  dailyPlans: [],
  schedule: null,
  today: null,
  activityEvents: [],
  allTimeBlocks: [],
  tasksForSelectedDate: [],
  timeBlocksForSelectedDate: [],
  userPreferences: null,
  productPreferences: null,
  notificationPreferences: [],
  adaptationProfile: null,
  replanSuggestions: [],
  calendarConnectionState: null,
  scheduleConstraints: [],
  weekScheduleConstraints: [],
  notificationPermissionStatus: "undetermined",
  onboardingBusy: false,
  account: null,
  authState: null,
  attachmentState: null,
  syncState: null,
  syncConflicts: [],

  bootstrap: async () => {
    if (get().bootStatus === "loading" || get().bootstrapped) {
      return;
    }

    set({ bootStatus: "loading", lastError: null });

    try {
      const currentPlanDate = getCurrentLocalDateString();
      await initializeAppServices();
      if (!accountSnapshotUnsubscribe) {
        accountSnapshotUnsubscribe = appServices.services.account.subscribe((snapshot) => {
          const state = get();
          const shouldRefreshFoundation = shouldRefreshFoundationForAccountChange(state, snapshot);

          set(mapAccountSnapshot(snapshot));

          if (shouldRefreshFoundation) {
            void queueFoundationRefreshFromAccountSnapshot().catch(() => null);
          }
        });
      }
      await appServices.services.notifications.configure().catch(() => null);
      const snapshot = await refreshAllState(currentPlanDate);
      const accountSnapshot = await appServices.services.account.getSnapshot();

      set({
        bootstrapped: true,
        bootStatus: "ready",
        ...snapshot,
        ...mapAccountSnapshot(accountSnapshot),
      });
      markStartupReady();

      if (
        accountSnapshot.auth.signedInAccountId &&
        accountSnapshot.attachment.status === "attached"
      ) {
        appServices.services.account
          .runStartupSyncIfNeeded()
          .then(async () => {
            await queueFoundationRefreshFromAccountSnapshot();
          })
          .catch(() => null);
      }
    } catch (error) {
      resetStartupReady();
      set({
        bootStatus: "error",
        lastError: error instanceof Error ? error.message : "Unknown bootstrap failure",
      });
    }
  },

  refreshGoals: async () => {
    const [domains, ambitions, goals, milestones, allTasks] = await Promise.all([
      appServices.repositories.preferences.listDomains(),
      appServices.repositories.goals.listAmbitions(),
      appServices.repositories.goals.listGoals(),
      appServices.repositories.goals.listMilestones(),
      appServices.repositories.tasks.listTasks(),
    ]);

    set({ domains, ambitions, goals, milestones, allTasks });
  },

  createAmbition: async (input) => {
    const state = get();
    const title = input.title.trim();
    if (!title) {
      throw new Error("An ambition needs a title.");
    }

    const accountId = getAttachedAccountId(state);
    const ambition = createAmbitionRecord({
      title,
      thesis: input.thesis,
      status: input.status,
      sortOrder: state.ambitions.length + 1,
      accountId,
    });

    await appServices.repositories.goals.saveAmbitions([...state.ambitions, ambition]);
    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });

    return ambition;
  },

  updateAmbition: async (ambitionId, patch) => {
    const state = get();
    const accountId = getAttachedAccountId(state);
    let updatedAmbition: Ambition | null = null;
    const nextAmbitions = state.ambitions.map((ambition) => {
      if (ambition.id !== ambitionId) {
        return ambition;
      }

      updatedAmbition = bindRecordToAccount(
        {
          ...ambition,
          ...patch,
          title: patch.title?.trim() ? patch.title.trim() : ambition.title,
          thesis:
            patch.thesis === undefined
              ? ambition.thesis
              : patch.thesis?.trim()
                ? patch.thesis.trim()
                : null,
          updatedAt: new Date().toISOString(),
          version: ambition.version + 1,
        },
        accountId,
      ) as Ambition;

      return updatedAmbition;
    });

    if (!updatedAmbition) {
      throw new Error("The ambition could not be found.");
    }

    await appServices.repositories.goals.saveAmbitions(nextAmbitions);
    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });

    return updatedAmbition;
  },

  createGoal: async (inference) => {
    const state = get();
    if (!state.userPreferences || !state.productPreferences) {
      throw new Error("Preferences are not available yet.");
    }

    await createGoalAndFirstPlan({
      inference,
      productPreferences: state.productPreferences,
      currentPreferences: state.userPreferences,
      today: state.planDate,
      adaptationProfile: getEffectiveAdaptationProfile(state),
      accountId: getAttachedAccountId(state),
    });

    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  previewGoalEdit: async (goalId, patch) => {
    const goals = await appServices.repositories.goals.listGoals();
    const goal = goals.find((entry) => entry.id === goalId);
    if (!goal) {
      throw new Error("The goal could not be found.");
    }

    const [milestones, tasks] = await Promise.all([
      appServices.repositories.goals.listMilestones(),
      appServices.repositories.tasks.listTasks(),
    ]);

    return evaluateGoalEditImpact({
      goal,
      patch,
      milestones: milestones.filter((milestone) => milestone.goalId === goalId),
      tasks: tasks.filter((task) => task.goalId === goalId),
    });
  },

  applyGoalEditDecision: async (goalId, patch, choice) => {
    const state = get();
    const goals = await appServices.repositories.goals.listGoals();
    const goal = goals.find((entry) => entry.id === goalId);
    if (!goal) {
      throw new Error("The goal could not be found.");
    }

    const accountId = getAttachedAccountId(state);
    const [milestones, tasks] = await Promise.all([
      appServices.repositories.goals.listMilestones(),
      appServices.repositories.tasks.listTasks(),
    ]);
    const goalMilestones = milestones.filter((milestone) => milestone.goalId === goalId);
    const goalTasks = tasks.filter((task) => task.goalId === goalId);
    const impact = evaluateGoalEditImpact({
      goal,
      patch,
      milestones: goalMilestones,
      tasks: goalTasks,
    });
    const updatedGoalBase = {
      ...goal,
      ...patch,
      updatedAt: new Date().toISOString(),
      version: goal.version + 1,
    };

    let updatedGoal = updatedGoalBase;
    if (choice !== "keep" && state.userPreferences) {
      const reviewDraft = await prepareGoalReview({
        goal: updatedGoalBase,
        mode: choice as GoalReviewMode,
        existingMilestones: goalMilestones,
        existingTasks: goalTasks,
        userPreferences: state.userPreferences,
        adaptationProfile: getEffectiveAdaptationProfile(state),
        impact,
      });
      updatedGoal = setGoalReviewDraft(updatedGoalBase, reviewDraft);
    } else {
      updatedGoal = setGoalRollbackSnapshot(setGoalReviewDraft(updatedGoalBase, null), null);
    }

    await appServices.repositories.goals.saveGoals(
      goals.map((entry) =>
        entry.id === goalId
          ? bindRecordToAccount(updatedGoal, accountId)
          : entry,
      ),
    );
    await appServices.repositories.history.saveActivityEvents(
      bindRecordsToAccount(
        [
          buildGoalUpdatedActivityEvent({
            goal,
            changedFields: impact.changedFields,
            occurredAt: updatedGoal.updatedAt,
            choice,
          }),
        ],
        accountId,
      ),
    );
    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  updateGoal: async (goalId, patch) => {
    const goals = await appServices.repositories.goals.listGoals();
    const accountId = getAttachedAccountId(get());
    const nextGoals = goals.map((goal) =>
      goal.id === goalId
        ? bindRecordToAccount({
            ...goal,
            ...patch,
            updatedAt: new Date().toISOString(),
            version: goal.version + 1,
          }, accountId)
        : goal,
    );

    await appServices.repositories.goals.saveGoals(nextGoals);
    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(get().planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  setGoalStatus: async (goalId, status) => {
    await get().updateGoal(goalId, { status });
  },

  setGoalStatusWithHandling: async (goalId, status, handling) => {
    const state = get();
    const goals = await appServices.repositories.goals.listGoals();
    const [milestones, tasks] = await Promise.all([
      appServices.repositories.goals.listMilestones(),
      appServices.repositories.tasks.listTasks(),
    ]);
    const goal = goals.find((entry) => entry.id === goalId);
    if (!goal) {
      throw new Error("The goal could not be found.");
    }

    const accountId = getAttachedAccountId(state);
    const updatedGoal = bindRecordToAccount(
      setGoalReviewDraft(
        {
          ...goal,
          status,
          updatedAt: new Date().toISOString(),
          version: goal.version + 1,
        },
        null,
      ),
      accountId,
    );

    await appServices.repositories.goals.saveGoals(
      goals.map((entry) => (entry.id === goalId ? updatedGoal : entry)),
    );

    if ([GoalStatus.Paused, GoalStatus.Archived].includes(status)) {
      const goalMilestones = milestones.filter((milestone) => milestone.goalId === goalId);
      const goalTasks = tasks.filter((task) => task.goalId === goalId);
      const next = applyDownstreamHandling({
        action: status === GoalStatus.Paused ? "pause" : "archive",
        handling,
        milestones: goalMilestones,
        tasks: goalTasks,
      });
      await appServices.repositories.goals.saveMilestones(
        bindRecordsToAccount(next.milestones, accountId),
      );
      await appServices.repositories.tasks.saveTasks(bindRecordsToAccount(next.tasks, accountId));
    }

    await appServices.repositories.history.saveActivityEvents(
      bindRecordsToAccount(
        [
          buildGoalStatusActivityEvent({
            goal,
            nextStatus: status,
            occurredAt: updatedGoal.updatedAt,
          }),
        ],
        accountId,
      ),
    );

    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  deleteGoals: async (goalIds) => {
    const uniqueGoalIds = Array.from(new Set(goalIds)).filter(Boolean);
    if (uniqueGoalIds.length === 0) {
      return;
    }

    const state = get();
    const accountId = getAttachedAccountId(state);
    const goalSet = new Set(uniqueGoalIds);
    const milestoneIds = state.milestones
      .filter((milestone) => goalSet.has(milestone.goalId))
      .map((milestone) => milestone.id);
    const taskIds = state.allTasks
      .filter((task) => task.goalId && goalSet.has(task.goalId))
      .map((task) => task.id);
    const timeBlockIds = state.allTimeBlocks
      .filter(
        (block) =>
          goalSet.has(block.goalId ?? "") ||
          (block.taskId ? taskIds.includes(block.taskId) : false),
      )
      .map((block) => block.id);
    const activityEventIds = state.activityEvents
      .filter(
        (event) =>
          goalSet.has(event.goalId ?? "") ||
          (event.milestoneId ? milestoneIds.includes(event.milestoneId) : false) ||
          (event.taskId ? taskIds.includes(event.taskId) : false) ||
          (event.timeBlockId ? timeBlockIds.includes(event.timeBlockId) : false),
      )
      .map((event) => event.id);
    const now = new Date().toISOString();
    const taskIdSet = new Set(taskIds);
    const nextWeeklyReviews = state.weeklyReviewHistory.map((review) => {
      const nextCarryover = review.carryoverTaskIds.filter((taskId) => !taskIdSet.has(taskId));
      const nextReview = review.reviewTaskIds.filter((taskId) => !taskIdSet.has(taskId));
      const nextReleased = review.releasedTaskIds.filter((taskId) => !taskIdSet.has(taskId));
      const changed =
        nextCarryover.length !== review.carryoverTaskIds.length ||
        nextReview.length !== review.reviewTaskIds.length ||
        nextReleased.length !== review.releasedTaskIds.length;

      if (!changed) {
        return review;
      }

      return bindRecordToAccount(
        {
          ...review,
          carryoverTaskIds: nextCarryover,
          reviewTaskIds: nextReview,
          releasedTaskIds: nextReleased,
          updatedAt: now,
          version: review.version + 1,
        },
        accountId,
      );
    });
    const nextMonthlyReviews = state.monthlyReviewHistory.map((review) => {
      const nextRecommit = review.recommitGoalIds.filter((goalId) => !goalSet.has(goalId));
      const nextReduce = review.reduceGoalIds.filter((goalId) => !goalSet.has(goalId));
      const nextPause = review.pauseGoalIds.filter((goalId) => !goalSet.has(goalId));
      const nextCoverage = review.goalCoverage.filter((coverage) => !goalSet.has(coverage.goalId));
      const changed =
        nextRecommit.length !== review.recommitGoalIds.length ||
        nextReduce.length !== review.reduceGoalIds.length ||
        nextPause.length !== review.pauseGoalIds.length ||
        nextCoverage.length !== review.goalCoverage.length;

      if (!changed) {
        return review;
      }

      return bindRecordToAccount(
        {
          ...review,
          recommitGoalIds: nextRecommit,
          reduceGoalIds: nextReduce,
          pauseGoalIds: nextPause,
          goalCoverage: nextCoverage,
          updatedAt: now,
          version: review.version + 1,
        },
        accountId,
      );
    });

    await sqliteClient.withTransaction(async (client) => {
      if (taskIds.length > 0) {
        const taskPlaceholders = taskIds.map(() => "?").join(", ");
        await client.run(
          `DELETE FROM time_blocks WHERE task_id IN (${taskPlaceholders});`,
          taskIds,
        );
        await client.run(
          `DELETE FROM replan_suggestions WHERE task_id IN (${taskPlaceholders});`,
          taskIds,
        );
      }

      if (timeBlockIds.length > 0) {
        const timeBlockPlaceholders = timeBlockIds.map(() => "?").join(", ");
        await client.run(
          `DELETE FROM activity_events WHERE time_block_id IN (${timeBlockPlaceholders});`,
          timeBlockIds,
        );
        await client.run(
          `DELETE FROM replan_suggestions WHERE time_block_id IN (${timeBlockPlaceholders});`,
          timeBlockIds,
        );
        await client.run(
          `DELETE FROM time_blocks WHERE id IN (${timeBlockPlaceholders});`,
          timeBlockIds,
        );
      }

      if (milestoneIds.length > 0) {
        const milestonePlaceholders = milestoneIds.map(() => "?").join(", ");
        await client.run(
          `DELETE FROM activity_events WHERE milestone_id IN (${milestonePlaceholders});`,
          milestoneIds,
        );
      }

      if (taskIds.length > 0) {
        const taskPlaceholders = taskIds.map(() => "?").join(", ");
        await client.run(
          `DELETE FROM activity_events WHERE task_id IN (${taskPlaceholders});`,
          taskIds,
        );
        await client.run(`DELETE FROM tasks WHERE id IN (${taskPlaceholders});`, taskIds);
      }

      if (milestoneIds.length > 0) {
        const milestonePlaceholders = milestoneIds.map(() => "?").join(", ");
        await client.run(
          `DELETE FROM goal_milestones WHERE id IN (${milestonePlaceholders});`,
          milestoneIds,
        );
      }

      const goalPlaceholders = uniqueGoalIds.map(() => "?").join(", ");
      await client.run(
        `DELETE FROM activity_events WHERE goal_id IN (${goalPlaceholders});`,
        uniqueGoalIds,
      );
      await client.run(`DELETE FROM goals WHERE id IN (${goalPlaceholders});`, uniqueGoalIds);
    });

    const nextAmbitions = state.ambitions.map((ambition) => {
      const remainingGoals = state.goals.filter(
        (goal) => goal.ambitionId === ambition.id && !goalSet.has(goal.id),
      );
      if (remainingGoals.length > 0) {
        return ambition;
      }

      return {
        ...ambition,
        updatedAt: new Date().toISOString(),
        version: ambition.version + 1,
      };
    });

    const deletedEntityIds = [
      ...uniqueGoalIds,
      ...milestoneIds,
      ...taskIds,
      ...timeBlockIds,
      ...activityEventIds,
    ];

    await Promise.all([
      appServices.repositories.goals.saveAmbitions(nextAmbitions),
      appServices.repositories.planning.saveWeeklyReviewStates(nextWeeklyReviews),
      appServices.repositories.planning.saveMonthlyReviewStates(nextMonthlyReviews),
      appServices.services.account.deleteSyncedEntities(deletedEntityIds),
    ]);

    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  acceptGoalReview: async (goalId) => {
    const state = get();
    const goals = await appServices.repositories.goals.listGoals();
    const goal = goals.find((entry) => entry.id === goalId);
    if (!goal) {
      throw new Error("The goal could not be found.");
    }

    const reviewDraft = getGoalReviewDraft(goal);
    if (!reviewDraft) {
      throw new Error("There is no pending review for this goal.");
    }

    const [milestones, tasks] = await Promise.all([
      appServices.repositories.goals.listMilestones(),
      appServices.repositories.tasks.listTasks(),
    ]);
    const goalMilestones = milestones.filter((milestone) => milestone.goalId === goalId);
    const goalTasks = tasks.filter((task) => task.goalId === goalId);
    const next = materializeAcceptedReview({
      goal,
      reviewDraft,
      existingMilestones: goalMilestones,
      existingTasks: goalTasks,
    });
    const accountId = getAttachedAccountId(state);
    const nextGoal =
      reviewDraft.mode === "new_goal"
        ? setGoalReviewDraft(goal, null)
        : setGoalRollbackSnapshot(setGoalReviewDraft(goal, null), next.rollbackSnapshot);
    const acceptedAt = new Date().toISOString();
    const nextTasks = next.tasksToSave.filter((task) => task.goalId === goalId);
    const nextMilestones = next.milestonesToSave.filter((milestone) => milestone.goalId === goalId);
    const historyEvents = buildPlanReviewAcceptedActivityEvents({
      goal,
      reviewDraft,
      existingTasks: goalTasks,
      nextTasks,
      existingMilestones: goalMilestones,
      nextMilestones,
      occurredAt: acceptedAt,
    });

    await Promise.all([
      appServices.repositories.goals.saveGoals(
        goals.map((entry) =>
          entry.id === goalId ? bindRecordToAccount(nextGoal, accountId) : entry,
        ),
      ),
      appServices.repositories.goals.saveMilestones(
        bindRecordsToAccount(next.milestonesToSave, accountId),
      ),
      appServices.repositories.tasks.saveTasks(bindRecordsToAccount(next.tasksToSave, accountId)),
      appServices.repositories.history.saveActivityEvents(
        bindRecordsToAccount(historyEvents, accountId),
      ),
    ]);

    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  regenerateGoalReview: async (goalId, mode) => {
    const state = get();
    if (!state.userPreferences) {
      throw new Error("User preferences are unavailable.");
    }

    const goals = await appServices.repositories.goals.listGoals();
    const goal = goals.find((entry) => entry.id === goalId);
    if (!goal) {
      throw new Error("The goal could not be found.");
    }

    const currentDraft = getGoalReviewDraft(goal);
    const [milestones, tasks] = await Promise.all([
      appServices.repositories.goals.listMilestones(),
      appServices.repositories.tasks.listTasks(),
    ]);
    const nextDraft = await prepareGoalReview({
      goal,
      mode: mode ?? currentDraft?.mode ?? "targeted_regeneration",
      existingMilestones: milestones.filter((milestone) => milestone.goalId === goalId),
        existingTasks: tasks.filter((task) => task.goalId === goalId),
        userPreferences: state.userPreferences,
        adaptationProfile: getEffectiveAdaptationProfile(state),
        impact: null,
      });
    const accountId = getAttachedAccountId(state);
    const occurredAt = new Date().toISOString();
    await appServices.repositories.goals.saveGoals(
      goals.map((entry) =>
        entry.id === goalId
          ? bindRecordToAccount(setGoalReviewDraft(goal, nextDraft), accountId)
          : entry,
      ),
    );
    await appServices.repositories.history.saveActivityEvents(
      bindRecordsToAccount(
        [
          buildPlanReviewGeneratedActivityEvent({
            goal,
            reviewDraft: nextDraft,
            occurredAt,
          }),
        ],
        accountId,
      ),
    );
    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  moveReviewTask: async (goalId, taskId, direction) => {
    const goals = await appServices.repositories.goals.listGoals();
    const goal = goals.find((entry) => entry.id === goalId);
    if (!goal) {
      throw new Error("The goal could not be found.");
    }

    const draft = getGoalReviewDraft(goal);
    if (!draft) {
      throw new Error("There is no pending review for this goal.");
    }

    const visibleTasks = draft.tasks.filter((task) => !task.removed);
    const index = visibleTasks.findIndex((task) => task.id === taskId);
    if (index < 0) {
      return;
    }

    const swapIndex = direction === "up" ? index - 1 : index + 1;
    if (swapIndex < 0 || swapIndex >= visibleTasks.length) {
      return;
    }

    const source = visibleTasks[index];
    const target = visibleTasks[swapIndex];
    const nextTasks = draft.tasks.map((task) => {
      if (task.id === source.id) {
        return { ...task, order: target.order, userAdjusted: true };
      }
      if (task.id === target.id) {
        return { ...task, order: source.order, userAdjusted: true };
      }
      return task;
    });
    nextTasks.sort((left, right) => left.order - right.order);

    await get().updateGoal(goalId, {
      metadata: {
        ...setGoalReviewDraft(goal, { ...draft, tasks: nextTasks }).metadata,
      },
    });
  },

  removeReviewTask: async (goalId, taskId) => {
    const goals = await appServices.repositories.goals.listGoals();
    const goal = goals.find((entry) => entry.id === goalId);
    if (!goal) {
      throw new Error("The goal could not be found.");
    }

    const draft = getGoalReviewDraft(goal);
    if (!draft) {
      throw new Error("There is no pending review for this goal.");
    }

    const nextDraft = {
      ...draft,
      tasks: draft.tasks.map((task) =>
        task.id === taskId ? { ...task, removed: true, userAdjusted: true } : task,
      ),
    };
    await get().updateGoal(goalId, {
      metadata: {
        ...setGoalReviewDraft(goal, nextDraft).metadata,
      },
    });
  },

  adjustReviewTask: async (goalId, taskId, patch) => {
    const goals = await appServices.repositories.goals.listGoals();
    const goal = goals.find((entry) => entry.id === goalId);
    if (!goal) {
      throw new Error("The goal could not be found.");
    }

    const draft = getGoalReviewDraft(goal);
    if (!draft) {
      throw new Error("There is no pending review for this goal.");
    }

    const nextDraft = {
      ...draft,
      tasks: draft.tasks.map((task) =>
        task.id === taskId
          ? {
              ...task,
              estimatedMinutes: patch.estimatedMinutes ?? task.estimatedMinutes,
              targetDate: patch.targetDate ?? task.targetDate,
              userAdjusted: true,
            }
          : task,
      ),
    };
    await get().updateGoal(goalId, {
      metadata: {
        ...setGoalReviewDraft(goal, nextDraft).metadata,
      },
    });
  },

  undoGoalRegeneration: async (goalId) => {
    const state = get();
    const goals = await appServices.repositories.goals.listGoals();
    const goal = goals.find((entry) => entry.id === goalId);
    if (!goal) {
      throw new Error("The goal could not be found.");
    }

    const rollbackSnapshot = getGoalRollbackSnapshot(goal);
    if (!rollbackSnapshot || !hasUndoAvailable(goal)) {
      throw new Error("The temporary rollback window has expired.");
    }

    const [milestones, tasks] = await Promise.all([
      appServices.repositories.goals.listMilestones(),
      appServices.repositories.tasks.listTasks(),
    ]);
    const next = restoreRollbackSnapshot({
      rollbackSnapshot,
      existingMilestones: milestones.filter((milestone) => milestone.goalId === goalId),
      existingTasks: tasks.filter((task) => task.goalId === goalId),
    });
    const accountId = getAttachedAccountId(state);

    await Promise.all([
      appServices.repositories.goals.saveGoals(
        goals.map((entry) =>
          entry.id === goalId
            ? bindRecordToAccount(setGoalRollbackSnapshot(goal, null), accountId)
            : entry,
        ),
      ),
      appServices.repositories.goals.saveMilestones(
        bindRecordsToAccount(next.milestonesToSave, accountId),
      ),
      appServices.repositories.tasks.saveTasks(bindRecordsToAccount(next.tasksToSave, accountId)),
      appServices.repositories.history.saveActivityEvents(
        bindRecordsToAccount(
          [
            buildPlanReviewRevertedActivityEvent({
              goal,
              occurredAt: new Date().toISOString(),
            }),
          ],
          accountId,
        ),
      ),
    ]);

    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  refreshPlanning: async (date) => {
    const planDate = date ?? get().planDate;
    set(await refreshAllState(planDate));
  },

  reviewWeek: async (input) => {
    const state = get();
    const accountId = getAttachedAccountId(state);
    const weekStartsOn = state.userPreferences?.weekStartsOn ?? 1;
    const weekStartDate = startOfWeek(state.planDate, weekStartsOn);
    const weekEndDate = endOfWeek(state.planDate, weekStartsOn);
    const existing = await appServices.repositories.planning.getWeeklyReviewState(weekStartDate);
    const digest = buildWeeklyReviewDigest({
      date: state.planDate,
      weekStartsOn,
      tasks: state.allTasks,
      rituals: state.dailyRitualHistory,
      events: buildActivityFeed(state.activityEvents, state.allTasks, state.milestones),
    });
    const now = new Date().toISOString();
    const nextState = bindWeeklyReviewToAccount(
      {
        ...createWeeklyReviewState({
          weekStartDate,
          weekEndDate,
          accountId,
          existing,
        }),
        reviewedAt: now,
        note: input.note?.trim() ? input.note.trim() : existing?.note ?? null,
        summary: digest.summary,
        metadata: {
          ...(existing?.metadata ?? {}),
          reads: digest.reads,
          unfinishedCount: digest.unfinishedTasks.length,
          carryCandidateCount: digest.carryCandidateTasks.length,
        },
        updatedAt: now,
        version: existing ? existing.version + 1 : 1,
      },
      accountId,
    );

    await Promise.all([
      appServices.repositories.planning.saveWeeklyReviewStates([nextState]),
      appServices.repositories.history.saveActivityEvents(
        bindRecordsToAccount(
          [
            buildWeekReviewedActivityEvent({
              weekStartDate,
              weekEndDate,
              occurredAt: now,
              completedCount: digest.summary.completedCount,
              reshapedCount: digest.summary.reshapedCount,
              heldSteady: digest.summary.heldSteady,
            }),
          ],
          accountId,
        ),
      ),
    ]);

    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  reviewWeeklyCarryover: async (input) => {
    const state = get();
    const accountId = getAttachedAccountId(state);
    const weekStartsOn = state.userPreferences?.weekStartsOn ?? 1;
    const weekStartDate = startOfWeek(state.planDate, weekStartsOn);
    const weekEndDate = endOfWeek(state.planDate, weekStartsOn);
    const nextWeekDate = addDays(weekEndDate, 1);
    const now = new Date().toISOString();
    const existing = await appServices.repositories.planning.getWeeklyReviewState(weekStartDate);
    const digest = buildWeeklyReviewDigest({
      date: state.planDate,
      weekStartsOn,
      tasks: state.allTasks,
      rituals: state.dailyRitualHistory,
      events: buildActivityFeed(state.activityEvents, state.allTasks, state.milestones),
    });
    const carryIds = new Set(input.carryTaskIds);
    const reviewIds = new Set(input.reviewTaskIds);
    const releasedIds = new Set(input.releasedTaskIds);
    const tasksToUpdate = state.allTasks
      .filter((task) => carryIds.has(task.id) || reviewIds.has(task.id) || releasedIds.has(task.id))
      .map((task) => {
        if (carryIds.has(task.id)) {
          return bindRecordToAccount(
            {
              ...task,
              status: TaskStatus.Deferred,
              schedulingState: TaskSchedulingState.Rolled,
              targetDate: nextWeekDate,
              scheduledDate: nextWeekDate,
              metadata: {
                ...task.metadata,
                weeklyCarryoverReviewedAt: now,
                weeklyCarryoverWeekStart: weekStartDate,
              },
              updatedAt: now,
              version: task.version + 1,
            },
            accountId,
          );
        }

        return bindRecordToAccount(
          {
            ...task,
            status: TaskStatus.Unscheduled,
            schedulingState: TaskSchedulingState.Unscheduled,
            targetDate: null,
            scheduledDate: null,
            metadata: {
              ...task.metadata,
              weeklyCarryoverReviewedAt: now,
              weeklyCarryoverWeekStart: weekStartDate,
              weeklyCarryoverDisposition: reviewIds.has(task.id) ? "review" : "released",
            },
            updatedAt: now,
            version: task.version + 1,
          },
          accountId,
        );
      });

    const nextState = bindWeeklyReviewToAccount(
      {
        ...createWeeklyReviewState({
          weekStartDate,
          weekEndDate,
          accountId,
          existing,
        }),
        reviewedAt: existing?.reviewedAt ?? now,
        carryoverTaskIds: input.carryTaskIds,
        reviewTaskIds: input.reviewTaskIds,
        releasedTaskIds: input.releasedTaskIds,
        summary: digest.summary,
        metadata: {
          ...(existing?.metadata ?? {}),
          carryoverReviewedAt: now,
        },
        updatedAt: now,
        version: existing ? existing.version + 1 : 1,
      },
      accountId,
    );

    await Promise.all([
      tasksToUpdate.length > 0
        ? appServices.repositories.tasks.saveTasks(tasksToUpdate)
        : Promise.resolve(),
      appServices.repositories.planning.saveWeeklyReviewStates([nextState]),
      appServices.repositories.history.saveActivityEvents(
        bindRecordsToAccount(
          [
            buildWeeklyCarryoverReviewedActivityEvent({
              weekStartDate,
              occurredAt: now,
              carryCount: input.carryTaskIds.length,
              reviewCount: input.reviewTaskIds.length,
              releasedCount: input.releasedTaskIds.length,
            }),
          ],
          accountId,
        ),
      ),
    ]);

    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  shapeNextWeek: async (input) => {
    const state = get();
    const accountId = getAttachedAccountId(state);
    const weekStartsOn = state.userPreferences?.weekStartsOn ?? 1;
    const nextWeekStartDate = addDays(startOfWeek(state.planDate, weekStartsOn), 7);
    const nextWeekEndDate = endOfWeek(nextWeekStartDate, weekStartsOn);
    const existing = await appServices.repositories.planning.getWeeklyReviewState(nextWeekStartDate);
    const now = new Date().toISOString();
    const nextState = bindWeeklyReviewToAccount(
      {
        ...createWeeklyReviewState({
          weekStartDate: nextWeekStartDate,
          weekEndDate: nextWeekEndDate,
          accountId,
          existing,
        }),
        nextWeekShapedAt: now,
        targetWeekIntensity: input.intensity,
        weeklyEmphasis: input.emphasis,
        carryoverPosture: input.carryoverPosture,
        note: input.note?.trim() ? input.note.trim() : existing?.note ?? null,
        metadata: {
          ...(existing?.metadata ?? {}),
          shapedFromWeek: startOfWeek(state.planDate, weekStartsOn),
        },
        updatedAt: now,
        version: existing ? existing.version + 1 : 1,
      },
      accountId,
    );

    await Promise.all([
      appServices.repositories.planning.saveWeeklyReviewStates([nextState]),
      appServices.repositories.history.saveActivityEvents(
        bindRecordsToAccount(
          [
            buildNextWeekShapedActivityEvent({
              weekStartDate: nextWeekStartDate,
              occurredAt: now,
              intensity: input.intensity,
              emphasis: input.emphasis,
              carryoverPosture: input.carryoverPosture,
            }),
          ],
          accountId,
        ),
      ),
    ]);

    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  reviewMonth: async (input) => {
    const state = get();
    const accountId = getAttachedAccountId(state);
    const monthStartDate = startOfMonth(state.planDate);
    const monthEndDate = endOfMonth(state.planDate);
    const existing = await appServices.repositories.planning.getMonthlyReviewState(monthStartDate);
    const digest = buildMonthlyReviewDigest({
      date: state.planDate,
      goals: state.goals,
      tasks: state.allTasks,
      rituals: state.dailyRitualHistory,
      weeklyReviews: state.weeklyReviewHistory,
      events: buildActivityFeed(state.activityEvents, state.allTasks, state.milestones),
    });
    const now = new Date().toISOString();
    const nextState = bindMonthlyReviewToAccount(
      {
        ...createMonthlyReviewState({
          monthStartDate,
          monthEndDate,
          accountId,
          existing,
        }),
        reviewedAt: now,
        reviewNote: input.reviewNote?.trim() ? input.reviewNote.trim() : existing?.reviewNote ?? null,
        recommitGoalIds: input.recommitGoalIds,
        reduceGoalIds: input.reduceGoalIds,
        pauseGoalIds: input.pauseGoalIds,
        goalCoverage: digest.goalCoverage,
        summary: digest.summary,
        metadata: {
          ...(existing?.metadata ?? {}),
          reads: digest.reads,
          headline: digest.headline,
        },
        updatedAt: now,
        version: existing ? existing.version + 1 : 1,
      },
      accountId,
    );

    await Promise.all([
      appServices.repositories.planning.saveMonthlyReviewStates([nextState]),
      appServices.repositories.history.saveActivityEvents(
        bindRecordsToAccount(
          [
            buildMonthReviewedActivityEvent({
              monthStartDate,
              monthEndDate,
              occurredAt: now,
              completedCount: digest.summary.completedCount,
              representedGoalCount: digest.summary.goalCoverageCount,
              underrepresentedGoalCount: digest.summary.underrepresentedGoalCount,
            }),
            buildMonthlyRecommitmentUpdatedActivityEvent({
              monthStartDate,
              occurredAt: now,
              recommitCount: input.recommitGoalIds.length,
              reduceCount: input.reduceGoalIds.length,
              pauseCount: input.pauseGoalIds.length,
            }),
            buildMonthlyCoverageReviewedActivityEvent({
              monthStartDate,
              occurredAt: now,
              coveredGoalCount: digest.summary.goalCoverageCount,
              dragGoalCount: digest.summary.dragGoalCount,
            }),
          ],
          accountId,
        ),
      ),
    ]);

    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  shapeNextMonth: async (input) => {
    const state = get();
    const accountId = getAttachedAccountId(state);
    const nextMonthStartDate = addMonths(startOfMonth(state.planDate), 1);
    const nextMonthEndDate = endOfMonth(nextMonthStartDate);
    const existing = await appServices.repositories.planning.getMonthlyReviewState(nextMonthStartDate);
    const now = new Date().toISOString();
    const nextState = bindMonthlyReviewToAccount(
      {
        ...createMonthlyReviewState({
          monthStartDate: nextMonthStartDate,
          monthEndDate: nextMonthEndDate,
          accountId,
          existing,
        }),
        strategySetAt: now,
        monthPosture: input.posture,
        monthlyEmphasis: input.emphasis,
        pressureLevel: input.pressureLevel,
        carryoverStance: input.carryoverStance,
        strategyNote: input.note?.trim() ? input.note.trim() : existing?.strategyNote ?? null,
        metadata: {
          ...(existing?.metadata ?? {}),
          shapedFromMonth: startOfMonth(state.planDate),
        },
        updatedAt: now,
        version: existing ? existing.version + 1 : 1,
      },
      accountId,
    );

    await Promise.all([
      appServices.repositories.planning.saveMonthlyReviewStates([nextState]),
      appServices.repositories.history.saveActivityEvents(
        bindRecordsToAccount(
          [
            buildNextMonthShapedActivityEvent({
              monthStartDate: nextMonthStartDate,
              occurredAt: now,
              posture: input.posture,
              emphasis: input.emphasis,
              pressureLevel: input.pressureLevel,
              carryoverStance: input.carryoverStance,
            }),
          ],
          accountId,
        ),
      ),
    ]);

    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  openDay: async (focus = null) => {
    const state = get();
    const accountId = getAttachedAccountId(state);
    const existing = await appServices.repositories.planning.getDailyRitualState(state.planDate);
    const now = new Date().toISOString();
    const ritualState = createDailyRitualState({
      date: state.planDate,
      accountId,
      existing,
    });
    const nextRitualState = bindRitualStateToAccount(
      {
        ...ritualState,
        openedAt: ritualState.openedAt ?? now,
        openingFocus: focus ?? ritualState.openingFocus ?? null,
        closedAt: null,
        updatedAt: now,
        version: ritualState.version + (existing ? 1 : 0),
      },
      accountId,
    );

    const updates: Promise<unknown>[] = [
      appServices.repositories.planning.saveDailyRitualStates([nextRitualState]),
      appServices.repositories.history.saveActivityEvents(
        bindRecordsToAccount(
          [
            buildDayOpenedActivityEvent({
              date: state.planDate,
              occurredAt: now,
              openingFocus: nextRitualState.openingFocus,
            }),
          ],
          accountId,
        ),
      ),
    ];

    if (state.dailyPlan && focus) {
      const focusCopy =
        focus === DailyRitualOpeningFocus.ProtectEssentials
          ? "Protect the essentials first. Anything extra needs to earn its way in."
          : focus === DailyRitualOpeningFocus.MeaningfulProgress
            ? "Move the one meaningful thing that makes the rest of the day easier."
            : "Keep the day light enough to stay believable from start to finish.";
      updates.push(
        appServices.repositories.planning.saveDailyPlans([
          bindRecordToAccount(
            {
              ...state.dailyPlan,
              focus: focusCopy,
              updatedAt: now,
              version: state.dailyPlan.version + 1,
            },
            accountId,
          ),
        ]),
      );
    }

    await Promise.all(updates);
    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  recoverDay: async (mode) => {
    const state = get();

    if (!state.userPreferences || !state.dailyPlan) {
      throw new Error("Today's plan is not ready for recovery.");
    }

    const accountId = getAttachedAccountId(state);
    const now = new Date().toISOString();
    const recoveryDate = addDays(state.planDate, 1);
    const candidateTasks = [...state.tasksForSelectedDate].sort((left, right) => {
      const leftScore =
        (left.status === TaskStatus.InProgress ? 60 : 0) +
        (left.status === TaskStatus.Scheduled ? 24 : 0) +
        (left.status === TaskStatus.Ready ? 16 : 0) +
        (left.difficulty === "light" ? 8 : left.difficulty === "moderate" ? 5 : 0) -
        left.estimatedMinutes / 10;
      const rightScore =
        (right.status === TaskStatus.InProgress ? 60 : 0) +
        (right.status === TaskStatus.Scheduled ? 24 : 0) +
        (right.status === TaskStatus.Ready ? 16 : 0) +
        (right.difficulty === "light" ? 8 : right.difficulty === "moderate" ? 5 : 0) -
        right.estimatedMinutes / 10;

      return rightScore - leftScore;
    });
    const keepCount =
      mode === DailyRitualRecoveryMode.SalvageEssentials
        ? 2
        : mode === DailyRitualRecoveryMode.LightenRest
          ? 1
          : 3;
    const keepTaskIds = new Set(
      candidateTasks
        .filter((task) => ![TaskStatus.Completed, TaskStatus.Cancelled].includes(task.status))
        .slice(0, keepCount)
        .map((task) => task.id),
    );

    const updatedTasks = state.tasksForSelectedDate.map((task) => {
      if ([TaskStatus.Completed, TaskStatus.Cancelled].includes(task.status)) {
        return task;
      }

      if (keepTaskIds.has(task.id)) {
        return bindRecordToAccount(
          {
            ...task,
            targetDate: state.planDate,
            scheduledDate: state.planDate,
            status:
              task.status === TaskStatus.InProgress
                ? TaskStatus.InProgress
                : task.status === TaskStatus.Completed
                  ? TaskStatus.Completed
                  : TaskStatus.Ready,
            schedulingState:
              task.status === TaskStatus.InProgress
                ? TaskSchedulingState.InFlight
                : TaskSchedulingState.Committed,
            metadata: {
              ...task.metadata,
              ritualRecoveryMode: mode,
              ritualRecoveryAppliedAt: now,
            },
            updatedAt: now,
            version: task.version + 1,
          },
          accountId,
        );
      }

      return bindRecordToAccount(
        {
          ...task,
          status: TaskStatus.Deferred,
          schedulingState: TaskSchedulingState.Rolled,
          targetDate: recoveryDate,
          scheduledDate: recoveryDate,
          metadata: {
            ...task.metadata,
            ritualRecoveryMode: mode,
            ritualRecoveryAppliedAt: now,
            ritualDeferredFrom: state.planDate,
          },
          updatedAt: now,
          version: task.version + 1,
        },
        accountId,
      );
    });

    await appServices.repositories.tasks.saveTasks(updatedTasks);

    const existing = await appServices.repositories.planning.getDailyRitualState(state.planDate);
    const ritualState = createDailyRitualState({
      date: state.planDate,
      accountId,
      existing,
    });
    const changedTaskCount = updatedTasks.filter((task) => !keepTaskIds.has(task.id)).length;
    const changedBlockCount = Math.max(
      0,
      state.timeBlocksForSelectedDate.filter((block) => block.taskId && !keepTaskIds.has(block.taskId)).length,
    );
    const recoveryMoment: DailyRitualRecoveryMoment = {
      occurredAt: now,
      mode,
      summary: summarizeRecoveryMode(mode, changedTaskCount),
      changedTaskCount,
      changedBlockCount,
      triggerLabels: [
        state.today?.ritual?.recoveryReasons?.[0] ?? "The original day shape no longer held.",
      ],
    };

    const nextRitualState = bindRitualStateToAccount(
      {
        ...ritualState,
        recoveryMoments: [...ritualState.recoveryMoments, recoveryMoment],
        updatedAt: now,
        version: ritualState.version + (existing ? 1 : 0),
      },
      accountId,
    );

    await Promise.all([
      appServices.repositories.planning.saveDailyRitualStates([nextRitualState]),
      appServices.repositories.history.saveActivityEvents(
        bindRecordsToAccount(
          [
            buildDayRecoveredActivityEvent({
              date: state.planDate,
              occurredAt: now,
              recoveryMode: mode,
              summary: recoveryMoment.summary,
              changedTaskCount,
              changedBlockCount,
            }),
          ],
          accountId,
        ),
      ),
    ]);

    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  closeDay: async (input) => {
    const state = get();
    const accountId = getAttachedAccountId(state);
    const now = new Date().toISOString();
    const existing = await appServices.repositories.planning.getDailyRitualState(state.planDate);
    const ritualState = createDailyRitualState({
      date: state.planDate,
      accountId,
      existing,
    });
    const tomorrow = addDays(state.planDate, 1);
    const unfinishedTasks = state.tasksForSelectedDate.filter(
      (task) => ![TaskStatus.Completed, TaskStatus.Cancelled].includes(task.status),
    );

    const updatedTasks = unfinishedTasks.map((task) => {
      if (input.carryDecision === DailyRitualCarryDecision.DeferDecision) {
        return bindRecordToAccount(
          {
            ...task,
            metadata: {
              ...task.metadata,
              ritualCloseDeferredAt: now,
            },
            updatedAt: now,
            version: task.version + 1,
          },
          accountId,
        );
      }

      if (input.carryDecision === DailyRitualCarryDecision.SendToReview) {
        return bindRecordToAccount(
          {
            ...task,
            status: TaskStatus.Unscheduled,
            schedulingState: TaskSchedulingState.Unscheduled,
            targetDate: null,
            scheduledDate: null,
            metadata: {
              ...task.metadata,
              ritualReviewRequestedAt: now,
              ritualCarryDecision: input.carryDecision,
            },
            updatedAt: now,
            version: task.version + 1,
          },
          accountId,
        );
      }

      return bindRecordToAccount(
        {
          ...task,
          status: TaskStatus.Deferred,
          schedulingState: TaskSchedulingState.Rolled,
          targetDate: tomorrow,
          scheduledDate: tomorrow,
          metadata: {
            ...task.metadata,
            ritualCarryDecision: input.carryDecision,
            ritualCarriedFrom: state.planDate,
          },
          updatedAt: now,
          version: task.version + 1,
        },
        accountId,
      );
    });

    if (updatedTasks.length > 0) {
      await appServices.repositories.tasks.saveTasks(updatedTasks);
    }

    const carryDecisionSummary: DailyRitualCarryDecisionSummary = {
      decidedAt: now,
      decision: input.carryDecision,
      unfinishedTaskCount: unfinishedTasks.length,
      carriedTaskCount:
        input.carryDecision === DailyRitualCarryDecision.CarryForward ? unfinishedTasks.length : 0,
      sentToReviewCount:
        input.carryDecision === DailyRitualCarryDecision.SendToReview ? unfinishedTasks.length : 0,
      deferredDecisionCount:
        input.carryDecision === DailyRitualCarryDecision.DeferDecision ? unfinishedTasks.length : 0,
    };

    const nextRitualState = bindRitualStateToAccount(
      {
        ...ritualState,
        openedAt: ritualState.openedAt ?? now,
        closedAt: now,
        dayLoadRating: input.dayLoadRating,
        energyRating: input.energyRating,
        clarityRating: input.clarityRating,
        reflectionNote: input.reflectionNote?.trim() ? input.reflectionNote.trim() : null,
        carryDecisionSummary,
        updatedAt: now,
        version: ritualState.version + (existing ? 1 : 0),
      },
      accountId,
    );

    const completedCount = state.tasksForSelectedDate.filter(
      (task) => task.status === TaskStatus.Completed,
    ).length;

    const historyEvents = [
      buildDayClosedActivityEvent({
        date: state.planDate,
        occurredAt: now,
        completedCount,
        unfinishedCount: unfinishedTasks.length,
      }),
      buildReflectionLoggedActivityEvent({
        date: state.planDate,
        occurredAt: now,
        dayLoad: input.dayLoadRating,
        energy: input.energyRating,
        clarity: input.clarityRating,
      }),
      buildCarryoverReviewedActivityEvent({
        date: state.planDate,
        occurredAt: now,
        decision: input.carryDecision,
        unfinishedCount: unfinishedTasks.length,
      }),
    ];

    await Promise.all([
      appServices.repositories.planning.saveDailyRitualStates([nextRitualState]),
      state.dailyPlan
        ? appServices.repositories.planning.saveDailyPlans([
            bindRecordToAccount(
              {
                ...state.dailyPlan,
                status: DailyPlanStatus.Completed,
                updatedAt: now,
                version: state.dailyPlan.version + 1,
              },
              accountId,
            ),
          ])
        : Promise.resolve(),
      appServices.repositories.history.saveActivityEvents(
        bindRecordsToAccount(historyEvents, accountId),
      ),
    ]);

    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
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
      adaptationProfile: getEffectiveAdaptationProfile(state),
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
    const task = state.tasksForSelectedDate.find((entry) => entry.id === taskId);
    const block = state.timeBlocksForSelectedDate.find((entry) => entry.taskId === taskId) ?? null;
    const goal = task?.goalId ? state.goals.find((entry) => entry.id === task.goalId) ?? null : null;
    const milestone =
      task?.milestoneId
        ? state.milestones.find((entry) => entry.id === task.milestoneId) ?? null
        : null;
    const historyEvent =
      task
        ? buildTaskActionActivityEvent({
            audit: execution.payload.audit,
            task,
            block,
            goal,
            milestone,
            dailyPlanId: state.dailyPlan.id,
          })
        : null;
    const accountId = getAttachedAccountId(state);

    await Promise.all([
      appServices.repositories.tasks.saveTasks(
        bindRecordsToAccount(execution.payload.mutation.tasksToSave, accountId),
      ),
      appServices.repositories.planning.saveTimeBlocks(
        bindRecordsToAccount(execution.payload.mutation.blocksToSave, accountId),
      ),
      appServices.repositories.planning.saveDailyPlans([
        bindRecordToAccount(execution.payload.mutation.dailyPlan, accountId),
      ]),
      appServices.repositories.adaptation.replaceReplanSuggestions(state.planDate, nextSuggestions),
      historyEvent
        ? appServices.repositories.history.saveActivityEvents(
            bindRecordsToAccount([historyEvent], accountId),
          )
        : Promise.resolve(),
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

      await appServices.repositories.adaptation.saveProfiles([
        bindRecordToAccount(adaptationResult.payload.profile, accountId),
      ]);
    }

    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(state.planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  refreshPreferences: async () => {
    const [userPreferences, notificationPreferences] = await Promise.all([
      appServices.repositories.preferences.getUserPreferences(),
      appServices.repositories.preferences.listNotificationPreferences(),
    ]);

    set({
      userPreferences,
      productPreferences: getProductPreferences(userPreferences),
      notificationPreferences,
    });
  },

  saveProductPreferences: async (productPreferences) => {
    const currentPreferences = get().userPreferences;
    if (!currentPreferences) {
      throw new Error("User preferences are unavailable.");
    }

    const nextPreferences = mergeProductPreferences(currentPreferences, productPreferences);
    const accountId = getAttachedAccountId(get());
    await appServices.repositories.preferences.saveUserPreferences(
      bindRecordToAccount(nextPreferences, accountId),
    );
    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(get().planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  updateNotificationPreference: async (reminderType, patch) => {
    const preferences = await appServices.repositories.preferences.listNotificationPreferences();
    const nextPreferences = preferences.map((preference) =>
      preference.reminderType === reminderType
        ? {
            ...preference,
            ...patch,
            updatedAt: new Date().toISOString(),
            version: preference.version + 1,
          }
        : preference,
    );

    const accountId = getAttachedAccountId(get());
    await appServices.repositories.preferences.saveNotificationPreferences(
      bindRecordsToAccount(nextPreferences, accountId),
    );
    const [foundationSnapshot, accountSnapshot] = await Promise.all([
      refreshAllState(get().planDate),
      appServices.services.account.notePendingChanges(),
    ]);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
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
    set(await refreshAllState(planDate));
  },

  requestCalendarAccess: async () => {
    await appServices.services.calendar.requestAccess();
    set(await refreshAllState(get().planDate));
  },

  requestNotificationAccess: async () => {
    await appServices.services.notifications.requestAccess();
    set(await refreshAllState(get().planDate));
  },

  createFirstPlan: async ({ inference, productPreferences }) => {
    const state = get();

    if (!state.userPreferences) {
      throw new Error("User preferences are unavailable.");
    }

    set({ onboardingBusy: true });

    try {
      await createGoalAndFirstPlan({
        inference,
        productPreferences,
        currentPreferences: state.userPreferences,
        today: state.planDate,
        adaptationProfile: getEffectiveAdaptationProfile(state),
        accountId: getAttachedAccountId(state),
      });
      const [foundationSnapshot, accountSnapshot] = await Promise.all([
        refreshAllState(state.planDate),
        appServices.services.account.notePendingChanges(),
      ]);
      set({
        ...foundationSnapshot,
        ...mapAccountSnapshot(accountSnapshot),
      });
    } finally {
      set({ onboardingBusy: false });
    }
  },

  refreshAccountState: async () => {
    const snapshot = await appServices.services.account.getSnapshot();
    set(mapAccountSnapshot(snapshot));
  },

  createAccount: async (input) => {
    const result = await appServices.services.account.createAccount(input);
    const foundationSnapshot = await refreshAllState(get().planDate);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(result.snapshot),
    });
    return result;
  },

  signIn: async (input) => {
    const result = await appServices.services.account.signIn(input);
    const foundationSnapshot = await refreshAllState(get().planDate);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(result.snapshot),
    });
    return result;
  },

  clearAuthFeedback: async () => {
    const snapshot = await appServices.services.account.clearTransientAuthFeedback();
    set(mapAccountSnapshot(snapshot));
  },

  signOut: async () => {
    const accountSnapshot = await appServices.services.account.signOut();
    const foundationSnapshot = await refreshAllState(get().planDate);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  deleteAccount: async (input) => {
    const accountSnapshot = await appServices.services.account.deleteAccount(input);
    const foundationSnapshot = await refreshAllState(get().planDate);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  attachLocalDataToAccount: async () => {
    const accountSnapshot = await appServices.services.account.attachLocalDataToSignedInAccount();
    const foundationSnapshot = await refreshAllState(get().planDate);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },

  deferLocalDataAttachment: async () => {
    const snapshot = await appServices.services.account.deferLocalAttachment();
    set(mapAccountSnapshot(snapshot));
  },

  syncAccountData: async (kind) => {
    const accountSnapshot = await appServices.services.account.syncNow(kind);
    const foundationSnapshot = await refreshAllState(get().planDate);
    set({
      ...foundationSnapshot,
      ...mapAccountSnapshot(accountSnapshot),
    });
  },
}));

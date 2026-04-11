import { create } from "zustand";

import { initializeAppServices, appServices } from "../bootstrap/runtime/appServices";
import { SchedulingOutput } from "../engines";
import {
  AdaptationProfile,
  AccountIdentity,
  AccountSnapshot,
  AuthStateSnapshot,
  CalendarConnectionState,
  DailyPlan,
  Domain,
  Goal,
  GoalMilestone,
  GoalStatus,
  LocalAttachmentState,
  NotificationPreference,
  ReplanSuggestion,
  ScheduleConstraint,
  SyncConflictRecord,
  SyncOperationKind,
  SyncStateSnapshot,
  Task,
  TaskActionType,
  TimeBlock,
  UserPreferences,
} from "../domain/models";
import { createGoalAndFirstPlan, createGoalArtifacts } from "../product/planOrchestrator";
import { getProductPreferences, mergeProductPreferences } from "../product/preferences";
import { ProductPreferences, GoalDraftInference } from "../product/types";
import { TodayViewModel } from "./viewModels/today";
import { initialPlanDate, refreshAllState } from "./runtime";

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
  allTasks: Task[];
  refreshGoals: () => Promise<void>;
  createGoal: (inference: GoalDraftInference) => Promise<void>;
  updateGoal: (goalId: string, patch: Partial<Goal>) => Promise<void>;
  setGoalStatus: (goalId: string, status: GoalStatus) => Promise<void>;
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
  productPreferences: ProductPreferences | null;
  notificationPreferences: NotificationPreference[];
  refreshPreferences: () => Promise<void>;
  saveProductPreferences: (productPreferences: ProductPreferences) => Promise<void>;
  updateNotificationPreference: (
    reminderType: NotificationPreference["reminderType"],
    enabled: boolean,
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
  signInWithApple: () => Promise<void>;
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

export const useAppStore = create<AppState>((set, get) => ({
  bootstrapped: false,
  bootStatus: "idle",
  lastError: null,
  domains: [],
  goals: [],
  milestones: [],
  allTasks: [],
  planDate: initialPlanDate,
  dailyPlan: null,
  schedule: null,
  today: null,
  tasksForSelectedDate: [],
  timeBlocksForSelectedDate: [],
  userPreferences: null,
  productPreferences: null,
  notificationPreferences: [],
  adaptationProfile: null,
  replanSuggestions: [],
  calendarConnectionState: null,
  scheduleConstraints: [],
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
      await initializeAppServices();
      await appServices.services.notifications.configure();
      const [snapshot, accountSnapshot] = await Promise.all([
        refreshAllState(get().planDate),
        appServices.services.account.getSnapshot(),
      ]);

      set({
        bootstrapped: true,
        bootStatus: "ready",
        ...snapshot,
        ...mapAccountSnapshot(accountSnapshot),
      });

      if (
        accountSnapshot.auth.signedInAccountId &&
        accountSnapshot.attachment.status === "attached"
      ) {
        appServices.services.account
          .syncNow(SyncOperationKind.Startup)
          .then((nextSnapshot) => {
            set(mapAccountSnapshot(nextSnapshot));
          })
          .catch(() => null);
      }
    } catch (error) {
      set({
        bootStatus: "error",
        lastError: error instanceof Error ? error.message : "Unknown bootstrap failure",
      });
    }
  },

  refreshGoals: async () => {
    const [domains, goals, milestones, allTasks] = await Promise.all([
      appServices.repositories.preferences.listDomains(),
      appServices.repositories.goals.listGoals(),
      appServices.repositories.goals.listMilestones(),
      appServices.repositories.tasks.listTasks(),
    ]);

    set({ domains, goals, milestones, allTasks });
  },

  createGoal: async (inference) => {
    const state = get();
    if (!state.userPreferences || !state.productPreferences) {
      throw new Error("Preferences are not available yet.");
    }

    const accountId =
      state.attachmentState?.status === "attached" ? state.authState?.signedInAccountId ?? null : null;

    const artifacts = await createGoalArtifacts({
      inference,
      productPreferences: state.productPreferences,
      currentPreferences: state.userPreferences,
      today: state.planDate,
      adaptationProfile: state.adaptationProfile,
    });
    const existingGoals = await appServices.repositories.goals.listGoals();

    await appServices.repositories.preferences.saveUserPreferences(
      bindRecordToAccount(artifacts.mergedPreferences, accountId),
    );
    await appServices.repositories.goals.saveGoals([
      ...existingGoals.map((goal, index) => ({ ...goal, sortOrder: index + 1 })),
      bindRecordToAccount(
        { ...artifacts.goal, sortOrder: existingGoals.length + 1 },
        accountId,
      ),
    ]);
    await appServices.repositories.goals.saveMilestones(
      artifacts.milestones.map((milestone) => bindRecordToAccount(milestone, accountId)),
    );
    await appServices.repositories.tasks.saveTasks(
      artifacts.tasks.map((task) => bindRecordToAccount(task, accountId)),
    );

    set(await refreshAllState(state.planDate));
  },

  updateGoal: async (goalId, patch) => {
    const goals = await appServices.repositories.goals.listGoals();
    const accountId =
      get().attachmentState?.status === "attached"
        ? get().authState?.signedInAccountId ?? null
        : null;
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
    set(await refreshAllState(get().planDate));
  },

  setGoalStatus: async (goalId, status) => {
    await get().updateGoal(goalId, { status });
  },

  refreshPlanning: async (date) => {
    const planDate = date ?? get().planDate;
    set(await refreshAllState(planDate));
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

    set(await refreshAllState(state.planDate));
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
    const accountId =
      get().attachmentState?.status === "attached"
        ? get().authState?.signedInAccountId ?? null
        : null;
    await appServices.repositories.preferences.saveUserPreferences(
      bindRecordToAccount(nextPreferences, accountId),
    );
    set(await refreshAllState(get().planDate));
  },

  updateNotificationPreference: async (reminderType, enabled) => {
    const preferences = await appServices.repositories.preferences.listNotificationPreferences();
    const nextPreferences = preferences.map((preference) =>
      preference.reminderType === reminderType
        ? {
            ...preference,
            enabled,
            updatedAt: new Date().toISOString(),
            version: preference.version + 1,
          }
        : preference,
    );

    await appServices.repositories.preferences.saveNotificationPreferences(nextPreferences);
    set(await refreshAllState(get().planDate));
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
        adaptationProfile: state.adaptationProfile,
      });
      const [foundationSnapshot, accountSnapshot] = await Promise.all([
        refreshAllState(state.planDate),
        appServices.services.account.getSnapshot(),
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

  signInWithApple: async () => {
    const snapshot = await appServices.services.account.signInWithApple();
    set(mapAccountSnapshot(snapshot));
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

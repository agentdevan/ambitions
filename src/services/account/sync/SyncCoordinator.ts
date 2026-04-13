import {
  AdaptationProfile,
  Ambition,
  ActivityEvent,
  DailyPlan,
  DailyRitualState,
  EntitySyncState,
  Goal,
  GoalMilestone,
  MonthlyReviewState,
  NotificationPreference,
  RemoteSyncRecord,
  SyncEntityKind,
  SyncMode,
  SyncOperationKind,
  SyncOperationStatus,
  SyncStateSnapshot,
  Task,
  TimeBlock,
  UserPreferences,
  WeeklyReviewState,
} from "../../../domain/models";
import { AccountRepository } from "../../../repositories/AccountRepository";
import { AdaptationRepository } from "../../../repositories/AdaptationRepository";
import { GoalRepository } from "../../../repositories/GoalRepository";
import { HistoryRepository } from "../../../repositories/HistoryRepository";
import { PlanRepository } from "../../../repositories/PlanRepository";
import { PreferencesRepository } from "../../../repositories/PreferencesRepository";
import { TaskRepository } from "../../../repositories/TaskRepository";
import { SupabaseAccountClient } from "../SupabaseAccountClient";
import { buildConflictRecord, buildConflictRecordId, MergeEvaluator } from "./MergeEvaluator";
import {
  normalizeRemoteRecord,
  prepareOwnedRecord,
  syncEntityOrder,
  SyncEntityRecord,
  toRemoteId,
} from "./syncScope";

interface SyncRepositories {
  goals: GoalRepository;
  tasks: TaskRepository;
  planning: PlanRepository;
  preferences: PreferencesRepository;
  adaptation: AdaptationRepository;
  history: HistoryRepository;
}

interface LocalSyncState {
  ambitions: Ambition[];
  goals: Goal[];
  milestones: GoalMilestone[];
  tasks: Task[];
  preferences: UserPreferences | null;
  notificationPreferences: NotificationPreference[];
  adaptationProfile: AdaptationProfile | null;
  dailyPlans: DailyPlan[];
  dailyRitualStates: DailyRitualState[];
  weeklyReviewStates: WeeklyReviewState[];
  monthlyReviewStates: MonthlyReviewState[];
  timeBlocks: TimeBlock[];
  activityEvents: ActivityEvent[];
}

export class SyncCoordinator {
  constructor(
    private readonly accountRepository: AccountRepository,
    private readonly repositories: SyncRepositories,
    private readonly remoteClient: SupabaseAccountClient,
  ) {}

  async countMeaningfulLocalRecords() {
    const [
      ambitions,
      goals,
      milestones,
      tasks,
      plans,
      ritualStates,
      weeklyStates,
      monthlyStates,
      preferences,
      activityEvents,
    ] = await Promise.all([
      this.repositories.goals.listAmbitions(),
      this.repositories.goals.listGoals(),
      this.repositories.goals.listMilestones(),
      this.repositories.tasks.listTasks(),
      this.repositories.planning.listDailyPlans(),
      this.repositories.planning.listDailyRitualStates(),
      this.repositories.planning.listWeeklyReviewStates(),
      this.repositories.planning.listMonthlyReviewStates(),
      this.repositories.preferences.getUserPreferences(),
      this.repositories.history.listActivityEvents(500),
    ]);

    return {
      hasMeaningfulLocalData:
        ambitions.length > 0 ||
        goals.length > 0 ||
        milestones.length > 0 ||
        tasks.length > 0 ||
        plans.length > 0 ||
        ritualStates.length > 0 ||
        weeklyStates.length > 0 ||
        monthlyStates.length > 0 ||
        activityEvents.length > 0 ||
        preferences?.metadata.onboardingCompleted === true ||
        preferences?.metadata.onboardingCompleted === "true",
      pendingRecordCount:
        ambitions.length +
        goals.length +
        milestones.length +
        tasks.length +
        plans.length +
        ritualStates.length +
        weeklyStates.length +
        monthlyStates.length +
        activityEvents.length +
        (preferences ? 1 : 0),
    };
  }

  async countPendingRecords(accountId: string) {
    const localState = await this.loadLocalSyncState();
    const allRecords = this.flattenLocal(localState).filter(
      (entry) => entry.record.ownerUserId === accountId,
    );
    const pendingPushCount = allRecords.filter(
      (entry) => entry.record.syncState !== EntitySyncState.Synced,
    ).length;

    return {
      totalRecordCount: allRecords.length,
      pendingPushCount,
    };
  }

  async attachLocalDataToAccount(accountId: string) {
    const now = new Date().toISOString();
    const localState = await this.loadLocalSyncState();

    await this.repositories.goals.saveAmbitions(
      localState.ambitions.map((ambition) =>
        prepareOwnedRecord("ambition", ambition, accountId, now),
      ),
    );
    await this.repositories.goals.saveGoals(
      localState.goals.map((goal) => prepareOwnedRecord("goal", goal, accountId, now)),
    );
    await this.repositories.goals.saveMilestones(
      localState.milestones.map((milestone) =>
        prepareOwnedRecord("milestone", milestone, accountId, now),
      ),
    );
    await this.repositories.tasks.saveTasks(
      localState.tasks.map((task) => prepareOwnedRecord("task", task, accountId, now)),
    );

    if (localState.preferences) {
      await this.repositories.preferences.saveUserPreferences(
        prepareOwnedRecord("preferences", localState.preferences, accountId, now),
      );
    }

    await this.repositories.preferences.saveNotificationPreferences(
      localState.notificationPreferences.map((preference) =>
        prepareOwnedRecord("notification_preference", preference, accountId, now),
      ),
    );

    if (localState.adaptationProfile) {
      await this.repositories.adaptation.saveProfiles([
        prepareOwnedRecord("adaptation_profile", localState.adaptationProfile, accountId, now),
      ]);
    }

    await this.repositories.planning.saveDailyPlans(
      localState.dailyPlans.map((plan) => prepareOwnedRecord("daily_plan", plan, accountId, now)),
    );
    await this.repositories.planning.saveDailyRitualStates(
      localState.dailyRitualStates.map((state) =>
        prepareOwnedRecord("daily_ritual_state", state, accountId, now),
      ),
    );
    await this.repositories.planning.saveWeeklyReviewStates(
      localState.weeklyReviewStates.map((state) =>
        prepareOwnedRecord("weekly_review_state", state, accountId, now),
      ),
    );
    await this.repositories.planning.saveMonthlyReviewStates(
      localState.monthlyReviewStates.map((state) =>
        prepareOwnedRecord("monthly_review_state", state, accountId, now),
      ),
    );
    await this.repositories.planning.saveTimeBlocks(
      localState.timeBlocks.map((block) => prepareOwnedRecord("time_block", block, accountId, now)),
    );
    await this.repositories.history.saveActivityEvents(
      localState.activityEvents.map((event) =>
        prepareOwnedRecord("activity_event", event, accountId, now),
      ),
    );
  }

  async sync(accountId: string, syncState: SyncStateSnapshot, kind: SyncOperationKind) {
    const now = new Date().toISOString();
    const operationId = `sync:${kind}:${now}`;
    const syncMetadata = {
      ...syncState.metadata,
      lastAttemptedSyncAt: now,
      lastOperationKind: kind,
    };

    await this.accountRepository.saveSyncOperation({
      id: operationId,
      accountId,
      kind,
      status: SyncOperationStatus.Running,
      startedAt: now,
      finishedAt: null,
      errorMessage: null,
      metadata: {},
      ownerUserId: accountId,
      remoteId: null,
      syncState: EntitySyncState.LocalOnly,
      version: 1,
      lastSyncedAt: null,
      createdAt: now,
      updatedAt: now,
    });

    await this.accountRepository.saveSyncState({
      ...syncState,
      accountId,
      mode: SyncMode.Syncing,
      lastError: null,
      metadata: syncMetadata,
      updatedAt: now,
    });

    try {
      const localState = await this.loadLocalSyncState();
      const remoteRecords = this.remoteClient.isConfigured()
        ? await this.remoteClient.listRemoteRecords(accountId)
        : await this.accountRepository.listRemoteRecords(accountId);
      const remoteByKey = new Map(
        remoteRecords.map((record) => [`${record.entityKind}:${record.remoteId}`, record] as const),
      );
      const remoteWrites: RemoteSyncRecord[] = [];
      let pendingPushCount = 0;
      let pendingPullCount = 0;
      let conflictCount = 0;

      for (const entityKind of syncEntityOrder) {
        const localRecords = this.getByKind(localState, entityKind).filter(
          (record) => record.ownerUserId === accountId,
        );

        for (const localRecord of localRecords) {
          const remoteId = toRemoteId(entityKind, localRecord);
          const remoteRecord = remoteByKey.get(`${entityKind}:${remoteId}`);

          if (!remoteRecord) {
            remoteWrites.push(this.toRemoteRecord(accountId, syncState.deviceId, entityKind, localRecord));
            await this.saveLocalRecord(
              entityKind,
              normalizeRemoteRecord(entityKind, localRecord, accountId, now),
            );
            pendingPushCount += 1;
            continue;
          }

          const remoteEntity = JSON.parse(remoteRecord.payload) as SyncEntityRecord;
          const baseline = localRecord.lastSyncedAt ?? syncState.lastSyncAt;
          const decision = MergeEvaluator.decide({
            kind: entityKind,
            local: localRecord,
            remote: remoteEntity,
            baseline,
          });

          if (decision.type === "push_local") {
            remoteWrites.push(this.toRemoteRecord(accountId, syncState.deviceId, entityKind, localRecord));
            await this.saveLocalRecord(
              entityKind,
              normalizeRemoteRecord(entityKind, localRecord, accountId, now),
            );
            pendingPushCount += 1;
            continue;
          }

          if (decision.type === "pull_remote") {
            await this.saveLocalRecord(
              entityKind,
              normalizeRemoteRecord(entityKind, remoteEntity, accountId, now),
            );
            pendingPullCount += 1;
            continue;
          }

          if (decision.type === "conflict") {
            await this.accountRepository.saveConflict(
              buildConflictRecord({
                id: buildConflictRecordId(accountId, entityKind, localRecord.id),
                accountId,
                kind: entityKind,
                entityId: localRecord.id,
                localVersion: localRecord.version,
                remoteVersion: remoteEntity.version,
                strategy: decision.strategy,
                summary: decision.summary,
                now,
              }),
            );
            conflictCount += 1;
            await this.saveLocalRecord(entityKind, {
              ...localRecord,
              syncState: EntitySyncState.Conflict,
              updatedAt: now,
            });

            continue;
          }

          await this.saveLocalRecord(
            entityKind,
            normalizeRemoteRecord(entityKind, localRecord, accountId, now),
          );
        }
      }

      const knownRemoteIds = new Set(
        this.flattenLocal(localState)
          .filter((entry) => entry.record.ownerUserId === accountId)
          .map((entry) => `${entry.kind}:${toRemoteId(entry.kind, entry.record)}`),
      );

      for (const remoteRecord of remoteRecords) {
        const key = `${remoteRecord.entityKind}:${remoteRecord.remoteId}`;
        if (knownRemoteIds.has(key)) {
          continue;
        }

        const remoteEntity = normalizeRemoteRecord(
          remoteRecord.entityKind,
          JSON.parse(remoteRecord.payload) as SyncEntityRecord,
          accountId,
          now,
        );
        await this.saveLocalRecord(remoteRecord.entityKind, remoteEntity);
        pendingPullCount += 1;
      }

      if (remoteWrites.length > 0 && this.remoteClient.isConfigured()) {
        await this.remoteClient.upsertRemoteRecords(remoteWrites);
      }

      if (remoteWrites.length > 0 || remoteRecords.length > 0) {
        await this.accountRepository.saveRemoteRecords([
          ...remoteRecords.filter((record) => record.accountId === accountId),
          ...remoteWrites,
        ]);
      }

      await this.accountRepository.saveSyncOperation({
        id: operationId,
        accountId,
        kind,
        status: SyncOperationStatus.Succeeded,
        startedAt: now,
        finishedAt: new Date().toISOString(),
        errorMessage: null,
        metadata: { pendingPushCount, pendingPullCount, conflictCount },
        ownerUserId: accountId,
        remoteId: null,
        syncState: EntitySyncState.LocalOnly,
        version: 2,
        lastSyncedAt: now,
        createdAt: now,
        updatedAt: now,
      });
      const remainingCounts = await this.countPendingRecords(accountId);
      const openConflicts = (await this.accountRepository.listOpenConflicts()).filter(
        (conflict) => conflict.accountId === accountId,
      );
      const totalConflictCount = openConflicts.length;

      await this.accountRepository.saveSyncState({
        ...syncState,
        accountId,
        mode:
          totalConflictCount > 0
            ? SyncMode.ReviewRequired
            : remainingCounts.pendingPushCount > 0
              ? SyncMode.PendingChanges
              : SyncMode.Synced,
        lastSyncAt: now,
        pendingPushCount: remainingCounts.pendingPushCount,
        pendingPullCount,
        unresolvedConflictCount: totalConflictCount,
        lastError: null,
        metadata: {
          ...syncMetadata,
          lastSuccessfulSyncAt: now,
        },
        updatedAt: now,
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : "Sync failed.";

      await this.accountRepository.saveSyncOperation({
        id: operationId,
        accountId,
        kind,
        status: SyncOperationStatus.Failed,
        startedAt: now,
        finishedAt: new Date().toISOString(),
        errorMessage: message,
        metadata: {},
        ownerUserId: accountId,
        remoteId: null,
        syncState: EntitySyncState.LocalOnly,
        version: 2,
        lastSyncedAt: null,
        createdAt: now,
        updatedAt: now,
      });

      await this.accountRepository.saveSyncState({
        ...syncState,
        accountId,
        mode: SyncMode.Issue,
        lastError: message,
        metadata: {
          ...syncMetadata,
          lastFailureAt: now,
        },
        updatedAt: now,
      });

      throw error;
    }
  }

  private async loadLocalSyncState(): Promise<LocalSyncState> {
    const [
      ambitions,
      goals,
      milestones,
      tasks,
      preferences,
      notificationPreferences,
      adaptationProfile,
      dailyPlans,
      dailyRitualStates,
      weeklyReviewStates,
      monthlyReviewStates,
      timeBlocks,
      activityEvents,
    ] = await Promise.all([
      this.repositories.goals.listAmbitions(),
      this.repositories.goals.listGoals(),
      this.repositories.goals.listMilestones(),
      this.repositories.tasks.listTasks(),
      this.repositories.preferences.getUserPreferences(),
      this.repositories.preferences.listNotificationPreferences(),
      this.repositories.adaptation.getLatestProfile(),
      this.repositories.planning.listDailyPlans(),
      this.repositories.planning.listDailyRitualStates(),
      this.repositories.planning.listWeeklyReviewStates(),
      this.repositories.planning.listMonthlyReviewStates(),
      this.repositories.planning.listTimeBlocks(),
      this.repositories.history.listActivityEvents(1000),
    ]);

    return {
      ambitions,
      goals,
      milestones,
      tasks,
      preferences,
      notificationPreferences,
      adaptationProfile,
      dailyPlans,
      dailyRitualStates,
      weeklyReviewStates,
      monthlyReviewStates,
      timeBlocks,
      activityEvents,
    };
  }

  private getByKind(state: LocalSyncState, kind: SyncEntityKind): SyncEntityRecord[] {
    switch (kind) {
      case "ambition":
        return state.ambitions;
      case "goal":
        return state.goals;
      case "milestone":
        return state.milestones;
      case "task":
        return state.tasks;
      case "daily_plan":
        return state.dailyPlans;
      case "time_block":
        return state.timeBlocks;
      case "daily_ritual_state":
        return state.dailyRitualStates;
      case "weekly_review_state":
        return state.weeklyReviewStates;
      case "monthly_review_state":
        return state.monthlyReviewStates;
      case "preferences":
        return state.preferences ? [state.preferences] : [];
      case "notification_preference":
        return state.notificationPreferences;
      case "adaptation_profile":
        return state.adaptationProfile ? [state.adaptationProfile] : [];
      case "activity_event":
        return state.activityEvents;
      default:
        return [];
    }
  }

  private async saveLocalRecord(kind: SyncEntityKind, record: SyncEntityRecord) {
    switch (kind) {
      case "ambition":
        return this.repositories.goals.saveAmbitions([record as Ambition]);
      case "goal":
        return this.repositories.goals.saveGoals([record as Goal]);
      case "milestone":
        return this.repositories.goals.saveMilestones([record as GoalMilestone]);
      case "task":
        return this.repositories.tasks.saveTasks([record as Task]);
      case "daily_plan":
        return this.repositories.planning.saveDailyPlans([record as DailyPlan]);
      case "time_block":
        return this.repositories.planning.saveTimeBlocks([record as TimeBlock]);
      case "daily_ritual_state":
        return this.repositories.planning.saveDailyRitualStates([record as DailyRitualState]);
      case "weekly_review_state":
        return this.repositories.planning.saveWeeklyReviewStates([record as WeeklyReviewState]);
      case "monthly_review_state":
        return this.repositories.planning.saveMonthlyReviewStates([record as MonthlyReviewState]);
      case "preferences":
        return this.repositories.preferences.saveUserPreferences(record as UserPreferences);
      case "notification_preference":
        return this.repositories.preferences.saveNotificationPreferences([
          record as NotificationPreference,
        ]);
      case "adaptation_profile":
        return this.repositories.adaptation.saveProfiles([record as AdaptationProfile]);
      case "activity_event":
        return this.repositories.history.saveActivityEvents([record as ActivityEvent]);
      default:
        return Promise.resolve();
    }
  }

  private toRemoteRecord(
    accountId: string,
    deviceId: string,
    kind: SyncEntityKind,
    record: SyncEntityRecord,
  ): RemoteSyncRecord {
    const remoteId = toRemoteId(kind, record);

    return {
      accountId,
      entityKind: kind,
      entityId: record.id,
      remoteId,
      payload: JSON.stringify({ ...record, remoteId }),
      version: record.version,
      lastWriterDeviceId: deviceId,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    };
  }

  private flattenLocal(state: LocalSyncState) {
    return syncEntityOrder.flatMap((kind) =>
      this.getByKind(state, kind).map((record) => ({ kind, record })),
    );
  }
}

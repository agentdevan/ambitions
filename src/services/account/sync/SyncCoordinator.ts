import {
  AdaptationProfile,
  DailyPlan,
  EntitySyncState,
  Goal,
  GoalMilestone,
  RemoteSyncRecord,
  SyncEntityKind,
  SyncMode,
  SyncOperationKind,
  SyncOperationStatus,
  SyncStateSnapshot,
  Task,
  UserPreferences,
} from "../../../domain/models";
import { AccountRepository } from "../../../repositories/AccountRepository";
import { AdaptationRepository } from "../../../repositories/AdaptationRepository";
import { GoalRepository } from "../../../repositories/GoalRepository";
import { PlanRepository } from "../../../repositories/PlanRepository";
import { PreferencesRepository } from "../../../repositories/PreferencesRepository";
import { TaskRepository } from "../../../repositories/TaskRepository";
import { buildConflictRecord, MergeEvaluator } from "./MergeEvaluator";
import {
  duplicateConflictRecord,
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
}

export class SyncCoordinator {
  constructor(
    private readonly accountRepository: AccountRepository,
    private readonly repositories: SyncRepositories,
  ) {}

  async countMeaningfulLocalRecords() {
    const [goals, milestones, tasks, plans, preferences] = await Promise.all([
      this.repositories.goals.listGoals(),
      this.repositories.goals.listMilestones(),
      this.repositories.tasks.listTasks(),
      this.repositories.planning.listDailyPlans(),
      this.repositories.preferences.getUserPreferences(),
    ]);

    return {
      hasMeaningfulLocalData:
        goals.length > 0 ||
        milestones.length > 0 ||
        tasks.length > 0 ||
        plans.length > 0 ||
        preferences?.metadata.onboardingCompleted === true ||
        preferences?.metadata.onboardingCompleted === "true",
      pendingRecordCount:
        goals.length + milestones.length + tasks.length + plans.length + (preferences ? 1 : 0),
    };
  }

  async attachLocalDataToAccount(accountId: string) {
    const now = new Date().toISOString();
    const {
      goals,
      milestones,
      tasks,
      preferences,
      adaptationProfile,
      dailyPlans,
    } = await this.loadLocalSyncState();

    await Promise.all([
      this.repositories.goals.saveGoals(
        goals.map((goal) => prepareOwnedRecord("goal", goal, accountId, now)),
      ),
      this.repositories.goals.saveMilestones(
        milestones.map((milestone) => prepareOwnedRecord("milestone", milestone, accountId, now)),
      ),
      this.repositories.tasks.saveTasks(
        tasks.map((task) => prepareOwnedRecord("task", task, accountId, now)),
      ),
      preferences
        ? this.repositories.preferences.saveUserPreferences(
            prepareOwnedRecord("preferences", preferences, accountId, now),
          )
        : Promise.resolve(),
      adaptationProfile
        ? this.repositories.adaptation.saveProfiles([
            prepareOwnedRecord("adaptation_profile", adaptationProfile, accountId, now),
          ])
        : Promise.resolve(),
      this.repositories.planning.saveDailyPlans(
        dailyPlans.map((plan) => prepareOwnedRecord("daily_plan", plan, accountId, now)),
      ),
    ]);
  }

  async sync(accountId: string, syncState: SyncStateSnapshot, kind: SyncOperationKind) {
    const now = new Date().toISOString();
    const operationId = `sync:${kind}:${now}`;

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
      updatedAt: now,
    });

    try {
      const localState = await this.loadLocalSyncState();
      const remoteRecords = await this.accountRepository.listRemoteRecords(accountId);
      const remoteByKey = new Map(
        remoteRecords.map((record) => [`${record.entityKind}:${record.remoteId}`, record] as const),
      );
      const remoteWrites: RemoteSyncRecord[] = [];
      let pendingPushCount = 0;
      let pendingPullCount = 0;
      let conflictCount = 0;

      for (const entityKind of syncEntityOrder) {
        const localRecords = this.getByKind(localState, entityKind);

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
                id: `conflict:${entityKind}:${localRecord.id}:${now}`,
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

            if (decision.strategy === "preserve_both") {
              const preserved = duplicateConflictRecord(entityKind, remoteEntity, now);
              if (preserved) {
                await this.saveLocalRecord(entityKind, preserved);
              }

              await this.saveLocalRecord(entityKind, {
                ...localRecord,
                syncState: EntitySyncState.Conflict,
                updatedAt: now,
              });
            }

            continue;
          }

          await this.saveLocalRecord(
            entityKind,
            normalizeRemoteRecord(entityKind, localRecord, accountId, now),
          );
        }
      }

      const knownRemoteIds = new Set(
        this.flattenLocal(localState).map((entry) => `${entry.kind}:${toRemoteId(entry.kind, entry.record)}`),
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

      if (remoteWrites.length > 0) {
        await this.accountRepository.saveRemoteRecords(remoteWrites);
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

      await this.accountRepository.saveSyncState({
        ...syncState,
        accountId,
        mode: conflictCount > 0 ? SyncMode.ReviewRequired : SyncMode.Ready,
        lastSyncAt: now,
        pendingPushCount,
        pendingPullCount,
        unresolvedConflictCount: conflictCount,
        lastError: null,
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
        mode: SyncMode.Degraded,
        lastError: message,
        updatedAt: now,
      });

      throw error;
    }
  }

  private async loadLocalSyncState() {
    const [goals, milestones, tasks, preferences, adaptationProfile, dailyPlans] = await Promise.all([
      this.repositories.goals.listGoals(),
      this.repositories.goals.listMilestones(),
      this.repositories.tasks.listTasks(),
      this.repositories.preferences.getUserPreferences(),
      this.repositories.adaptation.getLatestProfile(),
      this.repositories.planning.listDailyPlans(),
    ]);

    return { goals, milestones, tasks, preferences, adaptationProfile, dailyPlans };
  }

  private getByKind(
    state: Awaited<ReturnType<SyncCoordinator["loadLocalSyncState"]>>,
    kind: SyncEntityKind,
  ): SyncEntityRecord[] {
    switch (kind) {
      case "goal":
        return state.goals;
      case "milestone":
        return state.milestones;
      case "task":
        return state.tasks;
      case "preferences":
        return state.preferences ? [state.preferences] : [];
      case "adaptation_profile":
        return state.adaptationProfile ? [state.adaptationProfile] : [];
      case "daily_plan":
        return state.dailyPlans;
      default:
        return [];
    }
  }

  private async saveLocalRecord(kind: string, record: SyncEntityRecord) {
    switch (kind) {
      case "goal":
        return this.repositories.goals.saveGoals([record as Goal]);
      case "milestone":
        return this.repositories.goals.saveMilestones([record as GoalMilestone]);
      case "task":
        return this.repositories.tasks.saveTasks([record as Task]);
      case "preferences":
        return this.repositories.preferences.saveUserPreferences(record as UserPreferences);
      case "adaptation_profile":
        return this.repositories.adaptation.saveProfiles([record as AdaptationProfile]);
      case "daily_plan":
        return this.repositories.planning.saveDailyPlans([record as DailyPlan]);
      default:
        return Promise.resolve();
    }
  }

  private toRemoteRecord(
    accountId: string,
    deviceId: string,
    kind: string,
    record: SyncEntityRecord,
  ): RemoteSyncRecord {
    const remoteId = toRemoteId(kind as never, record);

    return {
      accountId,
      entityKind: kind as never,
      entityId: record.id,
      remoteId,
      payload: JSON.stringify({ ...record, remoteId }),
      version: record.version,
      lastWriterDeviceId: deviceId,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    };
  }

  private flattenLocal(state: Awaited<ReturnType<SyncCoordinator["loadLocalSyncState"]>>) {
    return syncEntityOrder.flatMap((kind) =>
      this.getByKind(state, kind).map((record) => ({ kind, record })),
    );
  }
}

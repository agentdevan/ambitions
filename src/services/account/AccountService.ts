import {
  AccountIdentity,
  AccountSnapshot,
  AuthProvider,
  AuthStatus,
  EntitySyncState,
  LocalAttachmentStatus,
  SyncMode,
  SyncOperationKind,
} from "../../domain/models";
import { AccountRepository } from "../../repositories/AccountRepository";
import { AdaptationRepository } from "../../repositories/AdaptationRepository";
import { GoalRepository } from "../../repositories/GoalRepository";
import { PlanRepository } from "../../repositories/PlanRepository";
import { PreferencesRepository } from "../../repositories/PreferencesRepository";
import { TaskRepository } from "../../repositories/TaskRepository";
import { AppleAuthenticationService } from "./AppleAuthenticationService";
import { SyncCoordinator } from "./sync/SyncCoordinator";

interface AccountServiceDependencies {
  accountRepository: AccountRepository;
  repositories: {
    goals: GoalRepository;
    tasks: TaskRepository;
    planning: PlanRepository;
    preferences: PreferencesRepository;
    adaptation: AdaptationRepository;
  };
}

export class AccountService {
  private readonly syncCoordinator: SyncCoordinator;

  constructor(private readonly dependencies: AccountServiceDependencies) {
    this.syncCoordinator = new SyncCoordinator(
      dependencies.accountRepository,
      dependencies.repositories,
    );
  }

  async initialize() {
    const now = new Date().toISOString();
    const [authState, attachmentState, syncState] = await Promise.all([
      this.dependencies.accountRepository.getAuthState(),
      this.dependencies.accountRepository.getAttachmentState(),
      this.dependencies.accountRepository.getSyncState(),
    ]);
    const appleAvailable = await AppleAuthenticationService.isAvailable();

    if (!authState) {
      await this.dependencies.accountRepository.saveAuthState({
        status: appleAvailable ? AuthStatus.LocalOnly : AuthStatus.Unavailable,
        signedInAccountId: null,
        primaryProvider: AuthProvider.Apple,
        availableProviders: [AuthProvider.Apple],
        canAttemptAppleSignIn: appleAvailable,
        lastAuthenticatedAt: null,
        lastError: null,
        createdAt: now,
        updatedAt: now,
      });
    } else if (authState.canAttemptAppleSignIn !== appleAvailable) {
      await this.dependencies.accountRepository.saveAuthState({
        ...authState,
        canAttemptAppleSignIn: appleAvailable,
        status:
          authState.signedInAccountId || appleAvailable ? authState.status : AuthStatus.Unavailable,
        updatedAt: now,
      });
    }

    if (!attachmentState) {
      const localCounts = await this.syncCoordinator.countMeaningfulLocalRecords();
      await this.dependencies.accountRepository.saveAttachmentState({
        accountId: null,
        status: LocalAttachmentStatus.Detached,
        hasMeaningfulLocalData: localCounts.hasMeaningfulLocalData,
        pendingRecordCount: localCounts.pendingRecordCount,
        lastAttachedAt: null,
        lastError: null,
        createdAt: now,
        updatedAt: now,
      });
    }

    if (!syncState) {
      await this.dependencies.accountRepository.saveSyncState({
        accountId: null,
        deviceId: `device:${now}`,
        mode: SyncMode.LocalOnly,
        lastSyncAt: null,
        pendingPushCount: 0,
        pendingPullCount: 0,
        unresolvedConflictCount: 0,
        lastError: null,
        metadata: { transport: "foundation" },
        createdAt: now,
        updatedAt: now,
      });
    }
  }

  async getSnapshot(): Promise<AccountSnapshot> {
    await this.initialize();
    const [auth, attachment, sync, conflicts] = await Promise.all([
      this.dependencies.accountRepository.getAuthState(),
      this.dependencies.accountRepository.getAttachmentState(),
      this.dependencies.accountRepository.getSyncState(),
      this.dependencies.accountRepository.listOpenConflicts(),
    ]);
    const localCounts = await this.syncCoordinator.countMeaningfulLocalRecords();
    const nextAttachment =
      attachment &&
      (attachment.hasMeaningfulLocalData !== localCounts.hasMeaningfulLocalData ||
        attachment.pendingRecordCount !== localCounts.pendingRecordCount)
        ? {
            ...attachment,
            hasMeaningfulLocalData: localCounts.hasMeaningfulLocalData,
            pendingRecordCount: localCounts.pendingRecordCount,
            updatedAt: new Date().toISOString(),
          }
        : attachment!;

    if (nextAttachment !== attachment) {
      await this.dependencies.accountRepository.saveAttachmentState(nextAttachment);
    }

    const account = auth?.signedInAccountId
      ? await this.dependencies.accountRepository.getAccount(auth.signedInAccountId)
      : null;

    return {
      account,
      auth: auth!,
      attachment: nextAttachment,
      sync: sync!,
      conflicts,
    };
  }

  async signInWithApple() {
    await this.initialize();
    const now = new Date().toISOString();
    const authState = (await this.dependencies.accountRepository.getAuthState())!;

    if (!authState.canAttemptAppleSignIn) {
      await this.dependencies.accountRepository.saveAuthState({
        ...authState,
        status: AuthStatus.Unavailable,
        lastError: "Sign in with Apple is only available in supported native builds.",
        updatedAt: now,
      });
      return this.getSnapshot();
    }

    await this.dependencies.accountRepository.saveAuthState({
      ...authState,
      status: AuthStatus.SigningIn,
      lastError: null,
      updatedAt: now,
    });

    try {
      const result = await AppleAuthenticationService.signIn();
      const accountId = `account:${result.provider}:${result.providerSubject}`;
      const existing = await this.dependencies.accountRepository.getAccount(accountId);
      const account: AccountIdentity = {
        id: accountId,
        provider: result.provider,
        providerSubject: result.providerSubject,
        email: result.email ?? existing?.email ?? null,
        displayName: result.displayName ?? existing?.displayName ?? null,
        metadata: existing?.metadata ?? {},
        ownerUserId: accountId,
        remoteId: accountId,
        syncState: EntitySyncState.LocalOnly,
        version: existing ? existing.version + 1 : 1,
        lastSyncedAt: existing?.lastSyncedAt ?? null,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      };

      await this.dependencies.accountRepository.saveAccount(account);

      const localCounts = await this.syncCoordinator.countMeaningfulLocalRecords();
      const attachmentState = (await this.dependencies.accountRepository.getAttachmentState())!;

      await Promise.all([
        this.dependencies.accountRepository.saveAuthState({
          ...authState,
          status: AuthStatus.Authenticated,
          signedInAccountId: accountId,
          lastAuthenticatedAt: now,
          lastError: null,
          updatedAt: now,
        }),
        this.dependencies.accountRepository.saveAttachmentState({
          ...attachmentState,
          accountId,
          status: localCounts.hasMeaningfulLocalData
            ? LocalAttachmentStatus.ConfirmationRequired
            : LocalAttachmentStatus.Detached,
          hasMeaningfulLocalData: localCounts.hasMeaningfulLocalData,
          pendingRecordCount: localCounts.pendingRecordCount,
          lastError: null,
          updatedAt: now,
        }),
      ]);
    } catch (error) {
      await this.dependencies.accountRepository.saveAuthState({
        ...authState,
        status: AuthStatus.Error,
        lastError: error instanceof Error ? error.message : "Sign in with Apple failed.",
        updatedAt: now,
      });
    }

    return this.getSnapshot();
  }

  async attachLocalDataToSignedInAccount() {
    const now = new Date().toISOString();
    const snapshot = await this.getSnapshot();
    const accountId = snapshot.auth.signedInAccountId;

    if (!accountId) {
      throw new Error("No signed-in account is available for attachment.");
    }

    await this.dependencies.accountRepository.saveAttachmentState({
      ...snapshot.attachment,
      accountId,
      status: LocalAttachmentStatus.Attaching,
      lastError: null,
      updatedAt: now,
    });

    try {
      await this.syncCoordinator.attachLocalDataToAccount(accountId);
      const syncState = (await this.dependencies.accountRepository.getSyncState())!;

      await Promise.all([
        this.dependencies.accountRepository.saveAttachmentState({
          ...snapshot.attachment,
          accountId,
          status: LocalAttachmentStatus.Attached,
          hasMeaningfulLocalData: false,
          pendingRecordCount: 0,
          lastAttachedAt: now,
          lastError: null,
          updatedAt: now,
        }),
        this.dependencies.accountRepository.saveSyncState({
          ...syncState,
          accountId,
          mode: SyncMode.Ready,
          lastError: null,
          updatedAt: now,
        }),
      ]);

      await this.syncCoordinator.sync(accountId, syncState, SyncOperationKind.AttachLocalData);
    } catch (error) {
      await this.dependencies.accountRepository.saveAttachmentState({
        ...snapshot.attachment,
        accountId,
        status: LocalAttachmentStatus.Failed,
        lastError: error instanceof Error ? error.message : "Local data could not be attached.",
        updatedAt: now,
      });
      throw error;
    }

    return this.getSnapshot();
  }

  async deferLocalAttachment() {
    const snapshot = await this.getSnapshot();
    const now = new Date().toISOString();

    await this.dependencies.accountRepository.saveAttachmentState({
      ...snapshot.attachment,
      status: LocalAttachmentStatus.Detached,
      lastError: null,
      updatedAt: now,
    });

    return this.getSnapshot();
  }

  async syncNow(kind: SyncOperationKind = SyncOperationKind.PushPull) {
    const snapshot = await this.getSnapshot();
    if (!snapshot.auth.signedInAccountId || snapshot.attachment.status !== LocalAttachmentStatus.Attached) {
      return snapshot;
    }

    await this.syncCoordinator.sync(snapshot.auth.signedInAccountId, snapshot.sync, kind);
    return this.getSnapshot();
  }
}

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
import { waitForStartupReady } from "../../bootstrap/runtime/startupBarrier";
import { AccountRepository } from "../../repositories/AccountRepository";
import { AdaptationRepository } from "../../repositories/AdaptationRepository";
import { GoalRepository } from "../../repositories/GoalRepository";
import { HistoryRepository } from "../../repositories/HistoryRepository";
import { PlanRepository } from "../../repositories/PlanRepository";
import { PreferencesRepository } from "../../repositories/PreferencesRepository";
import { TaskRepository } from "../../repositories/TaskRepository";
import { NetworkStatusService } from "./NetworkStatusService";
import { SupabaseAccountClient } from "./SupabaseAccountClient";
import { getAuthUnavailableMessage, mapAuthErrorMessage } from "./accountCopy";
import { SyncCoordinator } from "./sync/SyncCoordinator";

interface AccountServiceDependencies {
  accountRepository: AccountRepository;
  repositories: {
    goals: GoalRepository;
    tasks: TaskRepository;
    planning: PlanRepository;
    preferences: PreferencesRepository;
    adaptation: AdaptationRepository;
    history: HistoryRepository;
  };
}

export class AccountService {
  private readonly remoteClient = new SupabaseAccountClient();
  private readonly syncCoordinator: SyncCoordinator;
  private activeSyncPromise: Promise<void> | null = null;
  private startupSyncPromise: Promise<AccountSnapshot> | null = null;
  private initializationPromise: Promise<void> | null = null;

  constructor(private readonly dependencies: AccountServiceDependencies) {
    this.syncCoordinator = new SyncCoordinator(
      dependencies.accountRepository,
      dependencies.repositories,
      this.remoteClient,
    );
  }

  async initialize() {
    if (!this.initializationPromise) {
      this.initializationPromise = this.performInitialize().catch((error) => {
        this.initializationPromise = null;
        throw error;
      });
    }

    return this.initializationPromise;
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

  async createAccount(input: { email: string; password: string; displayName?: string }) {
    return this.authenticate("sign_up", input);
  }

  async signIn(input: { email: string; password: string }) {
    return this.authenticate("sign_in", input);
  }

  async signOut() {
    await this.initialize();
    const now = new Date().toISOString();
    const authState = (await this.dependencies.accountRepository.getAuthState())!;
    const syncState = (await this.dependencies.accountRepository.getSyncState())!;
    const localCounts = await this.syncCoordinator.countMeaningfulLocalRecords();

    if (this.remoteClient.isConfigured()) {
      await this.remoteClient.signOut();
    }

    await Promise.all([
      this.dependencies.accountRepository.saveAuthState({
        ...authState,
        status: this.remoteClient.isConfigured() ? AuthStatus.LocalOnly : AuthStatus.Unavailable,
        signedInAccountId: null,
        sessionExpiresAt: null,
        lastError: null,
        updatedAt: now,
      }),
      this.dependencies.accountRepository.saveAttachmentState({
        accountId: null,
        status: LocalAttachmentStatus.Detached,
        hasMeaningfulLocalData: localCounts.hasMeaningfulLocalData,
        pendingRecordCount: localCounts.pendingRecordCount,
        lastAttachedAt: null,
        lastError: null,
        createdAt: now,
        updatedAt: now,
      }),
      this.dependencies.accountRepository.saveSyncState({
        ...syncState,
        accountId: null,
        mode: SyncMode.LocalOnly,
        pendingPushCount: 0,
        pendingPullCount: 0,
        unresolvedConflictCount: 0,
        lastError: null,
        updatedAt: now,
      }),
    ]);

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

      await this.dependencies.accountRepository.saveAttachmentState({
        ...snapshot.attachment,
        accountId,
        status: LocalAttachmentStatus.Attached,
        hasMeaningfulLocalData: false,
        pendingRecordCount: 0,
        lastAttachedAt: now,
        lastError: null,
        updatedAt: now,
      });
      await this.dependencies.accountRepository.saveSyncState({
        ...syncState,
        accountId,
        mode: SyncMode.PendingChanges,
        lastError: null,
        updatedAt: now,
      });

      if (await NetworkStatusService.isConnected()) {
        await this.runSerializedSync(accountId, syncState, SyncOperationKind.AttachLocalData);
      } else {
        await this.dependencies.accountRepository.saveSyncState({
          ...syncState,
          accountId,
          mode: SyncMode.Offline,
          lastError: null,
          updatedAt: now,
        });
      }
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
      accountId: null,
      status: LocalAttachmentStatus.Detached,
      lastError: null,
      updatedAt: now,
    });

    await this.dependencies.accountRepository.saveSyncState({
      ...snapshot.sync,
      accountId: null,
      mode: SyncMode.LocalOnly,
      pendingPushCount: 0,
      pendingPullCount: 0,
      unresolvedConflictCount: 0,
      lastError: null,
      updatedAt: now,
    });

    return this.getSnapshot();
  }

  async notePendingChanges() {
    const snapshot = await this.getSnapshot();
    const accountId = snapshot.auth.signedInAccountId;

    if (!accountId || snapshot.attachment.status !== LocalAttachmentStatus.Attached) {
      return snapshot;
    }

    const now = new Date().toISOString();
    const counts = await this.syncCoordinator.countPendingRecords(accountId);

    await this.dependencies.accountRepository.saveSyncState({
      ...snapshot.sync,
      accountId,
      mode: counts.pendingPushCount > 0 ? SyncMode.PendingChanges : SyncMode.Synced,
      pendingPushCount: counts.pendingPushCount,
      lastError: null,
      updatedAt: now,
    });

    const online = await NetworkStatusService.isConnected();
    if (online && counts.pendingPushCount > 0) {
      void this.syncNow().catch(() => null);
    } else if (!online) {
      await this.dependencies.accountRepository.saveSyncState({
        ...snapshot.sync,
        accountId,
        mode: SyncMode.Offline,
        pendingPushCount: counts.pendingPushCount,
        updatedAt: now,
      });
    }

    return this.getSnapshot();
  }

  async syncNow(kind: SyncOperationKind = SyncOperationKind.PushPull) {
    await waitForStartupReady();

    const snapshot = await this.getSnapshot();
    if (!snapshot.auth.signedInAccountId || snapshot.attachment.status !== LocalAttachmentStatus.Attached) {
      return snapshot;
    }

    const online = await NetworkStatusService.isConnected();
    if (!online) {
      await this.dependencies.accountRepository.saveSyncState({
        ...snapshot.sync,
        accountId: snapshot.auth.signedInAccountId,
        mode: SyncMode.Offline,
        lastError: null,
        updatedAt: new Date().toISOString(),
      });
      return this.getSnapshot();
    }

    await this.runSerializedSync(snapshot.auth.signedInAccountId, snapshot.sync, kind);
    return this.getSnapshot();
  }

  async runStartupSyncIfNeeded() {
    if (!this.startupSyncPromise) {
      this.startupSyncPromise = (async () => {
        await waitForStartupReady();
        return this.syncNow(SyncOperationKind.Startup);
      })().finally(() => {
        this.startupSyncPromise = null;
      });
    }

    return this.startupSyncPromise;
  }

  private async authenticate(
    mode: "sign_up" | "sign_in",
    input: { email: string; password: string; displayName?: string },
  ) {
    await this.initialize();
    const now = new Date().toISOString();
    const authState = (await this.dependencies.accountRepository.getAuthState())!;

    if (!this.remoteClient.isConfigured()) {
      await this.dependencies.accountRepository.saveAuthState({
        ...authState,
        status: AuthStatus.Unavailable,
        lastError: getAuthUnavailableMessage(),
        updatedAt: now,
      });
      return this.getSnapshot();
    }

    await this.dependencies.accountRepository.saveAuthState({
      ...authState,
      status: mode === "sign_up" ? AuthStatus.SigningUp : AuthStatus.SigningIn,
      lastError: null,
      updatedAt: now,
    });

    try {
      const remoteSession =
        mode === "sign_up"
          ? await this.remoteClient.signUp(input)
          : await this.remoteClient.signIn(input);
      const accountId = `account:${remoteSession.user.id}`;
      const existing = await this.dependencies.accountRepository.getAccount(accountId);
      const identity = this.remoteClient.buildAccountIdentity(remoteSession.user);
      const account: AccountIdentity = {
        ...identity,
        metadata: {
          ...identity.metadata,
          initials: buildInitials(identity.displayName ?? identity.email ?? ""),
        },
        syncState: EntitySyncState.LocalOnly,
        version: existing ? existing.version + 1 : 1,
        lastSyncedAt: existing?.lastSyncedAt ?? null,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      };

      await this.dependencies.accountRepository.saveAccount(account);

      const localCounts = await this.syncCoordinator.countMeaningfulLocalRecords();
      const attachmentState = (await this.dependencies.accountRepository.getAttachmentState())!;
      const nextAttachmentStatus = localCounts.hasMeaningfulLocalData
        ? LocalAttachmentStatus.ConfirmationRequired
        : LocalAttachmentStatus.Attached;

      await Promise.all([
        this.dependencies.accountRepository.saveAuthState({
          ...authState,
          status: AuthStatus.Authenticated,
          signedInAccountId: accountId,
          sessionExpiresAt: remoteSession.session.expires_at
            ? new Date(remoteSession.session.expires_at * 1000).toISOString()
            : null,
          lastAuthenticatedAt: now,
          lastError: null,
          updatedAt: now,
        }),
        this.dependencies.accountRepository.saveAttachmentState({
          ...attachmentState,
          accountId,
          status: nextAttachmentStatus,
          hasMeaningfulLocalData: localCounts.hasMeaningfulLocalData,
          pendingRecordCount: localCounts.pendingRecordCount,
          lastError: null,
          updatedAt: now,
        }),
      ]);

      const syncState = (await this.dependencies.accountRepository.getSyncState())!;
      await this.dependencies.accountRepository.saveSyncState({
        ...syncState,
        accountId,
        mode:
          nextAttachmentStatus === LocalAttachmentStatus.Attached ? SyncMode.PendingChanges : SyncMode.LocalOnly,
        lastError: null,
        updatedAt: now,
      });

      if (nextAttachmentStatus === LocalAttachmentStatus.Attached) {
        if (await NetworkStatusService.isConnected()) {
          await this.runSerializedSync(accountId, syncState, SyncOperationKind.Startup);
        } else {
          await this.dependencies.accountRepository.saveSyncState({
            ...syncState,
            accountId,
            mode: SyncMode.Offline,
            lastError: null,
            updatedAt: now,
          });
        }
      }
    } catch (error) {
      await this.dependencies.accountRepository.saveAuthState({
        ...authState,
        status: AuthStatus.Error,
        lastError: mapAuthErrorMessage(error, mode),
        updatedAt: now,
      });
    }

    return this.getSnapshot();
  }

  private async restoreSession() {
    const authState = await this.dependencies.accountRepository.getAuthState();
    const syncState = await this.dependencies.accountRepository.getSyncState();

    if (!authState || !syncState || !this.remoteClient.isConfigured()) {
      return;
    }

    try {
      const remoteSession = await this.remoteClient.restoreSession();
      const now = new Date().toISOString();

      if (!remoteSession) {
        if (authState.signedInAccountId) {
          await this.dependencies.accountRepository.saveAuthState({
            ...authState,
            status: AuthStatus.LocalOnly,
            signedInAccountId: null,
            sessionExpiresAt: null,
            lastError: "Your session ended. Sign in again to keep syncing.",
            updatedAt: now,
          });
          await this.dependencies.accountRepository.saveSyncState({
            ...syncState,
            accountId: null,
            mode: SyncMode.LocalOnly,
            updatedAt: now,
          });
        }
        return;
      }

      const identity = this.remoteClient.buildAccountIdentity(remoteSession.user);
      const existing = await this.dependencies.accountRepository.getAccount(identity.id);
      const account: AccountIdentity = {
        ...identity,
        syncState: EntitySyncState.LocalOnly,
        version: existing ? Math.max(existing.version, 1) : 1,
        lastSyncedAt: existing?.lastSyncedAt ?? null,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      };

      await this.dependencies.accountRepository.saveAccount(account);
      await this.dependencies.accountRepository.saveAuthState({
        ...authState,
        status: AuthStatus.Authenticated,
        signedInAccountId: account.id,
        sessionExpiresAt: remoteSession.session.expires_at
          ? new Date(remoteSession.session.expires_at * 1000).toISOString()
          : null,
        lastAuthenticatedAt: now,
        lastError: null,
        updatedAt: now,
      });
    } catch (error) {
      await this.dependencies.accountRepository.saveAuthState({
        ...authState,
        status: AuthStatus.Error,
        signedInAccountId: null,
        sessionExpiresAt: null,
        lastError: mapAuthErrorMessage(error, "sign_in"),
        updatedAt: new Date().toISOString(),
      });
    }
  }

  private async runSerializedSync(
    accountId: string,
    syncState: AccountSnapshot["sync"],
    kind: SyncOperationKind,
  ) {
    while (this.activeSyncPromise) {
      await this.activeSyncPromise;
    }

    const syncPromise = this.syncCoordinator.sync(accountId, syncState, kind);
    this.activeSyncPromise = syncPromise.then(
      () => undefined,
      () => undefined,
    );

    try {
      await syncPromise;
    } finally {
      if (this.activeSyncPromise) {
        await this.activeSyncPromise;
        this.activeSyncPromise = null;
      }
    }
  }

  private async performInitialize() {
    const now = new Date().toISOString();
    const [authState, attachmentState, syncState] = await Promise.all([
      this.dependencies.accountRepository.getAuthState(),
      this.dependencies.accountRepository.getAttachmentState(),
      this.dependencies.accountRepository.getSyncState(),
    ]);
    const backendConfigured = this.remoteClient.isConfigured();

    if (!authState) {
      await this.dependencies.accountRepository.saveAuthState({
        status: backendConfigured ? AuthStatus.LocalOnly : AuthStatus.Unavailable,
        signedInAccountId: null,
        primaryProvider: AuthProvider.Email,
        availableProviders: backendConfigured ? [AuthProvider.Email] : [],
        sessionExpiresAt: null,
        lastAuthenticatedAt: null,
        lastError: backendConfigured ? null : getAuthUnavailableMessage(),
        createdAt: now,
        updatedAt: now,
      });
    } else if (!backendConfigured && authState.signedInAccountId) {
      await this.dependencies.accountRepository.saveAuthState({
        ...authState,
        status: AuthStatus.Unavailable,
        signedInAccountId: null,
        sessionExpiresAt: null,
        availableProviders: [],
        lastError: getAuthUnavailableMessage(),
        updatedAt: now,
      });
    } else if (
      authState.primaryProvider !== AuthProvider.Email ||
      authState.availableProviders.length !== (backendConfigured ? 1 : 0)
    ) {
      await this.dependencies.accountRepository.saveAuthState({
        ...authState,
        status:
          backendConfigured && authState.status === AuthStatus.Unavailable
            ? AuthStatus.LocalOnly
            : !backendConfigured && !authState.signedInAccountId
              ? AuthStatus.Unavailable
              : authState.status,
        primaryProvider: AuthProvider.Email,
        availableProviders: backendConfigured ? [AuthProvider.Email] : [],
        lastError: backendConfigured ? authState.lastError : getAuthUnavailableMessage(),
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
        deviceId: `device:${Math.random().toString(36).slice(2, 10)}`,
        mode: SyncMode.LocalOnly,
        lastSyncAt: null,
        pendingPushCount: 0,
        pendingPullCount: 0,
        unresolvedConflictCount: 0,
        lastError: null,
        metadata: { transport: backendConfigured ? "supabase" : "local_only" },
        createdAt: now,
        updatedAt: now,
      });
    } else if (!backendConfigured && syncState.accountId) {
      await this.dependencies.accountRepository.saveSyncState({
        ...syncState,
        accountId: null,
        mode: SyncMode.LocalOnly,
        pendingPushCount: 0,
        pendingPullCount: 0,
        unresolvedConflictCount: 0,
        lastError: null,
        updatedAt: now,
      });
    }

    await this.restoreSession();
  }
}

function buildInitials(value: string) {
  return value
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase() ?? "")
    .join("");
}

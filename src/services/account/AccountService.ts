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
import { RemoteSessionSnapshot, SupabaseAccountClient } from "./SupabaseAccountClient";
import {
  AuthFeedback,
  buildConfirmationRequiredFeedback,
  buildExistingAccountFeedback,
  getAuthUnavailableMessage,
  mapAuthErrorFeedback,
} from "./accountCopy";
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

type AccountSnapshotListener = (snapshot: AccountSnapshot) => void;

export interface AuthActionResult {
  snapshot: AccountSnapshot;
  feedback: AuthFeedback | null;
}

interface ResolvedAuthSession {
  session: RemoteSessionSnapshot["session"];
  user: RemoteSessionSnapshot["user"];
}

interface SignUpResolution {
  feedback: AuthFeedback | null;
  session: ResolvedAuthSession | null;
}

export class AccountService {
  private readonly remoteClient = new SupabaseAccountClient();
  private readonly syncCoordinator: SyncCoordinator;
  private activeSyncPromise: Promise<void> | null = null;
  private startupSyncPromise: Promise<AccountSnapshot> | null = null;
  private initializationPromise: Promise<void> | null = null;
  private reconnectListenerUnsubscribe: { remove: () => void } | null = null;
  private lastKnownConnectivity: boolean | null = null;
  private readonly snapshotListeners = new Set<AccountSnapshotListener>();

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

    await this.initializationPromise;
    this.ensureReconnectListener();
  }

  subscribe(listener: AccountSnapshotListener) {
    this.snapshotListeners.add(listener);
    return () => {
      this.snapshotListeners.delete(listener);
    };
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

    const signedInAccountId = auth?.signedInAccountId ?? null;
    const account = signedInAccountId
      ? await this.dependencies.accountRepository.getAccount(signedInAccountId)
      : null;

    return {
      account,
      auth: auth!,
      attachment: nextAttachment,
      sync: sync!,
      conflicts: signedInAccountId
        ? conflicts.filter((conflict) => conflict.accountId === signedInAccountId)
        : [],
    };
  }

  async createAccount(input: { email: string; password: string; displayName?: string }) {
    return this.authenticate("sign_up", input);
  }

  async signIn(input: { email: string; password: string }) {
    return this.authenticate("sign_in", input);
  }

  async clearTransientAuthFeedback() {
    await this.initialize();
    const now = new Date().toISOString();
    const authState = (await this.dependencies.accountRepository.getAuthState())!;
    const nextStatus =
      authState.signedInAccountId
        ? authState.status
        : this.remoteClient.isConfigured()
          ? AuthStatus.LocalOnly
          : AuthStatus.Unavailable;

    if (authState.lastError === null && authState.status === nextStatus) {
      return this.getSnapshot();
    }

    await this.dependencies.accountRepository.saveAuthState({
      ...authState,
      status: nextStatus,
      lastError: null,
      updatedAt: now,
    });

    return this.getSnapshot();
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
  ): Promise<AuthActionResult> {
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
      return { snapshot: await this.getSnapshot(), feedback: null };
    }

    await this.dependencies.accountRepository.saveAuthState({
      ...authState,
      status: mode === "sign_up" ? AuthStatus.SigningUp : AuthStatus.SigningIn,
      lastError: null,
      updatedAt: now,
    });

    try {
      let activeSession: ResolvedAuthSession | null = null;

      if (mode === "sign_up") {
        const signUpResolution = await this.handleSignUpAuthentication(authState, now, input);
        if (signUpResolution.feedback) {
          return { snapshot: await this.getSnapshot(), feedback: signUpResolution.feedback };
        }
        activeSession = signUpResolution.session;
      } else {
        const signInSession = await this.remoteClient.signIn(input);
        activeSession = {
          session: signInSession.session,
          user: signInSession.user,
        };
      }

      if (!activeSession) {
        return { snapshot: await this.getSnapshot(), feedback: null };
      }

      const accountId = `account:${activeSession.user.id}`;
      const existing = await this.dependencies.accountRepository.getAccount(accountId);
      const identity = this.remoteClient.buildAccountIdentity(activeSession.user);
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
          sessionExpiresAt: activeSession.session?.expires_at
            ? new Date(activeSession.session.expires_at * 1000).toISOString()
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
      const feedback = mapAuthErrorFeedback(error, mode);
      this.logAuthDiagnostic("auth_error", {
        mode,
        email: input.email,
        rawMessage: error instanceof Error ? error.message : String(error ?? ""),
        rawCode:
          error && typeof error === "object" && "code" in error
            ? String((error as { code?: unknown }).code ?? "")
            : "",
        mappedCode: feedback.code,
        mappedMessage: feedback.message,
      });
      await this.dependencies.accountRepository.saveAuthState({
        ...authState,
        status: AuthStatus.Error,
        lastError: feedback.message,
        updatedAt: now,
      });

      return { snapshot: await this.getSnapshot(), feedback };
    }

    return { snapshot: await this.getSnapshot(), feedback: null };
  }

  private async handleSignUpAuthentication(
    authState: NonNullable<Awaited<ReturnType<AccountRepository["getAuthState"]>>>,
    now: string,
    input: { email: string; password: string; displayName?: string },
  ): Promise<SignUpResolution> {
    const remoteSession = await this.remoteClient.signUp(input);

    if (__DEV__) {
        this.logAuthDiagnostic("sign_up_result", {
          email: input.email,
          outcome: remoteSession.outcome,
          hasSession: !!remoteSession.session,
          identitiesLength: remoteSession.debug.identitiesLength,
          emailConfirmedAt: remoteSession.debug.emailConfirmedAt,
          obfuscatedExistingUser: remoteSession.debug.obfuscatedExistingUser,
        });
    }

    if (remoteSession.outcome === "email_exists") {
      await this.dependencies.accountRepository.saveAuthState({
        ...authState,
        status: AuthStatus.LocalOnly,
        signedInAccountId: null,
        sessionExpiresAt: null,
        lastError: null,
        updatedAt: now,
      });

      return {
        session: null,
        feedback: buildExistingAccountFeedback(),
      };
    }

    if (remoteSession.outcome === "confirmation_required") {
      await this.dependencies.accountRepository.saveAuthState({
        ...authState,
        status: AuthStatus.LocalOnly,
        signedInAccountId: null,
        sessionExpiresAt: null,
        lastError: null,
        updatedAt: now,
      });

      return {
        session: null,
        feedback: buildConfirmationRequiredFeedback(),
      };
    }

    return {
      feedback: null,
      session: {
        session: remoteSession.session,
        user: remoteSession.user,
      },
    };
  }

  private async restoreSession() {
    const authState = await this.dependencies.accountRepository.getAuthState();
    const attachmentState = await this.dependencies.accountRepository.getAttachmentState();
    const syncState = await this.dependencies.accountRepository.getSyncState();

    if (!authState || !attachmentState || !syncState || !this.remoteClient.isConfigured()) {
      return;
    }

    try {
      const remoteSession = await this.remoteClient.restoreSession();
      const now = new Date().toISOString();

      if (!remoteSession) {
        if (authState.signedInAccountId) {
          await this.resetLocalOnlyState({
            authState,
            attachmentState,
            syncState,
            now,
            authStatus: AuthStatus.LocalOnly,
            authError: "Your session ended. Sign in again to keep syncing.",
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
      await Promise.all([
        this.dependencies.accountRepository.saveAuthState({
          ...authState,
          status: AuthStatus.Authenticated,
          signedInAccountId: account.id,
          sessionExpiresAt: remoteSession.session?.expires_at
            ? new Date(remoteSession.session.expires_at * 1000).toISOString()
            : null,
          lastAuthenticatedAt: now,
          lastError: null,
          updatedAt: now,
        }),
        this.dependencies.accountRepository.saveAttachmentState({
          ...attachmentState,
          accountId: account.id,
          updatedAt: now,
        }),
        this.dependencies.accountRepository.saveSyncState({
          ...syncState,
          accountId: account.id,
          updatedAt: now,
        }),
      ]);
    } catch (error) {
      const now = new Date().toISOString();
      await this.resetLocalOnlyState({
        authState,
        attachmentState,
        syncState,
        now,
        authStatus: AuthStatus.Error,
        authError: mapAuthErrorFeedback(error, "sign_in").message,
      });
    }
  }

  private logAuthDiagnostic(event: string, payload: Record<string, unknown>) {
    if (__DEV__) {
      console.info("[AccountService]", event, payload);
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
      await this.emitSnapshot();
      await syncPromise;
    } finally {
      if (this.activeSyncPromise) {
        await this.activeSyncPromise;
        this.activeSyncPromise = null;
      }
      await this.emitSnapshot();
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
        lastError: backendConfigured ? null : getAuthUnavailableMessage(),
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
    }

    if (!backendConfigured && authState && attachmentState && syncState) {
      await this.resetLocalOnlyState({
        authState,
        attachmentState,
        syncState,
        now,
        authStatus: AuthStatus.Unavailable,
        authError: getAuthUnavailableMessage(),
      });
    }

    await this.restoreSession();
  }

  private ensureReconnectListener() {
    if (this.reconnectListenerUnsubscribe) {
      return;
    }

    this.reconnectListenerUnsubscribe = NetworkStatusService.addListener((isConnected) => {
      const cameBackOnline = this.lastKnownConnectivity === false && isConnected === true;
      this.lastKnownConnectivity = isConnected;

      if (!cameBackOnline) {
        return;
      }

      void this.retrySyncAfterReconnect();
    });
  }

  private async retrySyncAfterReconnect() {
    try {
      const snapshot = await this.getSnapshot();
      const canRetry =
        snapshot.auth.signedInAccountId &&
        snapshot.attachment.status === LocalAttachmentStatus.Attached &&
        [SyncMode.Offline, SyncMode.PendingChanges, SyncMode.Issue].includes(snapshot.sync.mode);

      if (!canRetry) {
        return;
      }

      await this.runSerializedSync(
        snapshot.auth.signedInAccountId as string,
        snapshot.sync,
        SyncOperationKind.PushPull,
      );
    } catch {
      // Keep reconnect retries silent; sync state already surfaces issues.
    }
  }

  private async emitSnapshot() {
    if (this.snapshotListeners.size === 0) {
      return;
    }

    const snapshot = await this.getSnapshot();
    for (const listener of this.snapshotListeners) {
      listener(snapshot);
    }
  }

  private async resetLocalOnlyState({
    authState,
    attachmentState,
    syncState,
    now,
    authStatus,
    authError,
  }: {
    authState: NonNullable<Awaited<ReturnType<AccountRepository["getAuthState"]>>>;
    attachmentState: NonNullable<Awaited<ReturnType<AccountRepository["getAttachmentState"]>>>;
    syncState: NonNullable<Awaited<ReturnType<AccountRepository["getSyncState"]>>>;
    now: string;
    authStatus: AuthStatus;
    authError: string | null;
  }) {
    const localCounts = await this.syncCoordinator.countMeaningfulLocalRecords();

    await Promise.all([
      this.dependencies.accountRepository.saveAuthState({
        ...authState,
        status: authStatus,
        signedInAccountId: null,
        sessionExpiresAt: null,
        availableProviders: this.remoteClient.isConfigured() ? [AuthProvider.Email] : [],
        lastError: authError,
        updatedAt: now,
      }),
      this.dependencies.accountRepository.saveAttachmentState({
        ...attachmentState,
        accountId: null,
        status: LocalAttachmentStatus.Detached,
        hasMeaningfulLocalData: localCounts.hasMeaningfulLocalData,
        pendingRecordCount: localCounts.pendingRecordCount,
        lastError: null,
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

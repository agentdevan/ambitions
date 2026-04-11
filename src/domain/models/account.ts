import { AuditMetadata, EntityRecord, ISODateTimeString, JsonMap } from "./shared";

export enum AuthProvider {
  Apple = "apple",
}

export enum AuthStatus {
  LocalOnly = "local_only",
  SigningIn = "signing_in",
  Authenticated = "authenticated",
  Unavailable = "unavailable",
  Error = "error",
}

export enum LocalAttachmentStatus {
  Detached = "detached",
  ConfirmationRequired = "confirmation_required",
  Attaching = "attaching",
  Attached = "attached",
  Failed = "failed",
}

export enum SyncMode {
  LocalOnly = "local_only",
  Ready = "ready",
  Syncing = "syncing",
  Degraded = "degraded",
  ReviewRequired = "review_required",
}

export enum SyncOperationKind {
  Startup = "startup",
  AttachLocalData = "attach_local_data",
  PushPull = "push_pull",
}

export enum SyncOperationStatus {
  Running = "running",
  Succeeded = "succeeded",
  Failed = "failed",
}

export enum SyncConflictStrategy {
  PreserveBoth = "preserve_both",
  ReviewRequired = "review_required",
}

export enum SyncConflictStatus {
  Open = "open",
  Resolved = "resolved",
}

export type SyncEntityKind =
  | "goal"
  | "milestone"
  | "task"
  | "daily_plan"
  | "preferences"
  | "adaptation_profile";

export interface AccountIdentity extends EntityRecord {
  provider: AuthProvider;
  providerSubject: string;
  email: string | null;
  displayName: string | null;
  metadata: JsonMap;
}

export interface AuthStateSnapshot extends AuditMetadata {
  status: AuthStatus;
  signedInAccountId: string | null;
  primaryProvider: AuthProvider;
  availableProviders: AuthProvider[];
  canAttemptAppleSignIn: boolean;
  lastAuthenticatedAt: ISODateTimeString | null;
  lastError: string | null;
}

export interface LocalAttachmentState extends AuditMetadata {
  accountId: string | null;
  status: LocalAttachmentStatus;
  hasMeaningfulLocalData: boolean;
  pendingRecordCount: number;
  lastAttachedAt: ISODateTimeString | null;
  lastError: string | null;
}

export interface SyncStateSnapshot extends AuditMetadata {
  accountId: string | null;
  deviceId: string;
  mode: SyncMode;
  lastSyncAt: ISODateTimeString | null;
  pendingPushCount: number;
  pendingPullCount: number;
  unresolvedConflictCount: number;
  lastError: string | null;
  metadata: JsonMap;
}

export interface SyncOperationRecord extends EntityRecord {
  accountId: string | null;
  kind: SyncOperationKind;
  status: SyncOperationStatus;
  startedAt: ISODateTimeString;
  finishedAt: ISODateTimeString | null;
  errorMessage: string | null;
  metadata: JsonMap;
}

export interface SyncConflictRecord extends EntityRecord {
  accountId: string;
  entityKind: SyncEntityKind;
  entityId: string;
  localVersion: number;
  remoteVersion: number;
  strategy: SyncConflictStrategy;
  status: SyncConflictStatus;
  summary: string;
  metadata: JsonMap;
}

export interface RemoteSyncRecord extends AuditMetadata {
  accountId: string;
  entityKind: SyncEntityKind;
  entityId: string;
  payload: string;
  version: number;
  remoteId: string;
  lastWriterDeviceId: string;
}

export interface AccountSnapshot {
  account: AccountIdentity | null;
  auth: AuthStateSnapshot;
  attachment: LocalAttachmentState;
  sync: SyncStateSnapshot;
  conflicts: SyncConflictRecord[];
}

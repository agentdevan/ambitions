import {
  AccountIdentity,
  AuthStateSnapshot,
  LocalAttachmentState,
  RemoteSyncRecord,
  SyncConflictRecord,
  SyncOperationRecord,
  SyncStateSnapshot,
} from "../domain/models";

export interface AccountRepository {
  getAccount(accountId: string): Promise<AccountIdentity | null>;
  listAccounts(): Promise<AccountIdentity[]>;
  saveAccount(account: AccountIdentity): Promise<void>;
  getAuthState(): Promise<AuthStateSnapshot | null>;
  saveAuthState(state: AuthStateSnapshot): Promise<void>;
  getAttachmentState(): Promise<LocalAttachmentState | null>;
  saveAttachmentState(state: LocalAttachmentState): Promise<void>;
  getSyncState(): Promise<SyncStateSnapshot | null>;
  saveSyncState(state: SyncStateSnapshot): Promise<void>;
  saveSyncOperation(operation: SyncOperationRecord): Promise<void>;
  listOpenConflicts(): Promise<SyncConflictRecord[]>;
  saveConflict(conflict: SyncConflictRecord): Promise<void>;
  listRemoteRecords(accountId: string): Promise<RemoteSyncRecord[]>;
  saveRemoteRecords(records: RemoteSyncRecord[]): Promise<void>;
  deleteConflictsByEntityIds(accountId: string, entityIds: string[]): Promise<void>;
  deleteRemoteRecords(accountId: string, entityIds: string[]): Promise<void>;
}

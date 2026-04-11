import {
  AccountIdentity,
  AuthProvider,
  AuthStateSnapshot,
  AuthStatus,
  LocalAttachmentState,
  LocalAttachmentStatus,
  RemoteSyncRecord,
  SyncConflictRecord,
  SyncConflictStatus,
  SyncConflictStrategy,
  SyncMode,
  SyncOperationKind,
  SyncOperationRecord,
  SyncOperationStatus,
  SyncStateSnapshot,
} from "../../domain/models";
import { DatabaseClient } from "../../data/sqlite/client";
import { AccountRepository } from "../AccountRepository";
import { SQLiteRepository } from "../base";
import { decodeJson, encodeJson, entityParams, mapEntityRecord } from "./shared";

interface AccountRow {
  id: string;
  provider: AuthProvider;
  provider_subject: string;
  email: string | null;
  display_name: string | null;
  metadata_json: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state: AccountIdentity["syncState"];
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

interface AuthStateRow {
  id: string;
  status: AuthStatus;
  signed_in_account_id: string | null;
  primary_provider: AuthProvider;
  available_providers_json: string;
  can_attempt_apple_sign_in: number;
  last_authenticated_at: string | null;
  last_error: string | null;
  created_at: string;
  updated_at: string;
}

interface AttachmentStateRow {
  id: string;
  account_id: string | null;
  status: LocalAttachmentStatus;
  has_meaningful_local_data: number;
  pending_record_count: number;
  last_attached_at: string | null;
  last_error: string | null;
  created_at: string;
  updated_at: string;
}

interface SyncStateRow {
  id: string;
  account_id: string | null;
  device_id: string;
  mode: SyncMode;
  last_sync_at: string | null;
  pending_push_count: number;
  pending_pull_count: number;
  unresolved_conflict_count: number;
  last_error: string | null;
  metadata_json: string;
  created_at: string;
  updated_at: string;
}

interface SyncConflictRow {
  id: string;
  account_id: string;
  entity_kind: SyncConflictRecord["entityKind"];
  entity_id: string;
  local_version: number;
  remote_version: number;
  strategy: SyncConflictStrategy;
  status: SyncConflictStatus;
  summary: string;
  metadata_json: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state: SyncConflictRecord["syncState"];
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

interface RemoteSyncRecordRow {
  id: string;
  account_id: string;
  entity_kind: RemoteSyncRecord["entityKind"];
  entity_id: string;
  remote_id: string;
  payload_json: string;
  version: number;
  last_writer_device_id: string;
  created_at: string;
  updated_at: string;
}

export class SQLiteAccountRepository extends SQLiteRepository implements AccountRepository {
  constructor(database: DatabaseClient) {
    super(database);
  }

  async getAccount(accountId: string) {
    const row = await this.database.getFirst<AccountRow>(
      "SELECT * FROM accounts WHERE id = ? LIMIT 1;",
      [accountId],
    );
    return row ? mapAccount(row) : null;
  }

  async listAccounts() {
    const rows = await this.database.getAll<AccountRow>(
      "SELECT * FROM accounts ORDER BY updated_at DESC;",
    );
    return rows.map(mapAccount);
  }

  async saveAccount(account: AccountIdentity) {
    await this.database.run(
      `
        INSERT OR REPLACE INTO accounts (
          id, provider, provider_subject, email, display_name, metadata_json, owner_user_id,
          remote_id, sync_state, version, last_synced_at, created_at, updated_at
        ) VALUES (
          $id, $provider, $providerSubject, $email, $displayName, $metadataJson, $ownerUserId,
          $remoteId, $syncState, $version, $lastSyncedAt, $createdAt, $updatedAt
        );
      `,
      {
        ...entityParams(account),
        $provider: account.provider,
        $providerSubject: account.providerSubject,
        $email: account.email,
        $displayName: account.displayName,
        $metadataJson: encodeJson(account.metadata),
      },
    );
  }

  async getAuthState() {
    const row = await this.database.getFirst<AuthStateRow>(
      "SELECT * FROM auth_state WHERE id = 'primary' LIMIT 1;",
    );
    return row ? mapAuthState(row) : null;
  }

  async saveAuthState(state: AuthStateSnapshot) {
    await this.database.run(
      `
        INSERT OR REPLACE INTO auth_state (
          id, status, signed_in_account_id, primary_provider, available_providers_json,
          can_attempt_apple_sign_in, last_authenticated_at, last_error, created_at, updated_at
        ) VALUES (
          'primary', $status, $signedInAccountId, $primaryProvider, $availableProvidersJson,
          $canAttemptAppleSignIn, $lastAuthenticatedAt, $lastError, $createdAt, $updatedAt
        );
      `,
      {
        $status: state.status,
        $signedInAccountId: state.signedInAccountId,
        $primaryProvider: state.primaryProvider,
        $availableProvidersJson: encodeJson(state.availableProviders),
        $canAttemptAppleSignIn: state.canAttemptAppleSignIn ? 1 : 0,
        $lastAuthenticatedAt: state.lastAuthenticatedAt,
        $lastError: state.lastError,
        $createdAt: state.createdAt,
        $updatedAt: state.updatedAt,
      },
    );
  }

  async getAttachmentState() {
    const row = await this.database.getFirst<AttachmentStateRow>(
      "SELECT * FROM local_attachment_state WHERE id = 'primary' LIMIT 1;",
    );
    return row ? mapAttachmentState(row) : null;
  }

  async saveAttachmentState(state: LocalAttachmentState) {
    await this.database.run(
      `
        INSERT OR REPLACE INTO local_attachment_state (
          id, account_id, status, has_meaningful_local_data, pending_record_count, last_attached_at,
          last_error, created_at, updated_at
        ) VALUES (
          'primary', $accountId, $status, $hasMeaningfulLocalData, $pendingRecordCount,
          $lastAttachedAt, $lastError, $createdAt, $updatedAt
        );
      `,
      {
        $accountId: state.accountId,
        $status: state.status,
        $hasMeaningfulLocalData: state.hasMeaningfulLocalData ? 1 : 0,
        $pendingRecordCount: state.pendingRecordCount,
        $lastAttachedAt: state.lastAttachedAt,
        $lastError: state.lastError,
        $createdAt: state.createdAt,
        $updatedAt: state.updatedAt,
      },
    );
  }

  async getSyncState() {
    const row = await this.database.getFirst<SyncStateRow>(
      "SELECT * FROM sync_state WHERE id = 'primary' LIMIT 1;",
    );
    return row ? mapSyncState(row) : null;
  }

  async saveSyncState(state: SyncStateSnapshot) {
    await this.database.run(
      `
        INSERT OR REPLACE INTO sync_state (
          id, account_id, device_id, mode, last_sync_at, pending_push_count, pending_pull_count,
          unresolved_conflict_count, last_error, metadata_json, created_at, updated_at
        ) VALUES (
          'primary', $accountId, $deviceId, $mode, $lastSyncAt, $pendingPushCount, $pendingPullCount,
          $unresolvedConflictCount, $lastError, $metadataJson, $createdAt, $updatedAt
        );
      `,
      {
        $accountId: state.accountId,
        $deviceId: state.deviceId,
        $mode: state.mode,
        $lastSyncAt: state.lastSyncAt,
        $pendingPushCount: state.pendingPushCount,
        $pendingPullCount: state.pendingPullCount,
        $unresolvedConflictCount: state.unresolvedConflictCount,
        $lastError: state.lastError,
        $metadataJson: encodeJson(state.metadata),
        $createdAt: state.createdAt,
        $updatedAt: state.updatedAt,
      },
    );
  }

  async saveSyncOperation(operation: SyncOperationRecord) {
    await this.database.run(
      `
        INSERT OR REPLACE INTO sync_operations (
          id, account_id, kind, status, started_at, finished_at, error_message, metadata_json,
          owner_user_id, remote_id, sync_state, version, last_synced_at, created_at, updated_at
        ) VALUES (
          $id, $accountId, $kind, $status, $startedAt, $finishedAt, $errorMessage, $metadataJson,
          $ownerUserId, $remoteId, $syncState, $version, $lastSyncedAt, $createdAt, $updatedAt
        );
      `,
      {
        ...entityParams(operation),
        $accountId: operation.accountId,
        $kind: operation.kind,
        $status: operation.status,
        $startedAt: operation.startedAt,
        $finishedAt: operation.finishedAt,
        $errorMessage: operation.errorMessage,
        $metadataJson: encodeJson(operation.metadata),
      },
    );
  }

  async listOpenConflicts() {
    const rows = await this.database.getAll<SyncConflictRow>(
      "SELECT * FROM sync_conflicts WHERE status = 'open' ORDER BY updated_at DESC;",
    );
    return rows.map((row) =>
      mapEntityRecord<SyncConflictRecord>(row, {
        accountId: row.account_id,
        entityKind: row.entity_kind,
        entityId: row.entity_id,
        localVersion: row.local_version,
        remoteVersion: row.remote_version,
        strategy: row.strategy,
        status: row.status,
        summary: row.summary,
        metadata: decodeJson(row.metadata_json),
      }),
    );
  }

  async saveConflict(conflict: SyncConflictRecord) {
    await this.database.run(
      `
        INSERT OR REPLACE INTO sync_conflicts (
          id, account_id, entity_kind, entity_id, local_version, remote_version, strategy, status,
          summary, metadata_json, owner_user_id, remote_id, sync_state, version, last_synced_at,
          created_at, updated_at
        ) VALUES (
          $id, $accountId, $entityKind, $entityId, $localVersion, $remoteVersion, $strategy, $status,
          $summary, $metadataJson, $ownerUserId, $remoteId, $syncState, $version, $lastSyncedAt,
          $createdAt, $updatedAt
        );
      `,
      {
        ...entityParams(conflict),
        $accountId: conflict.accountId,
        $entityKind: conflict.entityKind,
        $entityId: conflict.entityId,
        $localVersion: conflict.localVersion,
        $remoteVersion: conflict.remoteVersion,
        $strategy: conflict.strategy,
        $status: conflict.status,
        $summary: conflict.summary,
        $metadataJson: encodeJson(conflict.metadata),
      },
    );
  }

  async listRemoteRecords(accountId: string) {
    const rows = await this.database.getAll<RemoteSyncRecordRow>(
      "SELECT * FROM remote_sync_records WHERE account_id = ? ORDER BY entity_kind ASC, updated_at ASC;",
      [accountId],
    );

    return rows.map((row) => ({
      accountId: row.account_id,
      entityKind: row.entity_kind,
      entityId: row.entity_id,
      payload: row.payload_json,
      version: row.version,
      remoteId: row.remote_id,
      lastWriterDeviceId: row.last_writer_device_id,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    }));
  }

  async saveRemoteRecords(records: RemoteSyncRecord[]) {
    await this.database.withTransaction(async (client) => {
      for (const record of records) {
        await client.run(
          `
            INSERT OR REPLACE INTO remote_sync_records (
              id, account_id, entity_kind, entity_id, remote_id, payload_json, version,
              last_writer_device_id, created_at, updated_at
            ) VALUES (
              $id, $accountId, $entityKind, $entityId, $remoteId, $payloadJson, $version,
              $lastWriterDeviceId, $createdAt, $updatedAt
            );
          `,
          {
            $id: `${record.accountId}:${record.entityKind}:${record.remoteId}`,
            $accountId: record.accountId,
            $entityKind: record.entityKind,
            $entityId: record.entityId,
            $remoteId: record.remoteId,
            $payloadJson: record.payload,
            $version: record.version,
            $lastWriterDeviceId: record.lastWriterDeviceId,
            $createdAt: record.createdAt,
            $updatedAt: record.updatedAt,
          },
        );
      }
    });
  }
}

function mapAccount(row: AccountRow): AccountIdentity {
  return mapEntityRecord<AccountIdentity>(row, {
    provider: row.provider,
    providerSubject: row.provider_subject,
    email: row.email,
    displayName: row.display_name,
    metadata: decodeJson(row.metadata_json),
  });
}

function mapAuthState(row: AuthStateRow): AuthStateSnapshot {
  return {
    status: row.status,
    signedInAccountId: row.signed_in_account_id,
    primaryProvider: row.primary_provider,
    availableProviders: decodeJson<AuthProvider[]>(row.available_providers_json),
    canAttemptAppleSignIn: row.can_attempt_apple_sign_in === 1,
    lastAuthenticatedAt: row.last_authenticated_at,
    lastError: row.last_error,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function mapAttachmentState(row: AttachmentStateRow): LocalAttachmentState {
  return {
    accountId: row.account_id,
    status: row.status,
    hasMeaningfulLocalData: row.has_meaningful_local_data === 1,
    pendingRecordCount: row.pending_record_count,
    lastAttachedAt: row.last_attached_at,
    lastError: row.last_error,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function mapSyncState(row: SyncStateRow): SyncStateSnapshot {
  return {
    accountId: row.account_id,
    deviceId: row.device_id,
    mode: row.mode,
    lastSyncAt: row.last_sync_at,
    pendingPushCount: row.pending_push_count,
    pendingPullCount: row.pending_pull_count,
    unresolvedConflictCount: row.unresolved_conflict_count,
    lastError: row.last_error,
    metadata: decodeJson(row.metadata_json),
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

import { EntityRecord } from "../../domain/models";
import { decodeJson, encodeJson } from "../../data/sqlite/helpers";

export interface EntityRow {
  id: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state?: string;
  sync_state_entity?: string;
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

export function mapEntityRecord<T extends EntityRecord>(
  row: EntityRow,
  record: Omit<T, keyof EntityRecord>,
  options?: { syncField?: "sync_state" | "sync_state_entity" },
): T {
  const syncField = options?.syncField ?? "sync_state";

  return {
    ...record,
    id: row.id,
    ownerUserId: row.owner_user_id,
    remoteId: row.remote_id,
    syncState: (row[syncField] ?? row.sync_state) as T["syncState"],
    version: row.version,
    lastSyncedAt: row.last_synced_at,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  } as T;
}

export function entityParams(record: EntityRecord, options?: { syncColumn?: string }) {
  return {
    $id: record.id,
    $ownerUserId: record.ownerUserId,
    $remoteId: record.remoteId,
    [options?.syncColumn ?? "$syncState"]: record.syncState,
    $version: record.version,
    $lastSyncedAt: record.lastSyncedAt,
    $createdAt: record.createdAt,
    $updatedAt: record.updatedAt,
  };
}

export { decodeJson, encodeJson };

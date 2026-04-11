export type EntityId = string;
export type ISODateString = string;
export type ISODateTimeString = string;
export type JsonValue =
  | boolean
  | number
  | string
  | null
  | JsonValue[]
  | { [key: string]: JsonValue };
export type JsonMap = Record<string, JsonValue>;

export enum EntitySyncState {
  LocalOnly = "local_only",
  PendingSync = "pending_sync",
  Synced = "synced",
  Conflict = "conflict",
}

export interface SyncMetadata {
  ownerUserId: string | null;
  remoteId: string | null;
  syncState: EntitySyncState;
  version: number;
  lastSyncedAt: ISODateTimeString | null;
}

export interface AuditMetadata {
  createdAt: ISODateTimeString;
  updatedAt: ISODateTimeString;
}

export interface EntityRecord extends AuditMetadata, SyncMetadata {
  id: EntityId;
}

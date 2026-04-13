import {
  EntitySyncState,
  SyncConflictStatus,
  SyncConflictStrategy,
  SyncEntityKind,
} from "../../../domain/models";
import { SyncEntityRecord } from "./syncScope";

export type MergeDecision =
  | { type: "push_local" }
  | { type: "pull_remote" }
  | { type: "noop" }
  | {
      type: "conflict";
      strategy: SyncConflictStrategy;
      summary: string;
    };

function stablePayload(record: SyncEntityRecord) {
  return JSON.stringify(record);
}

export class MergeEvaluator {
  static decide(params: {
    kind: SyncEntityKind;
    local: SyncEntityRecord;
    remote: SyncEntityRecord;
    baseline: string | null;
  }): MergeDecision {
    const localPayload = stablePayload(params.local);
    const remotePayload = stablePayload(params.remote);

    if (localPayload === remotePayload) {
      return { type: "noop" };
    }

    const localChanged =
      params.local.syncState !== EntitySyncState.Synced ||
      !params.baseline ||
      params.local.updatedAt > params.baseline;
    const remoteChanged = !params.baseline || params.remote.updatedAt > params.baseline;

    if (localChanged && !remoteChanged) {
      return { type: "push_local" };
    }

    if (!localChanged && remoteChanged) {
      return { type: "pull_remote" };
    }

    // Every synced entity in Ambitions should keep one stable logical identity.
    // When edits diverge, stop automatic replacement and keep the existing local
    // record in conflict instead of manufacturing preserved duplicates.
    const strategy = SyncConflictStrategy.ReviewRequired;

    return {
      type: "conflict",
      strategy,
      summary: "Both versions changed. Ambitions kept local data in place until this item is reviewed.",
    };
  }
}

export function buildConflictRecordId(accountId: string, kind: SyncEntityKind, entityId: string) {
  return `conflict:${accountId}:${kind}:${entityId}`;
}

export function buildConflictRecord(params: {
  id: string;
  accountId: string;
  kind: SyncEntityKind;
  entityId: string;
  localVersion: number;
  remoteVersion: number;
  strategy: SyncConflictStrategy;
  summary: string;
  now: string;
}) {
  return {
    id: params.id,
    accountId: params.accountId,
    entityKind: params.kind,
    entityId: params.entityId,
    localVersion: params.localVersion,
    remoteVersion: params.remoteVersion,
    strategy: params.strategy,
    status: SyncConflictStatus.Open,
    summary: params.summary,
    metadata: {},
    ownerUserId: params.accountId,
    remoteId: null,
    syncState: EntitySyncState.Conflict,
    version: 1,
    lastSyncedAt: null,
    createdAt: params.now,
    updatedAt: params.now,
  };
}

import { Ambition, EntitySyncState, Goal, GoalMilestone, JsonMap, Task } from "../../domain/models";

type PortfolioEntity = {
  id: string;
  remoteId: string | null;
  syncState: EntitySyncState;
  version: number;
  createdAt: string;
  updatedAt: string;
  metadata: JsonMap;
};

function isTruthyFlag(value: unknown) {
  return value === true || value === "true";
}

function hasPreservedConflictMetadata(metadata: JsonMap | null | undefined) {
  return isTruthyFlag(metadata?.preservedConflict);
}

function isPreservedConflictId(id: string) {
  return id.includes(":preserved:");
}

function getConflictSourceKey(record: PortfolioEntity) {
  const sourceId =
    typeof record.metadata.conflictSourceId === "string" ? record.metadata.conflictSourceId : null;

  if (sourceId) {
    return `source:${sourceId}`;
  }

  if (record.remoteId) {
    return `remote:${record.remoteId}`;
  }

  if (isPreservedConflictId(record.id)) {
    return `source:${record.id.split(":preserved:")[0]}`;
  }

  return `id:${record.id}`;
}

function compareCanonicalPriority(left: PortfolioEntity, right: PortfolioEntity) {
  const leftPreserved =
    hasPreservedConflictMetadata(left.metadata) || isPreservedConflictId(left.id);
  const rightPreserved =
    hasPreservedConflictMetadata(right.metadata) || isPreservedConflictId(right.id);

  if (leftPreserved !== rightPreserved) {
    return leftPreserved ? 1 : -1;
  }

  const leftConflict = left.syncState === EntitySyncState.Conflict;
  const rightConflict = right.syncState === EntitySyncState.Conflict;

  if (leftConflict !== rightConflict) {
    return leftConflict ? 1 : -1;
  }

  if (left.updatedAt !== right.updatedAt) {
    return right.updatedAt.localeCompare(left.updatedAt);
  }

  if (left.version !== right.version) {
    return right.version - left.version;
  }

  if (left.createdAt !== right.createdAt) {
    return left.createdAt.localeCompare(right.createdAt);
  }

  return left.id.localeCompare(right.id);
}

function warnOnCanonicalCollisions(kind: string, collisions: Array<{ key: string; ids: string[] }>) {
  if (typeof __DEV__ === "undefined" || !__DEV__ || collisions.length === 0) {
    return;
  }

  const summary = collisions
    .map((collision) => `${collision.key} => ${collision.ids.join(", ")}`)
    .join(" | ");
  console.warn(`[portfolio-integrity] deduped ${kind} records: ${summary}`);
}

function canonicalizeRecords<T extends PortfolioEntity>(kind: string, records: T[]) {
  const grouped = new Map<string, T[]>();

  for (const record of records) {
    const key = getConflictSourceKey(record);
    const existing = grouped.get(key) ?? [];
    existing.push(record);
    grouped.set(key, existing);
  }

  const collisions: Array<{ key: string; ids: string[] }> = [];
  const canonical = [...grouped.entries()].map(([key, group]) => {
    if (group.length > 1) {
      collisions.push({ key, ids: group.map((record) => record.id) });
    }

    return [...group].sort(compareCanonicalPriority)[0];
  });

  warnOnCanonicalCollisions(kind, collisions);
  return canonical;
}

export function canonicalizeAmbitions(ambitions: Ambition[]) {
  return canonicalizeRecords("ambition", ambitions);
}

export function canonicalizeGoals(goals: Goal[]) {
  return canonicalizeRecords("goal", goals);
}

export function canonicalizeGoalMilestones(milestones: GoalMilestone[]) {
  return canonicalizeRecords("milestone", milestones);
}

export function canonicalizeTasks(tasks: Task[]) {
  return canonicalizeRecords("task", tasks);
}

import { sha256Text, stableJson } from "./hash.js";
import { deletionIsSafe, desiredIssueState } from "./policy.js";
import type {
  CurrentWorkspace,
  DesiredWorkspaceManifest,
  Mutation,
  ReconciliationPlan,
} from "./types.js";

export async function planReconciliation(
  desired: DesiredWorkspaceManifest,
  current: CurrentWorkspace,
): Promise<ReconciliationPlan> {
  const mutations: Mutation[] = [];
  const exceptions: ReconciliationPlan["exceptions"] extends readonly (infer T)[]
    ? T[]
    : never = [];
  const desiredTasks = new Map(
    desired.projects.flatMap((project) =>
      project.tasks.map((task) => [task.canonicalKey, task] as const),
    ),
  );
  const currentByKey = new Map(
    current.issues
      .filter((issue) => issue.canonicalKey)
      .map((issue) => [issue.canonicalKey!, issue]),
  );
  for (const [key, task] of desiredTasks) {
    const issue = currentByKey.get(key);
    const payload = {
      title: task.title,
      description: task.body,
      projectSlug: task.projectSlug,
      globalRank: task.globalRank,
    };
    const desiredHash = await sha256Text(stableJson(payload));
    if (!issue) {
      mutations.push(
        await mutation(
          "create",
          "issue",
          key,
          "Missing repository Plan task",
          desiredHash,
          payload,
          desired.authorityCommit,
        ),
      );
      continue;
    }
    const state = desiredIssueState(issue);
    if (state !== issue.state)
      mutations.push(
        await mutation(
          "update",
          "issue",
          key,
          `State ${issue.state} → ${state}`,
          desiredHash,
          { state },
          desired.authorityCommit,
        ),
      );
  }
  for (const issue of current.issues) {
    if (!issue.canonicalKey || desiredTasks.has(issue.canonicalKey)) continue;
    exceptions.push({
      canonicalKey: issue.canonicalKey,
      category: "authority",
      severity: "warning",
      summary:
        "Unmapped issue requires deterministic classification before deletion",
    });
  }
  return {
    authorityCommit: desired.authorityCommit,
    desiredHash: desired.contractHash,
    mutations,
    exceptions,
  };
}

export function assertSafeMutation(item: Mutation): void {
  if (
    item.kind === "delete" &&
    (!item.deletionEvidence || !deletionIsSafe(item.deletionEvidence))
  )
    throw new Error(`UNSAFE_DELETE:${item.canonicalKey}`);
}

async function mutation(
  kind: Mutation["kind"],
  objectType: string,
  canonicalKey: string,
  reason: string,
  desiredHash: string,
  payload: Readonly<Record<string, unknown>>,
  authorityCommit: string,
): Promise<Mutation> {
  return {
    idempotencyKey: await sha256Text(
      `${authorityCommit}\0${kind}\0${canonicalKey}\0${desiredHash}`,
    ),
    kind,
    objectType,
    canonicalKey,
    reason,
    desiredHash,
    payload,
  };
}

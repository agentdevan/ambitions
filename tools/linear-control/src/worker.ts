import { sha256Text, stableJson } from "./core/hash.js";
import type { EventEnvelope } from "./core/types.js";
import { timingSafeEqual as nodeTimingSafeEqual } from "node:crypto";
import { LinearClient } from "./adapters/linear.js";
import { GitHubEvidenceClient } from "./adapters/github.js";
import {
  DEFAULT_RETRY_POLICY,
  fetchWithRetry,
  type RetryPolicy,
  type RetryRuntime,
} from "./adapters/http.js";
import {
  auditLiveWorkspace,
  RepairBudgetExhausted,
} from "./core/live-audit.js";
import type {
  LiveAuditOptions,
  LiveMutationCheckpoint,
  LiveMutationIntent,
  LiveProofReceipt,
} from "./core/live-audit.js";
import type {
  DesiredWorkspaceManifest,
  TaskProofEvidence,
  TaskContract,
} from "./core/types.js";

declare global {
  interface Env extends Cloudflare.Env {
    LINEAR_API_TOKEN: string;
    LINEAR_WEBHOOK_SECRET: string;
    GITHUB_WEBHOOK_SECRET: string;
    GITHUB_API_TOKEN: string;
    CONTROL_ADMIN_SECRET: string;
  }
}

const encoder = new TextEncoder();
export const EVENT_REPAIR_BUDGET = 3;
export const EXPECTED_PREFLIGHT_EXTERNAL_REQUESTS = 29;
export const MAX_EXTERNAL_REQUESTS_PER_REPAIR = 4;
const CONTINUATION_DELAY_SECONDS = 5;
const exactCommitSha = /^[0-9a-f]{40}$/;
const exactContentHash = /^[0-9a-f]{64}$/;
type Fetcher = typeof fetch;

interface WorkerRequestOptions {
  policy?: RetryPolicy;
  runtime?: RetryRuntime;
}

function exactCommitFromProperty(
  payload: unknown,
  property: string,
): string | null {
  if (typeof payload !== "object" || payload === null) return null;
  const value: unknown = Reflect.get(payload, property);
  return typeof value === "string" && exactCommitSha.test(value) ? value : null;
}

export function authorityCommitFromPayload(payload: unknown): string | null {
  return exactCommitFromProperty(payload, "authorityCommit");
}

function property(payload: unknown, name: string): unknown {
  return typeof payload === "object" && payload !== null
    ? Reflect.get(payload, name)
    : undefined;
}

function githubEvidenceIsEligible(payload: unknown, env: Env): boolean {
  const workflowEvent = property(payload, "workflowEvent");
  const conclusion = property(payload, "conclusion");
  const isMainPush = workflowEvent === "push" && conclusion === "success";
  return (
    property(payload, "schemaVersion") === 1 &&
    property(payload, "kind") === "code-quality" &&
    property(payload, "repository") === env.GITHUB_REPOSITORY &&
    property(payload, "headBranch") === "main" &&
    isMainPush
  );
}

export function repositoryRawUrl(
  repository: string,
  authorityCommit: string,
  path: string,
): string {
  if (!/^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/.test(repository))
    throw new Error("INVALID_GITHUB_REPOSITORY");
  if (!exactCommitSha.test(authorityCommit))
    throw new Error("INVALID_REPOSITORY_AUTHORITY_COMMIT");
  const segments = path.split("/");
  if (
    path.startsWith("/") ||
    segments.some((segment) => !segment || segment === "." || segment === "..")
  )
    throw new Error("INVALID_REPOSITORY_PATH");
  return `https://raw.githubusercontent.com/${repository}/${authorityCommit}/${segments.map(encodeURIComponent).join("/")}`;
}

interface PinnedAuthority {
  commit: string;
  pinnedAt: string;
}

async function latestVerifiedGithubAuthority(
  env: Env,
): Promise<PinnedAuthority | null> {
  const rows = await env.CONTROL_DB.prepare(
    "SELECT authority_commit, authority_pinned_at, payload_json FROM deliveries WHERE source = 'github' AND status IN ('verified', 'drift') AND authority_commit IS NOT NULL AND authority_pinned_at IS NOT NULL ORDER BY authority_pinned_at DESC LIMIT 20",
  ).all<{
    authority_commit: string | null;
    authority_pinned_at: string | null;
    payload_json: string | null;
  }>();
  for (const row of rows.results) {
    if (
      !row.authority_commit ||
      !exactCommitSha.test(row.authority_commit) ||
      !row.authority_pinned_at ||
      !row.payload_json
    )
      continue;
    let payload: unknown;
    try {
      payload = JSON.parse(row.payload_json);
    } catch {
      continue;
    }
    if (!githubEvidenceIsEligible(payload, env)) continue;
    if (authorityCommitFromPayload(payload) !== row.authority_commit) continue;
    return { commit: row.authority_commit, pinnedAt: row.authority_pinned_at };
  }
  return null;
}

async function currentGithubMainCommit(
  env: Env,
  fetcher: Fetcher,
  options: WorkerRequestOptions = {},
): Promise<string> {
  const response = await fetchWithRetry(
    fetcher,
    `https://api.github.com/repos/${env.GITHUB_REPOSITORY}/commits/main`,
    {
      headers: {
        Accept: "application/vnd.github+json",
        Authorization: `Bearer ${env.GITHUB_API_TOKEN}`,
        "User-Agent": "ambitions-linear-control",
        "X-GitHub-Api-Version": "2022-11-28",
      },
    },
    "GITHUB_MAIN",
    options.policy ?? DEFAULT_RETRY_POLICY,
    options.runtime,
  );
  if (!response.ok) throw new Error(`GITHUB_HEAD_HTTP_${response.status}`);
  const payload: unknown = await response.json();
  const commit = exactCommitFromProperty(payload, "sha");
  if (!commit) throw new Error("GITHUB_HEAD_INVALID");
  return commit;
}

export async function pinEventAuthority(
  env: Env,
  event: EventEnvelope,
): Promise<{ event: EventEnvelope; newlyPinned: boolean }> {
  if (event.authorityCommit) {
    if (!exactCommitSha.test(event.authorityCommit))
      throw new Error("INVALID_REPOSITORY_AUTHORITY_COMMIT");
    return { event, newlyPinned: false };
  }
  const stored = await env.CONTROL_DB.prepare(
    "SELECT authority_commit, authority_pinned_at FROM deliveries WHERE id = ?",
  )
    .bind(event.deliveryId)
    .first<{
      authority_commit: string | null;
      authority_pinned_at: string | null;
    }>();
  if (
    stored?.authority_commit &&
    exactCommitSha.test(stored.authority_commit) &&
    stored.authority_pinned_at
  )
    return {
      event: {
        ...event,
        authorityCommit: stored.authority_commit,
        authorityPinnedAt: stored.authority_pinned_at,
      },
      newlyPinned: false,
    };
  const verified = await latestVerifiedGithubAuthority(env);
  if (!verified) throw new Error("NO_VERIFIED_GITHUB_AUTHORITY");
  const authorityCommit = verified.commit;
  const authorityPinnedAt = verified.pinnedAt;
  const result = await env.CONTROL_DB.prepare(
    "UPDATE deliveries SET authority_commit = ?, authority_pinned_at = ?, updated_at = ? WHERE id = ? AND authority_commit IS NULL",
  )
    .bind(
      authorityCommit,
      authorityPinnedAt,
      authorityPinnedAt,
      event.deliveryId,
    )
    .run();
  if (result.meta.changes > 0)
    return {
      event: { ...event, authorityCommit, authorityPinnedAt },
      newlyPinned: true,
    };
  const winner = await env.CONTROL_DB.prepare(
    "SELECT authority_commit, authority_pinned_at FROM deliveries WHERE id = ?",
  )
    .bind(event.deliveryId)
    .first<{
      authority_commit: string | null;
      authority_pinned_at: string | null;
    }>();
  if (
    !winner?.authority_commit ||
    !exactCommitSha.test(winner.authority_commit) ||
    !winner.authority_pinned_at
  )
    throw new Error("DELIVERY_AUTHORITY_PIN_FAILED");
  return {
    event: {
      ...event,
      authorityCommit: winner.authority_commit,
      authorityPinnedAt: winner.authority_pinned_at,
    },
    newlyPinned: false,
  };
}

export async function authorityIsCurrent(
  env: Env,
  event: EventEnvelope,
  fetcher: Fetcher = fetch,
  options: WorkerRequestOptions = {},
): Promise<boolean> {
  if (!event.authorityCommit || !exactCommitSha.test(event.authorityCommit))
    return false;
  if (event.source === "github") {
    if (!githubEvidenceIsEligible(event.payload, env)) return false;
    return (
      event.authorityCommit ===
      (await currentGithubMainCommit(env, fetcher, options))
    );
  }
  const verified = await latestVerifiedGithubAuthority(env);
  return (
    verified?.commit === event.authorityCommit &&
    event.authorityCommit ===
      (await currentGithubMainCommit(env, fetcher, options))
  );
}

export async function loadManifestForEvent(
  env: Env,
  event: EventEnvelope,
  fetcher: Fetcher = fetch,
  options: WorkerRequestOptions = {},
): Promise<DesiredWorkspaceManifest> {
  if (!event.authorityCommit)
    throw new Error("REPOSITORY_AUTHORITY_COMMIT_UNPINNED");
  const repositoryUrl = repositoryRawUrl(
    env.GITHUB_REPOSITORY,
    event.authorityCommit,
    env.MANIFEST_PATH,
  );
  const response = await fetchWithRetry(
    fetcher,
    repositoryUrl,
    { headers: { "User-Agent": "ambitions-linear-control" } },
    "MANIFEST",
    options.policy ?? DEFAULT_RETRY_POLICY,
    options.runtime,
  );
  if (!response.ok) throw new Error(`MANIFEST_HTTP_${response.status}`);
  const payload: unknown = await response.json();
  const compileProvenanceCommit = exactCommitFromProperty(
    payload,
    "authorityCommit",
  );
  if (!compileProvenanceCommit)
    throw new Error("MANIFEST_AUTHORITY_COMMIT_INVALID");
  const contractHash = property(payload, "contractHash");
  const projects = property(payload, "projects");
  const schedule = property(payload, "schedule");
  if (
    property(payload, "schemaVersion") !== 1 ||
    typeof contractHash !== "string" ||
    !exactContentHash.test(contractHash) ||
    !Array.isArray(projects) ||
    !Array.isArray(schedule)
  )
    throw new Error("MANIFEST_CONTRACT_INVALID");
  const computedHash = await sha256Text(
    stableJson({
      schemaVersion: 1,
      authorityCommit: compileProvenanceCommit,
      projects,
      schedule,
    }),
  );
  if (computedHash !== contractHash)
    throw new Error("MANIFEST_CONTRACT_HASH_MISMATCH");
  return {
    schemaVersion: 1,
    authorityCommit: event.authorityCommit,
    compileProvenanceCommit,
    contractHash,
    projects: projects as unknown as DesiredWorkspaceManifest["projects"],
    schedule: schedule as unknown as DesiredWorkspaceManifest["schedule"],
  };
}

function pullRequestNumber(
  repository: string,
  attachmentUrl: string,
): number | null {
  let url: URL;
  try {
    url = new URL(attachmentUrl);
  } catch {
    return null;
  }
  if (url.protocol !== "https:" || url.hostname !== "github.com") return null;
  const match = /^\/([^/]+\/[^/]+)\/pull\/(\d+)\/?$/.exec(url.pathname);
  if (!match || match[1] !== repository) return null;
  const number = Number(match[2]);
  return Number.isSafeInteger(number) && number > 0 ? number : null;
}

export function taskProofResolver(
  env: Env,
  authorityCommit: string,
  client: Pick<
    GitHubEvidenceClient,
    "pullRequest" | "commitIncludes"
  > = new GitHubEvidenceClient(env.GITHUB_API_TOKEN),
): (input: {
  issueIdentifier: string;
  attachmentUrls: readonly string[];
  task: TaskContract;
}) => Promise<TaskProofEvidence> {
  const cache = new Map<string, Promise<TaskProofEvidence>>();
  return async ({ issueIdentifier, attachmentUrls, task }) => {
    const numbers = attachmentUrls.flatMap((url) => {
      const number = pullRequestNumber(env.GITHUB_REPOSITORY, url);
      return number === null ? [] : [number];
    });
    if (numbers.length !== 1)
      return {
        authorityCommit,
        mergedToMain: false,
        proofPassed: false,
        requiredProofFailed: false,
      };
    const number = numbers[0]!;
    const cacheKey = `${number}:${issueIdentifier}`;
    const cached = cache.get(cacheKey);
    if (cached) return cached;
    const resolved = (async (): Promise<TaskProofEvidence> => {
      const pullRequest = await client.pullRequest(
        env.GITHUB_REPOSITORY,
        number,
      );
      const identifiers = new Set(
        [pullRequest.title, pullRequest.headBranch]
          .flatMap((value) => value.match(/\bAMB-\d+\b/gi) ?? [])
          .map((value) => value.toUpperCase()),
      );
      const pullRequestUrl = `https://github.com/${env.GITHUB_REPOSITORY}/pull/${number}`;
      if (
        identifiers.size !== 1 ||
        !identifiers.has(issueIdentifier.toUpperCase())
      )
        return {
          source: "github",
          authorityCommit,
          mergedToMain: false,
          proofPassed: false,
          requiredProofFailed: false,
          issueIdentifier,
          pullRequestUrl,
        };
      if (!pullRequest.merged || !pullRequest.mergeCommitSha)
        return {
          source: "github",
          authorityCommit,
          mergedToMain: false,
          proofPassed: false,
          requiredProofFailed: false,
          issueIdentifier,
          pullRequestUrl,
        };
      const included = await client.commitIncludes(
        env.GITHUB_REPOSITORY,
        pullRequest.mergeCommitSha,
        authorityCommit,
      );
      const proofContractCovered =
        task.proof.validationCommands.length === 0 &&
        task.proof.required.every((requirement) => requirement === "audit");
      return {
        source: "github",
        authorityCommit,
        mergedToMain: included,
        proofPassed: included && proofContractCovered,
        requiredProofFailed: false,
        issueIdentifier,
        pullRequestUrl,
        mergeCommitSha: pullRequest.mergeCommitSha,
      };
    })();
    cache.set(cacheKey, resolved);
    return resolved;
  };
}

interface StoredTaskProofEvidence {
  schemaVersion: 1;
  authorityCommit: string;
  canonicalKey: string;
  issueIdentifier: string;
  pullRequestUrl: string;
  mergeCommitSha: string;
  proofContractHash: string;
}

type TaskProofInput = {
  issueIdentifier: string;
  attachmentUrls: readonly string[];
  task: TaskContract;
};

type TaskProofResolver = (input: TaskProofInput) => Promise<TaskProofEvidence>;

async function verifiedTaskProofReceipts(
  env: Env,
  authorityCommit: string,
): Promise<Map<string, StoredTaskProofEvidence>> {
  const rows = await env.CONTROL_DB.prepare(
    "SELECT mr.canonical_key, mr.desired_hash, mr.result_hash, mr.status, mr.evidence_json, r.authority_commit FROM mutation_receipts mr JOIN runs r ON r.id = mr.run_id WHERE mr.operation = 'task-proof' AND r.authority_commit = ? ORDER BY mr.verified_at DESC LIMIT 1000",
  )
    .bind(authorityCommit)
    .all<{
      canonical_key: string;
      desired_hash: string;
      result_hash: string | null;
      status: string;
      evidence_json: string | null;
      authority_commit: string;
    }>();
  const receipts = new Map<string, StoredTaskProofEvidence>();
  const ambiguous = new Set<string>();
  for (const row of rows.results) {
    if (
      row.status !== "verified" ||
      row.authority_commit !== authorityCommit ||
      !row.evidence_json ||
      !exactContentHash.test(row.desired_hash) ||
      row.result_hash !== row.desired_hash
    )
      continue;
    let evidence: unknown;
    try {
      evidence = JSON.parse(row.evidence_json);
    } catch {
      continue;
    }
    const canonicalKey = property(evidence, "canonicalKey");
    const issueIdentifier = property(evidence, "issueIdentifier");
    const pullRequestUrl = property(evidence, "pullRequestUrl");
    const mergeCommitSha = property(evidence, "mergeCommitSha");
    const proofContractHash = property(evidence, "proofContractHash");
    if (
      property(evidence, "schemaVersion") !== 1 ||
      property(evidence, "authorityCommit") !== authorityCommit ||
      canonicalKey !== row.canonical_key ||
      typeof canonicalKey !== "string" ||
      typeof issueIdentifier !== "string" ||
      !/^AMB-\d+$/.test(issueIdentifier) ||
      typeof pullRequestUrl !== "string" ||
      pullRequestNumber(env.GITHUB_REPOSITORY, pullRequestUrl) === null ||
      typeof mergeCommitSha !== "string" ||
      !exactCommitSha.test(mergeCommitSha) ||
      typeof proofContractHash !== "string" ||
      !exactContentHash.test(proofContractHash) ||
      (await sha256Text(stableJson(evidence))) !== row.desired_hash
    )
      continue;
    const parsed: StoredTaskProofEvidence = {
      schemaVersion: 1,
      authorityCommit,
      canonicalKey,
      issueIdentifier,
      pullRequestUrl,
      mergeCommitSha,
      proofContractHash,
    };
    const existing = receipts.get(canonicalKey);
    if (existing && stableJson(existing) !== stableJson(parsed)) {
      receipts.delete(canonicalKey);
      ambiguous.add(canonicalKey);
      continue;
    }
    if (!ambiguous.has(canonicalKey)) receipts.set(canonicalKey, parsed);
  }
  return receipts;
}

export async function taskProofResolverForEvent(
  env: Env,
  authorityCommit: string,
  fresh: TaskProofResolver = taskProofResolver(env, authorityCommit),
  onFreshReceipt?: (receipt: LiveProofReceipt) => Promise<void>,
): Promise<TaskProofResolver> {
  const receipts = await verifiedTaskProofReceipts(env, authorityCommit);
  return async (input) => {
    const receipt = receipts.get(input.task.canonicalKey);
    if (receipt) {
      const currentNumbers = input.attachmentUrls.flatMap((url) => {
        const number = pullRequestNumber(env.GITHUB_REPOSITORY, url);
        return number === null ? [] : [number];
      });
      const receiptNumber = pullRequestNumber(
        env.GITHUB_REPOSITORY,
        receipt.pullRequestUrl,
      );
      const proofContractHash = await sha256Text(stableJson(input.task.proof));
      if (
        receipt.authorityCommit === authorityCommit &&
        receipt.issueIdentifier === input.issueIdentifier &&
        receipt.canonicalKey === input.task.canonicalKey &&
        receipt.proofContractHash === proofContractHash &&
        input.task.proof.validationCommands.length === 0 &&
        input.task.proof.required.every(
          (requirement) => requirement === "audit",
        ) &&
        currentNumbers.length === 1 &&
        currentNumbers[0] === receiptNumber
      )
        return {
          source: "receipt",
          authorityCommit,
          mergedToMain: true,
          proofPassed: true,
          requiredProofFailed: false,
          issueIdentifier: receipt.issueIdentifier,
          pullRequestUrl: receipt.pullRequestUrl,
          mergeCommitSha: receipt.mergeCommitSha,
        };
    }
    const evidence = await fresh(input);
    const freshReceipt = await taskProofReceipt(
      env.GITHUB_REPOSITORY,
      authorityCommit,
      input,
      evidence,
    );
    if (freshReceipt) await onFreshReceipt?.(freshReceipt);
    return evidence;
  };
}

async function taskProofReceipt(
  repository: string,
  authorityCommit: string,
  input: TaskProofInput,
  evidence: TaskProofEvidence,
): Promise<LiveProofReceipt | null> {
  const attachmentNumbers = input.attachmentUrls.flatMap((url) => {
    const number = pullRequestNumber(repository, url);
    return number === null ? [] : [number];
  });
  const evidenceNumber = evidence.pullRequestUrl
    ? pullRequestNumber(repository, evidence.pullRequestUrl)
    : null;
  if (
    evidence.source !== "github" ||
    evidence.authorityCommit !== authorityCommit ||
    !evidence.mergedToMain ||
    !evidence.proofPassed ||
    evidence.requiredProofFailed ||
    evidence.issueIdentifier !== input.issueIdentifier ||
    !evidence.pullRequestUrl ||
    evidenceNumber === null ||
    attachmentNumbers.length !== 1 ||
    attachmentNumbers[0] !== evidenceNumber ||
    !evidence.mergeCommitSha ||
    !exactCommitSha.test(evidence.mergeCommitSha) ||
    input.task.proof.validationCommands.length !== 0 ||
    !input.task.proof.required.every((requirement) => requirement === "audit")
  )
    return null;
  const evidenceJson = stableJson({
    schemaVersion: 1,
    authorityCommit,
    canonicalKey: input.task.canonicalKey,
    issueIdentifier: input.issueIdentifier,
    pullRequestUrl: evidence.pullRequestUrl,
    mergeCommitSha: evidence.mergeCommitSha,
    proofContractHash: await sha256Text(stableJson(input.task.proof)),
  });
  return {
    canonicalKey: input.task.canonicalKey,
    evidenceHash: await sha256Text(evidenceJson),
    evidenceJson,
  };
}

async function persistTaskProofReceipt(
  env: Env,
  runId: string,
  receipt: LiveProofReceipt,
  verifiedAt = new Date().toISOString(),
): Promise<void> {
  await env.CONTROL_DB.prepare(
    "INSERT OR REPLACE INTO mutation_receipts (id, run_id, canonical_key, operation, before_hash, desired_hash, result_hash, status, created_at, verified_at, error, evidence_json) VALUES (?, ?, ?, 'task-proof', NULL, ?, ?, 'verified', ?, ?, NULL, ?)",
  )
    .bind(
      await sha256Text(
        `${runId}\0${receipt.canonicalKey}\0task-proof\0${receipt.evidenceHash}`,
      ),
      runId,
      receipt.canonicalKey,
      receipt.evidenceHash,
      receipt.evidenceHash,
      verifiedAt,
      verifiedAt,
      receipt.evidenceJson,
    )
    .run();
}

export async function fetchRepositoryText(
  env: Env,
  authorityCommit: string,
  path: string,
  fetcher: Fetcher = fetch,
  options: WorkerRequestOptions = {},
): Promise<string> {
  const sourceResponse = await fetchWithRetry(
    fetcher,
    repositoryRawUrl(env.GITHUB_REPOSITORY, authorityCommit, path),
    { headers: { "User-Agent": "ambitions-linear-control" } },
    "REPOSITORY_SOURCE",
    options.policy ?? DEFAULT_RETRY_POLICY,
    options.runtime,
  );
  if (!sourceResponse.ok)
    throw new Error(`REPOSITORY_SOURCE_HTTP_${sourceResponse.status}:${path}`);
  return sourceResponse.text();
}

async function executeD1Batches(
  database: D1Database,
  statements: D1PreparedStatement[],
  batchSize = 50,
): Promise<void> {
  for (let index = 0; index < statements.length; index += batchSize)
    await database.batch(statements.slice(index, index + batchSize));
}

async function durableMutationReconciliationKey(
  authorityCommit: string,
  intent: Pick<
    LiveMutationIntent,
    "canonicalKey" | "operation" | "desiredHash"
  >,
): Promise<string> {
  return sha256Text(
    `${authorityCommit}\0${intent.canonicalKey}\0${intent.operation}\0${intent.desiredHash}`,
  );
}

export function durableMutationCallbacks(
  env: Env,
  runId: string,
  authorityCommit: string,
  repairLimit = Number.POSITIVE_INFINITY,
): Pick<
  LiveAuditOptions,
  | "beforeMutation"
  | "onMutationIntent"
  | "onMutationResult"
  | "onMutationCheckpoint"
> {
  if (
    repairLimit !== Number.POSITIVE_INFINITY &&
    (!Number.isSafeInteger(repairLimit) || repairLimit < 0)
  )
    throw new Error("INVALID_REPAIR_BUDGET");
  let claimedMutations = 0;
  const activeAttemptIds = new Map<string, string>();
  const beforeMutation = async (): Promise<void> => {
    await Promise.resolve();
    if (claimedMutations >= repairLimit)
      throw new RepairBudgetExhausted(repairLimit);
    claimedMutations += 1;
  };
  const onMutationIntent = async (
    intent: LiveMutationIntent,
  ): Promise<void> => {
    const now = new Date().toISOString();
    const reconciliationKey = await durableMutationReconciliationKey(
      authorityCommit,
      intent,
    );
    const id = crypto.randomUUID();
    await env.CONTROL_DB.prepare(
      "INSERT INTO mutation_receipts (id, run_id, canonical_key, operation, before_hash, desired_hash, result_hash, status, created_at, verified_at, error, evidence_json, reconciliation_key) VALUES (?, ?, ?, ?, ?, ?, NULL, 'pending', ?, NULL, NULL, NULL, ?)",
    )
      .bind(
        id,
        runId,
        intent.canonicalKey,
        intent.operation,
        intent.beforeHash,
        intent.desiredHash,
        now,
        reconciliationKey,
      )
      .run();
    activeAttemptIds.set(reconciliationKey, id);
  };
  const onMutationResult = async (
    result: LiveMutationCheckpoint,
  ): Promise<void> => {
    const now = new Date().toISOString();
    const reconciliationKey = await durableMutationReconciliationKey(
      authorityCommit,
      result,
    );
    const id = activeAttemptIds.get(reconciliationKey);
    if (!id) throw new Error("DURABLE_MUTATION_ATTEMPT_ID_MISSING");
    const outcomeKnown = result.resultHash.length > 0;
    const status = result.reconciled
      ? "verified"
      : result.skipped
        ? "skipped"
        : !outcomeKnown
          ? "pending"
          : result.verified
            ? "verified"
            : "failed";
    const update = await env.CONTROL_DB.prepare(
      "UPDATE mutation_receipts SET result_hash = ?, status = ?, verified_at = ?, error = ?, evidence_json = ? WHERE id = ? AND reconciliation_key = ? AND status = 'pending'",
    )
      .bind(
        outcomeKnown ? result.resultHash : null,
        status,
        status === "verified" ? now : null,
        status === "verified"
          ? null
          : (result.error ??
              (outcomeKnown
                ? "POST_WRITE_VERIFICATION_FAILED"
                : "POST_WRITE_OUTCOME_UNKNOWN")),
        stableJson({
          reconciled: result.reconciled === true,
          outcomeKnown,
          skipped: result.skipped === true,
        }),
        id,
        reconciliationKey,
      )
      .run();
    activeAttemptIds.delete(reconciliationKey);
    if (update.meta.changes !== 1)
      throw new Error("DURABLE_MUTATION_PENDING_RECEIPT_MISSING");
  };
  const onMutationCheckpoint = async (
    checkpoint: LiveMutationCheckpoint,
  ): Promise<void> => {
    if (
      !checkpoint.verified ||
      checkpoint.resultHash !== checkpoint.desiredHash
    )
      return;
    const now = new Date().toISOString();
    const reconciliationKey = await durableMutationReconciliationKey(
      authorityCommit,
      checkpoint,
    );
    await env.CONTROL_DB.prepare(
      "UPDATE mutation_receipts SET result_hash = desired_hash, status = 'verified', verified_at = ?, error = NULL, evidence_json = ? WHERE reconciliation_key = ? AND status = 'pending' AND desired_hash = ?",
    )
      .bind(
        now,
        stableJson({ reconciled: true }),
        reconciliationKey,
        checkpoint.desiredHash,
      )
      .run();
  };
  return {
    beforeMutation,
    onMutationIntent,
    onMutationResult,
    onMutationCheckpoint,
  };
}

function json(value: unknown, status = 200): Response {
  return Response.json(value, {
    status,
    headers: { "Cache-Control": "no-store" },
  });
}

function timingSafeEqual(left: string, right: string): boolean {
  const leftBytes = encoder.encode(left);
  const rightBytes = encoder.encode(right);
  if (leftBytes.byteLength !== rightBytes.byteLength) return false;
  return nodeTimingSafeEqual(leftBytes, rightBytes);
}

async function hmacHex(secret: string, value: Uint8Array): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const copy = Uint8Array.from(value);
  const signature = await crypto.subtle.sign("HMAC", key, copy.buffer);
  return [...new Uint8Array(signature)]
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

async function signedEnvelope(
  request: Request,
  env: Env,
  source: "linear" | "github" | "manual",
): Promise<EventEnvelope> {
  const length = Number(request.headers.get("content-length") ?? "0");
  const max = Number(env.MAX_EVENT_BYTES);
  if (length > max) throw new Error("PAYLOAD_TOO_LARGE");
  const body = new Uint8Array(await request.arrayBuffer());
  if (body.byteLength > max) throw new Error("PAYLOAD_TOO_LARGE");
  const deliveryId =
    request.headers.get(
      source === "github" ? "x-github-delivery" : "linear-delivery",
    ) ?? request.headers.get("x-delivery-id");
  if (!deliveryId) throw new Error("MISSING_DELIVERY_ID");
  const supplied = request.headers
    .get(
      source === "linear"
        ? "linear-signature"
        : source === "github"
          ? "x-hub-signature-256"
          : "x-control-signature",
    )
    ?.replace(/^sha256=/, "");
  if (!supplied) throw new Error("MISSING_SIGNATURE");
  const secret =
    source === "linear"
      ? env.LINEAR_WEBHOOK_SECRET
      : source === "github"
        ? env.GITHUB_WEBHOOK_SECRET
        : env.CONTROL_ADMIN_SECRET;
  const expected = await hmacHex(secret, body);
  if (!timingSafeEqual(expected, supplied))
    throw new Error("INVALID_SIGNATURE");
  const payload = JSON.parse(new TextDecoder().decode(body)) as unknown;
  if (source === "linear") {
    const timestamp =
      typeof payload === "object" &&
      payload !== null &&
      "webhookTimestamp" in payload
        ? Number(payload.webhookTimestamp)
        : Number(request.headers.get("linear-timestamp"));
    if (
      !Number.isFinite(timestamp) ||
      Math.abs(Date.now() - timestamp) > 60_000
    )
      throw new Error("STALE_SIGNATURE");
  }
  const authorityCommit =
    source === "github" ? authorityCommitFromPayload(payload) : null;
  if (source === "github") {
    if (!authorityCommit) throw new Error("MISSING_AUTHORITY_COMMIT");
    if (!githubEvidenceIsEligible(payload, env))
      throw new Error("INELIGIBLE_GITHUB_EVIDENCE");
  }
  const receivedAt = new Date().toISOString();
  return {
    schemaVersion: 1,
    deliveryId,
    source,
    receivedAt,
    ...(authorityCommit
      ? { authorityCommit, authorityPinnedAt: receivedAt }
      : {}),
    payload,
  };
}

async function persistDelivery(
  env: Env,
  event: EventEnvelope,
): Promise<boolean> {
  const hash = await sha256Text(JSON.stringify(event.payload));
  const now = new Date().toISOString();
  const result = await env.CONTROL_DB.prepare(
    "INSERT OR IGNORE INTO deliveries (id, source, schema_version, payload_hash, payload_json, status, authority_commit, authority_pinned_at, received_at, updated_at) VALUES (?, ?, ?, ?, ?, 'queued', ?, ?, ?, ?)",
  )
    .bind(
      event.deliveryId,
      event.source,
      event.schemaVersion,
      hash,
      JSON.stringify(event.payload),
      event.authorityCommit ?? null,
      event.authorityPinnedAt ?? (event.authorityCommit ? now : null),
      now,
      now,
    )
    .run();
  return result.meta.changes > 0;
}

async function enqueue(
  env: Env,
  event: EventEnvelope,
  acceptedStatus = 202,
): Promise<Response> {
  const inserted = await persistDelivery(env, event);
  if (inserted) await env.CONTROL_QUEUE.send(event, { contentType: "json" });
  return json(
    { accepted: true, duplicate: !inserted, deliveryId: event.deliveryId },
    acceptedStatus,
  );
}

export async function continuePinnedEvent(
  env: Env,
  event: EventEnvelope,
  runId: string,
): Promise<void> {
  const continuedAt = new Date().toISOString();
  const receiptCount = await env.CONTROL_DB.prepare(
    "SELECT COUNT(*) AS count FROM mutation_receipts WHERE run_id = ? AND operation <> 'task-proof' AND status = 'verified' AND COALESCE(json_extract(evidence_json, '$.skipped'), 0) = 0",
  )
    .bind(runId)
    .first<{ count: number }>();
  const verifiedRepairs = receiptCount?.count ?? 0;
  await env.CONTROL_DB.batch([
    env.CONTROL_DB.prepare(
      "UPDATE runs SET status = 'continuing', mutation_count = ?, completed_at = ?, error = NULL WHERE id = ?",
    ).bind(verifiedRepairs, continuedAt, runId),
    env.CONTROL_DB.prepare(
      "UPDATE deliveries SET status = 'continuing', updated_at = ?, last_error = NULL WHERE id = ?",
    ).bind(continuedAt, event.deliveryId),
  ]);
  await env.CONTROL_QUEUE.send(event, {
    contentType: "json",
    delaySeconds: CONTINUATION_DELAY_SECONDS,
  });
}

async function processEvent(
  env: Env,
  receivedEvent: EventEnvelope,
): Promise<void> {
  const existing = await env.CONTROL_DB.prepare(
    "SELECT status FROM deliveries WHERE id = ?",
  )
    .bind(receivedEvent.deliveryId)
    .first<{ status: string }>();
  if (existing?.status === "verified" || existing?.status === "superseded")
    return;
  const started = new Date().toISOString();
  await env.CONTROL_DB.prepare(
    "UPDATE deliveries SET status = 'processing', attempts = attempts + 1, updated_at = ? WHERE id = ?",
  )
    .bind(started, receivedEvent.deliveryId)
    .run();
  const { event } = await pinEventAuthority(env, receivedEvent);
  if (!(await authorityIsCurrent(env, event))) {
    await env.CONTROL_DB.prepare(
      "UPDATE deliveries SET status = 'superseded', updated_at = ?, last_error = 'Superseded before reconciliation by newer main authority' WHERE id = ?",
    )
      .bind(started, event.deliveryId)
      .run();
    return;
  }
  const runId = crypto.randomUUID();
  const manifest = await loadManifestForEvent(env, event);
  const commit = manifest.authorityCommit;
  const desiredHash = manifest.contractHash;
  const github = new GitHubEvidenceClient(env.GITHUB_API_TOKEN);
  const runtimeLifecycleTree = (
    await github.repositoryTree(env.GITHUB_REPOSITORY, commit)
  ).blobs;
  let taskProofResolverPromise: Promise<TaskProofResolver> | undefined;
  const resolveTaskProof: TaskProofResolver = async (input) => {
    taskProofResolverPromise ??= taskProofResolverForEvent(
      env,
      commit,
      taskProofResolver(env, commit),
      async (receipt) => persistTaskProofReceipt(env, runId, receipt),
    );
    return (await taskProofResolverPromise)(input);
  };
  await env.CONTROL_DB.prepare(
    "INSERT INTO runs (id, delivery_id, mode, authority_commit, desired_hash, status, started_at) VALUES (?, ?, 'event', ?, ?, 'verifying', ?)",
  )
    .bind(runId, event.deliveryId, commit, desiredHash, started)
    .run();
  const mutationCallbacks = durableMutationCallbacks(
    env,
    runId,
    commit,
    EVENT_REPAIR_BUDGET,
  );
  let audit;
  try {
    audit = await auditLiveWorkspace(
      new LinearClient(env.LINEAR_API_TOKEN, env.LINEAR_API_URL),
      manifest,
      env.MUTATIONS_ENABLED,
      {
        loadRepositoryText: async (path) => {
          return fetchRepositoryText(env, commit, path);
        },
        runtimeLifecycleTree,
        verifyRuntimeAuthority: async () => authorityIsCurrent(env, event),
        resolveTaskProof,
        ...mutationCallbacks,
      },
    );
  } catch (error) {
    if (error instanceof RepairBudgetExhausted) {
      await continuePinnedEvent(env, event, runId);
      return;
    }
    throw error;
  }
  if (!(await authorityIsCurrent(env, event)))
    throw new Error("RUNTIME_AUTHORITY_SUPERSEDED");
  const completed = new Date().toISOString();
  await Promise.all(
    audit.proofReceipts.map((receipt) =>
      persistTaskProofReceipt(env, runId, receipt, completed),
    ),
  );
  const mappingStatements = audit.mappings.map((mapping) =>
    env.CONTROL_DB.prepare(
      "INSERT INTO object_mappings (canonical_key, linear_id, object_type, authority_commit, desired_hash, verified_at) VALUES (?, ?, ?, ?, ?, ?) ON CONFLICT(canonical_key) DO UPDATE SET linear_id = excluded.linear_id, object_type = excluded.object_type, authority_commit = excluded.authority_commit, desired_hash = excluded.desired_hash, verified_at = excluded.verified_at",
    ).bind(
      mapping.canonicalKey,
      mapping.linearId,
      mapping.objectType,
      commit,
      mapping.desiredHash,
      completed,
    ),
  );
  await executeD1Batches(env.CONTROL_DB, mappingStatements);
  await env.CONTROL_DB.prepare(
    "UPDATE exceptions SET resolved_at = ? WHERE resolved_at IS NULL",
  )
    .bind(completed)
    .run();
  const exceptionStatements = await Promise.all(
    audit.exceptions.map(async (item) => {
      const id = await sha256Text(
        `${item.canonicalKey ?? "workspace"}\0${item.summary}`,
      );
      return env.CONTROL_DB.prepare(
        "INSERT INTO exceptions (id, canonical_key, category, severity, summary, first_seen_at, last_seen_at, resolved_at) VALUES (?, ?, ?, ?, ?, ?, ?, NULL) ON CONFLICT(id) DO UPDATE SET severity = excluded.severity, summary = excluded.summary, last_seen_at = excluded.last_seen_at, resolved_at = NULL",
      ).bind(
        id,
        item.canonicalKey ?? null,
        item.category,
        item.severity,
        item.summary,
        completed,
        completed,
      );
    }),
  );
  await executeD1Batches(env.CONTROL_DB, exceptionStatements);
  await env.CONTROL_DB.prepare(
    "INSERT INTO metric_snapshots (id, captured_at, authority_commit, payload_json) VALUES (?, ?, ?, ?)",
  )
    .bind(crypto.randomUUID(), completed, commit, JSON.stringify(audit.metrics))
    .run();
  const status = audit.exceptions.length === 0 ? "converged" : "drift";
  await env.CONTROL_DB.batch([
    env.CONTROL_DB.prepare(
      "UPDATE runs SET status = ?, mutation_count = ?, completed_at = ? WHERE id = ?",
    ).bind(status, audit.repairs, completed, runId),
    env.CONTROL_DB.prepare(
      "UPDATE deliveries SET status = ?, updated_at = ?, last_error = NULL WHERE id = ?",
    ).bind(
      status === "converged" ? "verified" : "drift",
      completed,
      event.deliveryId,
    ),
    ...(status === "converged"
      ? [
          env.CONTROL_DB.prepare(
            "UPDATE deliveries SET status = 'superseded', updated_at = ?, last_error = 'Superseded by a later converged full audit' WHERE status IN ('queued', 'processing', 'continuing', 'retrying', 'drift') AND received_at < ? AND id <> ?",
          ).bind(completed, started, event.deliveryId),
        ]
      : []),
  ]);
  console.log(
    JSON.stringify({
      message: "workspace reconciliation completed",
      deliveryId: event.deliveryId,
      source: event.source,
      mutationsEnabled: env.MUTATIONS_ENABLED,
      status,
      exceptions: audit.exceptions.length,
      repairs: audit.repairs,
    }),
  );
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    if (request.method === "GET" && url.pathname === "/health") {
      const row = await env.CONTROL_DB.prepare(
        "SELECT COUNT(*) AS count FROM exceptions WHERE resolved_at IS NULL",
      ).first<{ count: number }>();
      const latest = await env.CONTROL_DB.prepare(
        "SELECT captured_at, authority_commit, payload_json FROM metric_snapshots ORDER BY captured_at DESC LIMIT 1",
      ).first<{
        captured_at: string;
        authority_commit: string;
        payload_json: string;
      }>();
      return json({
        status: "ok",
        mutationsEnabled: env.MUTATIONS_ENABLED,
        openExceptions: row?.count ?? 0,
        latestAudit: latest
          ? {
              capturedAt: latest.captured_at,
              authorityCommit: latest.authority_commit,
              metrics: JSON.parse(latest.payload_json) as unknown,
            }
          : null,
        now: new Date().toISOString(),
      });
    }
    if (request.method !== "POST") return json({ error: "NOT_FOUND" }, 404);
    try {
      if (url.pathname === "/webhooks/linear")
        return await enqueue(
          env,
          await signedEnvelope(request, env, "linear"),
          200,
        );
      if (url.pathname === "/events/github")
        return await enqueue(env, await signedEnvelope(request, env, "github"));
      if (url.pathname === "/reconcile")
        return await enqueue(env, await signedEnvelope(request, env, "manual"));
      if (url.pathname === "/replay") {
        const requestEvent = await signedEnvelope(request, env, "manual");
        const requested = requestEvent.payload as { deliveryId?: unknown };
        if (typeof requested.deliveryId !== "string")
          return json({ error: "DELIVERY_ID_REQUIRED" }, 400);
        const stored = await env.CONTROL_DB.prepare(
          "SELECT source, schema_version, payload_json, authority_commit, authority_pinned_at FROM deliveries WHERE id = ?",
        )
          .bind(requested.deliveryId)
          .first<{
            source: EventEnvelope["source"];
            schema_version: 1;
            payload_json: string | null;
            authority_commit: string | null;
            authority_pinned_at: string | null;
          }>();
        if (!stored?.payload_json)
          return json({ error: "DELIVERY_NOT_REPLAYABLE" }, 404);
        return await enqueue(env, {
          schemaVersion: stored.schema_version,
          deliveryId: `replay:${requested.deliveryId}:${crypto.randomUUID()}`,
          source: stored.source,
          receivedAt: new Date().toISOString(),
          ...(stored.authority_commit
            ? {
                authorityCommit: stored.authority_commit,
                ...(stored.authority_pinned_at
                  ? { authorityPinnedAt: stored.authority_pinned_at }
                  : {}),
              }
            : {}),
          payload: JSON.parse(stored.payload_json) as unknown,
        });
      }
      return json({ error: "NOT_FOUND" }, 404);
    } catch (error) {
      const message = error instanceof Error ? error.message : "UNKNOWN_ERROR";
      console.error(
        JSON.stringify({
          message: "ingress rejected",
          reason: message,
          path: url.pathname,
        }),
      );
      return json(
        { error: message },
        message === "PAYLOAD_TOO_LARGE" ? 413 : 401,
      );
    }
  },
  async queue(batch: MessageBatch<EventEnvelope>, env: Env): Promise<void> {
    for (const message of batch.messages) {
      try {
        await processEvent(env, message.body);
        message.ack();
      } catch (error) {
        const reason = error instanceof Error ? error.message : "UNKNOWN_ERROR";
        console.error(
          JSON.stringify({
            message: "delivery failed",
            deliveryId: message.body.deliveryId,
            reason,
          }),
        );
        await env.CONTROL_DB.prepare(
          "UPDATE deliveries SET status = 'retrying', updated_at = ?, last_error = ? WHERE id = ?",
        )
          .bind(new Date().toISOString(), reason, message.body.deliveryId)
          .run();
        message.retry({
          delaySeconds: Math.min(3600, 30 * 2 ** message.attempts),
        });
      }
    }
  },
  async scheduled(_controller: ScheduledController, env: Env): Promise<void> {
    const event: EventEnvelope = {
      schemaVersion: 1,
      deliveryId: `scheduled:${new Date().toISOString().slice(0, 13)}`,
      source: "scheduled",
      receivedAt: new Date().toISOString(),
      payload: { kind: "full-check" },
    };
    if (await persistDelivery(env, event))
      await env.CONTROL_QUEUE.send(event, { contentType: "json" });
  },
} satisfies ExportedHandler<Env, EventEnvelope>;

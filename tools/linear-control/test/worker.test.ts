import { createHmac } from "node:crypto";
import { readFileSync } from "node:fs";
import { DatabaseSync, type SQLInputValue } from "node:sqlite";
import { describe, expect, it, vi } from "vitest";
import worker, {
  authorityIsCurrent,
  authorityCommitFromPayload,
  durableMutationCallbacks,
  fetchRepositoryText,
  loadManifestForEvent,
  pinEventAuthority,
  repositoryRawUrl,
  taskProofResolver,
  taskProofResolverForEvent,
} from "../src/worker.js";
import type { LiveMutationIntent } from "../src/core/live-audit.js";
import type { EventEnvelope, TaskContract } from "../src/core/types.js";
import { sha256Text, stableJson } from "../src/core/hash.js";
import type { RetryPolicy } from "../src/adapters/http.js";

const requestTestPolicy: RetryPolicy = {
  attempts: 2,
  requestTimeoutMs: 50,
  totalBudgetMs: 5_000,
  baseDelayMs: 1,
  maxServerDelayMs: 3_000,
};

function environment(changeCount = 1): {
  env: Env;
  queueSend: ReturnType<typeof vi.fn>;
  prepare: ReturnType<typeof vi.fn>;
  statement: {
    bind: ReturnType<typeof vi.fn>;
    run: ReturnType<typeof vi.fn>;
    first: ReturnType<typeof vi.fn>;
    all: ReturnType<typeof vi.fn>;
  };
} {
  const defaultAuthority = "e".repeat(40);
  const statement = {
    bind: vi.fn().mockReturnThis(),
    run: vi.fn().mockResolvedValue({ meta: { changes: changeCount } }),
    first: vi.fn().mockResolvedValue({
      authority_commit: defaultAuthority,
      authority_pinned_at: "2026-08-09T00:00:00.000Z",
    }),
    all: vi.fn().mockResolvedValue({
      results: [greenAuthorityRow(defaultAuthority)],
    }),
  };
  const queueSend = vi.fn().mockResolvedValue(undefined);
  const prepare = vi.fn().mockReturnValue(statement);
  const env = {
    CONTROL_ADMIN_SECRET: "admin-secret",
    GITHUB_WEBHOOK_SECRET: "github-secret",
    GITHUB_API_TOKEN: "github-api-token",
    GITHUB_REPOSITORY: "agentdevan/ambitions",
    MANIFEST_PATH: "tools/linear-control/generated/desired-workspace.json",
    CONTROL_DB: {
      prepare,
    },
    CONTROL_QUEUE: {
      send: queueSend,
    },
    MAX_EVENT_BYTES: "65536",
  } as unknown as Env;
  return { env, queueSend, prepare, statement };
}

function greenAuthorityRow(
  authorityCommit: string,
  authorityPinnedAt = "2026-08-09T00:00:00.000Z",
) {
  return {
    authority_commit: authorityCommit,
    authority_pinned_at: authorityPinnedAt,
    payload_json: JSON.stringify({
      schemaVersion: 1,
      kind: "code-quality",
      authorityCommit,
      conclusion: "success",
      repository: "agentdevan/ambitions",
      workflowEvent: "push",
      headBranch: "main",
    }),
  };
}

function event(
  source: EventEnvelope["source"],
  authorityCommit?: string,
  authorityPinnedAt?: string,
): EventEnvelope {
  return {
    schemaVersion: 1,
    deliveryId: `delivery-${source}`,
    source,
    receivedAt: "2026-08-09T00:00:00.000Z",
    ...(authorityCommit ? { authorityCommit } : {}),
    ...(authorityPinnedAt ? { authorityPinnedAt } : {}),
    payload: { kind: "test" },
  };
}

async function manifestAt(compileProvenanceCommit: string) {
  const semantic = {
    schemaVersion: 1 as const,
    authorityCommit: compileProvenanceCommit,
    projects: [],
    schedule: [],
  };
  return {
    ...semantic,
    contractHash: await sha256Text(stableJson(semantic)),
  };
}

function proofTask(): TaskContract {
  return {
    id: "T3",
    canonicalKey: "cross-taxonomy-relationship-authority:T3",
    title: "O*NET-SOC and gated O*NET-ESCO",
    body: "3. Implement exact O*NET-SOC granularity.",
    projectSlug: "cross-taxonomy-relationship-authority",
    order: 3,
    dependencies: ["cross-taxonomy-relationship-authority:T1"],
    sharedPaths: [],
    proof: { required: ["audit"], validationCommands: [], rollback: "stop" },
    frontendImpact: "none",
    visualGate: "not-required",
  };
}

async function proofReceiptRow(
  authorityCommit: string,
  overrides: Readonly<Record<string, unknown>> = {},
) {
  const task = proofTask();
  const evidence = {
    schemaVersion: 1,
    authorityCommit,
    canonicalKey: task.canonicalKey,
    issueIdentifier: "AMB-1870",
    pullRequestUrl: "https://github.com/agentdevan/ambitions/pull/81",
    mergeCommitSha: "3".repeat(40),
    proofContractHash: await sha256Text(stableJson(task.proof)),
    ...overrides,
  };
  const evidenceJson = stableJson(evidence);
  const evidenceHash = await sha256Text(evidenceJson);
  return {
    canonical_key: task.canonicalKey,
    authority_commit: authorityCommit,
    desired_hash: evidenceHash,
    result_hash: evidenceHash,
    status: "verified",
    evidence_json: evidenceJson,
  };
}

describe("Worker ingress", () => {
  it("authenticates and queues one manual reconciliation", async () => {
    const { env, queueSend } = environment();
    const body = JSON.stringify({ kind: "full-check" });
    const signature = createHmac("sha256", env.CONTROL_ADMIN_SECRET)
      .update(body)
      .digest("hex");
    const response = await worker.fetch(
      new Request("https://control.example/reconcile", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-control-signature": signature,
          "x-delivery-id": "test-delivery",
        },
        body,
      }),
      env,
    );

    expect(response.status).toBe(202);
    await expect(response.json()).resolves.toEqual({
      accepted: true,
      duplicate: false,
      deliveryId: "test-delivery",
    });
    expect(queueSend).toHaveBeenCalledOnce();
  });

  it("rejects an invalid signature without queueing", async () => {
    const { env, queueSend } = environment();
    const response = await worker.fetch(
      new Request("https://control.example/reconcile", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-control-signature": "invalid",
          "x-delivery-id": "bad-delivery",
        },
        body: JSON.stringify({ kind: "full-check" }),
      }),
      env,
    );

    expect(response.status).toBe(401);
    expect(queueSend).not.toHaveBeenCalled();
  });

  it("extracts and queues the exact signed GitHub authority commit", async () => {
    const { env, queueSend } = environment();
    const authorityCommit = "a".repeat(40);
    const body = JSON.stringify({
      schemaVersion: 1,
      kind: "code-quality",
      authorityCommit,
      conclusion: "success",
      repository: "agentdevan/ambitions",
      workflowEvent: "push",
      headBranch: "main",
    });
    const signature = createHmac("sha256", env.GITHUB_WEBHOOK_SECRET)
      .update(body)
      .digest("hex");

    const response = await worker.fetch(
      new Request("https://control.example/events/github", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-github-delivery": "github-delivery",
          "x-hub-signature-256": `sha256=${signature}`,
        },
        body,
      }),
      env,
    );

    expect(response.status).toBe(202);
    expect(queueSend).toHaveBeenCalledWith(
      expect.objectContaining({ authorityCommit }),
      { contentType: "json" },
    );
  });

  it("ignores authority fields from non-GitHub ingress", async () => {
    const { env, queueSend } = environment();
    const body = JSON.stringify({
      kind: "manual-reconcile",
      authorityCommit: "a".repeat(40),
    });
    const signature = createHmac("sha256", env.CONTROL_ADMIN_SECRET)
      .update(body)
      .digest("hex");

    const response = await worker.fetch(
      new Request("https://control.example/reconcile", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-delivery-id": "manual-delivery",
          "x-control-signature": `sha256=${signature}`,
        },
        body,
      }),
      env,
    );

    expect(response.status).toBe(202);
    const queued = queueSend.mock.calls[0]?.[0] as EventEnvelope;
    expect(queued.authorityCommit).toBeUndefined();
    expect(queueSend).toHaveBeenCalledWith(queued, { contentType: "json" });
  });

  it("rejects signed pull-request authority events", async () => {
    const { env, queueSend } = environment();
    const body = JSON.stringify({
      schemaVersion: 1,
      kind: "code-quality",
      authorityCommit: "d".repeat(40),
      conclusion: "success",
      repository: "agentdevan/ambitions",
      workflowEvent: "pull_request",
      headBranch: "feature-branch",
    });
    const signature = createHmac("sha256", env.GITHUB_WEBHOOK_SECRET)
      .update(body)
      .digest("hex");

    const response = await worker.fetch(
      new Request("https://control.example/events/github", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-github-delivery": "pull-request-delivery",
          "x-hub-signature-256": `sha256=${signature}`,
        },
        body,
      }),
      env,
    );

    expect(response.status).toBe(401);
    expect(queueSend).not.toHaveBeenCalled();
  });

  it.each([
    { conclusion: "failure", workflowEvent: "push", headBranch: "main" },
    { conclusion: "success", workflowEvent: "push", headBranch: "other" },
    {
      conclusion: "success",
      workflowEvent: "push",
      headBranch: "main",
      repository: "other/repository",
    },
  ])("rejects ineligible signed GitHub evidence %#", async (evidence) => {
    const { env, queueSend } = environment();
    const body = JSON.stringify({
      schemaVersion: 1,
      kind: "code-quality",
      authorityCommit: "f".repeat(40),
      repository: "agentdevan/ambitions",
      ...evidence,
    });
    const signature = createHmac("sha256", env.GITHUB_WEBHOOK_SECRET)
      .update(body)
      .digest("hex");

    const response = await worker.fetch(
      new Request("https://control.example/events/github", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-github-delivery": `ineligible-${evidence.conclusion}-${evidence.headBranch}`,
          "x-hub-signature-256": `sha256=${signature}`,
        },
        body,
      }),
      env,
    );

    expect(response.status).toBe(401);
    expect(queueSend).not.toHaveBeenCalled();
  });

  it("rejects workflow_dispatch as completion authority", async () => {
    const { env, queueSend } = environment();
    const body = JSON.stringify({
      schemaVersion: 1,
      kind: "code-quality",
      authorityCommit: "f".repeat(40),
      conclusion: "manual",
      repository: "agentdevan/ambitions",
      workflowEvent: "workflow_dispatch",
      headBranch: "main",
    });
    const signature = createHmac("sha256", env.GITHUB_WEBHOOK_SECRET)
      .update(body)
      .digest("hex");

    const response = await worker.fetch(
      new Request("https://control.example/events/github", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-github-delivery": "manual-completion-authority",
          "x-hub-signature-256": `sha256=${signature}`,
        },
        body,
      }),
      env,
    );

    expect(response.status).toBe(401);
    expect(queueSend).not.toHaveBeenCalled();
  });

  it("accepts only exact commit SHAs for repository authority", () => {
    const authorityCommit = "b".repeat(40);
    expect(authorityCommitFromPayload({ authorityCommit })).toBe(
      authorityCommit,
    );
    expect(authorityCommitFromPayload({ authorityCommit: "main" })).toBeNull();
    expect(authorityCommitFromPayload({})).toBeNull();
  });

  it("builds repository URLs against an exact immutable commit", () => {
    const authorityCommit = "c".repeat(40);
    expect(
      repositoryRawUrl(
        "agentdevan/ambitions",
        authorityCommit,
        "tools/linear-control/generated/desired-workspace.json",
      ),
    ).toBe(
      `https://raw.githubusercontent.com/agentdevan/ambitions/${authorityCommit}/tools/linear-control/generated/desired-workspace.json`,
    );
    expect(() =>
      repositoryRawUrl("agentdevan/ambitions", "main", "manifest.json"),
    ).toThrow("INVALID_REPOSITORY_AUTHORITY_COMMIT");
  });

  it("reuses a persisted delivery authority across retries without GitHub", async () => {
    const { env, statement } = environment();
    const fetcher = vi.fn();

    const pinned = await pinEventAuthority(env, event("linear"));
    const replayed = await pinEventAuthority(env, pinned.event);

    expect(pinned.event.authorityCommit).toBe("e".repeat(40));
    expect(pinned.event.authorityPinnedAt).toBe("2026-08-09T00:00:00.000Z");
    expect(pinned.newlyPinned).toBe(false);
    expect(replayed.event).toBe(pinned.event);
    expect(statement.first).toHaveBeenCalledOnce();
    expect(fetcher).not.toHaveBeenCalled();
  });

  it("atomically pins the latest exact green authority on first queue consumption", async () => {
    const { env, prepare, statement } = environment();
    statement.first.mockResolvedValueOnce(null);
    const verified = "e".repeat(40);

    const pinned = await pinEventAuthority(env, event("linear"));

    expect(pinned.event.authorityCommit).toBe(verified);
    expect(pinned.event.authorityPinnedAt).toBe("2026-08-09T00:00:00.000Z");
    expect(pinned.newlyPinned).toBe(true);
    expect(prepare).toHaveBeenCalledWith(
      expect.stringContaining("authority_commit IS NULL"),
    );
  });

  it("does not pin an unverified current GitHub head for non-GitHub events", async () => {
    const { env, statement } = environment();
    statement.first.mockResolvedValue(null);
    const authorityCommit = "1".repeat(40);
    statement.all.mockResolvedValue({
      results: [
        {
          authority_commit: authorityCommit,
          authority_pinned_at: "2026-08-09T00:00:00.000Z",
          payload_json: JSON.stringify({
            schemaVersion: 1,
            kind: "code-quality",
            authorityCommit,
            conclusion: "manual",
            repository: "agentdevan/ambitions",
            workflowEvent: "workflow_dispatch",
            headBranch: "main",
          }),
        },
      ],
    });

    await expect(pinEventAuthority(env, event("scheduled"))).rejects.toThrow(
      "NO_VERIFIED_GITHUB_AUTHORITY",
    );
  });

  it("accepts non-GitHub events only at the latest exact green authority", async () => {
    const { env, statement } = environment();
    const verified = "2".repeat(40);
    const queued = "3".repeat(40);
    const fetcher = vi.fn().mockResolvedValue(Response.json({ sha: queued }));

    statement.all.mockResolvedValueOnce({
      results: [greenAuthorityRow(queued, "2026-08-09T00:01:00.000Z")],
    });
    await expect(
      authorityIsCurrent(
        env,
        event("linear", queued, "2026-08-09T00:01:00.000Z"),
        fetcher,
      ),
    ).resolves.toBe(true);

    statement.all.mockResolvedValueOnce({
      results: [greenAuthorityRow(verified, "2026-08-09T00:02:00.000Z")],
    });
    fetcher.mockResolvedValueOnce(Response.json({ sha: queued }));
    await expect(
      authorityIsCurrent(
        env,
        event("linear", queued, "2026-08-09T00:01:00.000Z"),
        fetcher,
      ),
    ).resolves.toBe(false);
  });

  it("rejects last-green authority after main advances until the exact later green event", async () => {
    const { env, statement } = environment();
    const lastGreen = "2".repeat(40);
    const advancedMain = "3".repeat(40);
    const fetcher = vi
      .fn()
      .mockResolvedValueOnce(Response.json({ sha: advancedMain }))
      .mockResolvedValueOnce(Response.json({ sha: advancedMain }));

    statement.all.mockResolvedValueOnce({
      results: [greenAuthorityRow(lastGreen)],
    });
    await expect(
      authorityIsCurrent(env, event("scheduled", lastGreen), fetcher),
    ).resolves.toBe(false);

    statement.all.mockResolvedValueOnce({
      results: [greenAuthorityRow(advancedMain)],
    });
    await expect(
      authorityIsCurrent(env, event("scheduled", advancedMain), fetcher),
    ).resolves.toBe(true);
  });

  it("supersedes scheduled delivery before live audit when main is ahead of last green", async () => {
    const { env, prepare } = environment();
    const originalFetch = globalThis.fetch;
    globalThis.fetch = vi
      .fn<typeof fetch>()
      .mockResolvedValue(Response.json({ sha: "f".repeat(40) }));
    const message = {
      body: event("scheduled", "e".repeat(40)),
      attempts: 0,
      ack: vi.fn(),
      retry: vi.fn(),
    };
    try {
      await worker.queue(
        { messages: [message] } as unknown as MessageBatch<EventEnvelope>,
        env,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }

    expect(message.ack).toHaveBeenCalledOnce();
    expect(message.retry).not.toHaveBeenCalled();
    expect(
      prepare.mock.calls.some(([query]) =>
        String(query).includes("status = 'superseded'"),
      ),
    ).toBe(true);
    expect(
      prepare.mock.calls.some(([query]) =>
        String(query).includes("INSERT INTO runs"),
      ),
    ).toBe(false);
  });

  it("checks signed GitHub authority against current main", async () => {
    const { env } = environment();
    const current = "2".repeat(40);
    const stale = "3".repeat(40);
    const fetcher = vi.fn().mockResolvedValue(Response.json({ sha: current }));

    await expect(
      authorityIsCurrent(env, event("github", stale), fetcher),
    ).resolves.toBe(false);
  });

  it("accepts completion authority only for exact current-main Code Quality push success", async () => {
    const { env } = environment();
    const current = "2".repeat(40);
    const exact = event("github", current);
    exact.payload = {
      schemaVersion: 1,
      kind: "code-quality",
      authorityCommit: current,
      conclusion: "success",
      repository: "agentdevan/ambitions",
      workflowEvent: "push",
      headBranch: "main",
    };
    const fetcher = vi.fn().mockResolvedValue(Response.json({ sha: current }));

    await expect(authorityIsCurrent(env, exact, fetcher)).resolves.toBe(true);
  });

  it("respects rate reset while resolving exact current main", async () => {
    const { env } = environment();
    const current = "2".repeat(40);
    const exact = event("github", current);
    exact.payload = {
      schemaVersion: 1,
      kind: "code-quality",
      authorityCommit: current,
      conclusion: "success",
      repository: "agentdevan/ambitions",
      workflowEvent: "push",
      headBranch: "main",
    };
    const sleep = vi.fn().mockResolvedValue(undefined);
    const fetcher = vi
      .fn<typeof fetch>()
      .mockResolvedValueOnce(
        new Response(null, { status: 429, headers: { "Retry-After": "1" } }),
      )
      .mockResolvedValueOnce(Response.json({ sha: current }));

    await expect(
      authorityIsCurrent(env, exact, fetcher, {
        policy: requestTestPolicy,
        runtime: { sleep },
      }),
    ).resolves.toBe(true);
    expect(sleep).toHaveBeenCalledWith(1_000);
  });

  it("carries task proof forward only when its unique PR merge is in exact green main", async () => {
    const { env } = environment();
    const authorityCommit = "4".repeat(40);
    const github = {
      pullRequest: vi.fn().mockResolvedValue({
        number: 81,
        title: "AMB-1870: Implement O*NET-SOC and gated O*NET-ESCO",
        state: "closed",
        merged: true,
        mergeCommitSha: "3".repeat(40),
        headBranch: "codex/amb-1870-onet-soc-esco",
      }),
      commitIncludes: vi.fn().mockResolvedValue(true),
    };
    const resolve = taskProofResolver(env, authorityCommit, github);

    await expect(
      resolve({
        issueIdentifier: "AMB-1870",
        attachmentUrls: ["https://github.com/agentdevan/ambitions/pull/81"],
        task: proofTask(),
      }),
    ).resolves.toEqual({
      source: "github",
      authorityCommit,
      mergedToMain: true,
      proofPassed: true,
      requiredProofFailed: false,
      issueIdentifier: "AMB-1870",
      pullRequestUrl: "https://github.com/agentdevan/ambitions/pull/81",
      mergeCommitSha: "3".repeat(40),
    });
    expect(github.commitIncludes).toHaveBeenCalledWith(
      "agentdevan/ambitions",
      "3".repeat(40),
      authorityCommit,
    );
  });

  it("fails task proof closed when PR mapping is ambiguous", async () => {
    const { env } = environment();
    const github = {
      pullRequest: vi.fn(),
      commitIncludes: vi.fn(),
    };
    const authorityCommit = "4".repeat(40);
    const resolve = taskProofResolver(env, authorityCommit, github);

    await expect(
      resolve({
        issueIdentifier: "AMB-1870",
        attachmentUrls: [
          "https://github.com/agentdevan/ambitions/pull/81",
          "https://github.com/agentdevan/ambitions/pull/82",
        ],
        task: proofTask(),
      }),
    ).resolves.toMatchObject({
      authorityCommit,
      mergedToMain: false,
      proofPassed: false,
    });
    expect(github.pullRequest).not.toHaveBeenCalled();
  });

  it.each([
    [
      "duplicate same URL",
      [
        "https://github.com/agentdevan/ambitions/pull/81",
        "https://github.com/agentdevan/ambitions/pull/81",
      ],
    ],
    [
      "duplicate equivalent URL",
      [
        "https://github.com/agentdevan/ambitions/pull/81",
        "https://github.com/agentdevan/ambitions/pull/81/",
      ],
    ],
  ])("fails task proof closed for %s attachment rows", async (_name, urls) => {
    const { env } = environment();
    const github = {
      pullRequest: vi.fn(),
      commitIncludes: vi.fn(),
    };
    const authorityCommit = "4".repeat(40);
    const resolve = taskProofResolver(env, authorityCommit, github);

    await expect(
      resolve({
        issueIdentifier: "AMB-1870",
        attachmentUrls: urls,
        task: proofTask(),
      }),
    ).resolves.toMatchObject({ mergedToMain: false, proofPassed: false });
    expect(github.pullRequest).not.toHaveBeenCalled();
  });

  it.each([
    {
      name: "missing",
      title: "Implement O*NET-SOC and gated O*NET-ESCO",
      headBranch: "codex/onet-soc-esco",
    },
    {
      name: "mismatched",
      title: "AMB-9999: Unrelated repair",
      headBranch: "codex/amb-9999-unrelated",
    },
    {
      name: "ambiguous",
      title: "AMB-1870 and AMB-1871 combined repair",
      headBranch: "codex/amb-1870-amb-1871",
    },
  ])("fails task proof closed for $name PR identity", async (identity) => {
    const { env } = environment();
    const github = {
      pullRequest: vi.fn().mockResolvedValue({
        number: 81,
        title: identity.title,
        state: "closed",
        merged: true,
        mergeCommitSha: "3".repeat(40),
        headBranch: identity.headBranch,
      }),
      commitIncludes: vi.fn(),
    };
    const authorityCommit = "4".repeat(40);
    const resolve = taskProofResolver(env, authorityCommit, github);

    await expect(
      resolve({
        issueIdentifier: "AMB-1870",
        attachmentUrls: ["https://github.com/agentdevan/ambitions/pull/81"],
        task: proofTask(),
      }),
    ).resolves.toMatchObject({
      authorityCommit,
      mergedToMain: false,
      proofPassed: false,
    });
    expect(github.commitIncludes).not.toHaveBeenCalled();
  });

  it("keeps merge ancestry separate from unproven task validation commands", async () => {
    const { env } = environment();
    const authorityCommit = "4".repeat(40);
    const github = {
      pullRequest: vi.fn().mockResolvedValue({
        number: 81,
        title: "AMB-1870: Implement O*NET-SOC",
        state: "closed",
        merged: true,
        mergeCommitSha: "3".repeat(40),
        headBranch: "codex/amb-1870-onet-soc",
      }),
      commitIncludes: vi.fn().mockResolvedValue(true),
    };
    const resolve = taskProofResolver(env, authorityCommit, github);
    const task = proofTask();
    task.proof = {
      ...task.proof,
      validationCommands: ["make exact-task-proof"],
    };

    await expect(
      resolve({
        issueIdentifier: "AMB-1870",
        attachmentUrls: ["https://github.com/agentdevan/ambitions/pull/81"],
        task,
      }),
    ).resolves.toMatchObject({
      mergedToMain: true,
      proofPassed: false,
      requiredProofFailed: false,
    });
  });

  it("reuses exact-authority verified task proof without GitHub calls", async () => {
    const { env, statement } = environment();
    const authorityCommit = "4".repeat(40);
    statement.all.mockResolvedValue({
      results: [await proofReceiptRow(authorityCommit)],
    });
    const fresh = vi.fn();
    const resolve = await taskProofResolverForEvent(
      env,
      authorityCommit,
      fresh,
    );

    await expect(
      resolve({
        issueIdentifier: "AMB-1870",
        attachmentUrls: ["https://github.com/agentdevan/ambitions/pull/81"],
        task: proofTask(),
      }),
    ).resolves.toMatchObject({
      source: "receipt",
      authorityCommit,
      mergedToMain: true,
      proofPassed: true,
      issueIdentifier: "AMB-1870",
    });
    expect(fresh).not.toHaveBeenCalled();
  });

  it("does not reuse a receipt when duplicate equivalent PR rows exist", async () => {
    const { env, statement } = environment();
    const authorityCommit = "4".repeat(40);
    statement.all.mockResolvedValue({
      results: [await proofReceiptRow(authorityCommit)],
    });
    const fresh = vi.fn().mockResolvedValue({
      authorityCommit,
      mergedToMain: false,
      proofPassed: false,
      requiredProofFailed: false,
    });
    const resolve = await taskProofResolverForEvent(
      env,
      authorityCommit,
      fresh,
    );
    const input = {
      issueIdentifier: "AMB-1870",
      attachmentUrls: [
        "https://github.com/agentdevan/ambitions/pull/81",
        "https://github.com/agentdevan/ambitions/pull/81/",
      ],
      task: proofTask(),
    };

    await expect(resolve(input)).resolves.toMatchObject({ proofPassed: false });
    expect(fresh).toHaveBeenCalledWith(input);
  });

  it("requires fresh ancestry once for a new green authority", async () => {
    const { env, statement } = environment();
    const previousAuthority = "4".repeat(40);
    const newAuthority = "5".repeat(40);
    statement.all.mockResolvedValue({
      results: [await proofReceiptRow(previousAuthority)],
    });
    const fresh = vi.fn().mockResolvedValue({
      source: "github",
      authorityCommit: newAuthority,
      mergedToMain: true,
      proofPassed: true,
      requiredProofFailed: false,
      issueIdentifier: "AMB-1870",
      pullRequestUrl: "https://github.com/agentdevan/ambitions/pull/81",
      mergeCommitSha: "3".repeat(40),
    });
    const resolve = await taskProofResolverForEvent(env, newAuthority, fresh);
    const input = {
      issueIdentifier: "AMB-1870",
      attachmentUrls: ["https://github.com/agentdevan/ambitions/pull/81"],
      task: proofTask(),
    };

    await expect(resolve(input)).resolves.toMatchObject({
      source: "github",
      authorityCommit: newAuthority,
    });
    expect(fresh).toHaveBeenCalledOnce();
    expect(fresh).toHaveBeenCalledWith(input);
  });

  it.each([
    {
      name: "failed",
      row: async () => ({
        ...(await proofReceiptRow("4".repeat(40))),
        status: "failed",
      }),
    },
    {
      name: "ambiguous",
      row: async () =>
        proofReceiptRow("4".repeat(40), {
          issueIdentifier: ["AMB-1870", "AMB-1871"],
        }),
    },
  ])("never authorizes a $name task-proof receipt", async ({ row }) => {
    const { env, statement } = environment();
    const authorityCommit = "4".repeat(40);
    statement.all.mockResolvedValue({ results: [await row()] });
    const fresh = vi.fn().mockResolvedValue({
      authorityCommit,
      mergedToMain: false,
      proofPassed: false,
      requiredProofFailed: false,
    });
    const resolve = await taskProofResolverForEvent(
      env,
      authorityCommit,
      fresh,
    );

    await expect(
      resolve({
        issueIdentifier: "AMB-1870",
        attachmentUrls: ["https://github.com/agentdevan/ambitions/pull/81"],
        task: proofTask(),
      }),
    ).resolves.toMatchObject({ mergedToMain: false, proofPassed: false });
    expect(fresh).toHaveBeenCalledOnce();
  });

  it("rebinds stale manifest provenance to the exact green event authority", async () => {
    const { env } = environment();
    const repositoryRef = "4".repeat(40);
    const compileProvenanceCommit = "5".repeat(40);
    const manifest = await manifestAt(compileProvenanceCommit);
    const fetcher = vi
      .fn()
      .mockResolvedValueOnce(Response.json(manifest))
      .mockResolvedValueOnce(new Response("canonical source"));

    await expect(
      loadManifestForEvent(env, event("github", repositoryRef), fetcher),
    ).resolves.toEqual({
      ...manifest,
      authorityCommit: repositoryRef,
      compileProvenanceCommit,
    });
    await expect(
      fetchRepositoryText(
        env,
        repositoryRef,
        "docs/product-development/example/research.md",
        fetcher,
      ),
    ).resolves.toBe("canonical source");

    expect(fetcher.mock.calls[0]?.[0]).toBe(
      repositoryRawUrl(env.GITHUB_REPOSITORY, repositoryRef, env.MANIFEST_PATH),
    );
    expect(fetcher.mock.calls[1]?.[0]).toBe(
      repositoryRawUrl(
        env.GITHUB_REPOSITORY,
        repositoryRef,
        "docs/product-development/example/research.md",
      ),
    );
  });

  it("rejects a manifest whose compile-provenance contract hash is invalid", async () => {
    const { env } = environment();
    const fetcher = vi.fn().mockResolvedValue(
      Response.json({
        ...(await manifestAt("5".repeat(40))),
        contractHash: "6".repeat(64),
      }),
    );

    await expect(
      loadManifestForEvent(env, event("github", "4".repeat(40)), fetcher),
    ).rejects.toThrow("MANIFEST_CONTRACT_HASH_MISMATCH");
  });

  it("rejects a manifest with invalid embedded authority", async () => {
    const { env } = environment();
    const fetcher = vi.fn().mockResolvedValue(
      Response.json({
        schemaVersion: 1,
        authorityCommit: "main",
        contractHash: "7".repeat(64),
        projects: [],
        schedule: [],
      }),
    );

    await expect(
      loadManifestForEvent(env, event("github", "8".repeat(40)), fetcher),
    ).rejects.toThrow("MANIFEST_AUTHORITY_COMMIT_INVALID");
  });

  it("fails closed when a raw repository source request times out", async () => {
    const { env } = environment();
    const fetcher = vi.fn<typeof fetch>(
      (_input, init) =>
        new Promise<Response>((_resolve, reject) => {
          init?.signal?.addEventListener("abort", () =>
            reject(new DOMException("aborted", "AbortError")),
          );
        }),
    );

    await expect(
      fetchRepositoryText(
        env,
        "8".repeat(40),
        "docs/product-development/example/research.md",
        fetcher,
        {
          policy: {
            ...requestTestPolicy,
            attempts: 1,
            requestTimeoutMs: 1,
          },
          runtime: { sleep: async () => Promise.resolve() },
        },
      ),
    ).rejects.toThrow("REPOSITORY_SOURCE_TIMEOUT");
  });

  it("preserves a raw repository quota error instead of reporting a missing document", async () => {
    const { env } = environment();
    const fetcher = vi
      .fn<typeof fetch>()
      .mockResolvedValue(new Response(null, { status: 429 }));

    await expect(
      fetchRepositoryText(
        env,
        "8".repeat(40),
        "docs/product-development/example/research.md",
        fetcher,
        {
          policy: { ...requestTestPolicy, attempts: 1 },
        },
      ),
    ).rejects.toThrow("REPOSITORY_SOURCE_HTTP_429");
    await expect(
      fetchRepositoryText(
        env,
        "8".repeat(40),
        "docs/product-development/example/research.md",
        fetcher,
        {
          policy: { ...requestTestPolicy, attempts: 1 },
        },
      ),
    ).rejects.not.toThrow("RUNTIME_DOCUMENT_CONTRACT_MISSING");
  });

  it("replay preserves the original authority pin through persistence and consumption", async () => {
    const { env, queueSend, statement } = environment();
    const authorityCommit = "a".repeat(40);
    const authorityPinnedAt = "2026-08-09T00:03:00.000Z";
    statement.first.mockResolvedValueOnce({
      source: "scheduled",
      schema_version: 1,
      payload_json: JSON.stringify({ kind: "full-check" }),
      authority_commit: authorityCommit,
      authority_pinned_at: authorityPinnedAt,
    });
    const body = JSON.stringify({ deliveryId: "original-delivery" });
    const signature = createHmac("sha256", env.CONTROL_ADMIN_SECRET)
      .update(body)
      .digest("hex");

    const response = await worker.fetch(
      new Request("https://control.example/replay", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-delivery-id": "replay-request",
          "x-control-signature": `sha256=${signature}`,
        },
        body,
      }),
      env,
    );

    expect(response.status).toBe(202);
    const replay = queueSend.mock.calls[0]?.[0] as EventEnvelope;
    expect(replay).toMatchObject({ authorityCommit, authorityPinnedAt });
    expect(statement.bind).toHaveBeenCalledWith(
      replay.deliveryId,
      "scheduled",
      1,
      expect.any(String),
      JSON.stringify({ kind: "full-check" }),
      authorityCommit,
      authorityPinnedAt,
      expect.any(String),
      expect.any(String),
    );
    await expect(pinEventAuthority(env, replay)).resolves.toEqual({
      event: replay,
      newlyPinned: false,
    });
  });
});

describe("D1 authority-pin migration", () => {
  it("backfills legacy authority rows from their received time", () => {
    const database = new DatabaseSync(":memory:");
    try {
      database.exec(
        readFileSync(
          new URL("../migrations/0001_initial.sql", import.meta.url),
          "utf8",
        ),
      );
      database.exec(
        readFileSync(
          new URL("../migrations/0002_replay_payload.sql", import.meta.url),
          "utf8",
        ),
      );
      database
        .prepare(
          "INSERT INTO deliveries (id, source, schema_version, payload_hash, payload_json, status, authority_commit, received_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        )
        .run(
          "legacy",
          "github",
          1,
          "hash",
          "{}",
          "verified",
          "a".repeat(40),
          "2026-08-09T00:04:00.000Z",
          "2026-08-09T00:05:00.000Z",
        );
      database.exec(
        readFileSync(
          new URL("../migrations/0003_authority_pin.sql", import.meta.url),
          "utf8",
        ),
      );
      database.exec(
        readFileSync(
          new URL(
            "../migrations/0004_task_proof_evidence.sql",
            import.meta.url,
          ),
          "utf8",
        ),
      );

      expect(
        database
          .prepare(
            "SELECT authority_pinned_at FROM deliveries WHERE id = 'legacy'",
          )
          .get(),
      ).toEqual({ authority_pinned_at: "2026-08-09T00:04:00.000Z" });
      expect(
        database
          .prepare("PRAGMA table_info(mutation_receipts)")
          .all()
          .some((column) => column.name === "evidence_json"),
      ).toBe(true);
      expect(
        database
          .prepare("PRAGMA table_info(mutation_receipts)")
          .all()
          .some((column) => column.name === "reconciliation_key"),
      ).toBe(true);
    } finally {
      database.close();
    }
  });
});

describe("durable mutation checkpoints", () => {
  it("retains append-only attempts for repeated drift and reconciles pending history", async () => {
    const database = new DatabaseSync(":memory:");
    try {
      database.exec(
        readFileSync(
          new URL("../migrations/0001_initial.sql", import.meta.url),
          "utf8",
        ),
      );
      database.exec(
        readFileSync(
          new URL(
            "../migrations/0004_task_proof_evidence.sql",
            import.meta.url,
          ),
          "utf8",
        ),
      );
      for (const runId of ["run-one", "run-two", "run-three", "run-four"])
        database
          .prepare(
            "INSERT INTO runs (id, mode, authority_commit, desired_hash, status, started_at) VALUES (?, 'event', ?, 'desired', 'verifying', '2026-08-09T00:00:00.000Z')",
          )
          .run(runId, "a".repeat(40));

      const d1 = {
        prepare(sql: string) {
          let values: SQLInputValue[] = [];
          const statement = {
            bind(...next: unknown[]) {
              values = next as SQLInputValue[];
              return statement;
            },
            async run() {
              await Promise.resolve();
              const result = database.prepare(sql).run(...values);
              return { meta: { changes: Number(result.changes) } };
            },
          };
          return statement;
        },
      } as unknown as D1Database;
      const env = { CONTROL_DB: d1 } as unknown as Env;
      const intent: LiveMutationIntent = {
        canonicalKey: "example:T1",
        operation: "issue-state-update",
        beforeHash: "before",
        desiredHash: "desired",
      };

      for (const runId of ["run-one", "run-two"]) {
        const callbacks = durableMutationCallbacks(env, runId, "a".repeat(40));
        await callbacks.onMutationIntent!(intent);
        await callbacks.onMutationResult!({
          ...intent,
          resultHash: intent.desiredHash,
          verified: true,
        });
      }
      expect(
        database
          .prepare(
            "SELECT COUNT(*) AS count, COUNT(DISTINCT id) AS ids, COUNT(DISTINCT reconciliation_key) AS keys FROM mutation_receipts",
          )
          .get(),
      ).toEqual({ count: 2, ids: 2, keys: 1 });
      expect(
        database
          .prepare(
            "SELECT run_id, status FROM mutation_receipts ORDER BY run_id",
          )
          .all(),
      ).toEqual([
        { run_id: "run-one", status: "verified" },
        { run_id: "run-two", status: "verified" },
      ]);

      const unknownIntent: LiveMutationIntent = {
        ...intent,
        desiredHash: "unknown-desired",
      };
      const unknownCallbacks = durableMutationCallbacks(
        env,
        "run-three",
        "a".repeat(40),
      );
      await unknownCallbacks.onMutationIntent!(unknownIntent);
      await unknownCallbacks.onMutationResult!({
        ...unknownIntent,
        resultHash: "",
        verified: false,
        error: "LINEAR_POST_WRITE_READ_TIMEOUT",
      });
      expect(
        database
          .prepare(
            "SELECT status, result_hash, error FROM mutation_receipts WHERE desired_hash = 'unknown-desired'",
          )
          .get(),
      ).toEqual({
        status: "pending",
        result_hash: null,
        error: "LINEAR_POST_WRITE_READ_TIMEOUT",
      });
      await durableMutationCallbacks(env, "run-four", "a".repeat(40))
        .onMutationCheckpoint!({
        ...unknownIntent,
        resultHash: unknownIntent.desiredHash,
        verified: true,
        reconciled: true,
      });
      expect(
        database
          .prepare(
            "SELECT run_id, status, result_hash, evidence_json FROM mutation_receipts WHERE desired_hash = 'unknown-desired'",
          )
          .get(),
      ).toEqual({
        run_id: "run-three",
        status: "verified",
        result_hash: "unknown-desired",
        evidence_json: stableJson({ reconciled: true }),
      });

      const failedIntent: LiveMutationIntent = {
        ...intent,
        desiredHash: "other-desired",
      };
      const callbacks = durableMutationCallbacks(
        env,
        "run-four",
        "a".repeat(40),
      );
      await callbacks.onMutationIntent!(failedIntent);
      await callbacks.onMutationResult!({
        ...failedIntent,
        resultHash: "observed",
        verified: false,
        error: "POST_WRITE_VERIFICATION_FAILED",
      });
      expect(
        database
          .prepare(
            "SELECT status, result_hash, error FROM mutation_receipts WHERE desired_hash = 'other-desired'",
          )
          .get(),
      ).toEqual({
        status: "failed",
        result_hash: "observed",
        error: "POST_WRITE_VERIFICATION_FAILED",
      });
    } finally {
      database.close();
    }
  });
});

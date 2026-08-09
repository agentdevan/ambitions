import { createHmac } from "node:crypto";
import { readFileSync } from "node:fs";
import { DatabaseSync } from "node:sqlite";
import { describe, expect, it, vi } from "vitest";
import worker, {
  authorityIsCurrent,
  authorityCommitFromPayload,
  fetchRepositoryText,
  loadManifestForEvent,
  pinEventAuthority,
  repositoryRawUrl,
} from "../src/worker.js";
import type { EventEnvelope } from "../src/core/types.js";

function environment(changeCount = 1): {
  env: Env;
  queueSend: ReturnType<typeof vi.fn>;
  prepare: ReturnType<typeof vi.fn>;
  statement: {
    bind: ReturnType<typeof vi.fn>;
    run: ReturnType<typeof vi.fn>;
    first: ReturnType<typeof vi.fn>;
  };
} {
  const statement = {
    bind: vi.fn().mockReturnThis(),
    run: vi.fn().mockResolvedValue({ meta: { changes: changeCount } }),
    first: vi.fn().mockResolvedValue({
      authority_commit: "e".repeat(40),
      authority_pinned_at: "2026-08-09T00:00:00.000Z",
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

    const pinned = await pinEventAuthority(env, event("linear"), fetcher);
    const replayed = await pinEventAuthority(env, pinned.event, fetcher);

    expect(pinned.event.authorityCommit).toBe("e".repeat(40));
    expect(pinned.event.authorityPinnedAt).toBe("2026-08-09T00:00:00.000Z");
    expect(pinned.newlyPinned).toBe(false);
    expect(replayed.event).toBe(pinned.event);
    expect(statement.first).toHaveBeenCalledOnce();
    expect(fetcher).not.toHaveBeenCalled();
  });

  it("atomically pins current main on first queue consumption", async () => {
    const { env, prepare, statement } = environment();
    statement.first.mockResolvedValueOnce(null);
    const current = "9".repeat(40);
    const fetcher = vi.fn().mockResolvedValue(Response.json({ sha: current }));

    const pinned = await pinEventAuthority(env, event("linear"), fetcher);

    expect(pinned.event.authorityCommit).toBe(current);
    expect(pinned.event.authorityPinnedAt).toMatch(/^2026-/);
    expect(pinned.newlyPinned).toBe(true);
    expect(prepare).toHaveBeenCalledWith(
      expect.stringContaining("authority_commit IS NULL"),
    );
  });

  it("pins fallback authority from the current GitHub main when no verified delivery exists", async () => {
    const { env, statement } = environment();
    statement.first.mockResolvedValueOnce(null);
    const authorityCommit = "1".repeat(40);
    const fetcher = vi
      .fn()
      .mockResolvedValue(Response.json({ sha: authorityCommit }));

    const pinned = await pinEventAuthority(env, event("scheduled"), fetcher);

    expect(pinned.event.authorityCommit).toBe(authorityCommit);
    expect(pinned.newlyPinned).toBe(true);
    expect(fetcher).toHaveBeenCalledWith(
      "https://api.github.com/repos/agentdevan/ambitions/commits/main",
      {
        headers: {
          Accept: "application/vnd.github+json",
          Authorization: "Bearer github-api-token",
          "User-Agent": "ambitions-linear-control",
          "X-GitHub-Api-Version": "2022-11-28",
        },
      },
    );
  });

  it("orders non-GitHub authority by persisted pin time", async () => {
    const { env, statement } = environment();
    const verified = "2".repeat(40);
    const queued = "3".repeat(40);
    const fetcher = vi.fn();

    statement.first.mockResolvedValueOnce({
      authority_commit: verified,
      authority_pinned_at: "2026-08-09T00:00:00.000Z",
    });
    await expect(
      authorityIsCurrent(
        env,
        event("linear", queued, "2026-08-09T00:01:00.000Z"),
        fetcher,
      ),
    ).resolves.toBe(true);

    statement.first.mockResolvedValueOnce({
      authority_commit: verified,
      authority_pinned_at: "2026-08-09T00:02:00.000Z",
    });
    await expect(
      authorityIsCurrent(
        env,
        event("linear", queued, "2026-08-09T00:01:00.000Z"),
        fetcher,
      ),
    ).resolves.toBe(false);
    expect(fetcher).not.toHaveBeenCalled();
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

  it("loads the manifest and source bytes from exact consumer URLs", async () => {
    const { env } = environment();
    const repositoryRef = "4".repeat(40);
    const authorityCommit = "5".repeat(40);
    const manifest = {
      schemaVersion: 1,
      authorityCommit,
      contractHash: "6".repeat(64),
      projects: [],
      schedule: [],
    };
    const fetcher = vi
      .fn()
      .mockResolvedValueOnce(Response.json(manifest))
      .mockResolvedValueOnce(new Response("canonical source"));

    await expect(
      loadManifestForEvent(env, event("github", repositoryRef), fetcher),
    ).resolves.toEqual(manifest);
    await expect(
      fetchRepositoryText(
        env,
        authorityCommit,
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
        authorityCommit,
        "docs/product-development/example/research.md",
      ),
    );
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
    await expect(pinEventAuthority(env, replay, vi.fn())).resolves.toEqual({
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

      expect(
        database
          .prepare(
            "SELECT authority_pinned_at FROM deliveries WHERE id = 'legacy'",
          )
          .get(),
      ).toEqual({ authority_pinned_at: "2026-08-09T00:04:00.000Z" });
    } finally {
      database.close();
    }
  });
});

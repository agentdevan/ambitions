import { describe, expect, it, vi } from "vitest";

const auditMock = vi.hoisted(() => vi.fn());

vi.mock("../src/core/live-audit.js", async (importOriginal) => {
  const actual =
    await importOriginal<typeof import("../src/core/live-audit.js")>();
  return { ...actual, auditLiveWorkspace: auditMock };
});

import worker, {
  EVENT_REPAIR_BUDGET,
  EXTERNAL_REQUEST_ATTEMPT_LIMIT,
} from "../src/worker.js";
import { RepairBudgetExhausted } from "../src/core/live-audit.js";
import { sha256Text, stableJson } from "../src/core/hash.js";
import type { EventEnvelope } from "../src/core/types.js";
import type { LinearClient } from "../src/adapters/linear.js";

describe("bounded event continuation", () => {
  it("uses recovered continuation headroom without weakening the hard request ceiling", () => {
    expect(EVENT_REPAIR_BUDGET).toBe(8);
    expect(EVENT_REPAIR_BUDGET).toBeLessThan(EXTERNAL_REQUEST_ATTEMPT_LIMIT);
    expect(EXTERNAL_REQUEST_ATTEMPT_LIMIT).toBeLessThan(50);
  });

  it("requeues the exact pinned envelope and acknowledges normal continuation", async () => {
    const authorityCommit = "a".repeat(40);
    const semantic = {
      schemaVersion: 1 as const,
      authorityCommit,
      projects: [],
      schedule: [],
    };
    const manifest = {
      ...semantic,
      contractHash: await sha256Text(stableJson(semantic)),
    };
    const fetchMock = vi.fn<typeof fetch>((input) => {
      const url =
        input instanceof Request
          ? input.url
          : input instanceof URL
            ? input.href
            : input;
      if (url.endsWith("/commits/main"))
        return Promise.resolve(Response.json({ sha: authorityCommit }));
      if (url.includes("raw.githubusercontent.com"))
        return Promise.resolve(Response.json(manifest));
      if (url.includes("/git/trees/"))
        return Promise.resolve(Response.json({ truncated: false, tree: [] }));
      return Promise.reject(new Error(`UNEXPECTED_FETCH:${url}`));
    });
    const originalFetch = globalThis.fetch;
    globalThis.fetch = fetchMock;
    auditMock.mockRejectedValueOnce(new RepairBudgetExhausted(3));

    const statement = {
      bind: vi.fn().mockReturnThis(),
      run: vi.fn().mockResolvedValue({ meta: { changes: 1 } }),
      first: vi.fn().mockResolvedValue({ count: 0 }),
      all: vi.fn().mockResolvedValue({ results: [] }),
    };
    const queueSend = vi.fn().mockResolvedValue(undefined);
    const env = {
      GITHUB_API_TOKEN: "github-token",
      GITHUB_REPOSITORY: "agentdevan/ambitions",
      LINEAR_API_TOKEN: "linear-token",
      LINEAR_API_URL: "https://api.linear.app/graphql",
      MANIFEST_PATH: "tools/linear-control/generated/desired-workspace.json",
      MUTATIONS_ENABLED: true,
      CONTROL_DB: {
        prepare: vi.fn().mockReturnValue(statement),
        batch: vi.fn().mockResolvedValue([]),
      },
      CONTROL_QUEUE: { send: queueSend },
    } as unknown as Env;
    const event: EventEnvelope = {
      schemaVersion: 1,
      deliveryId: "delivery-continuation",
      source: "github",
      receivedAt: "2026-08-09T00:00:00.000Z",
      authorityCommit,
      authorityPinnedAt: "2026-08-09T00:00:00.000Z",
      payload: {
        schemaVersion: 1,
        kind: "code-quality",
        authorityCommit,
        conclusion: "success",
        repository: "agentdevan/ambitions",
        workflowEvent: "push",
        headBranch: "main",
      },
    };
    const message = {
      body: event,
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
    expect(queueSend).toHaveBeenCalledWith(event, {
      contentType: "json",
      delaySeconds: 5,
    });
    expect(fetchMock).toHaveBeenCalledTimes(3);
  });

  it("continues the exact envelope before a 45th external attempt across preflight and Linear", async () => {
    const authorityCommit = "b".repeat(40);
    const semantic = {
      schemaVersion: 1 as const,
      authorityCommit,
      projects: [],
      schedule: [],
    };
    const manifest = {
      ...semantic,
      contractHash: await sha256Text(stableJson(semantic)),
    };
    const fetchMock = vi.fn<typeof fetch>((input) => {
      const url =
        input instanceof Request
          ? input.url
          : input instanceof URL
            ? input.href
            : input;
      if (url.endsWith("/commits/main"))
        return Promise.resolve(Response.json({ sha: authorityCommit }));
      if (url.includes("raw.githubusercontent.com"))
        return Promise.resolve(Response.json(manifest));
      if (url.includes("/git/trees/"))
        return Promise.resolve(Response.json({ truncated: false, tree: [] }));
      if (url === "https://api.linear.app/graphql")
        return Promise.resolve(
          Response.json({ data: { viewer: { id: "1" } } }),
        );
      return Promise.reject(new Error(`UNEXPECTED_FETCH:${url}`));
    });
    const originalFetch = globalThis.fetch;
    globalThis.fetch = fetchMock;
    auditMock.mockImplementationOnce(async (client: LinearClient) => {
      for (let index = 0; index < 42; index += 1)
        await client.request("query { viewer { id } }");
      throw new Error("SHOULD_HAVE_CONTINUED_BEFORE_THIS_POINT");
    });
    const statement = {
      bind: vi.fn().mockReturnThis(),
      run: vi.fn().mockResolvedValue({ meta: { changes: 1 } }),
      first: vi.fn().mockResolvedValue({ count: 0 }),
      all: vi.fn().mockResolvedValue({ results: [] }),
    };
    const queueSend = vi.fn().mockResolvedValue(undefined);
    const env = {
      GITHUB_API_TOKEN: "github-token",
      GITHUB_REPOSITORY: "agentdevan/ambitions",
      LINEAR_API_TOKEN: "linear-token",
      LINEAR_API_URL: "https://api.linear.app/graphql",
      MANIFEST_PATH: "tools/linear-control/generated/desired-workspace.json",
      MUTATIONS_ENABLED: true,
      CONTROL_DB: {
        prepare: vi.fn().mockReturnValue(statement),
        batch: vi.fn().mockResolvedValue([]),
      },
      CONTROL_QUEUE: { send: queueSend },
    } as unknown as Env;
    const event: EventEnvelope = {
      schemaVersion: 1,
      deliveryId: "delivery-external-budget",
      source: "github",
      receivedAt: "2026-08-09T00:00:00.000Z",
      authorityCommit,
      authorityPinnedAt: "2026-08-09T00:00:00.000Z",
      payload: {
        schemaVersion: 1,
        kind: "code-quality",
        authorityCommit,
        conclusion: "success",
        repository: "agentdevan/ambitions",
        workflowEvent: "push",
        headBranch: "main",
      },
    };
    const message = {
      body: event,
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

    expect(fetchMock).toHaveBeenCalledTimes(44);
    expect(message.ack).toHaveBeenCalledOnce();
    expect(message.retry).not.toHaveBeenCalled();
    expect(queueSend).toHaveBeenCalledWith(event, {
      contentType: "json",
      delaySeconds: 5,
    });
  });
});

import { describe, expect, it, vi } from "vitest";
import { GitHubEvidenceClient } from "../src/adapters/github.js";
import {
  ExternalRequestBudget,
  ExternalRequestBudgetExhausted,
  fetchWithRetry,
  type RetryPolicy,
} from "../src/adapters/http.js";
import { LinearClient } from "../src/adapters/linear.js";

const testPolicy: RetryPolicy = {
  attempts: 2,
  requestTimeoutMs: 50,
  totalBudgetMs: 5_000,
  baseDelayMs: 1,
  maxServerDelayMs: 3_000,
};

describe("provider adapters", () => {
  it("counts every actual retry attempt against one shared external budget", async () => {
    const budget = new ExternalRequestBudget(2);
    const fetcher = vi
      .fn<typeof fetch>()
      .mockResolvedValue(new Response(null, { status: 500 }));

    await expect(
      fetchWithRetry(
        fetcher,
        "https://example.test/retrying",
        {},
        "TEST",
        { ...testPolicy, attempts: 5 },
        { beforeAttempt: () => budget.beforeAttempt() },
      ),
    ).rejects.toBeInstanceOf(ExternalRequestBudgetExhausted);
    expect(fetcher).toHaveBeenCalledTimes(2);
    expect(budget.attempts).toBe(2);
  });

  it("shares one hard cap across GitHub and Linear clients without a 45th fetch", async () => {
    const budget = new ExternalRequestBudget(44);
    const fetcher = vi.fn<typeof fetch>((input) =>
      Promise.resolve(
        Response.json(
          (input instanceof Request
            ? input.url
            : input instanceof URL
              ? input.href
              : input
          ).endsWith("/graphql")
            ? { data: { viewer: { id: "1" } } }
            : { commit: { sha: "abc", commit: {} } },
        ),
      ),
    );
    const runtime = { beforeAttempt: () => budget.beforeAttempt() };
    const github = new GitHubEvidenceClient(
      "token",
      "https://example.test",
      fetcher,
      testPolicy,
      runtime,
    );
    const linear = new LinearClient(
      "token",
      "https://example.test/graphql",
      fetcher,
      testPolicy,
      runtime,
    );

    for (let index = 0; index < 22; index += 1) {
      await github.branchHead("agentdevan/ambitions");
      await linear.request("query { viewer { id } }");
    }
    await expect(
      github.branchHead("agentdevan/ambitions"),
    ).rejects.toBeInstanceOf(ExternalRequestBudgetExhausted);
    expect(fetcher).toHaveBeenCalledTimes(44);
    expect(budget.attempts).toBe(44);
  });

  it("normalizes GitHub branch and pull-request evidence", async () => {
    const fetcher = vi
      .fn<typeof fetch>()
      .mockResolvedValueOnce(
        Response.json({
          commit: {
            sha: "abc123",
            commit: { verification: { verified: true } },
          },
        }),
      )
      .mockResolvedValueOnce(
        Response.json({
          number: 42,
          title: "AMB-2094: Repair exact proof authority",
          state: "closed",
          merged: true,
          merge_commit_sha: "def456",
          head: { ref: "codex/amb-2094-proof-gates", sha: "head456" },
        }),
      )
      .mockResolvedValueOnce(
        Response.json({
          status: "ahead",
        }),
      )
      .mockResolvedValueOnce(
        Response.json({
          truncated: false,
          tree: [
            {
              path: "docs/product-development/example/research.md",
              type: "blob",
              sha: "1".repeat(40),
              size: 123,
            },
            { path: "docs/product-development/example", type: "tree" },
          ],
        }),
      );
    const client = new GitHubEvidenceClient(
      "token",
      "https://example.test",
      fetcher,
    );

    await expect(client.branchHead("agentdevan/ambitions")).resolves.toEqual({
      sha: "abc123",
      verified: true,
    });
    await expect(
      client.pullRequest("agentdevan/ambitions", 42),
    ).resolves.toEqual({
      number: 42,
      title: "AMB-2094: Repair exact proof authority",
      state: "closed",
      merged: true,
      mergeCommitSha: "def456",
      headBranch: "codex/amb-2094-proof-gates",
      headSha: "head456",
    });
    await expect(
      client.commitIncludes("agentdevan/ambitions", "def456", "current-main"),
    ).resolves.toBe(true);
    await expect(
      client.repositoryTree("agentdevan/ambitions", "current-main"),
    ).resolves.toEqual({
      blobs: [
        {
          path: "docs/product-development/example/research.md",
          oid: "1".repeat(40),
          byteLength: 123,
        },
      ],
    });
    expect(fetcher).toHaveBeenCalledTimes(4);
  });

  it("retrieves one completed successful Code Quality check for the exact PR head", async () => {
    const headSha = "a".repeat(40);
    const fetcher = vi.fn<typeof fetch>().mockResolvedValue(
      Response.json({
        total_count: 1,
        check_runs: [
          {
            id: 42,
            name: "Code Quality",
            head_sha: headSha,
            status: "completed",
            conclusion: "success",
            app: { id: 15368, slug: "github-actions" },
            html_url: "https://github.com/agentdevan/ambitions/actions/runs/42",
          },
        ],
      }),
    );
    const client = new GitHubEvidenceClient(
      "token",
      "https://example.test",
      fetcher,
    );

    await expect(
      client.exactHeadCodeQuality("agentdevan/ambitions", headSha),
    ).resolves.toEqual({
      id: 42,
      name: "Code Quality",
      headSha,
      status: "completed",
      conclusion: "success",
      appId: 15368,
      appSlug: "github-actions",
      url: "https://github.com/agentdevan/ambitions/actions/runs/42",
    });
    expect(fetcher).toHaveBeenCalledWith(
      expect.stringContaining(`/commits/${headSha}/check-runs`),
      expect.anything(),
    );
  });

  it("rejects a third-party check named Code Quality", async () => {
    const headSha = "a".repeat(40);
    const fetcher = vi.fn<typeof fetch>().mockResolvedValue(
      Response.json({
        total_count: 1,
        check_runs: [
          {
            id: 42,
            name: "Code Quality",
            head_sha: headSha,
            status: "completed",
            conclusion: "success",
            app: { id: 999, slug: "third-party-ci" },
          },
        ],
      }),
    );
    const client = new GitHubEvidenceClient(
      "token",
      "https://example.test",
      fetcher,
    );

    await expect(
      client.exactHeadCodeQuality("agentdevan/ambitions", headSha),
    ).resolves.toBeNull();
  });

  it.each([
    ["absent", { total_count: 0, check_runs: [] }],
    [
      "duplicate",
      {
        total_count: 2,
        check_runs: [
          {
            id: 1,
            name: "Code Quality",
            head_sha: "a".repeat(40),
            status: "completed",
            conclusion: "success",
          },
          {
            id: 2,
            name: "Code Quality",
            head_sha: "a".repeat(40),
            status: "completed",
            conclusion: "success",
          },
        ],
      },
    ],
    [
      "wrong head",
      {
        total_count: 1,
        check_runs: [
          {
            id: 1,
            name: "Code Quality",
            head_sha: "b".repeat(40),
            status: "completed",
            conclusion: "success",
          },
        ],
      },
    ],
    ["incomplete page", { total_count: 2, check_runs: [] }],
  ])("fails exact-head check evidence closed when %s", async (_name, body) => {
    const fetcher = vi
      .fn<typeof fetch>()
      .mockResolvedValue(Response.json(body));
    const client = new GitHubEvidenceClient(
      "token",
      "https://example.test",
      fetcher,
    );

    await expect(
      client.exactHeadCodeQuality("agentdevan/ambitions", "a".repeat(40)),
    ).resolves.toBeNull();
  });

  it.each([
    {
      name: "malformed oid",
      entry: { path: "docs/a.md", type: "blob", sha: "bad", size: 1 },
    },
    {
      name: "malformed size",
      entry: {
        path: "docs/a.md",
        type: "blob",
        sha: "1".repeat(40),
        size: -1,
      },
    },
  ])("fails closed on a GitHub tree blob with $name", async ({ entry }) => {
    const fetcher = vi.fn<typeof fetch>().mockResolvedValue(
      Response.json({
        truncated: false,
        tree: [entry],
      }),
    );
    const client = new GitHubEvidenceClient(
      "token",
      "https://example.test",
      fetcher,
    );

    await expect(
      client.repositoryTree("agentdevan/ambitions", "current-main"),
    ).rejects.toThrow("GITHUB_TREE_BLOB_INVALID:docs/a.md");
    expect(fetcher).toHaveBeenCalledOnce();
  });

  it("retries a transient Linear response without exposing the token", async () => {
    const fetcher = vi
      .fn<typeof fetch>()
      .mockResolvedValueOnce(new Response(null, { status: 500 }))
      .mockResolvedValueOnce(Response.json({ data: { viewer: { id: "1" } } }));
    const client = new LinearClient(
      "secret",
      "https://example.test",
      fetcher,
      testPolicy,
      { sleep: async () => Promise.resolve() },
    );
    await expect(
      client.request<{ viewer: { id: string } }>("query { viewer { id } }"),
    ).resolves.toEqual({ viewer: { id: "1" } });
    expect(fetcher).toHaveBeenCalledTimes(2);
  });

  it("reports bounded Linear HTTP error detail without exposing the token", async () => {
    const fetcher = vi.fn<typeof fetch>().mockResolvedValue(
      new Response(
        JSON.stringify({
          errors: [{ message: "Unknown field summary for token secret" }],
        }),
        { status: 400 },
      ),
    );
    const client = new LinearClient("secret", "https://example.test", fetcher);
    await expect(client.request("query { invalid }")).rejects.toThrow(
      'LINEAR_HTTP_400:{"errors":[{"message":"Unknown field summary for token [REDACTED]"}]}',
    );
    await expect(client.request("query { invalid }")).rejects.not.toThrow(
      "secret",
    );
  });

  it("respects Retry-After without sleeping past the bounded budget", async () => {
    const sleep = vi.fn().mockResolvedValue(undefined);
    const fetcher = vi
      .fn<typeof fetch>()
      .mockResolvedValueOnce(
        new Response(null, { status: 429, headers: { "Retry-After": "2" } }),
      )
      .mockResolvedValueOnce(Response.json({ data: { viewer: { id: "1" } } }));
    const client = new LinearClient(
      "secret",
      "https://example.test",
      fetcher,
      testPolicy,
      { sleep },
    );

    await expect(client.request("query { viewer { id } }")).resolves.toEqual({
      viewer: { id: "1" },
    });
    expect(sleep).toHaveBeenCalledWith(2_000);
  });

  it("respects GitHub rate reset on a bounded 403 retry", async () => {
    const sleep = vi.fn().mockResolvedValue(undefined);
    const fetcher = vi
      .fn<typeof fetch>()
      .mockResolvedValueOnce(
        new Response(null, {
          status: 403,
          headers: {
            "x-ratelimit-remaining": "0",
            "x-ratelimit-reset": "101",
          },
        }),
      )
      .mockResolvedValueOnce(
        Response.json({ commit: { sha: "abc", commit: {} } }),
      );
    const client = new GitHubEvidenceClient(
      "token",
      "https://example.test",
      fetcher,
      testPolicy,
      { now: () => 100_000, sleep },
    );

    await expect(client.branchHead("agentdevan/ambitions")).resolves.toEqual({
      sha: "abc",
      verified: false,
    });
    expect(sleep).toHaveBeenCalledWith(1_000);
  });

  it("does not double-count retry sleep when the clock advances", async () => {
    let clock = 0;
    const fetcher = vi
      .fn<typeof fetch>()
      .mockResolvedValueOnce(
        new Response(null, { status: 429, headers: { "Retry-After": "2" } }),
      )
      .mockResolvedValueOnce(Response.json({ data: { viewer: { id: "1" } } }));
    const client = new LinearClient(
      "secret",
      "https://example.test",
      fetcher,
      { ...testPolicy, totalBudgetMs: 3_000 },
      {
        now: () => clock,
        sleep: async (milliseconds) => {
          await Promise.resolve();
          clock += milliseconds;
        },
      },
    );

    await expect(client.request("query { viewer { id } }")).resolves.toEqual({
      viewer: { id: "1" },
    });
    expect(fetcher).toHaveBeenCalledTimes(2);
  });

  it("aborts when a response body stalls beyond the request timeout", async () => {
    const fetcher = vi.fn<typeof fetch>(async (_input, init) => {
      await Promise.resolve();
      const body = new ReadableStream<Uint8Array>({
        start(controller) {
          const timer = setTimeout(() => {
            controller.enqueue(
              new TextEncoder().encode(
                JSON.stringify({ commit: { sha: "late", commit: {} } }),
              ),
            );
            controller.close();
          }, 20);
          init?.signal?.addEventListener("abort", () => {
            clearTimeout(timer);
            controller.error(new DOMException("aborted", "AbortError"));
          });
        },
      });
      return new Response(body, {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    });
    const client = new GitHubEvidenceClient(
      "token",
      "https://example.test",
      fetcher,
      { ...testPolicy, attempts: 1, requestTimeoutMs: 1 },
    );

    await expect(client.branchHead("agentdevan/ambitions")).rejects.toThrow(
      "GITHUB_TIMEOUT",
    );
  });

  it("fails closed when a GitHub request exceeds its per-attempt timeout", async () => {
    const fetcher = vi.fn<typeof fetch>(
      (_input, init) =>
        new Promise<Response>((_resolve, reject) => {
          init?.signal?.addEventListener("abort", () =>
            reject(new DOMException("aborted", "AbortError")),
          );
        }),
    );
    const client = new GitHubEvidenceClient(
      "token",
      "https://example.test",
      fetcher,
      { ...testPolicy, attempts: 1, requestTimeoutMs: 1 },
      { sleep: async () => Promise.resolve() },
    );

    await expect(client.branchHead("agentdevan/ambitions")).rejects.toThrow(
      "GITHUB_TIMEOUT",
    );
  });
});

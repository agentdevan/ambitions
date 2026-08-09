import { describe, expect, it, vi } from "vitest";
import { GitHubEvidenceClient } from "../src/adapters/github.js";
import { LinearClient } from "../src/adapters/linear.js";

describe("provider adapters", () => {
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
          state: "closed",
          merged: true,
          merge_commit_sha: "def456",
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
      state: "closed",
      merged: true,
      mergeCommitSha: "def456",
    });
    expect(fetcher).toHaveBeenCalledTimes(2);
  });

  it("retries a transient Linear response without exposing the token", async () => {
    const originalFetch = globalThis.fetch;
    const fetcher = vi
      .fn<typeof fetch>()
      .mockResolvedValueOnce(new Response(null, { status: 500 }))
      .mockResolvedValueOnce(Response.json({ data: { viewer: { id: "1" } } }));
    globalThis.fetch = fetcher;
    try {
      const client = new LinearClient("secret", "https://example.test");
      await expect(
        client.request<{ viewer: { id: string } }>("query { viewer { id } }"),
      ).resolves.toEqual({ viewer: { id: "1" } });
      expect(fetcher).toHaveBeenCalledTimes(2);
    } finally {
      globalThis.fetch = originalFetch;
    }
  });

  it("reports bounded Linear HTTP error detail without exposing the token", async () => {
    const originalFetch = globalThis.fetch;
    const fetcher = vi.fn<typeof fetch>().mockResolvedValue(
      new Response(
        JSON.stringify({
          errors: [{ message: "Unknown field summary for token secret" }],
        }),
        { status: 400 },
      ),
    );
    globalThis.fetch = fetcher;
    try {
      const client = new LinearClient("secret", "https://example.test");
      await expect(client.request("query { invalid }")).rejects.toThrow(
        'LINEAR_HTTP_400:{"errors":[{"message":"Unknown field summary for token [REDACTED]"}]}',
      );
      await expect(client.request("query { invalid }")).rejects.not.toThrow(
        "secret",
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  });
});

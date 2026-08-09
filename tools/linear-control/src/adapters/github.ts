import {
  DEFAULT_RETRY_POLICY,
  fetchWithRetry,
  type RetryPolicy,
  type RetryRuntime,
} from "./http.js";

const DEFAULT_URL = "https://api.github.com";

export interface GitHubCommitEvidence {
  sha: string;
  verified: boolean;
}

export interface GitHubPullRequestEvidence {
  number: number;
  title: string;
  state: string;
  merged: boolean;
  headBranch: string;
  headSha: string;
  mergeCommitSha?: string;
}

export interface GitHubCheckRunEvidence {
  id: number;
  name: string;
  headSha: string;
  status: string;
  conclusion?: string;
  appId: number;
  appSlug: string;
  url?: string;
}

interface GitHubCompareEvidence {
  status: "ahead" | "behind" | "diverged" | "identical";
}

export interface GitHubTreeEvidence {
  blobs: readonly {
    path: string;
    oid: string;
    byteLength: number;
  }[];
}

type Fetcher = typeof fetch;

export class GitHubEvidenceClient {
  constructor(
    private readonly token: string,
    private readonly endpoint = DEFAULT_URL,
    private readonly fetcher: Fetcher = fetch,
    private readonly retryPolicy: RetryPolicy = DEFAULT_RETRY_POLICY,
    private readonly retryRuntime: RetryRuntime = {},
  ) {}

  private async request<T>(path: string): Promise<T> {
    const response = await fetchWithRetry(
      this.fetcher,
      `${this.endpoint}${path}`,
      {
        headers: {
          Accept: "application/vnd.github+json",
          Authorization: `Bearer ${this.token}`,
          "User-Agent": "ambitions-linear-control",
          "X-GitHub-Api-Version": "2022-11-28",
        },
      },
      "GITHUB",
      this.retryPolicy,
      this.retryRuntime,
    );
    if (!response.ok) throw new Error(`GITHUB_HTTP_${response.status}`);
    return response.json();
  }

  async branchHead(
    repository: string,
    branch = "main",
  ): Promise<GitHubCommitEvidence> {
    const data = await this.request<{
      commit: {
        sha: string;
        commit: { verification?: { verified?: boolean } };
      };
    }>(
      `/repos/${encodeURIComponent(repository).replace("%2F", "/")}/branches/${encodeURIComponent(branch)}`,
    );
    return {
      sha: data.commit.sha,
      verified: data.commit.commit.verification?.verified === true,
    };
  }

  async pullRequest(
    repository: string,
    number: number,
  ): Promise<GitHubPullRequestEvidence> {
    const data = await this.request<{
      number: number;
      title: string;
      state: string;
      merged: boolean;
      merge_commit_sha: string | null;
      head: { ref: string; sha: string };
    }>(
      `/repos/${encodeURIComponent(repository).replace("%2F", "/")}/pulls/${number}`,
    );
    return {
      number: data.number,
      title: data.title,
      state: data.state,
      merged: data.merged,
      headBranch: data.head.ref,
      headSha: data.head.sha,
      ...(data.merge_commit_sha
        ? { mergeCommitSha: data.merge_commit_sha }
        : {}),
    };
  }

  async exactHeadCodeQuality(
    repository: string,
    headSha: string,
  ): Promise<GitHubCheckRunEvidence | null> {
    if (!/^[0-9a-f]{40}$/.test(headSha))
      throw new Error("GITHUB_CHECK_HEAD_INVALID");
    const checkRuns: Array<{
      id: number;
      name: string;
      head_sha: string;
      status: string;
      conclusion: string | null;
      app?: { id: number; slug: string } | null;
      html_url?: string | null;
    }> = [];
    let expectedTotal: number | undefined;
    for (let page = 1; page <= 100; page += 1) {
      const data = await this.request<{
        total_count: number;
        check_runs: Array<{
          id: number;
          name: string;
          head_sha: string;
          status: string;
          conclusion: string | null;
          app?: { id: number; slug: string } | null;
          html_url?: string | null;
        }>;
      }>(
        `/repos/${encodeURIComponent(repository).replace("%2F", "/")}/commits/${encodeURIComponent(headSha)}/check-runs?check_name=${encodeURIComponent("Code Quality")}&filter=all&per_page=100&page=${page}`,
      );
      if (
        !Number.isSafeInteger(data.total_count) ||
        data.total_count < 0 ||
        !Array.isArray(data.check_runs) ||
        (expectedTotal !== undefined && expectedTotal !== data.total_count)
      )
        return null;
      expectedTotal ??= data.total_count;
      checkRuns.push(...data.check_runs);
      if (checkRuns.length >= expectedTotal) break;
      if (data.check_runs.length === 0) return null;
    }
    if (expectedTotal === undefined || checkRuns.length !== expectedTotal)
      return null;
    const exact = checkRuns.filter(
      (run) => run.name === "Code Quality" && run.head_sha === headSha,
    );
    if (exact.length !== 1 || checkRuns.length !== 1) return null;
    const run = exact[0]!;
    if (
      !Number.isSafeInteger(run.id) ||
      run.id < 1 ||
      !Number.isSafeInteger(run.app?.id) ||
      (run.app?.id ?? 0) < 1 ||
      run.app?.slug !== "github-actions"
    )
      return null;
    return {
      id: run.id,
      name: run.name,
      headSha: run.head_sha,
      status: run.status,
      ...(run.conclusion ? { conclusion: run.conclusion } : {}),
      appId: run.app.id,
      appSlug: "github-actions",
      ...(run.html_url ? { url: run.html_url } : {}),
    };
  }

  async commitIncludes(
    repository: string,
    ancestorCommit: string,
    authorityCommit: string,
  ): Promise<boolean> {
    if (ancestorCommit === authorityCommit) return true;
    const data = await this.request<GitHubCompareEvidence>(
      `/repos/${encodeURIComponent(repository).replace("%2F", "/")}/compare/${encodeURIComponent(ancestorCommit)}...${encodeURIComponent(authorityCommit)}`,
    );
    return data.status === "ahead" || data.status === "identical";
  }

  async repositoryTree(
    repository: string,
    authorityCommit: string,
  ): Promise<GitHubTreeEvidence> {
    const data = await this.request<{
      truncated: boolean;
      tree: Array<{
        path: string;
        type: string;
        sha?: string;
        size?: number;
      }>;
    }>(
      `/repos/${encodeURIComponent(repository).replace("%2F", "/")}/git/trees/${encodeURIComponent(authorityCommit)}?recursive=1`,
    );
    if (data.truncated) throw new Error("GITHUB_TREE_TRUNCATED");
    const blobEntries = data.tree.filter((entry) => entry.type === "blob");
    for (const entry of blobEntries)
      if (
        !/^[0-9a-f]{40}$/.test(entry.sha ?? "") ||
        !Number.isSafeInteger(entry.size) ||
        (entry.size ?? -1) < 0
      )
        throw new Error(`GITHUB_TREE_BLOB_INVALID:${entry.path}`);
    return {
      blobs: blobEntries
        .map((entry) => ({
          path: entry.path,
          oid: entry.sha!,
          byteLength: entry.size!,
        }))
        .sort((left, right) => left.path.localeCompare(right.path)),
    };
  }
}

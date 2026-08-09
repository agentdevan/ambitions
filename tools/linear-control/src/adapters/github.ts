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
  mergeCommitSha?: string;
}

interface GitHubCompareEvidence {
  status: "ahead" | "behind" | "diverged" | "identical";
}

export interface GitHubTreeEvidence {
  paths: readonly string[];
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
      head: { ref: string };
    }>(
      `/repos/${encodeURIComponent(repository).replace("%2F", "/")}/pulls/${number}`,
    );
    return {
      number: data.number,
      title: data.title,
      state: data.state,
      merged: data.merged,
      headBranch: data.head.ref,
      ...(data.merge_commit_sha
        ? { mergeCommitSha: data.merge_commit_sha }
        : {}),
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
      tree: Array<{ path: string; type: string }>;
    }>(
      `/repos/${encodeURIComponent(repository).replace("%2F", "/")}/git/trees/${encodeURIComponent(authorityCommit)}?recursive=1`,
    );
    if (data.truncated) throw new Error("GITHUB_TREE_TRUNCATED");
    return {
      paths: data.tree
        .filter((entry) => entry.type === "blob")
        .map((entry) => entry.path)
        .sort(),
    };
  }
}

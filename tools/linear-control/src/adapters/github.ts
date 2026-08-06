const DEFAULT_URL = "https://api.github.com";

export interface GitHubCommitEvidence {
  sha: string;
  verified: boolean;
}

export interface GitHubPullRequestEvidence {
  number: number;
  state: string;
  merged: boolean;
  mergeCommitSha?: string;
}

type Fetcher = typeof fetch;

export class GitHubEvidenceClient {
  constructor(
    private readonly token: string,
    private readonly endpoint = DEFAULT_URL,
    private readonly fetcher: Fetcher = fetch,
  ) {}

  private async request<T>(path: string): Promise<T> {
    for (let attempt = 0; attempt < 5; attempt += 1) {
      const response = await this.fetcher(`${this.endpoint}${path}`, {
        headers: {
          Accept: "application/vnd.github+json",
          Authorization: `Bearer ${this.token}`,
          "User-Agent": "ambitions-linear-control",
          "X-GitHub-Api-Version": "2022-11-28",
        },
      });
      if (response.status === 429 || response.status >= 500) {
        await new Promise((resolve) => setTimeout(resolve, 250 * 2 ** attempt));
        continue;
      }
      if (!response.ok) throw new Error(`GITHUB_HTTP_${response.status}`);
      return response.json();
    }
    throw new Error("GITHUB_RETRY_EXHAUSTED");
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
      state: string;
      merged: boolean;
      merge_commit_sha: string | null;
    }>(
      `/repos/${encodeURIComponent(repository).replace("%2F", "/")}/pulls/${number}`,
    );
    return {
      number: data.number,
      state: data.state,
      merged: data.merged,
      ...(data.merge_commit_sha
        ? { mergeCommitSha: data.merge_commit_sha }
        : {}),
    };
  }
}

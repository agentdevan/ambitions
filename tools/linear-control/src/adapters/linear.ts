import {
  DEFAULT_RETRY_POLICY,
  fetchWithRetry,
  type RetryPolicy,
  type RetryRuntime,
} from "./http.js";

const DEFAULT_URL = "https://api.linear.app/graphql";

export class LinearClient {
  constructor(
    private readonly token: string,
    private readonly endpoint = DEFAULT_URL,
    private readonly fetcher: typeof fetch = fetch,
    private readonly retryPolicy: RetryPolicy = DEFAULT_RETRY_POLICY,
    private readonly retryRuntime: RetryRuntime = {},
  ) {}

  async request<T>(
    query: string,
    variables: Readonly<Record<string, unknown>> = {},
  ): Promise<T> {
    const response = await fetchWithRetry(
      this.fetcher,
      this.endpoint,
      {
        method: "POST",
        headers: {
          Authorization: this.token,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ query, variables }),
      },
      "LINEAR",
      this.retryPolicy,
      this.retryRuntime,
    );
    if (!response.ok) {
      const detail = (await response.text())
        .replaceAll(this.token, "[REDACTED]")
        .replace(/\s+/g, " ")
        .slice(0, 1000);
      throw new Error(
        `LINEAR_HTTP_${response.status}${detail ? `:${detail}` : ""}`,
      );
    }
    const result: {
      data?: T;
      errors?: Array<{ message: string }>;
    } = await response.json();
    if (result.errors?.length)
      throw new Error(
        `LINEAR_GRAPHQL:${result.errors.map((error) => error.message).join(" | ")}`,
      );
    if (!result.data) throw new Error("LINEAR_EMPTY_DATA");
    return result.data;
  }
}

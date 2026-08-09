const DEFAULT_URL = "https://api.linear.app/graphql";

export class LinearClient {
  constructor(
    private readonly token: string,
    private readonly endpoint = DEFAULT_URL,
  ) {}

  async request<T>(
    query: string,
    variables: Readonly<Record<string, unknown>> = {},
  ): Promise<T> {
    for (let attempt = 0; attempt < 5; attempt += 1) {
      const response = await fetch(this.endpoint, {
        method: "POST",
        headers: {
          Authorization: this.token,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ query, variables }),
      });
      if (response.status === 429 || response.status >= 500) {
        await new Promise((resolve) => setTimeout(resolve, 250 * 2 ** attempt));
        continue;
      }
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
    throw new Error("LINEAR_RETRY_EXHAUSTED");
  }
}

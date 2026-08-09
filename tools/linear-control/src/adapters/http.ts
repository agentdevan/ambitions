export interface RetryPolicy {
  attempts: number;
  requestTimeoutMs: number;
  totalBudgetMs: number;
  baseDelayMs: number;
  maxServerDelayMs: number;
}

export interface RetryRuntime {
  now?: () => number;
  sleep?: (milliseconds: number) => Promise<void>;
  beforeAttempt?: () => void | Promise<void>;
}

export class ExternalRequestBudgetExhausted extends Error {
  readonly limit: number;

  constructor(limit: number) {
    super(`EXTERNAL_REQUEST_BUDGET_EXHAUSTED:${limit}`);
    this.name = "ExternalRequestBudgetExhausted";
    this.limit = limit;
  }
}

export class ExternalRequestBudget {
  #attempts = 0;

  constructor(readonly limit: number) {
    if (!Number.isSafeInteger(limit) || limit < 1)
      throw new Error("INVALID_EXTERNAL_REQUEST_BUDGET");
  }

  get attempts(): number {
    return this.#attempts;
  }

  beforeAttempt(): void {
    if (this.#attempts >= this.limit)
      throw new ExternalRequestBudgetExhausted(this.limit);
    this.#attempts += 1;
  }
}

export const DEFAULT_RETRY_POLICY: RetryPolicy = {
  attempts: 5,
  requestTimeoutMs: 5_000,
  totalBudgetMs: 20_000,
  baseDelayMs: 250,
  maxServerDelayMs: 10_000,
};

type Fetcher = typeof fetch;

function serverDelayMs(response: Response, now: number): number | undefined {
  const retryAfter = response.headers.get("retry-after");
  if (retryAfter) {
    const seconds = Number(retryAfter);
    if (Number.isFinite(seconds) && seconds >= 0) return seconds * 1_000;
    const date = Date.parse(retryAfter);
    if (Number.isFinite(date)) return Math.max(0, date - now);
  }
  const reset = Number(response.headers.get("x-ratelimit-reset"));
  if (Number.isFinite(reset) && reset > 0)
    return Math.max(0, reset * 1_000 - now);
  return undefined;
}

function retryable(response: Response): boolean {
  return (
    response.status === 429 ||
    response.status >= 500 ||
    (response.status === 403 &&
      (response.headers.has("retry-after") ||
        response.headers.get("x-ratelimit-remaining") === "0"))
  );
}

export async function fetchWithRetry(
  fetcher: Fetcher,
  input: string,
  init: RequestInit,
  errorPrefix: string,
  policy: RetryPolicy = DEFAULT_RETRY_POLICY,
  runtime: RetryRuntime = {},
): Promise<Response> {
  const now = runtime.now ?? Date.now;
  const sleep =
    runtime.sleep ??
    ((milliseconds: number) =>
      new Promise<void>((resolve) => setTimeout(resolve, milliseconds)));
  const started = now();
  let waited = 0;
  let lastFailure = `${errorPrefix}_RETRY_EXHAUSTED`;

  for (let attempt = 0; attempt < policy.attempts; attempt += 1) {
    const elapsed = Math.max(now() - started, waited);
    const remaining = policy.totalBudgetMs - elapsed;
    if (remaining <= 0)
      throw new Error(`${errorPrefix}_RETRY_BUDGET_EXHAUSTED`);
    // This hook deliberately sits outside the provider catch/relabeling block:
    // exhausting the shared Worker budget is a normal queue continuation, not
    // a GitHub or Linear network failure.
    await runtime.beforeAttempt?.();
    const controller = new AbortController();
    const timeout = setTimeout(
      () => controller.abort(),
      Math.min(policy.requestTimeoutMs, remaining),
    );
    let response: Response;
    try {
      const networkResponse = await fetcher(input, {
        ...init,
        signal: controller.signal,
      });
      const body = await networkResponse.arrayBuffer();
      response = new Response(body.byteLength === 0 ? null : body, {
        status: networkResponse.status,
        statusText: networkResponse.statusText,
        headers: networkResponse.headers,
      });
    } catch {
      const timedOut = controller.signal.aborted;
      lastFailure = timedOut
        ? `${errorPrefix}_TIMEOUT`
        : `${errorPrefix}_NETWORK`;
      if (attempt + 1 >= policy.attempts) throw new Error(lastFailure);
      const delay = policy.baseDelayMs * 2 ** attempt;
      if (delay > policy.maxServerDelayMs || delay >= remaining)
        throw new Error(`${errorPrefix}_RETRY_BUDGET_EXHAUSTED`);
      await sleep(delay);
      waited += delay;
      continue;
    } finally {
      clearTimeout(timeout);
    }

    if (!retryable(response)) return response;
    lastFailure = `${errorPrefix}_HTTP_${response.status}`;
    if (attempt + 1 >= policy.attempts) throw new Error(lastFailure);
    const delay =
      serverDelayMs(response, now()) ?? policy.baseDelayMs * 2 ** attempt;
    const retryRemaining =
      policy.totalBudgetMs - Math.max(now() - started, waited);
    if (delay > policy.maxServerDelayMs || delay >= retryRemaining)
      throw new Error(`${errorPrefix}_RETRY_BUDGET_EXHAUSTED`);
    await sleep(delay);
    waited += delay;
  }
  throw new Error(lastFailure);
}

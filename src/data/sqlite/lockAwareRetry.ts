const SQLITE_LOCK_ERROR_PATTERNS = [
  "database is locked",
  "database locked",
  "database table is locked",
  "calling the 'execasync' function has failed",
];

const DEFAULT_MAX_ATTEMPTS = 3;
const DEFAULT_INITIAL_DELAY_MS = 40;

function delay(durationMs: number) {
  return new Promise<void>((resolve) => {
    setTimeout(resolve, durationMs);
  });
}

export function isDatabaseLockError(error: unknown) {
  if (!(error instanceof Error)) {
    return false;
  }

  const message = error.message.toLowerCase();
  return SQLITE_LOCK_ERROR_PATTERNS.some((pattern) => message.includes(pattern));
}

export async function withLockAwareRetry<T>(
  operation: () => Promise<T>,
  options?: {
    maxAttempts?: number;
    initialDelayMs?: number;
  },
): Promise<T> {
  const maxAttempts = options?.maxAttempts ?? DEFAULT_MAX_ATTEMPTS;
  const initialDelayMs = options?.initialDelayMs ?? DEFAULT_INITIAL_DELAY_MS;
  let lastError: unknown;

  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    try {
      return await operation();
    } catch (error) {
      lastError = error;

      if (!isDatabaseLockError(error) || attempt >= maxAttempts) {
        throw error;
      }

      await delay(initialDelayMs * attempt);
    }
  }

  throw lastError instanceof Error ? lastError : new Error("SQLite operation failed.");
}

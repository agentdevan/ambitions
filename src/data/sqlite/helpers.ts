export function encodeJson(value: unknown): string {
  return JSON.stringify(value);
}

export function decodeJson<T>(value: string): T {
  return JSON.parse(value) as T;
}

export function fromSqliteBoolean(value: number): boolean {
  return value === 1;
}

export function toSqliteBoolean(value: boolean): number {
  return value ? 1 : 0;
}

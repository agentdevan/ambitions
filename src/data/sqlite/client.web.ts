import { getUnsupportedDatabaseMessage } from "../../bootstrap/runtime/runtimeSupport";

export interface DatabaseClient {
  exec(statements: string[]): Promise<void>;
  run(statement: string, params?: readonly unknown[] | Record<string, unknown>): Promise<void>;
  getAll<T>(
    statement: string,
    params?: readonly unknown[] | Record<string, unknown>,
  ): Promise<T[]>;
  getFirst<T>(
    statement: string,
    params?: readonly unknown[] | Record<string, unknown>,
  ): Promise<T | null>;
  withTransaction<T>(operation: (client: DatabaseClient) => Promise<T>): Promise<T>;
}

function unsupported(): never {
  throw new Error(getUnsupportedDatabaseMessage());
}

export const sqliteClient: DatabaseClient = {
  async exec() {
    unsupported();
  },
  async run() {
    unsupported();
  },
  async getAll() {
    unsupported();
  },
  async getFirst() {
    unsupported();
  },
  async withTransaction() {
    unsupported();
  },
};

export async function initializeDatabase() {
  unsupported();
}

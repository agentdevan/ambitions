import * as SQLite from "expo-sqlite";

import { schemaMigrations } from "./migrations";

export interface DatabaseClient {
  exec(statements: string[]): Promise<void>;
  run(statement: string, params?: SQLite.SQLiteBindParams): Promise<void>;
  getAll<T>(statement: string, params?: SQLite.SQLiteBindParams): Promise<T[]>;
  getFirst<T>(statement: string, params?: SQLite.SQLiteBindParams): Promise<T | null>;
  withTransaction<T>(operation: (client: DatabaseClient) => Promise<T>): Promise<T>;
}

let databasePromise: Promise<SQLite.SQLiteDatabase> | null = null;

async function getDatabase() {
  if (!databasePromise) {
    databasePromise = SQLite.openDatabaseAsync("ambitions.db");
  }

  return databasePromise;
}

class SQLiteClient implements DatabaseClient {
  async exec(statements: string[]) {
    const database = await getDatabase();

    for (const statement of statements) {
      await database.execAsync(statement);
    }
  }

  async run(statement: string, params?: SQLite.SQLiteBindParams) {
    const database = await getDatabase();
    if (params === undefined) {
      await database.runAsync(statement);
      return;
    }

    await database.runAsync(statement, params);
  }

  async getAll<T>(statement: string, params?: SQLite.SQLiteBindParams) {
    const database = await getDatabase();
    if (params === undefined) {
      return database.getAllAsync<T>(statement);
    }

    return database.getAllAsync<T>(statement, params);
  }

  async getFirst<T>(statement: string, params?: SQLite.SQLiteBindParams) {
    const database = await getDatabase();
    if (params === undefined) {
      return database.getFirstAsync<T>(statement);
    }

    return database.getFirstAsync<T>(statement, params);
  }

  async withTransaction<T>(operation: (client: DatabaseClient) => Promise<T>) {
    const database = await getDatabase();
    let result: T | undefined;

    await database.withExclusiveTransactionAsync(async (transaction) => {
      const transactionalClient: DatabaseClient = {
        exec: async (statements) => {
          for (const statement of statements) {
            await transaction.execAsync(statement);
          }
        },
        run: async (statement, params) => {
          if (params === undefined) {
            await transaction.runAsync(statement);
            return;
          }

          await transaction.runAsync(statement, params);
        },
        getAll: async (statement, params) =>
          params === undefined
            ? transaction.getAllAsync(statement)
            : transaction.getAllAsync(statement, params),
        getFirst: async (statement, params) =>
          params === undefined
            ? transaction.getFirstAsync(statement)
            : transaction.getFirstAsync(statement, params),
        withTransaction: async (nestedOperation) => nestedOperation(transactionalClient),
      };

      result = await operation(transactionalClient);
    });

    return result as T;
  }
}

export const sqliteClient: DatabaseClient = new SQLiteClient();

export async function initializeDatabase() {
  await sqliteClient.exec([
    "PRAGMA foreign_keys = ON;",
    `
      CREATE TABLE IF NOT EXISTS schema_migrations (
        id INTEGER PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        applied_at TEXT NOT NULL
      );
    `,
    `
      CREATE TABLE IF NOT EXISTS app_metadata (
        key TEXT PRIMARY KEY NOT NULL,
        value TEXT NOT NULL
      );
    `,
  ]);

  const appliedRows = await sqliteClient.getAll<{ id: number }>(
    "SELECT id FROM schema_migrations ORDER BY id ASC;",
  );
  const appliedIds = new Set(appliedRows.map((row) => row.id));

  for (const migration of schemaMigrations) {
    if (appliedIds.has(migration.id)) {
      continue;
    }

    await sqliteClient.withTransaction(async (client) => {
      await client.exec(migration.statements);
      await client.run(
        "INSERT INTO schema_migrations (id, name, applied_at) VALUES (?, ?, ?);",
        [migration.id, migration.name, new Date().toISOString()],
      );
    });
  }
}

import * as SQLite from "expo-sqlite";

import { withLockAwareRetry } from "./lockAwareRetry";
import { SQLiteOperationQueue } from "./operationQueue";
import { schemaMigrations } from "./migrations";

export interface DatabaseClient {
  exec(statements: string[]): Promise<void>;
  run(statement: string, params?: SQLite.SQLiteBindParams): Promise<void>;
  getAll<T>(statement: string, params?: SQLite.SQLiteBindParams): Promise<T[]>;
  getFirst<T>(statement: string, params?: SQLite.SQLiteBindParams): Promise<T | null>;
  withTransaction<T>(operation: (client: DatabaseClient) => Promise<T>): Promise<T>;
}

let databasePromise: Promise<SQLite.SQLiteDatabase> | null = null;
let databaseSetupPromise: Promise<SQLite.SQLiteDatabase> | null = null;
const operationQueue = new SQLiteOperationQueue();

async function getDatabase() {
  if (!databasePromise) {
    databasePromise = SQLite.openDatabaseAsync("ambitions.db").catch((error) => {
      databasePromise = null;
      databaseSetupPromise = null;
      throw error;
    });
  }

  if (!databaseSetupPromise) {
    databaseSetupPromise = databasePromise
      .then(async (database) => {
        await database.execAsync("PRAGMA foreign_keys = ON;");
        await database.execAsync("PRAGMA journal_mode = WAL;");
        await database.execAsync("PRAGMA busy_timeout = 5000;");

        return database;
      })
      .catch((error) => {
        databaseSetupPromise = null;
        throw error;
      });
  }

  return databaseSetupPromise;
}

class SQLiteClient implements DatabaseClient {
  async exec(statements: string[]) {
    await operationQueue.enqueue(() =>
      withLockAwareRetry(async () => {
        const database = await getDatabase();

        for (const statement of statements) {
          await database.execAsync(statement);
        }
      }),
    );
  }

  async run(statement: string, params?: SQLite.SQLiteBindParams) {
    await operationQueue.enqueue(() =>
      withLockAwareRetry(async () => {
        const database = await getDatabase();
        if (params === undefined) {
          await database.runAsync(statement);
          return;
        }

        await database.runAsync(statement, params);
      }),
    );
  }

  async getAll<T>(statement: string, params?: SQLite.SQLiteBindParams) {
    return operationQueue.enqueue(() =>
      withLockAwareRetry(async () => {
        const database = await getDatabase();
        if (params === undefined) {
          return database.getAllAsync<T>(statement);
        }

        return database.getAllAsync<T>(statement, params);
      }),
    );
  }

  async getFirst<T>(statement: string, params?: SQLite.SQLiteBindParams) {
    return operationQueue.enqueue(() =>
      withLockAwareRetry(async () => {
        const database = await getDatabase();
        if (params === undefined) {
          return database.getFirstAsync<T>(statement);
        }

        return database.getFirstAsync<T>(statement, params);
      }),
    );
  }

  async withTransaction<T>(operation: (client: DatabaseClient) => Promise<T>) {
    return operationQueue.enqueue(() =>
      withLockAwareRetry(async () => {
        const database = await getDatabase();
        let result: T | undefined;

        await database.withExclusiveTransactionAsync(async (transaction) => {
          const transactionalClient: DatabaseClient = {
            exec: async (statements) => {
              for (const statement of statements) {
                await transaction.execAsync(statement);
              }
            },
            run: async (statement, nestedParams) => {
              if (nestedParams === undefined) {
                await transaction.runAsync(statement);
                return;
              }

              await transaction.runAsync(statement, nestedParams);
            },
            getAll: async (statement, nestedParams) =>
              nestedParams === undefined
                ? transaction.getAllAsync(statement)
                : transaction.getAllAsync(statement, nestedParams),
            getFirst: async (statement, nestedParams) =>
              nestedParams === undefined
                ? transaction.getFirstAsync(statement)
                : transaction.getFirstAsync(statement, nestedParams),
            withTransaction: async (nestedOperation) => nestedOperation(transactionalClient),
          };

          result = await operation(transactionalClient);
        });

        return result as T;
      }),
    );
  }
}

export const sqliteClient: DatabaseClient = new SQLiteClient();

export async function initializeDatabase() {
  await sqliteClient.exec([
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

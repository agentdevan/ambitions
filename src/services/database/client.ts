import * as SQLite from "expo-sqlite";

import { migrations } from "./migrations";

let databasePromise: Promise<SQLite.SQLiteDatabase> | null = null;

export async function getDatabase() {
  if (!databasePromise) {
    databasePromise = SQLite.openDatabaseAsync("ambitions.db");
  }

  return databasePromise;
}

export async function initializeDatabase() {
  const database = await getDatabase();

  await database.withExclusiveTransactionAsync(async (transaction) => {
    for (const statement of migrations) {
      await transaction.execAsync(statement);
    }
  });
}

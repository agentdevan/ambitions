import { DatabaseClient } from "../data/sqlite/client";

export abstract class SQLiteRepository {
  protected constructor(protected readonly database: DatabaseClient) {}
}

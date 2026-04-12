import { createClient, Session, SupabaseClient, User } from "@supabase/supabase-js";

import { AuthProvider, RemoteSyncRecord } from "../../domain/models";
import { accountSessionStorage } from "./sessionStorage";
import { getSupabaseConfig } from "./supabaseConfig";

interface RemoteSessionSnapshot {
  user: User;
  session: Session;
}

interface AuthInput {
  email: string;
  password: string;
  displayName?: string;
}

interface RemoteSyncRecordRow {
  account_id: string;
  entity_kind: RemoteSyncRecord["entityKind"];
  entity_id: string;
  remote_id: string;
  payload_json: string;
  version: number;
  last_writer_device_id: string;
  created_at: string;
  updated_at: string;
}

function buildStorageKey(url: string) {
  return `sb-${url.replace(/[^a-z0-9]/gi, "_").toLowerCase()}-auth-token`;
}

export class SupabaseAccountClient {
  private client: SupabaseClient | null = null;

  private getClient() {
    if (this.client) {
      return this.client;
    }

    const config = getSupabaseConfig();
    if (!config) {
      return null;
    }

    this.client = createClient(config.url, config.anonKey, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: false,
        storageKey: buildStorageKey(config.url),
        storage: accountSessionStorage,
      },
    });

    return this.client;
  }

  isConfigured() {
    return this.getClient() !== null;
  }

  async restoreSession(): Promise<RemoteSessionSnapshot | null> {
    const client = this.getClient();
    if (!client) {
      return null;
    }

    const {
      data: { session },
      error,
    } = await client.auth.getSession();

    if (error) {
      throw error;
    }

    if (!session?.user) {
      return null;
    }

    return { session, user: session.user };
  }

  async signUp(input: AuthInput): Promise<RemoteSessionSnapshot> {
    const client = this.requireClient();
    const { data, error } = await client.auth.signUp({
      email: input.email,
      password: input.password,
      options: {
        data: {
          display_name: input.displayName?.trim() || null,
        },
      },
    });

    if (error) {
      throw error;
    }

    if (!data.session || !data.user) {
      throw new Error("Check your email to finish creating your account, then sign in.");
    }

    return { session: data.session, user: data.user };
  }

  async signIn(input: AuthInput): Promise<RemoteSessionSnapshot> {
    const client = this.requireClient();
    const { data, error } = await client.auth.signInWithPassword({
      email: input.email,
      password: input.password,
    });

    if (error) {
      throw error;
    }

    if (!data.session || !data.user) {
      throw new Error("The account session could not be restored.");
    }

    return { session: data.session, user: data.user };
  }

  async signOut() {
    const client = this.requireClient();
    const { error } = await client.auth.signOut();
    if (error) {
      throw error;
    }
  }

  async listRemoteRecords(accountId: string) {
    const client = this.requireClient();
    const { data, error } = await client
      .from("sync_records")
      .select(
        "account_id, entity_kind, entity_id, remote_id, payload_json, version, last_writer_device_id, created_at, updated_at",
      )
      .eq("account_id", accountId);

    if (error) {
      throw error;
    }

    return (data ?? []).map(mapRemoteRecordRow);
  }

  async upsertRemoteRecords(records: RemoteSyncRecord[]) {
    if (records.length === 0) {
      return;
    }

    const client = this.requireClient();
    const payload = records.map((record) => ({
      account_id: record.accountId,
      entity_kind: record.entityKind,
      entity_id: record.entityId,
      remote_id: record.remoteId,
      payload_json: record.payload,
      version: record.version,
      last_writer_device_id: record.lastWriterDeviceId,
      created_at: record.createdAt,
      updated_at: record.updatedAt,
    }));
    const { error } = await client
      .from("sync_records")
      .upsert(payload, { onConflict: "account_id,entity_kind,remote_id" });

    if (error) {
      throw error;
    }
  }

  buildAccountIdentity(user: User) {
    const displayName = readUserMetadata(user, "display_name");
    return {
      id: `account:${user.id}`,
      provider: AuthProvider.Email,
      providerSubject: user.id,
      email: user.email ?? null,
      displayName,
      metadata: {
        provider: "supabase",
        emailConfirmed: !!user.email_confirmed_at,
      },
      ownerUserId: `account:${user.id}`,
      remoteId: user.id,
    };
  }

  private requireClient() {
    const client = this.getClient();
    if (!client) {
      throw new Error("Account sync is not configured for this build.");
    }
    return client;
  }
}

function mapRemoteRecordRow(row: RemoteSyncRecordRow): RemoteSyncRecord {
  return {
    accountId: row.account_id,
    entityKind: row.entity_kind,
    entityId: row.entity_id,
    remoteId: row.remote_id,
    payload: row.payload_json,
    version: row.version,
    lastWriterDeviceId: row.last_writer_device_id,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function readUserMetadata(user: User, key: string) {
  const metadata = user.user_metadata as Record<string, unknown> | undefined;
  const value = metadata?.[key];
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : null;
}

import { sha256Text } from "./core/hash.js";
import type { EventEnvelope } from "./core/types.js";
import { timingSafeEqual as nodeTimingSafeEqual } from "node:crypto";
import { LinearClient } from "./adapters/linear.js";
import { auditLiveWorkspace } from "./core/live-audit.js";
import type { DesiredWorkspaceManifest } from "./core/types.js";

const encoder = new TextEncoder();

async function executeD1Batches(
  database: D1Database,
  statements: D1PreparedStatement[],
  batchSize = 50,
): Promise<void> {
  for (let index = 0; index < statements.length; index += batchSize)
    await database.batch(statements.slice(index, index + batchSize));
}

function json(value: unknown, status = 200): Response {
  return Response.json(value, {
    status,
    headers: { "Cache-Control": "no-store" },
  });
}

function timingSafeEqual(left: string, right: string): boolean {
  const leftBytes = encoder.encode(left);
  const rightBytes = encoder.encode(right);
  if (leftBytes.byteLength !== rightBytes.byteLength) return false;
  return nodeTimingSafeEqual(leftBytes, rightBytes);
}

async function hmacHex(secret: string, value: Uint8Array): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const copy = Uint8Array.from(value);
  const signature = await crypto.subtle.sign("HMAC", key, copy.buffer);
  return [...new Uint8Array(signature)]
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

async function signedEnvelope(
  request: Request,
  env: Env,
  source: "linear" | "github" | "manual",
): Promise<EventEnvelope> {
  const length = Number(request.headers.get("content-length") ?? "0");
  const max = Number(env.MAX_EVENT_BYTES);
  if (length > max) throw new Error("PAYLOAD_TOO_LARGE");
  const body = new Uint8Array(await request.arrayBuffer());
  if (body.byteLength > max) throw new Error("PAYLOAD_TOO_LARGE");
  const deliveryId =
    request.headers.get(
      source === "github" ? "x-github-delivery" : "linear-delivery",
    ) ?? request.headers.get("x-delivery-id");
  if (!deliveryId) throw new Error("MISSING_DELIVERY_ID");
  const supplied = request.headers
    .get(
      source === "linear"
        ? "linear-signature"
        : source === "github"
          ? "x-hub-signature-256"
          : "x-control-signature",
    )
    ?.replace(/^sha256=/, "");
  if (!supplied) throw new Error("MISSING_SIGNATURE");
  const secret =
    source === "linear"
      ? env.LINEAR_WEBHOOK_SECRET
      : source === "github"
        ? env.GITHUB_WEBHOOK_SECRET
        : env.CONTROL_ADMIN_SECRET;
  const expected = await hmacHex(secret, body);
  if (!timingSafeEqual(expected, supplied))
    throw new Error("INVALID_SIGNATURE");
  const payload = JSON.parse(new TextDecoder().decode(body)) as unknown;
  if (source === "linear") {
    const timestamp =
      typeof payload === "object" &&
      payload !== null &&
      "webhookTimestamp" in payload
        ? Number(payload.webhookTimestamp)
        : Number(request.headers.get("linear-timestamp"));
    if (
      !Number.isFinite(timestamp) ||
      Math.abs(Date.now() - timestamp) > 60_000
    )
      throw new Error("STALE_SIGNATURE");
  }
  return {
    schemaVersion: 1,
    deliveryId,
    source,
    receivedAt: new Date().toISOString(),
    payload,
  };
}

async function persistDelivery(
  env: Env,
  event: EventEnvelope,
): Promise<boolean> {
  const hash = await sha256Text(JSON.stringify(event.payload));
  const now = new Date().toISOString();
  const result = await env.CONTROL_DB.prepare(
    "INSERT OR IGNORE INTO deliveries (id, source, schema_version, payload_hash, payload_json, status, authority_commit, received_at, updated_at) VALUES (?, ?, ?, ?, ?, 'queued', ?, ?, ?)",
  )
    .bind(
      event.deliveryId,
      event.source,
      event.schemaVersion,
      hash,
      JSON.stringify(event.payload),
      event.authorityCommit ?? null,
      now,
      now,
    )
    .run();
  return result.meta.changes > 0;
}

async function enqueue(
  env: Env,
  event: EventEnvelope,
  acceptedStatus = 202,
): Promise<Response> {
  const inserted = await persistDelivery(env, event);
  if (inserted) await env.CONTROL_QUEUE.send(event, { contentType: "json" });
  return json(
    { accepted: true, duplicate: !inserted, deliveryId: event.deliveryId },
    acceptedStatus,
  );
}

async function processEvent(env: Env, event: EventEnvelope): Promise<void> {
  const existing = await env.CONTROL_DB.prepare(
    "SELECT status FROM deliveries WHERE id = ?",
  )
    .bind(event.deliveryId)
    .first<{ status: string }>();
  if (existing?.status === "verified" || existing?.status === "superseded")
    return;
  const started = new Date().toISOString();
  await env.CONTROL_DB.prepare(
    "UPDATE deliveries SET status = 'processing', attempts = attempts + 1, updated_at = ? WHERE id = ?",
  )
    .bind(started, event.deliveryId)
    .run();
  const runId = crypto.randomUUID();
  const repositoryUrl = `https://raw.githubusercontent.com/${env.GITHUB_REPOSITORY}/main/${env.MANIFEST_PATH}`;
  const manifestResponse = await fetch(repositoryUrl, {
    headers: { "User-Agent": "ambitions-linear-control" },
  });
  if (!manifestResponse.ok)
    throw new Error(`MANIFEST_HTTP_${manifestResponse.status}`);
  const manifest: DesiredWorkspaceManifest = await manifestResponse.json();
  const commit = manifest.authorityCommit;
  const desiredHash = manifest.contractHash;
  await env.CONTROL_DB.prepare(
    "INSERT INTO runs (id, delivery_id, mode, authority_commit, desired_hash, status, started_at) VALUES (?, ?, 'event', ?, ?, 'verifying', ?)",
  )
    .bind(runId, event.deliveryId, commit, desiredHash, started)
    .run();
  const audit = await auditLiveWorkspace(
    new LinearClient(env.LINEAR_API_TOKEN, env.LINEAR_API_URL),
    manifest,
    env.MUTATIONS_ENABLED,
  );
  const completed = new Date().toISOString();
  const receiptStatements = await Promise.all(
    audit.repairReceipts.map(async (receipt) => {
      const id = await sha256Text(
        `${runId}\0${receipt.canonicalKey}\0${receipt.operation}\0${receipt.desiredHash}`,
      );
      return env.CONTROL_DB.prepare(
        "INSERT OR REPLACE INTO mutation_receipts (id, run_id, canonical_key, operation, before_hash, desired_hash, result_hash, status, created_at, verified_at, error) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      ).bind(
        id,
        runId,
        receipt.canonicalKey,
        receipt.operation,
        receipt.beforeHash,
        receipt.desiredHash,
        receipt.resultHash,
        receipt.verified ? "verified" : "failed",
        completed,
        receipt.verified ? completed : null,
        receipt.verified ? null : "POST_WRITE_VERIFICATION_FAILED",
      );
    }),
  );
  await executeD1Batches(env.CONTROL_DB, receiptStatements);
  const mappingStatements = audit.mappings.map((mapping) =>
    env.CONTROL_DB.prepare(
      "INSERT INTO object_mappings (canonical_key, linear_id, object_type, authority_commit, desired_hash, verified_at) VALUES (?, ?, ?, ?, ?, ?) ON CONFLICT(canonical_key) DO UPDATE SET linear_id = excluded.linear_id, object_type = excluded.object_type, authority_commit = excluded.authority_commit, desired_hash = excluded.desired_hash, verified_at = excluded.verified_at",
    ).bind(
      mapping.canonicalKey,
      mapping.linearId,
      mapping.objectType,
      commit,
      mapping.desiredHash,
      completed,
    ),
  );
  await executeD1Batches(env.CONTROL_DB, mappingStatements);
  await env.CONTROL_DB.prepare(
    "UPDATE exceptions SET resolved_at = ? WHERE resolved_at IS NULL",
  )
    .bind(completed)
    .run();
  const exceptionStatements = await Promise.all(
    audit.exceptions.map(async (item) => {
      const id = await sha256Text(
        `${item.canonicalKey ?? "workspace"}\0${item.summary}`,
      );
      return env.CONTROL_DB.prepare(
        "INSERT INTO exceptions (id, canonical_key, category, severity, summary, first_seen_at, last_seen_at, resolved_at) VALUES (?, ?, ?, ?, ?, ?, ?, NULL) ON CONFLICT(id) DO UPDATE SET severity = excluded.severity, summary = excluded.summary, last_seen_at = excluded.last_seen_at, resolved_at = NULL",
      ).bind(
        id,
        item.canonicalKey ?? null,
        item.category,
        item.severity,
        item.summary,
        completed,
        completed,
      );
    }),
  );
  await executeD1Batches(env.CONTROL_DB, exceptionStatements);
  await env.CONTROL_DB.prepare(
    "INSERT INTO metric_snapshots (id, captured_at, authority_commit, payload_json) VALUES (?, ?, ?, ?)",
  )
    .bind(crypto.randomUUID(), completed, commit, JSON.stringify(audit.metrics))
    .run();
  const status = audit.exceptions.length === 0 ? "converged" : "drift";
  await env.CONTROL_DB.batch([
    env.CONTROL_DB.prepare(
      "UPDATE runs SET status = ?, mutation_count = ?, completed_at = ? WHERE id = ?",
    ).bind(status, audit.repairs, completed, runId),
    env.CONTROL_DB.prepare(
      "UPDATE deliveries SET status = ?, updated_at = ?, last_error = NULL WHERE id = ?",
    ).bind(
      status === "converged" ? "verified" : "drift",
      completed,
      event.deliveryId,
    ),
    ...(status === "converged"
      ? [
          env.CONTROL_DB.prepare(
            "UPDATE deliveries SET status = 'superseded', updated_at = ?, last_error = 'Superseded by a later converged full audit' WHERE status IN ('queued', 'processing', 'retrying', 'drift') AND received_at < ? AND id <> ?",
          ).bind(completed, started, event.deliveryId),
        ]
      : []),
  ]);
  console.log(
    JSON.stringify({
      message: "workspace reconciliation completed",
      deliveryId: event.deliveryId,
      source: event.source,
      mutationsEnabled: env.MUTATIONS_ENABLED,
      status,
      exceptions: audit.exceptions.length,
      repairs: audit.repairs,
    }),
  );
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    if (request.method === "GET" && url.pathname === "/health") {
      const row = await env.CONTROL_DB.prepare(
        "SELECT COUNT(*) AS count FROM exceptions WHERE resolved_at IS NULL",
      ).first<{ count: number }>();
      const latest = await env.CONTROL_DB.prepare(
        "SELECT captured_at, authority_commit, payload_json FROM metric_snapshots ORDER BY captured_at DESC LIMIT 1",
      ).first<{
        captured_at: string;
        authority_commit: string;
        payload_json: string;
      }>();
      return json({
        status: "ok",
        mutationsEnabled: env.MUTATIONS_ENABLED,
        openExceptions: row?.count ?? 0,
        latestAudit: latest
          ? {
              capturedAt: latest.captured_at,
              authorityCommit: latest.authority_commit,
              metrics: JSON.parse(latest.payload_json) as unknown,
            }
          : null,
        now: new Date().toISOString(),
      });
    }
    if (request.method !== "POST") return json({ error: "NOT_FOUND" }, 404);
    try {
      if (url.pathname === "/webhooks/linear")
        return await enqueue(
          env,
          await signedEnvelope(request, env, "linear"),
          200,
        );
      if (url.pathname === "/events/github")
        return await enqueue(env, await signedEnvelope(request, env, "github"));
      if (url.pathname === "/reconcile")
        return await enqueue(env, await signedEnvelope(request, env, "manual"));
      if (url.pathname === "/replay") {
        const requestEvent = await signedEnvelope(request, env, "manual");
        const requested = requestEvent.payload as { deliveryId?: unknown };
        if (typeof requested.deliveryId !== "string")
          return json({ error: "DELIVERY_ID_REQUIRED" }, 400);
        const stored = await env.CONTROL_DB.prepare(
          "SELECT source, schema_version, payload_json, authority_commit FROM deliveries WHERE id = ?",
        )
          .bind(requested.deliveryId)
          .first<{
            source: EventEnvelope["source"];
            schema_version: 1;
            payload_json: string | null;
            authority_commit: string | null;
          }>();
        if (!stored?.payload_json)
          return json({ error: "DELIVERY_NOT_REPLAYABLE" }, 404);
        return await enqueue(env, {
          schemaVersion: stored.schema_version,
          deliveryId: `replay:${requested.deliveryId}:${crypto.randomUUID()}`,
          source: stored.source,
          receivedAt: new Date().toISOString(),
          ...(stored.authority_commit
            ? { authorityCommit: stored.authority_commit }
            : {}),
          payload: JSON.parse(stored.payload_json) as unknown,
        });
      }
      return json({ error: "NOT_FOUND" }, 404);
    } catch (error) {
      const message = error instanceof Error ? error.message : "UNKNOWN_ERROR";
      console.error(
        JSON.stringify({
          message: "ingress rejected",
          reason: message,
          path: url.pathname,
        }),
      );
      return json(
        { error: message },
        message === "PAYLOAD_TOO_LARGE" ? 413 : 401,
      );
    }
  },
  async queue(batch: MessageBatch<EventEnvelope>, env: Env): Promise<void> {
    for (const message of batch.messages) {
      try {
        await processEvent(env, message.body);
        message.ack();
      } catch (error) {
        const reason = error instanceof Error ? error.message : "UNKNOWN_ERROR";
        console.error(
          JSON.stringify({
            message: "delivery failed",
            deliveryId: message.body.deliveryId,
            reason,
          }),
        );
        await env.CONTROL_DB.prepare(
          "UPDATE deliveries SET status = 'retrying', updated_at = ?, last_error = ? WHERE id = ?",
        )
          .bind(new Date().toISOString(), reason, message.body.deliveryId)
          .run();
        message.retry({
          delaySeconds: Math.min(3600, 30 * 2 ** message.attempts),
        });
      }
    }
  },
  async scheduled(_controller: ScheduledController, env: Env): Promise<void> {
    const event: EventEnvelope = {
      schemaVersion: 1,
      deliveryId: `scheduled:${new Date().toISOString().slice(0, 13)}`,
      source: "scheduled",
      receivedAt: new Date().toISOString(),
      payload: { kind: "full-check" },
    };
    if (await persistDelivery(env, event))
      await env.CONTROL_QUEUE.send(event, { contentType: "json" });
  },
} satisfies ExportedHandler<Env, EventEnvelope>;

import { sha256Text } from "./core/hash.js";
import type { EventEnvelope } from "./core/types.js";
import { timingSafeEqual as nodeTimingSafeEqual } from "node:crypto";

const encoder = new TextEncoder();

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
    .get(source === "linear" ? "linear-signature" : "x-hub-signature-256")
    ?.replace(/^sha256=/, "");
  if (!supplied) throw new Error("MISSING_SIGNATURE");
  const secret =
    source === "linear" ? env.LINEAR_WEBHOOK_SECRET : env.GITHUB_WEBHOOK_SECRET;
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
    "INSERT OR IGNORE INTO deliveries (id, source, schema_version, payload_hash, status, authority_commit, received_at, updated_at) VALUES (?, ?, ?, ?, 'queued', ?, ?, ?)",
  )
    .bind(
      event.deliveryId,
      event.source,
      event.schemaVersion,
      hash,
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
  const started = new Date().toISOString();
  await env.CONTROL_DB.prepare(
    "UPDATE deliveries SET status = 'processing', attempts = attempts + 1, updated_at = ? WHERE id = ?",
  )
    .bind(started, event.deliveryId)
    .run();
  const runId = crypto.randomUUID();
  const commit = event.authorityCommit ?? "main";
  const desiredHash = await sha256Text(
    `${event.source}\0${event.deliveryId}\0${commit}`,
  );
  await env.CONTROL_DB.prepare(
    "INSERT INTO runs (id, delivery_id, mode, authority_commit, desired_hash, status, started_at) VALUES (?, ?, 'event', ?, ?, 'verifying', ?)",
  )
    .bind(runId, event.deliveryId, commit, desiredHash, started)
    .run();
  const completed = new Date().toISOString();
  await env.CONTROL_DB.batch([
    env.CONTROL_DB.prepare(
      "UPDATE runs SET status = 'converged', completed_at = ? WHERE id = ?",
    ).bind(completed, runId),
    env.CONTROL_DB.prepare(
      "UPDATE deliveries SET status = 'verified', updated_at = ?, last_error = NULL WHERE id = ?",
    ).bind(completed, event.deliveryId),
  ]);
  console.log(
    JSON.stringify({
      message: "delivery verified",
      deliveryId: event.deliveryId,
      source: event.source,
      mutationsEnabled: env.MUTATIONS_ENABLED,
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
      return json({
        status: "ok",
        mutationsEnabled: env.MUTATIONS_ENABLED,
        openExceptions: row?.count ?? 0,
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

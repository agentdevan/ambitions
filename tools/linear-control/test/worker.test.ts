import { createHmac } from "node:crypto";
import { describe, expect, it, vi } from "vitest";
import worker from "../src/worker.js";

function environment(changeCount = 1): {
  env: Env;
  queueSend: ReturnType<typeof vi.fn>;
} {
  const statement = {
    bind: vi.fn().mockReturnThis(),
    run: vi.fn().mockResolvedValue({ meta: { changes: changeCount } }),
    first: vi.fn().mockResolvedValue(null),
  };
  const queueSend = vi.fn().mockResolvedValue(undefined);
  const env = {
    CONTROL_ADMIN_SECRET: "admin-secret",
    CONTROL_DB: {
      prepare: vi.fn().mockReturnValue(statement),
    },
    CONTROL_QUEUE: {
      send: queueSend,
    },
    MAX_EVENT_BYTES: "65536",
  } as unknown as Env;
  return { env, queueSend };
}

describe("Worker ingress", () => {
  it("authenticates and queues one manual reconciliation", async () => {
    const { env, queueSend } = environment();
    const body = JSON.stringify({ kind: "full-check" });
    const signature = createHmac("sha256", env.CONTROL_ADMIN_SECRET)
      .update(body)
      .digest("hex");
    const response = await worker.fetch(
      new Request("https://control.example/reconcile", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-control-signature": signature,
          "x-delivery-id": "test-delivery",
        },
        body,
      }),
      env,
    );

    expect(response.status).toBe(202);
    await expect(response.json()).resolves.toEqual({
      accepted: true,
      duplicate: false,
      deliveryId: "test-delivery",
    });
    expect(queueSend).toHaveBeenCalledOnce();
  });

  it("rejects an invalid signature without queueing", async () => {
    const { env, queueSend } = environment();
    const response = await worker.fetch(
      new Request("https://control.example/reconcile", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-control-signature": "invalid",
          "x-delivery-id": "bad-delivery",
        },
        body: JSON.stringify({ kind: "full-check" }),
      }),
      env,
    );

    expect(response.status).toBe(401);
    expect(queueSend).not.toHaveBeenCalled();
  });
});

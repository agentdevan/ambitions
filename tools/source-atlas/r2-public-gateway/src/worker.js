import { ALLOWED_OBJECT_KEYS } from "./allowed-object-keys.generated.js";

const PRIVATE_MARKERS = [
  "account_id",
  "capture",
  "device_id",
  "goal_text",
  "private_graph",
  "proof_id",
  "receipt",
  "schedule",
  "user_id",
];

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const method = request.method.toUpperCase();

    if (method !== "GET" && method !== "HEAD") {
      return methodNotAllowed();
    }
    if (url.search !== "" || url.hash !== "") {
      return notFound();
    }

    const objectKey = normalizeObjectKey(url.pathname);
    if (!objectKeyIsAllowed(objectKey)) {
      return notFound();
    }

    const object = await env.SOURCE_ATLAS_BUCKET.get(objectKey);
    if (object === null) {
      return notFound();
    }

    const headers = new Headers();
    object.writeHttpMetadata(headers);
    headers.set("Content-Type", headers.get("Content-Type") ?? "application/json; charset=utf-8");
    headers.set("Cache-Control", headers.get("Cache-Control") ?? "public, max-age=300");
    headers.set("X-Source-Atlas-Public-Reference", "true");
    headers.set("X-Source-Atlas-Gateway", "production-stable-public-reference");
    headers.set("X-Content-Type-Options", "nosniff");

    if (method === "HEAD") {
      return new Response(null, { status: 200, headers });
    }
    return new Response(object.body, { status: 200, headers });
  },
};

function normalizeObjectKey(pathname) {
  const trimmed = pathname.replace(/^\/+/, "");
  try {
    return decodeURIComponent(trimmed);
  } catch {
    return "";
  }
}

function objectKeyIsAllowed(objectKey) {
  if (!ALLOWED_OBJECT_KEYS.has(objectKey)) {
    return false;
  }
  const lower = objectKey.toLowerCase();
  return PRIVATE_MARKERS.every((marker) => !lower.includes(marker));
}

function methodNotAllowed() {
  return new Response("Method not allowed", {
    status: 405,
    headers: {
      Allow: "GET, HEAD",
      "Cache-Control": "no-store",
      "X-Content-Type-Options": "nosniff",
    },
  });
}

function notFound() {
  return new Response("Not found", {
    status: 404,
    headers: {
      "Cache-Control": "no-store",
      "X-Content-Type-Options": "nosniff",
    },
  });
}

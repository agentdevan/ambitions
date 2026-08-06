import { describe, expect, it } from "vitest";
import { sha256Text, stableJson } from "../src/core/hash.js";

describe("contract hashing", () => {
  it("uses stable key order", () =>
    expect(stableJson({ b: 2, a: 1 })).toBe('{"a":1,"b":2}'));
  it("matches the SHA-256 reference vector", async () =>
    expect(await sha256Text("abc")).toBe(
      "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
    ));
});

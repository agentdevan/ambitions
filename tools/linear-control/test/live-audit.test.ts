import { describe, expect, it } from "vitest";
import { fencedTextBodies } from "../src/core/live-audit.js";

describe("live mirror audit", () => {
  it("extracts exact text bodies with collision-safe fences", () => {
    const content = [
      "metadata",
      "````text",
      "line one",
      "```",
      "line two",
      "````",
      "tail",
    ].join("\n");
    expect(fencedTextBodies(content)).toEqual([
      ["line one", "```", "line two"].join("\n"),
    ]);
  });
});

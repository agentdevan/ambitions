import { describe, expect, it } from "vitest";
import {
  desiredLiveIssueState,
  fencedTextBodies,
  requiredFrontendGateLabels,
} from "../src/core/live-audit.js";
import type { ProjectContract, TaskContract } from "../src/core/types.js";

function contracts(visualGate: TaskContract["visualGate"]): {
  project: ProjectContract;
  task: TaskContract;
} {
  const task: TaskContract = {
    id: "T1",
    canonicalKey: "example:T1",
    title: "Task",
    body: "1. Task",
    projectSlug: "example",
    order: 1,
    dependencies: [],
    sharedPaths: [],
    proof: { required: [], validationCommands: [], rollback: "stop" },
    frontendImpact: "affected",
    visualGate,
  };
  return {
    task,
    project: {
      slug: "example",
      canonicalKey: "project:example",
      name: "Example",
      folder: "example",
      documents: [],
      tasks: [task],
      projectDependencies: [],
      sharedPaths: [],
      frontendAudit: { status: "passed", visualGate },
      admission: "ready",
      admissionBlockers: [],
    },
  };
}

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

  it("keeps material frontend work blocked and labeled until visual approval", () => {
    const required = contracts("required");
    expect(requiredFrontendGateLabels(required.project, required.task)).toEqual(
      ["gate:visual-approval"],
    );
    expect(
      desiredLiveIssueState(
        "Ready For Codex",
        false,
        required.project,
        required.task,
      ),
    ).toBe("Blocked");
    expect(
      desiredLiveIssueState("Done", false, required.project, required.task),
    ).toBe("Needs Repair");
    expect(
      desiredLiveIssueState(
        "Needs Repair",
        false,
        required.project,
        required.task,
      ),
    ).toBe("Needs Repair");

    const approved = contracts("approved");
    expect(requiredFrontendGateLabels(approved.project, approved.task)).toEqual(
      [],
    );
    expect(
      desiredLiveIssueState("Backlog", false, approved.project, approved.task),
    ).toBe("Ready For Codex");
  });
});

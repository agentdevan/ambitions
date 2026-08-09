import { describe, expect, it } from "vitest";
import {
  desiredLiveIssueState,
  desiredLiveStatesByDependency,
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

  it("repairs native Linear premature Done to In Review until exact proof passes", () => {
    const { project, task } = contracts("not-required");
    const authorityCommit = "a".repeat(40);

    expect(
      desiredLiveIssueState("Done", false, project, task, {
        authorityCommit,
        mergedToMain: true,
        proofPassed: false,
        requiredProofFailed: false,
      }),
    ).toBe("In Review");
    expect(
      desiredLiveIssueState("Done", false, project, task, {
        authorityCommit,
        mergedToMain: true,
        proofPassed: true,
        requiredProofFailed: false,
      }),
    ).toBe("Done");
  });

  it("keeps merged but incompletely proven work in review instead of executable", () => {
    const { project, task } = contracts("not-required");
    expect(
      desiredLiveIssueState("Ready For Codex", false, project, task, {
        authorityCommit: "a".repeat(40),
        mergedToMain: true,
        proofPassed: false,
        requiredProofFailed: false,
      }),
    ).toBe("In Review");
  });

  it("uses Needs Repair only for explicit failed proof evidence", () => {
    const { project, task } = contracts("not-required");
    expect(
      desiredLiveIssueState("Done", false, project, task, {
        authorityCommit: "a".repeat(40),
        mergedToMain: true,
        proofPassed: false,
        requiredProofFailed: true,
      }),
    ).toBe("Needs Repair");
  });

  it.each(["Canceled", "Duplicate", "Won’t Do"] as const)(
    "preserves terminal %s before dependency, frontend, repair, and proof gates",
    (terminalState) => {
      const { project, task } = contracts("required");
      expect(
        desiredLiveIssueState(terminalState, true, project, task, {
          source: "receipt",
          authorityCommit: "a".repeat(40),
          mergedToMain: true,
          proofPassed: true,
          requiredProofFailed: true,
          issueIdentifier: "AMB-1",
          pullRequestUrl: "https://github.com/agentdevan/ambitions/pull/1",
          mergeCommitSha: "b".repeat(40),
        }),
      ).toBe(terminalState);
    },
  );

  it("blocks a dependent in the same pass when its Done prerequisite loses proof", () => {
    const prerequisite = contracts("not-required");
    prerequisite.task.canonicalKey = "example:T1";
    prerequisite.task.id = "T1";
    const dependent = {
      ...prerequisite.task,
      id: "T2",
      canonicalKey: "example:T2",
      order: 2,
      dependencies: ["example:T1"],
    };
    prerequisite.project.tasks = [prerequisite.task, dependent];
    const states = desiredLiveStatesByDependency(
      [prerequisite.project],
      new Map([
        ["example:T1", "Done"],
        ["example:T2", "Ready For Codex"],
      ]),
      new Map([
        [
          "example:T1",
          {
            authorityCommit: "a".repeat(40),
            mergedToMain: true,
            proofPassed: false,
            requiredProofFailed: false,
          },
        ],
      ]),
    );

    expect(states.get("example:T1")).toBe("In Review");
    expect(states.get("example:T2")).toBe("Blocked");
  });
});

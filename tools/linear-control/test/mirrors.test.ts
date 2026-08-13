import { describe, expect, it } from "vitest";
import {
  issueAuthorityEnvelope,
  milestoneAuthorityMirror,
  projectSummaryMirror,
  repositoryMirror,
} from "../src/core/mirrors.js";
import { fencedTextBodies } from "../src/core/live-audit.js";
import type {
  ProjectContract,
  ScheduleGroup,
  TaskContract,
} from "../src/core/types.js";

const task: TaskContract = {
  id: "T1",
  canonicalKey: "example:T1",
  title: "Build the view",
  body: '1. Build the view.\n   Frontend: affected; Visual gate: required.\n   ```swift\n   Text("Example")\n   ```',
  projectSlug: "example",
  order: 1,
  dependencies: [],
  sharedPaths: [],
  proof: { required: ["ui"], validationCommands: [], rollback: "stop" },
  frontendImpact: "affected",
  visualGate: "required",
  globalRank: 4,
  parallelGroup: "G01",
};
const project: ProjectContract = {
  slug: "example",
  canonicalKey: "project:example",
  name: "Lifecycle — Example",
  folder: "docs/product-development/example",
  documents: [],
  tasks: [task],
  projectDependencies: [],
  sharedPaths: [],
  frontendAudit: {
    status: "passed",
    visualGate: "required",
    firstFrontendTaskKey: task.canonicalKey,
  },
  admission: "ready",
  admissionBlockers: [],
};
const group: ScheduleGroup = {
  id: "G01",
  projectSlugs: ["example", "peer"],
  taskKeys: [task.canonicalKey],
};

describe("Linear authority mirrors", () => {
  it("preserves exact repository bytes inside a collision-safe text fence", () => {
    const source = "line one\n```\nline two\n";
    const content = repositoryMirror(
      [
        {
          contract: {
            kind: "design",
            path: "docs/product-development/example/design.md",
            revision: "1",
            status: "approved",
            sha256: "abc",
            byteLength: source.length,
            gitBlobOid: "1".repeat(40),
          },
          content: source,
        },
      ],
      "commit",
      "contract",
      "Grooming",
      "now",
    );
    expect(fencedTextBodies(content)).toEqual([source.replace(/\n$/, "")]);
    expect(content).toContain("Content SHA-256: abc");
  });

  it("renders exact task authority and frontend gates", () => {
    const content = issueAuthorityEnvelope(
      task,
      group,
      project,
      "commit",
      "contract",
    );
    expect(fencedTextBodies(content)).toEqual([task.body]);
    expect(content).toContain("Frontend impact: affected");
    expect(content).toContain("Visual gate: required");
    expect(content).toContain("Parallel-safe peer Projects: peer");
  });

  it("does not claim current-main completion when terminal state lacks proof", () => {
    const progress = {
      phase: "Validating",
      terminalTasks: 1,
      verifiedTasks: 0,
      totalTasks: 1,
      groupOrdinal: 1,
      totalGroups: 1,
      projectOrdinal: 1,
    };

    expect(projectSummaryMirror(group, progress)).toContain(
      "1/1 terminal • 0 verified on current main",
    );
    expect(
      milestoneAuthorityMirror(
        "M4 — Implementation Complete",
        project,
        "a".repeat(40),
        progress,
      ),
    ).not.toContain("PASS");
  });

  it("renders P0 and held-lane summaries without inventing executable next work", () => {
    const progress = {
      phase: "Building",
      terminalTasks: 0,
      verifiedTasks: 0,
      totalTasks: 6,
      reviewTasks: 4,
      blockedTasks: 2,
      nextTask: task,
      groupOrdinal: 2,
      totalGroups: 21,
      projectOrdinal: 1,
    };
    const held = { ...project, executionLane: "normal" as const };
    expect(projectSummaryMirror(group, progress, held, true)).toBe(
      "P0 hold • closure-only • 0/6 terminal • 4 in review • 2 blocked",
    );
    const p0 = { ...project, executionLane: "p0" as const };
    expect(
      projectSummaryMirror({ ...group, id: "P0" }, progress, p0, true),
    ).toBe(
      "P0 • UFP active • external ledger sync required • phase/task/progress withheld",
    );
  });
});

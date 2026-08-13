import { describe, expect, it } from "vitest";
import { planReconciliation } from "../src/core/reconcile.js";
import type {
  DesiredWorkspaceManifest,
  ProjectContract,
} from "../src/core/types.js";

function project(slug: string): ProjectContract {
  return {
    slug,
    canonicalKey: `project:${slug}`,
    name: slug,
    folder: slug,
    documents: [],
    tasks: [
      {
        id: "T1",
        canonicalKey: `${slug}:T1`,
        title: "Task",
        body: "1. Task",
        projectSlug: slug,
        order: 1,
        dependencies: [],
        sharedPaths: [],
        proof: {
          required: ["audit"],
          validationCommands: [],
          rollback: "stop",
        },
        frontendImpact: "none",
        visualGate: "not-required",
      },
    ],
    projectDependencies: [],
    sharedPaths: [],
    frontendAudit: { status: "passed", visualGate: "not-required" },
    admission: "ready",
    admissionBlockers: [],
  };
}

describe("reconciliation planner", () => {
  it("plans only scheduled operational projects", async () => {
    const manifest: DesiredWorkspaceManifest = {
      schemaVersion: 1,
      authorityCommit: "abc",
      contractHash: "hash",
      projects: [project("operational"), project("fixture")],
      schedule: [
        {
          id: "G00",
          projectSlugs: ["operational"],
          taskKeys: ["operational:T1"],
        },
      ],
    };
    const plan = await planReconciliation(manifest, {
      projects: [],
      issues: [],
    });
    expect(plan.mutations.map((mutation) => mutation.canonicalKey)).toEqual([
      "operational:T1",
    ]);
  });

  it("blocks an existing frontend issue while visual approval is required", async () => {
    const gated = project("gated");
    gated.tasks[0]!.frontendImpact = "affected";
    gated.tasks[0]!.visualGate = "required";
    gated.frontendAudit = {
      status: "passed",
      visualGate: "required",
      firstFrontendTaskKey: "gated:T1",
    };
    const manifest: DesiredWorkspaceManifest = {
      schemaVersion: 1,
      authorityCommit: "abc",
      contractHash: "hash",
      projects: [gated],
      schedule: [
        { id: "G00", projectSlugs: ["gated"], taskKeys: ["gated:T1"] },
      ],
    };

    const plan = await planReconciliation(manifest, {
      projects: [],
      issues: [
        {
          id: "issue",
          identifier: "AMB-1",
          canonicalKey: "gated:T1",
          state: "Backlog",
          labels: [],
          blockedBy: [],
          mergedToMain: false,
          proofPassed: false,
          requiredProofFailed: false,
        },
      ],
    });

    expect(plan.mutations[0]!.payload.state).toBe("Blocked");
  });

  it("holds existing normal issues and lazily avoids future issue creation while P0 is active", async () => {
    const p0 = project("p0");
    p0.executionLane = "p0";
    const control = project("control");
    control.executionLane = "control";
    const normal = project("normal");
    normal.executionLane = "normal";
    const manifest: DesiredWorkspaceManifest = {
      schemaVersion: 1,
      authorityCommit: "abc",
      contractHash: "hash",
      projects: [p0, control, normal],
      schedule: [
        { id: "P0", projectSlugs: ["p0"], taskKeys: ["p0:T1"] },
        {
          id: "G00",
          projectSlugs: ["control"],
          taskKeys: ["control:T1"],
        },
        { id: "G01", projectSlugs: ["normal"], taskKeys: ["normal:T1"] },
      ],
      executionPolicy: {
        p0: {
          active: true,
          projectSlug: "p0",
          blocksNormalStarts: true,
          concurrentProjectSlugs: ["control"],
          ownerOverrideRequired: true,
          operationalLedgerPath: "/authority/PROGRAM.json",
          projectionDirection: "one-way",
        },
        unscheduledProjectSlugs: [],
        materialization: {
          mode: "execution-horizon",
          alwaysProjectSlugs: ["p0", "control"],
          currentNormalGroupsWhenP0Inactive: 1,
          nextNormalGroupsWhenP0Inactive: 1,
          futureGroups: "repository-authoritative",
        },
      },
    };
    const plan = await planReconciliation(manifest, {
      projects: [],
      issues: [
        {
          id: "normal-issue",
          identifier: "AMB-3",
          canonicalKey: "normal:T1",
          state: "Ready For Codex",
          labels: [],
          blockedBy: [],
          mergedToMain: false,
          proofPassed: false,
          requiredProofFailed: false,
        },
      ],
    });

    expect(
      plan.mutations
        .filter((mutation) => mutation.kind === "create")
        .map((mutation) => mutation.canonicalKey),
    ).toEqual(["p0:T1", "control:T1"]);
    expect(
      plan.mutations.find((mutation) => mutation.canonicalKey === "normal:T1")
        ?.payload.state,
    ).toBe("Blocked");
  });
});

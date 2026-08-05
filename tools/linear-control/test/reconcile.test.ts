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
      },
    ],
    projectDependencies: [],
    sharedPaths: [],
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
});

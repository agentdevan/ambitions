import { describe, expect, it } from "vitest";
import {
  deletionIsSafe,
  desiredIssueState,
  desiredProjectPhase,
  scheduleProjects,
} from "../src/core/policy.js";
import { projectHealth } from "../src/core/health.js";
import type { CurrentIssue, ProjectContract } from "../src/core/types.js";

function issue(overrides: Partial<CurrentIssue> = {}): CurrentIssue {
  return {
    id: "1",
    identifier: "AMB-1",
    state: "Backlog",
    labels: [],
    blockedBy: [],
    mergedToMain: false,
    proofPassed: false,
    requiredProofFailed: false,
    ...overrides,
  };
}

function project(
  slug: string,
  dependencies: string[] = [],
  sharedPaths: string[] = [],
): ProjectContract {
  return {
    slug,
    canonicalKey: `project:${slug}`,
    name: slug,
    folder: slug,
    documents: [],
    tasks: [],
    projectDependencies: dependencies,
    sharedPaths,
    frontendAudit: { status: "passed", visualGate: "not-required" },
    admission: "ready",
    admissionBlockers: [],
  };
}

describe("lifecycle policy", () => {
  it("proof-gates Done", () => {
    expect(
      desiredIssueState(issue({ mergedToMain: true, proofPassed: false })),
    ).toBe("In Review");
    expect(
      desiredIssueState(issue({ mergedToMain: true, proofPassed: true })),
    ).toBe("Done");
    expect(desiredIssueState(issue({ requiredProofFailed: true }))).toBe(
      "Needs Repair",
    );
  });

  it("blocks frontend work until repository and visual gates pass", () => {
    expect(
      desiredIssueState(
        issue({ frontendAffected: true, frontendContractPassed: false }),
      ),
    ).toBe("Blocked");
    expect(
      desiredIssueState(
        issue({
          frontendAffected: true,
          frontendContractPassed: true,
          visualGateRequired: true,
          visualGateApproved: false,
        }),
      ),
    ).toBe("Blocked");
    expect(
      desiredIssueState(
        issue({
          frontendAffected: true,
          frontendContractPassed: true,
          visualGateRequired: true,
          visualGateApproved: true,
        }),
      ),
    ).toBe("Ready For Codex");
    expect(desiredIssueState(issue({ frontendAffected: false }))).toBe(
      "Ready For Codex",
    );
  });

  it("enforces the active P0 start lock without blocking control or review closure", () => {
    const normal = { p0Active: true, lane: "normal" as const };
    expect(desiredIssueState(issue({ state: "Backlog" }), normal)).toBe(
      "Blocked",
    );
    expect(desiredIssueState(issue({ state: "Ready For Codex" }), normal)).toBe(
      "Blocked",
    );
    expect(desiredIssueState(issue({ state: "In Progress" }), normal)).toBe(
      "In Progress",
    );
    expect(desiredIssueState(issue({ state: "In Review" }), normal)).toBe(
      "In Review",
    );
    expect(
      desiredIssueState(
        issue({ state: "In Review", mergedToMain: true, proofPassed: true }),
        normal,
      ),
    ).toBe("Done");
    expect(
      desiredIssueState(issue(), { p0Active: true, lane: "control" }),
    ).toBe("Ready For Codex");
    expect(
      desiredIssueState(issue(), { p0Active: false, lane: "normal" }),
    ).toBe("Ready For Codex");
  });

  it("derives project phases", () => {
    expect(desiredProjectPhase(["Ready For Codex"], true)).toBe("Grooming");
    expect(desiredProjectPhase(["In Progress"], true)).toBe("Building");
    expect(desiredProjectPhase(["In Review"], true)).toBe("Validating");
    expect(desiredProjectPhase(["In Review", "Blocked"], true)).toBe(
      "Building",
    );
    expect(desiredProjectPhase(["Done", "In Review"], true)).toBe("Validating");
    expect(desiredProjectPhase(["Done"], true)).toBe("Completed");
    expect(desiredProjectPhase(["Duplicate"], true)).toBe("Completed");
  });

  it("forms dependency-safe pairs and serializes shared paths", () => {
    const groups = scheduleProjects([
      project("a", [], ["project.yml"]),
      project("b", [], ["project.yml"]),
      project("c", ["a"]),
    ]);
    expect(groups.map((group) => group.projectSlugs)).toEqual([
      ["a"],
      ["b", "c"],
    ]);
  });

  it("rejects dependency cycles", () => {
    expect(() =>
      scheduleProjects([project("a", ["b"]), project("b", ["a"])]),
    ).toThrow("PROJECT_DEPENDENCY_CYCLE");
  });

  it("requires complete deletion evidence", () => {
    expect(
      deletionIsSafe({
        disposition: "duplicate",
        zeroUniqueValue: true,
        commentsInspected: true,
        attachmentsInspected: true,
        descendantsInspected: true,
        inboundRelationsInspected: true,
        referencesRepaired: true,
        activeWorkPreserved: true,
        canonicalTruthPreserved: true,
      }),
    ).toBe(true);
    expect(
      deletionIsSafe({
        disposition: "duplicate",
        zeroUniqueValue: true,
        commentsInspected: false,
        attachmentsInspected: true,
        descendantsInspected: true,
        inboundRelationsInspected: true,
        referencesRepaired: true,
        activeWorkPreserved: true,
        canonicalTruthPreserved: true,
      }),
    ).toBe(false);
  });

  it("classifies health at exact thresholds", () => {
    const now = new Date("2026-08-05T12:00:00Z");
    expect(
      projectHealth({
        now,
        lastSyncAt: new Date("2026-08-05T11:50:00Z"),
        oldestBlockerBusinessDays: 0,
        oldestReviewBusinessDays: 0,
        wipViolation: false,
        proofFailed: false,
      }),
    ).toBe("onTrack");
    expect(
      projectHealth({
        now,
        lastSyncAt: new Date("2026-08-05T11:40:00Z"),
        oldestBlockerBusinessDays: 0,
        oldestReviewBusinessDays: 0,
        wipViolation: false,
        proofFailed: false,
      }),
    ).toBe("atRisk");
    expect(
      projectHealth({
        now,
        lastSyncAt: new Date("2026-08-05T10:00:00Z"),
        oldestBlockerBusinessDays: 0,
        oldestReviewBusinessDays: 0,
        wipViolation: false,
        proofFailed: false,
      }),
    ).toBe("offTrack");
  });
});

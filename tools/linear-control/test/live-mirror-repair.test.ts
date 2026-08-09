import { describe, expect, it } from "vitest";
import type { LinearClient } from "../src/adapters/linear.js";
import {
  CONTROLLED_TEMPLATES,
  OPERATIONAL_VIEWS,
} from "../src/core/definitions.js";
import { sha256Text } from "../src/core/hash.js";
import {
  auditLiveWorkspace,
  desiredProjectMirrorProgress,
} from "../src/core/live-audit.js";
import {
  initiativeIndexMirror,
  issueAuthorityEnvelope,
  repositoryMirror,
} from "../src/core/mirrors.js";
import type {
  DesiredWorkspaceManifest,
  DocumentContract,
  IssueState,
  ProjectContract,
  ScheduleGroup,
  TaskContract,
} from "../src/core/types.js";

const issueStates = [
  "Backlog",
  "Ready For Codex",
  "Blocked",
  "In Progress",
  "In Review",
  "Needs Repair",
  "Done",
  "Canceled",
  "Duplicate",
  "Won’t Do",
];

const initiatives = [
  "Ambitions Constitution → Market-Leading App Store Launch",
  "Onboarding + Reviews + Guidance",
  "Source / Trust / Reference Infrastructure",
  "QA + Release + App Store Readiness",
  "Security + Privacy",
  "Accessibility + Inclusive Interaction",
  "Design System + Visual Language",
  "iOS System Integrations",
  "Accounts + Entitlements",
  "Persistence + Local Data System",
  "Private Life Runtime",
  "Motion Behavior Layer",
  "Search + Local Find/Act/Inspect",
  "Global Capture",
  "You Surface",
  "Goals Surface",
  "Time Surface",
  "Today Surface",
  "Native Stage OS + Shell",
  "Ambitions Product Canon + Operating Model",
];

const milestones = [
  "M0 — Research Passed",
  "M1 — Scope Passed",
  "M2 — Design Passed",
  "M3 — Groomed for Implementation",
  "M4 — Implementation Complete",
  "M5 — Validation and Merge",
  "M6 — Closeout",
];

class RepairingLinearClient {
  projectQueries: string[] = [];
  projectPageCursors: Array<string | null> = [];
  splitProjectAcrossPages = false;
  omitNextProjectCursor = false;
  documentContents = new Map<string, string>();
  issueDescription = "";
  projectSummary = "stale summary";
  projectDescription = "stale description";
  projectStatus = "Building";
  initiativeNames = ["Test Initiative"];
  failProjectVerification = false;
  failMilestoneVerification = false;
  milestoneDescriptions = new Map(
    milestones.map((name) => [name, `stale ${name}`]),
  );

  constructor(private readonly project: ProjectContract) {}

  async request<T>(
    query: string,
    variables: Readonly<Record<string, unknown>> = {},
  ): Promise<T> {
    await Promise.resolve();
    if (query.includes("projects(")) this.projectQueries.push(query);
    if (query.includes("projects(first: 10")) {
      const after = (variables.after as string | null | undefined) ?? null;
      this.projectPageCursors.push(after);
      if (this.splitProjectAcrossPages && after === null) {
        return {
          projects: {
            nodes: [],
            pageInfo: {
              hasNextPage: true,
              endCursor: this.omitNextProjectCursor ? null : "project-page-2",
            },
          },
        } as T;
      }
      return {
        projects: {
          nodes: [
            {
              id: "project-id",
              name: `Lifecycle — ${this.project.slug}`,
              summary: this.projectSummary,
              description: this.projectDescription,
              status: {
                id: `project-status:${this.projectStatus}`,
                name: this.projectStatus,
              },
              initiatives: {
                nodes: this.initiativeNames.map((name) => ({ name })),
              },
              labels: { nodes: [] },
              projectMilestones: {
                nodes: milestones.map((name) => ({
                  id: `milestone:${name}`,
                  name,
                  description: this.milestoneDescriptions.get(name),
                })),
              },
              documents: {
                nodes: [...this.documentContents].map(([title, content]) => ({
                  id: `document:${title}`,
                  title,
                  content,
                })),
              },
            },
          ],
          pageInfo: { hasNextPage: false, endCursor: null },
        },
      } as T;
    }
    if (query.includes("workflowStates(first: 50")) {
      return {
        workflowStates: {
          nodes: issueStates.map((name) => ({ id: `state:${name}`, name })),
        },
        issueLabels: { nodes: [{ id: "label:work:test", name: "work:test" }] },
        projectLabels: { nodes: [] },
        projectStatuses: {
          nodes: ["Grooming", "Building", "Validating", "Completed"].map(
            (name) => ({ id: `project-status:${name}`, name }),
          ),
        },
        customViews: { nodes: OPERATIONAL_VIEWS.map(({ name }) => ({ name })) },
        templates: CONTROLLED_TEMPLATES.map((name) => ({ name })),
        initiatives: { nodes: initiatives.map((name) => ({ name })) },
        cycles: {
          nodes: [
            { isActive: true, isNext: false },
            { isActive: false, isNext: true },
          ],
        },
      } as T;
    }
    if (query.includes("issues(first: 100")) {
      return {
        issues: {
          nodes: [
            {
              id: "issue-id",
              identifier: "AMB-1",
              title: "Plan Task 01 — Build the contract",
              description: this.issueDescription,
              state: {
                id: "state:Ready For Codex",
                name: "Ready For Codex",
                type: "unstarted",
              },
              project: { name: `Lifecycle — ${this.project.slug}` },
              parent: null,
              labels: { nodes: [{ id: "label:work:test", name: "work:test" }] },
              relations: { nodes: [] },
              inverseRelations: { nodes: [] },
            },
          ],
          pageInfo: { hasNextPage: false, endCursor: null },
        },
      } as T;
    }
    if (query.includes("documentUpdate")) {
      const id = variables.id as string;
      const input = variables.input as { content: string };
      const title = id.replace(/^document:/, "");
      this.documentContents.set(title, input.content);
      return {
        documentUpdate: {
          success: true,
          document: { content: input.content },
        },
      } as T;
    }
    if (query.includes("projectMilestoneUpdate")) {
      const id = variables.id as string;
      const input = variables.input as { description: string };
      const name = id.replace(/^milestone:/, "");
      if (!this.failMilestoneVerification)
        this.milestoneDescriptions.set(name, input.description);
      return {
        projectMilestoneUpdate: {
          success: true,
          projectMilestone: {
            description: this.milestoneDescriptions.get(name),
          },
        },
      } as T;
    }
    if (query.includes("projectUpdate")) {
      const input = variables.input as {
        description: string;
        content: string;
        statusId: string;
      };
      if (!this.failProjectVerification) {
        this.projectSummary = input.description;
        this.projectDescription = input.content;
        this.projectStatus = input.statusId.replace(/^project-status:/, "");
      }
      return {
        projectUpdate: {
          success: true,
          project: {
            summary: this.projectSummary,
            description: this.projectDescription,
            status: { name: this.projectStatus },
          },
        },
      } as T;
    }
    if (query.includes("issueUpdate") && variables.input) {
      const input = variables.input as { description?: string };
      if (input.description !== undefined)
        this.issueDescription = input.description;
      return {
        issueUpdate: {
          success: true,
          issue: { description: this.issueDescription },
        },
      } as T;
    }
    throw new Error(`UNEXPECTED_QUERY:${query}`);
  }
}

async function fixture(): Promise<{
  client: RepairingLinearClient;
  desired: DesiredWorkspaceManifest;
  sourceByPath: ReadonlyMap<string, string>;
}> {
  const sourceByKind = new Map([
    ["research", "research body\n"],
    ["scope", "scope body\n"],
    ["design", "design body\n"],
    ["plan", "plan body\n"],
  ]);
  const documents: DocumentContract[] = await Promise.all(
    [...sourceByKind].map(async ([kind, content]) => ({
      kind: kind as DocumentContract["kind"],
      path: `docs/product-development/example/${kind}.md`,
      revision: "1",
      status: "approved",
      sha256: await sha256Text(content),
      byteLength: content.length,
    })),
  );
  const task: TaskContract = {
    id: "T1",
    canonicalKey: "example:T1",
    title: "Build the contract",
    body: "1. Build the contract.",
    projectSlug: "example",
    order: 1,
    dependencies: [],
    sharedPaths: [],
    proof: { required: [], validationCommands: [], rollback: "stop" },
    frontendImpact: "none",
    visualGate: "not-required",
    globalRank: 1,
    parallelGroup: "G01",
  };
  const project: ProjectContract = {
    slug: "example",
    canonicalKey: "project:example",
    name: "Lifecycle — example",
    folder: "docs/product-development/example",
    documents,
    tasks: [task],
    projectDependencies: [],
    sharedPaths: [],
    frontendAudit: { status: "passed", visualGate: "not-required" },
    admission: "ready",
    admissionBlockers: [],
  };
  const group: ScheduleGroup = {
    id: "G01",
    projectSlugs: [project.slug],
    taskKeys: [task.canonicalKey],
  };
  const desired: DesiredWorkspaceManifest = {
    schemaVersion: 1,
    authorityCommit: "new-commit",
    contractHash: "new-contract",
    projects: [project],
    schedule: [group],
  };
  const client = new RepairingLinearClient(project);
  const oldCommit = "old-commit";
  const oldContract = "old-contract";
  const oldSync = "2026-08-05T00:00:00Z";
  client.documentContents.set(
    "00 — Initiative Brief and Lifecycle Index",
    initiativeIndexMirror(
      project,
      group,
      oldCommit,
      oldContract,
      "Grooming",
      oldSync,
      new Map([[task.canonicalKey, "AMB-1"]]),
    ),
  );
  for (const [title, kind] of [
    ["10 — Research", "research"],
    ["20 — Scope", "scope"],
    ["30 — Design", "design"],
    ["40 — Implementation Plan", "plan"],
  ] as const) {
    const contract = documents.find((item) => item.kind === kind)!;
    client.documentContents.set(
      title,
      repositoryMirror(
        [{ contract, content: sourceByKind.get(kind)! }],
        oldCommit,
        oldContract,
        "Grooming",
        oldSync,
      ),
    );
  }
  client.issueDescription = issueAuthorityEnvelope(
    task,
    group,
    project,
    oldCommit,
    oldContract,
  );
  const sourceByPath = new Map(
    documents.map((contract) => [
      contract.path,
      sourceByKind.get(contract.kind)!,
    ]),
  );
  return { client, desired, sourceByPath };
}

describe("live authority mirror repair", () => {
  it("keeps the nested Project audit query below Linear's complexity ceiling", async () => {
    const { client, desired } = await fixture();

    await auditLiveWorkspace(client as unknown as LinearClient, desired, false);

    expect(client.projectQueries).toHaveLength(1);
    expect(client.projectQueries[0]).toContain("projects(first: 10");
    expect(client.projectQueries[0]).toContain(
      "pageInfo { hasNextPage endCursor }",
    );
  });

  it("collects lifecycle Projects across every bounded Project page", async () => {
    const { client, desired } = await fixture();
    client.splitProjectAcrossPages = true;

    const result = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      false,
    );

    expect(client.projectPageCursors).toEqual([null, "project-page-2"]);
    expect(result.mappings).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          canonicalKey: "project:example",
          linearId: "project-id",
        }),
      ]),
    );
  });

  it("fails closed when Linear advertises another Project page without a cursor", async () => {
    const { client, desired } = await fixture();
    client.splitProjectAcrossPages = true;
    client.omitNextProjectCursor = true;

    await expect(
      auditLiveWorkspace(client as unknown as LinearClient, desired, false),
    ).rejects.toThrow("LINEAR_PROJECT_PAGE_CURSOR_MISSING");
  });

  it("repairs stale Project, milestone, Document, and Issue mirrors once", async () => {
    const { client, desired } = await fixture();
    for (const [title, content] of client.documentContents)
      client.documentContents.set(
        title,
        content.replace(
          "Repository commit: old-commit",
          "Repository commit: new-commit",
        ),
      );

    const repaired = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      true,
    );

    expect(repaired.exceptions).toEqual([]);
    expect(repaired.repairs).toBe(14);
    expect(
      repaired.repairReceipts.map((item) => item.operation).sort(),
    ).toEqual([
      "document-authority-update",
      "document-authority-update",
      "document-authority-update",
      "document-authority-update",
      "document-authority-update",
      "issue-authority-update",
      "project-authority-update",
      "project-milestone-update",
      "project-milestone-update",
      "project-milestone-update",
      "project-milestone-update",
      "project-milestone-update",
      "project-milestone-update",
      "project-milestone-update",
    ]);
    expect(client.projectSummary).toBe(
      "G01 • Grooming • 0/1 terminal • 0 verified on current main • next T1",
    );
    expect(client.projectDescription).toContain(
      "Repository commit: new-commit",
    );
    expect(client.projectStatus).toBe("Grooming");
    expect(
      client.milestoneDescriptions.get("M4 — Implementation Complete"),
    ).toContain("0 of 1 canonical Plan Tasks are terminal");

    const idempotent = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      true,
    );
    expect(idempotent.exceptions).toEqual([]);
    expect(idempotent.repairs).toBe(0);
  });

  it("reloads verified repository bytes when a Document body has drifted", async () => {
    const { client, desired, sourceByPath } = await fixture();
    client.documentContents.set(
      "30 — Design",
      client.documentContents
        .get("30 — Design")!
        .replace("design body", "stale design body"),
    );

    const repaired = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      true,
      {
        loadRepositoryText: async (path) => {
          await Promise.resolve();
          const content = sourceByPath.get(path);
          if (content === undefined) throw new Error(`SOURCE_MISSING:${path}`);
          return content;
        },
      },
    );

    expect(repaired.exceptions).toEqual([]);
    expect(repaired.repairs).toBe(14);
    expect(client.documentContents.get("30 — Design")).toContain("design body");
    expect(client.documentContents.get("30 — Design")).not.toContain(
      "stale design body",
    );
  });

  it("reports failed Project and milestone post-write verification", async () => {
    const { client, desired } = await fixture();
    client.failProjectVerification = true;
    client.failMilestoneVerification = true;

    const repaired = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      true,
    );

    expect(
      repaired.exceptions.some((item) =>
        item.summary.includes("Lifecycle Project mirror repair did not verify"),
      ),
    ).toBe(true);
    expect(
      repaired.exceptions.some((item) =>
        item.summary.includes("Lifecycle milestone repair did not verify"),
      ),
    ).toBe(true);
    expect(
      repaired.repairReceipts
        .filter(
          (item) =>
            item.operation === "project-authority-update" ||
            item.operation === "project-milestone-update",
        )
        .every((item) => !item.verified),
    ).toBe(true);
  });

  it("does not let stale Linear Initiative ordering rewrite repository authority", async () => {
    const { client, desired } = await fixture();
    client.initiativeNames = ["Stale Initiative", "Other Initiative"];

    const repaired = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      true,
    );

    expect(repaired.exceptions).toEqual([]);
    expect(client.projectDescription).toContain(
      "Linear Initiative relationship is authoritative for portfolio ownership",
    );
    expect(client.projectDescription).not.toContain("Stale Initiative");
  });

  it("audits a manifest-declared primary Initiative independently", async () => {
    const { client, desired } = await fixture();
    const project = desired.projects[0]!;
    project.primaryInitiative = "Canonical Initiative";
    client.initiativeNames = ["Stale Initiative", "Canonical Initiative"];

    const repaired = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      true,
    );

    expect(repaired.exceptions).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          summary:
            "Primary Initiative relationship should be exactly Canonical Initiative",
        }),
      ]),
    );
    expect(client.projectDescription).toContain(
      "Primary Initiative: Canonical Initiative",
    );
  });
});

describe("canonical Project mirror policy", () => {
  function twoTaskFixture(): {
    project: ProjectContract;
    group: ScheduleGroup;
  } {
    const first: TaskContract = {
      id: "T1",
      canonicalKey: "example:T1",
      title: "First",
      body: "1. First.",
      projectSlug: "example",
      order: 1,
      dependencies: [],
      sharedPaths: [],
      proof: { required: [], validationCommands: [], rollback: "stop" },
      frontendImpact: "none",
      visualGate: "not-required",
    };
    const second: TaskContract = {
      ...first,
      id: "T2",
      canonicalKey: "example:T2",
      title: "Second",
      body: "2. Second.",
      order: 2,
    };
    return {
      project: {
        slug: "example",
        canonicalKey: "project:example",
        name: "Lifecycle — example",
        folder: "docs/product-development/example",
        documents: [],
        tasks: [first, second],
        projectDependencies: [],
        sharedPaths: [],
        frontendAudit: { status: "passed", visualGate: "not-required" },
        admission: "ready",
        admissionBlockers: [],
      },
      group: {
        id: "G01",
        projectSlugs: ["example"],
        taskKeys: ["example:T1"],
      },
    };
  }

  it.each([
    {
      name: "Building",
      states: new Map<string, IssueState>([
        ["example:T1", "Done"],
        ["example:T2", "In Progress"],
      ]),
      phase: "Building",
      next: "T2",
    },
    {
      name: "Validating",
      states: new Map<string, IssueState>([
        ["example:T1", "Done"],
        ["example:T2", "In Review"],
      ]),
      phase: "Validating",
      next: "T2",
    },
    {
      name: "Completed",
      states: new Map<string, IssueState>([
        ["example:T1", "Canceled"],
        ["example:T2", "Won’t Do"],
      ]),
      phase: "Completed",
      next: undefined,
    },
  ])("derives $name from canonical task states", ({ states, phase, next }) => {
    const { project, group } = twoTaskFixture();
    const progress = desiredProjectMirrorProgress(
      project,
      group,
      [group],
      states,
    );
    expect(progress.phase).toBe(phase);
    expect(progress.nextTask?.id).toBe(next);
  });

  it("treats missing tasks as incomplete and ignores extra task-like Issues", () => {
    const { project, group } = twoTaskFixture();
    const progress = desiredProjectMirrorProgress(
      project,
      group,
      [group],
      new Map<string, IssueState>([
        ["example:T1", "Done"],
        ["example:T99", "In Review"],
      ]),
    );
    expect(progress.phase).toBe("Building");
    expect(progress.terminalTasks).toBe(1);
    expect(progress.nextTask).toBeUndefined();
  });

  it("never advertises Duplicate as executable next work", () => {
    const { project, group } = twoTaskFixture();
    const progress = desiredProjectMirrorProgress(
      project,
      group,
      [group],
      new Map<string, IssueState>([
        ["example:T1", "Duplicate"],
        ["example:T2", "Ready For Codex"],
      ]),
    );
    expect(progress.nextTask?.id).toBe("T2");
  });

  it("closes an all-Duplicate Project without advertising next work", () => {
    const { project, group } = twoTaskFixture();
    const progress = desiredProjectMirrorProgress(
      project,
      group,
      [group],
      new Map<string, IssueState>([
        ["example:T1", "Duplicate"],
        ["example:T2", "Duplicate"],
      ]),
    );
    expect(progress.phase).toBe("Completed");
    expect(progress.terminalTasks).toBe(2);
    expect(progress.verifiedTasks).toBe(0);
    expect(progress.nextTask).toBeUndefined();
  });
});

import { describe, expect, it } from "vitest";
import type { LinearClient } from "../src/adapters/linear.js";
import {
  CONTROLLED_TEMPLATES,
  OPERATIONAL_VIEWS,
} from "../src/core/definitions.js";
import { sha256Text } from "../src/core/hash.js";
import { auditLiveWorkspace } from "../src/core/live-audit.js";
import {
  initiativeIndexMirror,
  issueAuthorityEnvelope,
  repositoryMirror,
} from "../src/core/mirrors.js";
import type {
  DesiredWorkspaceManifest,
  DocumentContract,
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
  documentContents = new Map<string, string>();
  issueDescription = "";

  constructor(private readonly project: ProjectContract) {}

  async request<T>(
    query: string,
    variables: Readonly<Record<string, unknown>> = {},
  ): Promise<T> {
    await Promise.resolve();
    if (query.includes("projects(first: 50)")) {
      return {
        projects: {
          nodes: [
            {
              id: "project-id",
              name: `Lifecycle — ${this.project.slug}`,
              description: null,
              status: { id: "status-id", name: "Building" },
              labels: { nodes: [] },
              projectMilestones: {
                nodes: milestones.map((name) => ({ name })),
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
  it("repairs stale Document metadata and Issue envelopes once", async () => {
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
    expect(repaired.repairs).toBe(6);
    expect(
      repaired.repairReceipts.map((item) => item.operation).sort(),
    ).toEqual([
      "document-authority-update",
      "document-authority-update",
      "document-authority-update",
      "document-authority-update",
      "document-authority-update",
      "issue-authority-update",
    ]);

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
    expect(repaired.repairs).toBe(6);
    expect(client.documentContents.get("30 — Design")).toContain("design body");
    expect(client.documentContents.get("30 — Design")).not.toContain(
      "stale design body",
    );
  });
});

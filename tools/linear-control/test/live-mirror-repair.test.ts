import { createHash } from "node:crypto";
import { describe, expect, it, vi } from "vitest";
import type { LinearClient } from "../src/adapters/linear.js";
import {
  CONTROLLED_TEMPLATES,
  OPERATIONAL_VIEWS,
} from "../src/core/definitions.js";
import { sha256Text } from "../src/core/hash.js";
import {
  auditLiveWorkspace,
  desiredProjectMirrorProgress,
  RepairBudgetExhausted,
} from "../src/core/live-audit.js";
import type { LiveAuditOptions } from "../src/core/live-audit.js";
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
  issueQueries: string[] = [];
  issuePageCursors: Array<string | null> = [];
  splitIssueAcrossPages = false;
  omitNextIssueCursor = false;
  documentContents = new Map<string, string>();
  issueDescription = "";
  issueLabelNames = ["work:test"];
  issueState: IssueState = "Ready For Codex";
  issueStateMutationCalls = 0;
  freshIssueReadCalls = 0;
  freshStateOverrideOnce?: IssueState;
  attachmentUrls: string[] = [];
  attachmentHasNextPage = false;
  projectSummary = "stale summary";
  projectDescription = "stale description";
  projectStatus = "Building";
  initiativeNames = ["Test Initiative"];
  failProjectVerification = false;
  failProjectReadOnce = false;
  failMilestoneVerification = false;
  milestoneDescriptions = new Map(
    milestones.map((name) => [name, `stale ${name}`]),
  );

  constructor(private readonly project: ProjectContract) {}

  private issueNode(): Record<string, unknown> {
    return {
      id: "issue-id",
      identifier: "AMB-1",
      title: "Plan Task 01 — Build the contract",
      description: this.issueDescription,
      state: {
        id: `state:${this.issueState}`,
        name: this.issueState,
        type: ["Done", "Canceled", "Duplicate", "Won’t Do"].includes(
          this.issueState,
        )
          ? "completed"
          : this.issueState === "In Progress"
            ? "started"
            : "unstarted",
      },
      project: { name: `Lifecycle — ${this.project.slug}` },
      parent: null,
      attachments: {
        nodes: this.attachmentUrls.map((url) => ({ url })),
        pageInfo: {
          hasNextPage: this.attachmentHasNextPage,
          endCursor: this.attachmentHasNextPage ? "attachment-page-2" : null,
        },
      },
      labels: {
        nodes: this.issueLabelNames.map((name) => ({
          id: `label:${name}`,
          name,
        })),
      },
      relations: { nodes: [] },
      inverseRelations: { nodes: [] },
    };
  }

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
    if (query.includes("issues(")) this.issueQueries.push(query);
    if (query.includes("issues(") && query.includes("first: 25")) {
      const after = (variables.after as string | null | undefined) ?? null;
      this.issuePageCursors.push(after);
      if (this.splitIssueAcrossPages && after === null) {
        return {
          issues: {
            nodes: [],
            pageInfo: {
              hasNextPage: true,
              endCursor: this.omitNextIssueCursor ? null : "issue-page-2",
            },
          },
        } as T;
      }
      return {
        issues: {
          nodes: [this.issueNode()],
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
    if (query.includes("document(id: $id)")) {
      const title = (variables.id as string).replace(/^document:/, "");
      return {
        document: { content: this.documentContents.get(title) ?? "" },
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
    if (query.includes("projectMilestone(id: $id)")) {
      const name = (variables.id as string).replace(/^milestone:/, "");
      return {
        projectMilestone: {
          description: this.milestoneDescriptions.get(name) ?? "",
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
    if (query.includes("project(id: $id)")) {
      if (this.failProjectReadOnce) {
        this.failProjectReadOnce = false;
        throw new Error("SIMULATED_PROJECT_READ_TIMEOUT");
      }
      return {
        project: {
          summary: this.projectSummary,
          description: this.projectDescription,
          status: {
            id: `project-status:${this.projectStatus}`,
            name: this.projectStatus,
          },
        },
      } as T;
    }
    if (query.includes("issueUpdate") && variables.state) {
      this.issueStateMutationCalls += 1;
      this.issueState = (variables.state as string).replace(
        /^state:/,
        "",
      ) as IssueState;
      return { issueUpdate: { success: true } } as T;
    }
    if (query.includes("issueUpdate") && variables.labels) {
      const labels = variables.labels as string[];
      this.issueLabelNames = labels.map((id) => id.replace(/^label:/, ""));
      return { issueUpdate: { success: true } } as T;
    }
    if (query.includes("issue(id: $id)")) {
      this.freshIssueReadCalls += 1;
      if (this.freshStateOverrideOnce) {
        this.issueState = this.freshStateOverrideOnce;
        delete this.freshStateOverrideOnce;
      }
      return { issue: this.issueNode() } as T;
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
    ["tasks", "tasks body\n"],
    ["verification", "verification body\n"],
  ]);
  const documents: DocumentContract[] = await Promise.all(
    [...sourceByKind].map(async ([kind, content]) => ({
      kind: kind as DocumentContract["kind"],
      path: `docs/product-development/example/${
        ["plan", "tasks", "verification"].includes(kind)
          ? `implementation/${kind}.md`
          : `${kind}.md`
      }`,
      revision: "1",
      status: "approved",
      sha256: await sha256Text(content),
      byteLength: content.length,
      gitBlobOid: createHash("sha1")
        .update(`blob ${Buffer.byteLength(content)}\0`)
        .update(content)
        .digest("hex"),
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

function runtimeOptions(
  sourceByPath: ReadonlyMap<string, string>,
  overrides: LiveAuditOptions = {},
): LiveAuditOptions {
  return {
    loadRepositoryText: async (path) => {
      await Promise.resolve();
      const content = sourceByPath.get(path);
      if (content === undefined) throw new Error(`SOURCE_MISSING:${path}`);
      return content;
    },
    runtimeLifecycleTree: [...sourceByPath].map(([path, content]) => ({
      path,
      oid: createHash("sha1")
        .update(`blob ${Buffer.byteLength(content)}\0`)
        .update(content)
        .digest("hex"),
      byteLength: Buffer.byteLength(content),
    })),
    ...overrides,
  };
}

describe("live authority mirror repair", () => {
  it("aborts before Linear when any runtime lifecycle contract changed after compilation", async () => {
    const { client, desired, sourceByPath } = await fixture();
    desired.compileProvenanceCommit = "old-compile-commit";
    desired.authorityCommit = "new-runtime-commit";
    const changedRuntimeSources = new Map(sourceByPath);
    const resolveTaskProof = vi.fn();
    changedRuntimeSources.set(
      "docs/product-development/example/implementation/tasks.md",
      "changed tasks body\n",
    );

    await expect(
      auditLiveWorkspace(
        client as unknown as LinearClient,
        desired,
        true,
        runtimeOptions(changedRuntimeSources, { resolveTaskProof }),
      ),
    ).rejects.toThrow(
      "RUNTIME_DOCUMENT_CONTRACT_MISMATCH:project:example:docs/product-development/example/implementation/tasks.md",
    );

    expect(client.projectQueries).toEqual([]);
    expect(client.issueQueries).toEqual([]);
    expect(resolveTaskProof).not.toHaveBeenCalled();
    expect(client.projectSummary).toBe("stale summary");
    expect(client.issueState).toBe("Ready For Codex");
  });

  it("detects a same-length runtime byte change through Git blob identity", async () => {
    const { client, desired, sourceByPath } = await fixture();
    desired.compileProvenanceCommit = "old-compile-commit";
    desired.authorityCommit = "new-runtime-commit";
    const changedRuntimeSources = new Map(sourceByPath);
    changedRuntimeSources.set(
      "docs/product-development/example/research.md",
      "Research body\n",
    );
    expect(
      Buffer.byteLength(
        changedRuntimeSources.get(
          "docs/product-development/example/research.md",
        )!,
      ),
    ).toBe(
      Buffer.byteLength(
        sourceByPath.get("docs/product-development/example/research.md")!,
      ),
    );

    await expect(
      auditLiveWorkspace(
        client as unknown as LinearClient,
        desired,
        true,
        runtimeOptions(changedRuntimeSources),
      ),
    ).rejects.toThrow(
      "RUNTIME_DOCUMENT_CONTRACT_MISMATCH:project:example:docs/product-development/example/research.md",
    );
    expect(client.projectQueries).toEqual([]);
  });

  it("aborts before Linear when a pending unscheduled Project source changed after compilation", async () => {
    const { client, desired, sourceByPath } = await fixture();
    const admitted = desired.projects[0]!;
    const pendingDocuments = admitted.documents.map((document) => ({
      ...document,
      path: document.path.replace(
        "docs/product-development/example/",
        "docs/product-development/pending-example/",
      ),
    }));
    desired.projects = [
      ...desired.projects,
      {
        ...admitted,
        slug: "pending-example",
        canonicalKey: "project:pending-example",
        name: "Lifecycle — pending-example",
        folder: "docs/product-development/pending-example",
        documents: pendingDocuments,
        tasks: [],
        admission: "pending",
        admissionBlockers: ["Documentation review pending"],
      },
    ];
    desired.compileProvenanceCommit = "old-compile-commit";
    desired.authorityCommit = "new-runtime-commit";
    const pendingSources = new Map(sourceByPath);
    for (const document of pendingDocuments) {
      const admittedPath = document.path.replace(
        "docs/product-development/pending-example/",
        "docs/product-development/example/",
      );
      pendingSources.set(document.path, sourceByPath.get(admittedPath)!);
    }
    pendingSources.set(
      "docs/product-development/pending-example/implementation/tasks.md",
      "stale pending tasks body\n",
    );
    const resolveTaskProof = vi.fn();

    await expect(
      auditLiveWorkspace(
        client as unknown as LinearClient,
        desired,
        true,
        runtimeOptions(pendingSources, { resolveTaskProof }),
      ),
    ).rejects.toThrow(
      "RUNTIME_DOCUMENT_CONTRACT_MISMATCH:project:pending-example:docs/product-development/pending-example/implementation/tasks.md",
    );

    expect(client.projectQueries).toEqual([]);
    expect(client.issueQueries).toEqual([]);
    expect(resolveTaskProof).not.toHaveBeenCalled();
  });

  it("aborts before Linear when the event SHA contains a lifecycle folder absent from the manifest", async () => {
    const { client, desired, sourceByPath } = await fixture();
    desired.compileProvenanceCommit = "old-compile-commit";
    desired.authorityCommit = "new-runtime-commit";
    const resolveTaskProof = vi.fn();
    const runtimeLifecycleTree = [
      ...runtimeOptions(sourceByPath).runtimeLifecycleTree!,
      {
        path: "docs/product-development/new-current-initiative/research.md",
        oid: "1".repeat(40),
        byteLength: 1,
      },
    ];

    await expect(
      auditLiveWorkspace(
        client as unknown as LinearClient,
        desired,
        true,
        runtimeOptions(sourceByPath, {
          runtimeLifecycleTree,
          resolveTaskProof,
        }),
      ),
    ).rejects.toThrow("RUNTIME_LIFECYCLE_INVENTORY_MISMATCH");

    expect(client.projectQueries).toEqual([]);
    expect(client.issueQueries).toEqual([]);
    expect(resolveTaskProof).not.toHaveBeenCalled();
  });

  it("aborts before Linear when a manifest lifecycle path is missing from the event tree", async () => {
    const { client, desired, sourceByPath } = await fixture();
    desired.compileProvenanceCommit = "old-compile-commit";
    desired.authorityCommit = "new-runtime-commit";
    const options = runtimeOptions(sourceByPath);
    options.runtimeLifecycleTree = options.runtimeLifecycleTree!.filter(
      (entry) => !entry.path.endsWith("implementation/verification.md"),
    );

    await expect(
      auditLiveWorkspace(
        client as unknown as LinearClient,
        desired,
        true,
        options,
      ),
    ).rejects.toThrow("RUNTIME_LIFECYCLE_INVENTORY_MISMATCH");
    expect(client.projectQueries).toEqual([]);
  });

  it("aborts before Linear when the event tree repeats a lifecycle path", async () => {
    const { client, desired, sourceByPath } = await fixture();
    desired.compileProvenanceCommit = "old-compile-commit";
    desired.authorityCommit = "new-runtime-commit";
    const options = runtimeOptions(sourceByPath);
    options.runtimeLifecycleTree = [
      ...options.runtimeLifecycleTree!,
      { ...options.runtimeLifecycleTree![0]! },
    ];

    await expect(
      auditLiveWorkspace(
        client as unknown as LinearClient,
        desired,
        true,
        options,
      ),
    ).rejects.toThrow("RUNTIME_LIFECYCLE_INVENTORY_DUPLICATE_PATH");
    expect(client.projectQueries).toEqual([]);
  });

  it.each([
    {
      name: "bad blob oid",
      mutate: (entry: { oid: string; byteLength: number }) => {
        entry.oid = "f".repeat(40);
      },
    },
    {
      name: "bad byte length",
      mutate: (entry: { oid: string; byteLength: number }) => {
        entry.byteLength += 1;
      },
    },
  ])("fails closed before Linear on $name", async ({ mutate }) => {
    const { client, desired, sourceByPath } = await fixture();
    desired.compileProvenanceCommit = "old-compile-commit";
    desired.authorityCommit = "new-runtime-commit";
    const options = runtimeOptions(sourceByPath);
    const entry = options.runtimeLifecycleTree![0]!;
    mutate(entry);

    await expect(
      auditLiveWorkspace(
        client as unknown as LinearClient,
        desired,
        true,
        options,
      ),
    ).rejects.toThrow("RUNTIME_DOCUMENT_CONTRACT_MISMATCH");
    expect(client.projectQueries).toEqual([]);
    expect(client.issueQueries).toEqual([]);
  });

  it("uses tree evidence for all-project preflight without raw source subrequests", async () => {
    const { client, desired, sourceByPath } = await fixture();
    desired.compileProvenanceCommit = "old-compile-commit";
    desired.authorityCommit = "new-runtime-commit";
    const loadRepositoryText = vi.fn(() =>
      Promise.reject(new Error("RAW_SOURCE_MUST_NOT_BE_USED_FOR_PREFLIGHT")),
    );

    await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      false,
      runtimeOptions(sourceByPath, { loadRepositoryText }),
    );

    expect(loadRepositoryText).not.toHaveBeenCalled();
  });

  it("keeps the nested Project audit query below Linear's complexity ceiling", async () => {
    const { client, desired, sourceByPath } = await fixture();

    await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      false,
      runtimeOptions(sourceByPath),
    );

    expect(client.projectQueries).toHaveLength(1);
    expect(client.projectQueries[0]).toContain("projects(first: 10");
    expect(client.projectQueries[0]).toContain(
      "pageInfo { hasNextPage endCursor }",
    );
  });

  it("identifies the exact stale Project mirror fields in read-only audits", async () => {
    const { client, desired, sourceByPath } = await fixture();

    const result = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      false,
      runtimeOptions(sourceByPath),
    );

    const projectException = result.exceptions.find(
      (item) => item.canonicalKey === "project:example",
    );
    expect(projectException?.summary).toMatch(
      /^Lifecycle Project mirror is stale: summary, description\(.+\), status\(Building -> Grooming\)$/,
    );
  });

  it("collects lifecycle Projects across every bounded Project page", async () => {
    const { client, desired, sourceByPath } = await fixture();
    client.splitProjectAcrossPages = true;

    const result = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      false,
      runtimeOptions(sourceByPath),
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
    const { client, desired, sourceByPath } = await fixture();
    client.splitProjectAcrossPages = true;
    client.omitNextProjectCursor = true;

    await expect(
      auditLiveWorkspace(
        client as unknown as LinearClient,
        desired,
        false,
        runtimeOptions(sourceByPath),
      ),
    ).rejects.toThrow("LINEAR_PROJECT_PAGE_CURSOR_MISSING");
  });

  it("keeps the nested Issue audit query below Linear's complexity ceiling", async () => {
    const { client, desired, sourceByPath } = await fixture();

    await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      false,
      runtimeOptions(sourceByPath),
    );

    expect(client.issueQueries).toHaveLength(1);
    expect(client.issueQueries[0]).toMatch(/issues\(\s*first:\s*25/);
    expect(client.issueQueries[0]).toMatch(
      /filter:\s*\{\s*project:\s*\{\s*name:\s*\{\s*startsWith:\s*"Lifecycle — "\s*\}\s*\}\s*\}/,
    );
  });

  it("collects lifecycle Issues across every bounded Issue page", async () => {
    const { client, desired, sourceByPath } = await fixture();
    client.splitIssueAcrossPages = true;

    const result = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      false,
      runtimeOptions(sourceByPath),
    );

    expect(client.issuePageCursors).toEqual([null, "issue-page-2"]);
    expect(result.mappings).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          canonicalKey: "example:T1",
          linearId: "issue-id",
        }),
      ]),
    );
  });

  it("fails closed when Linear advertises another Issue page without a cursor", async () => {
    const { client, desired, sourceByPath } = await fixture();
    client.splitIssueAcrossPages = true;
    client.omitNextIssueCursor = true;

    await expect(
      auditLiveWorkspace(
        client as unknown as LinearClient,
        desired,
        false,
        runtimeOptions(sourceByPath),
      ),
    ).rejects.toThrow("LINEAR_ISSUE_PAGE_CURSOR_MISSING");
  });

  it("fails closed when an Issue attachment connection is incomplete", async () => {
    const { client, desired, sourceByPath } = await fixture();
    client.attachmentHasNextPage = true;

    await expect(
      auditLiveWorkspace(
        client as unknown as LinearClient,
        desired,
        false,
        runtimeOptions(sourceByPath),
      ),
    ).rejects.toThrow("LINEAR_ATTACHMENT_PAGE_INCOMPLETE:AMB-1");
  });

  it("aborts before the first live mutation when runtime main advances", async () => {
    const { client, desired, sourceByPath } = await fixture();
    desired.compileProvenanceCommit = "old-compile-commit";
    const verifyRuntimeAuthority = async () => {
      await Promise.resolve();
      return false;
    };

    await expect(
      auditLiveWorkspace(
        client as unknown as LinearClient,
        desired,
        true,
        runtimeOptions(sourceByPath, { verifyRuntimeAuthority }),
      ),
    ).rejects.toThrow("RUNTIME_AUTHORITY_SUPERSEDED");

    expect(client.projectSummary).toBe("stale summary");
    expect(client.projectStatus).toBe("Building");
    expect(client.issueState).toBe("Ready For Codex");
  });

  it("safely rebinds stale provenance when every runtime contract is unchanged", async () => {
    const { client, desired, sourceByPath } = await fixture();
    desired.compileProvenanceCommit = "old-compile-commit";
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
      runtimeOptions(sourceByPath, {
        verifyRuntimeAuthority: async () => {
          await Promise.resolve();
          return true;
        },
      }),
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
    expect(client.projectDescription).toContain(
      "Repository authority: [https://github.com/agentdevan/ambitions/tree/new-commit/docs/product-development/example](<https://github.com/agentdevan/ambitions/tree/new-commit/docs/product-development/example>)",
    );
    expect(client.projectDescription).not.toContain(
      "Repository authority: https://github.com/agentdevan/ambitions/tree/new-commit/docs/product-development/example",
    );
    expect(client.projectDescription).toContain(
      "* Repository commit: new-commit",
    );
    expect(client.projectDescription).not.toMatch(/^- /m);
    expect(client.projectStatus).toBe("Grooming");
    expect(
      client.milestoneDescriptions.get("M4 — Implementation Complete"),
    ).toContain("0 of 1 canonical Plan Tasks are terminal");

    client.freshIssueReadCalls = 0;
    const idempotent = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      true,
      runtimeOptions(sourceByPath, {
        verifyRuntimeAuthority: async () => {
          await Promise.resolve();
          return true;
        },
      }),
    );
    expect(idempotent.exceptions).toEqual([]);
    expect(idempotent.repairs).toBe(0);
    expect(client.freshIssueReadCalls).toBe(0);
  });

  it("stops at the repair budget before another authority check or durable intent", async () => {
    const { client, desired, sourceByPath } = await fixture();
    desired.compileProvenanceCommit = "old-compile-commit";
    for (const [title, content] of client.documentContents)
      client.documentContents.set(
        title,
        content.replace(
          "Repository commit: old-commit",
          "Repository commit: new-commit",
        ),
      );
    const authorityChecks = vi.fn().mockResolvedValue(true);
    const persistedIntents: string[] = [];
    let mutationClaims = 0;

    await expect(
      auditLiveWorkspace(
        client as unknown as LinearClient,
        desired,
        true,
        runtimeOptions(sourceByPath, {
          beforeMutation: async () => {
            await Promise.resolve();
            if (mutationClaims >= 3) throw new RepairBudgetExhausted(3);
            mutationClaims += 1;
          },
          verifyRuntimeAuthority: authorityChecks,
          onMutationIntent: async (intent) => {
            await Promise.resolve();
            persistedIntents.push(intent.operation);
          },
        }),
      ),
    ).rejects.toBeInstanceOf(RepairBudgetExhausted);

    expect(authorityChecks).toHaveBeenCalledTimes(3);
    expect(persistedIntents).toHaveLength(3);
    expect(mutationClaims).toBe(3);
  });

  it("recovers a pending receipt after a successful write and preserves it across a later audit failure", async () => {
    const { client, desired, sourceByPath } = await fixture();
    const durable = new Map<
      string,
      { status: "pending" | "verified" | "failed"; reconciled: boolean }
    >();
    const keyFor = (value: {
      canonicalKey: string;
      operation: string;
      desiredHash: string;
    }) => `${value.canonicalKey}:${value.operation}:${value.desiredHash}`;
    client.failProjectReadOnce = true;

    await expect(
      auditLiveWorkspace(
        client as unknown as LinearClient,
        desired,
        true,
        runtimeOptions(sourceByPath, {
          onMutationIntent: async (intent) => {
            await Promise.resolve();
            durable.set(keyFor(intent), {
              status: "pending",
              reconciled: false,
            });
          },
          onMutationResult: async (result) => {
            await Promise.resolve();
            if (result.resultHash)
              durable.set(keyFor(result), {
                status: result.verified ? "verified" : "failed",
                reconciled: false,
              });
          },
        }),
      ),
    ).rejects.toThrow("SIMULATED_PROJECT_READ_TIMEOUT");

    expect(client.projectSummary).toContain("G01 • Grooming");
    expect([...durable.values()]).toEqual([
      { status: "pending", reconciled: false },
    ]);

    let failedLaterMutation = false;
    await expect(
      auditLiveWorkspace(
        client as unknown as LinearClient,
        desired,
        true,
        runtimeOptions(sourceByPath, {
          onMutationCheckpoint: async (checkpoint) => {
            await Promise.resolve();
            const key = keyFor(checkpoint);
            const existing = durable.get(key);
            if (existing?.status === "pending")
              durable.set(key, { status: "verified", reconciled: true });
          },
          onMutationIntent: async (intent) => {
            await Promise.resolve();
            if (intent.operation === "project-milestone-update") {
              failedLaterMutation = true;
              throw new Error("SIMULATED_LATER_AUDIT_FAILURE");
            }
            durable.set(keyFor(intent), {
              status: "pending",
              reconciled: false,
            });
          },
        }),
      ),
    ).rejects.toThrow("SIMULATED_LATER_AUDIT_FAILURE");

    expect(failedLaterMutation).toBe(true);
    expect(
      [...durable.values()].some(
        (receipt) => receipt.status === "verified" && receipt.reconciled,
      ),
    ).toBe(true);
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
      runtimeOptions(sourceByPath),
    );

    expect(repaired.exceptions).toEqual([]);
    expect(repaired.repairs).toBe(14);
    expect(client.documentContents.get("30 — Design")).toContain("design body");
    expect(client.documentContents.get("30 — Design")).not.toContain(
      "stale design body",
    );
  });

  it("reports failed Project and milestone post-write verification", async () => {
    const { client, desired, sourceByPath } = await fixture();
    client.failProjectVerification = true;
    client.failMilestoneVerification = true;

    const repaired = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      true,
      runtimeOptions(sourceByPath),
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

  it("repairs premature Done before exact proof, then completes on green-main evidence", async () => {
    const { client, desired, sourceByPath } = await fixture();
    client.issueState = "Done";
    client.attachmentUrls = ["https://github.com/agentdevan/ambitions/pull/81"];

    const beforeProof = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      true,
      runtimeOptions(sourceByPath, {
        resolveTaskProof: async () => {
          await Promise.resolve();
          return {
            authorityCommit: desired.authorityCommit,
            mergedToMain: true,
            proofPassed: false,
            requiredProofFailed: false,
          };
        },
      }),
    );

    expect(client.issueState).toBe("In Review");
    expect(client.projectSummary).toContain("0 verified on current main");
    expect(beforeProof.proofReceipts).toEqual([]);

    client.freshIssueReadCalls = 0;
    const afterProof = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      true,
      runtimeOptions(sourceByPath, {
        resolveTaskProof: async () => {
          await Promise.resolve();
          return {
            authorityCommit: desired.authorityCommit,
            mergedToMain: true,
            proofPassed: true,
            requiredProofFailed: false,
            pullRequestUrl: "https://github.com/agentdevan/ambitions/pull/81",
            mergeCommitSha: desired.authorityCommit,
          };
        },
      }),
    );

    expect(client.issueState).toBe("Done");
    expect(client.freshIssueReadCalls).toBe(2);
    expect(client.projectSummary).toContain("1 verified on current main");
    expect(afterProof.proofReceipts).toHaveLength(1);
  });

  it("preserves a terminal disposition that arrives immediately before state mutation and refreshes progress", async () => {
    const { client, desired, sourceByPath } = await fixture();
    client.issueState = "Ready For Codex";
    client.freshStateOverrideOnce = "Canceled";
    client.attachmentUrls = ["https://github.com/agentdevan/ambitions/pull/81"];

    const result = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      true,
      runtimeOptions(sourceByPath, {
        resolveTaskProof: async () => {
          await Promise.resolve();
          return {
            source: "github",
            authorityCommit: desired.authorityCommit,
            mergedToMain: true,
            proofPassed: true,
            requiredProofFailed: false,
            issueIdentifier: "AMB-1",
            pullRequestUrl: "https://github.com/agentdevan/ambitions/pull/81",
            mergeCommitSha: desired.authorityCommit,
          };
        },
      }),
    );

    expect(client.issueState).toBe("Canceled");
    expect(client.projectSummary).toContain("0 verified on current main");
    expect(result.proofReceipts).toEqual([]);
    expect(
      result.repairReceipts.some(
        (receipt) => receipt.operation === "issue-state-update",
      ),
    ).toBe(false);
  });

  it("re-reads terminal state after pending receipt persistence and refuses the state write", async () => {
    const { client, desired, sourceByPath } = await fixture();
    client.issueState = "Ready For Codex";

    const result = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      true,
      runtimeOptions(sourceByPath, {
        resolveTaskProof: async () => {
          await Promise.resolve();
          return {
            source: "github",
            authorityCommit: desired.authorityCommit,
            mergedToMain: true,
            proofPassed: true,
            requiredProofFailed: false,
            issueIdentifier: "AMB-1",
            pullRequestUrl: "https://github.com/agentdevan/ambitions/pull/81",
            mergeCommitSha: desired.authorityCommit,
          };
        },
        onMutationIntent: async (intent) => {
          await Promise.resolve();
          if (intent.operation === "issue-state-update")
            client.issueState = "Canceled";
        },
      }),
    );

    expect(client.issueState).toBe("Canceled");
    expect(client.issueStateMutationCalls).toBe(0);
    expect(client.projectSummary).toContain("0 verified on current main");
    expect(result.proofReceipts).toEqual([]);
  });

  it.each(["Canceled", "Duplicate", "Won’t Do"] as const)(
    "does not count or receipt terminal %s work as verified completion",
    async (terminalState) => {
      const { client, desired, sourceByPath } = await fixture();
      client.issueState = terminalState;
      client.attachmentUrls = [
        "https://github.com/agentdevan/ambitions/pull/81",
      ];

      const resolveTaskProof = vi.fn();
      const result = await auditLiveWorkspace(
        client as unknown as LinearClient,
        desired,
        true,
        runtimeOptions(sourceByPath, {
          resolveTaskProof,
        }),
      );

      expect(client.issueState).toBe(terminalState);
      expect(client.projectSummary).toContain("0 verified on current main");
      expect(result.proofReceipts).toEqual([]);
      expect(resolveTaskProof).not.toHaveBeenCalled();
    },
  );

  it("does not let stale Linear Initiative ordering rewrite repository authority", async () => {
    const { client, desired, sourceByPath } = await fixture();
    client.initiativeNames = ["Stale Initiative", "Other Initiative"];

    const repaired = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      true,
      runtimeOptions(sourceByPath),
    );

    expect(repaired.exceptions).toEqual([]);
    expect(client.projectDescription).toContain(
      "Linear Initiative relationship is authoritative for portfolio ownership",
    );
    expect(client.projectDescription).not.toContain("Stale Initiative");
  });

  it("audits a manifest-declared primary Initiative independently", async () => {
    const { client, desired, sourceByPath } = await fixture();
    const project = desired.projects[0]!;
    project.primaryInitiative = "Canonical Initiative";
    client.initiativeNames = ["Stale Initiative", "Canonical Initiative"];

    const repaired = await auditLiveWorkspace(
      client as unknown as LinearClient,
      desired,
      true,
      runtimeOptions(sourceByPath),
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

  it("counts verified work from exact-authority proof rather than Done state", () => {
    const { project, group } = twoTaskFixture();
    const authorityCommit = "a".repeat(40);
    const states = new Map<string, IssueState>([
      ["example:T1", "Done"],
      ["example:T2", "Done"],
    ]);
    const evidence = new Map([
      [
        "example:T1",
        {
          authorityCommit,
          mergedToMain: true,
          proofPassed: true,
          requiredProofFailed: false,
        },
      ],
      [
        "example:T2",
        {
          authorityCommit: "b".repeat(40),
          mergedToMain: true,
          proofPassed: true,
          requiredProofFailed: false,
        },
      ],
    ]);

    const progress = desiredProjectMirrorProgress(
      project,
      group,
      [group],
      states,
      evidence,
      authorityCommit,
    );

    expect(progress.terminalTasks).toBe(2);
    expect(progress.verifiedTasks).toBe(1);
  });
});

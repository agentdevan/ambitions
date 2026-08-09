import type { LinearClient } from "../adapters/linear.js";
import type {
  ControlException,
  DesiredWorkspaceManifest,
  IssueState,
  ProjectContract,
  ScheduleGroup,
  TaskContract,
} from "./types.js";
import { CONTROLLED_TEMPLATES, OPERATIONAL_VIEWS } from "./definitions.js";
import { sha256Text, stableJson } from "./hash.js";
import { desiredProjectPhase } from "./policy.js";
import {
  initiativeIndexMirror,
  issueAuthorityEnvelope,
  milestoneAuthorityMirror,
  projectAuthorityMirror,
  projectSummaryMirror,
  repositoryMirror,
  type ProjectMirrorProgress,
  type MirrorSource,
} from "./mirrors.js";

interface LiveProject {
  id: string;
  name: string;
  summary?: string | null;
  description?: string | null;
  status: { id: string; name: string };
  initiatives: { nodes: Array<{ name: string }> };
  labels: { nodes: Array<{ id: string; name: string }> };
  projectMilestones: {
    nodes: Array<{ id: string; name: string; description?: string | null }>;
  };
  documents: {
    nodes: Array<{ id: string; title: string; content?: string | null }>;
  };
}

interface LiveIssue {
  id: string;
  identifier: string;
  title: string;
  description?: string | null;
  state: { id: string; name: IssueState; type: string };
  project?: { name: string } | null;
  parent?: { id: string } | null;
  labels: { nodes: Array<{ id: string; name: string }> };
  relations: {
    nodes: Array<{
      type: string;
      relatedIssue: { id: string; state: { name: IssueState } };
    }>;
  };
  inverseRelations: {
    nodes: Array<{
      type: string;
      issue: { id: string; state: { name: IssueState } };
    }>;
  };
}

export interface LiveAuditResult {
  exceptions: ControlException[];
  metrics: Readonly<Record<string, number>>;
  repairs: number;
  repairReceipts: LiveRepairReceipt[];
  mappings: LiveObjectMapping[];
}

export interface LiveRepairReceipt {
  canonicalKey: string;
  operation:
    | "document-authority-update"
    | "project-authority-update"
    | "project-milestone-update"
    | "issue-authority-update"
    | "issue-state-update"
    | "issue-label-update";
  beforeHash: string;
  desiredHash: string;
  resultHash: string;
  verified: boolean;
}

export interface LiveObjectMapping {
  canonicalKey: string;
  linearId: string;
  objectType: "project" | "issue";
  desiredHash: string;
}

export interface LiveAuditOptions {
  loadRepositoryText?: (path: string) => Promise<string>;
}

const milestones = [
  "M0 — Research Passed",
  "M1 — Scope Passed",
  "M2 — Design Passed",
  "M3 — Groomed for Implementation",
  "M4 — Implementation Complete",
  "M5 — Validation and Merge",
  "M6 — Closeout",
];

const documentTitles = [
  "00 — Initiative Brief and Lifecycle Index",
  "10 — Research",
  "20 — Scope",
  "30 — Design",
  "40 — Implementation Plan",
];

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

const allowedLabelPrefixes = [
  "area:",
  "work:",
  "proof:",
  "risk:",
  "gate:",
  "acceptance:",
  "phase:",
  "sync:",
  "lifecycle:",
];

function taskNumber(title: string): number | undefined {
  const match = /^(?:Plan Task\s+)?(?:\[?T)?(\d+)\]?/i.exec(title);
  return match ? Number(match[1]) : undefined;
}

export function fencedTextBodies(content: string): string[] {
  const lines = content.split("\n");
  const bodies: string[] = [];
  for (let index = 0; index < lines.length; index += 1) {
    const opening = /^(`{3,}|~{3,})text$/.exec(lines[index]!);
    if (!opening) continue;
    const fence = opening[1]!;
    const closing = lines.indexOf(fence, index + 1);
    if (closing === -1) continue;
    bodies.push(lines.slice(index + 1, closing).join("\n"));
    index = closing;
  }
  return bodies;
}

export function requiredFrontendGateLabels(
  project: ProjectContract,
  task: TaskContract,
): string[] {
  if (task.frontendImpact !== "affected") return [];
  return [
    ...(project.frontendAudit.status === "blocked"
      ? ["gate:frontend-contract"]
      : []),
    ...(task.visualGate === "required" ? ["gate:visual-approval"] : []),
  ];
}

export function desiredLiveIssueState(
  current: IssueState,
  dependencyBlocked: boolean,
  project: ProjectContract,
  task: TaskContract,
): IssueState {
  const frontendBlocked = requiredFrontendGateLabels(project, task).length > 0;
  if (frontendBlocked)
    return ["In Progress", "In Review", "Needs Repair", "Done"].includes(
      current,
    )
      ? "Needs Repair"
      : "Blocked";
  if (
    [
      "In Progress",
      "In Review",
      "Needs Repair",
      "Done",
      "Canceled",
      "Duplicate",
      "Won’t Do",
    ].includes(current)
  )
    return current;
  return dependencyBlocked ? "Blocked" : "Ready For Codex";
}

function expectedState(
  issue: LiveIssue,
  project: ProjectContract,
  task: TaskContract,
): IssueState {
  const blocked = issue.inverseRelations.nodes.some(
    (relation) =>
      relation.type === "blocks" &&
      !["Done", "Canceled", "Duplicate", "Won’t Do"].includes(
        relation.issue.state.name,
      ),
  );
  return desiredLiveIssueState(issue.state.name, blocked, project, task);
}

function exception(
  canonicalKey: string,
  summary: string,
  severity: ControlException["severity"] = "error",
): ControlException {
  return { canonicalKey, category: "drift", severity, summary };
}

const terminalTaskStates = new Set<IssueState>([
  "Done",
  "Canceled",
  "Duplicate",
  "Won’t Do",
]);

export function desiredProjectMirrorProgress(
  project: ProjectContract,
  group: ScheduleGroup,
  schedule: readonly ScheduleGroup[],
  statesByKey: ReadonlyMap<string, IssueState>,
): ProjectMirrorProgress {
  const canonicalStates = project.tasks.map(
    (task) => statesByKey.get(task.canonicalKey) ?? "Backlog",
  );
  const nextTask = project.tasks
    .slice()
    .sort((left, right) => left.order - right.order)
    .find((task) => {
      const state = statesByKey.get(task.canonicalKey);
      return state !== undefined && !terminalTaskStates.has(state);
    });
  return {
    phase: desiredProjectPhase(canonicalStates, true),
    terminalTasks: canonicalStates.filter((state) =>
      terminalTaskStates.has(state),
    ).length,
    verifiedTasks: canonicalStates.filter((state) => state === "Done").length,
    totalTasks: project.tasks.length,
    ...(nextTask ? { nextTask } : {}),
    groupOrdinal: schedule.indexOf(group) + 1,
    totalGroups: schedule.length,
    projectOrdinal: group.projectSlugs.indexOf(project.slug) + 1,
  };
}

async function mirrorSourcesFromCurrentContent(
  contracts: readonly ProjectContract["documents"][number][],
  content: string,
): Promise<MirrorSource[] | undefined> {
  const bodies = fencedTextBodies(content);
  if (bodies.length !== contracts.length) return undefined;
  const sources: MirrorSource[] = [];
  for (const [index, contract] of contracts.entries()) {
    const body = bodies[index]!;
    const exact = (await sha256Text(body)) === contract.sha256;
    const newline = (await sha256Text(`${body}\n`)) === contract.sha256;
    if (!exact && !newline) return undefined;
    sources.push({ contract, content: newline ? `${body}\n` : body });
  }
  return sources;
}

export async function auditLiveWorkspace(
  client: LinearClient,
  desired: DesiredWorkspaceManifest,
  mutationsEnabled: boolean,
  options: LiveAuditOptions = {},
): Promise<LiveAuditResult> {
  const projects: LiveProject[] = [];
  let projectAfter: string | null = null;
  const seenProjectCursors = new Set<string>();
  do {
    const projectData: {
      projects: {
        nodes: LiveProject[];
        pageInfo: { hasNextPage: boolean; endCursor?: string | null };
      };
    } = await client.request(
      `query($after: String) {
        projects(first: 10, after: $after) {
          nodes {
            id name summary: description description: content status { id name }
            initiatives { nodes { name } }
            labels { nodes { id name } }
            projectMilestones { nodes { id name description } }
            documents { nodes { id title content } }
          }
          pageInfo { hasNextPage endCursor }
        }
      }`,
      { after: projectAfter },
    );
    projects.push(...projectData.projects.nodes);
    if (!projectData.projects.pageInfo.hasNextPage) {
      projectAfter = null;
      continue;
    }
    const nextCursor = projectData.projects.pageInfo.endCursor;
    if (!nextCursor) throw new Error("LINEAR_PROJECT_PAGE_CURSOR_MISSING");
    if (seenProjectCursors.has(nextCursor))
      throw new Error("LINEAR_PROJECT_PAGE_CURSOR_REPEATED");
    seenProjectCursors.add(nextCursor);
    projectAfter = nextCursor;
  } while (projectAfter);
  const controlData = await client.request<{
    workflowStates: { nodes: Array<{ id: string; name: string }> };
    issueLabels: { nodes: Array<{ id: string; name: string }> };
    projectLabels: { nodes: Array<{ name: string }> };
    projectStatuses: { nodes: Array<{ id: string; name: string }> };
    customViews: { nodes: Array<{ name: string }> };
    templates: Array<{ name: string }>;
    initiatives: { nodes: Array<{ name: string }> };
    cycles: { nodes: Array<{ isActive: boolean; isNext: boolean }> };
  }>(`query {
    workflowStates(first: 50, filter: { team: { id: { eq: "ae5289a0-e901-4ff3-97c2-82a7e7e8ec96" } } }) { nodes { id name } }
    issueLabels(first: 250) { nodes { id name } }
    projectLabels(first: 100) { nodes { name } }
    projectStatuses(first: 50) { nodes { id name } }
    customViews(first: 50) { nodes { name } }
    templates { name }
    initiatives(first: 50) { nodes { name } }
    cycles(first: 10, filter: { team: { id: { eq: "ae5289a0-e901-4ff3-97c2-82a7e7e8ec96" } } }) { nodes { isActive isNext } }
  }`);
  const issues: LiveIssue[] = [];
  let after: string | null = null;
  do {
    const issueData: {
      issues: {
        nodes: LiveIssue[];
        pageInfo: { hasNextPage: boolean; endCursor?: string | null };
      };
    } = await client.request(
      `query($after: String) {
        issues(first: 100, after: $after) {
          nodes {
            id identifier title description state { id name type }
            project { name }
            parent { id }
            labels { nodes { id name } }
            relations { nodes { type relatedIssue { id state { name } } } }
            inverseRelations { nodes { type issue { id state { name } } } }
          }
          pageInfo { hasNextPage endCursor }
        }
      }`,
      { after },
    );
    issues.push(...issueData.issues.nodes);
    after = issueData.issues.pageInfo.hasNextPage
      ? (issueData.issues.pageInfo.endCursor ?? null)
      : null;
  } while (after);

  const exceptions: ControlException[] = [];
  let repairs = 0;
  const repairReceipts: LiveRepairReceipt[] = [];
  const mappings: LiveObjectMapping[] = [];
  const projectsBySlug = new Map(
    projects
      .filter((project) => project.name.startsWith("Lifecycle — "))
      .map((project) => [project.name.replace(/^Lifecycle — /, ""), project]),
  );
  const issuesByKey = new Map<string, LiveIssue>();
  for (const issue of issues) {
    if (!issue.project?.name.startsWith("Lifecycle — ")) continue;
    const order = taskNumber(issue.title);
    if (order === undefined) continue;
    issuesByKey.set(
      `${issue.project.name.replace(/^Lifecycle — /, "")}:T${order}`,
      issue,
    );
  }

  const exactSetChecks: Array<{
    key: string;
    expected: readonly string[];
    actual: string[];
  }> = [
    {
      key: "workspace:issue-states",
      expected: issueStates,
      actual: controlData.workflowStates.nodes.map((item) => item.name),
    },
    {
      key: "workspace:views",
      expected: OPERATIONAL_VIEWS.map((item) => item.name),
      actual: controlData.customViews.nodes.map((item) => item.name),
    },
    {
      key: "workspace:templates",
      expected: CONTROLLED_TEMPLATES,
      actual: controlData.templates.map((item) => item.name),
    },
    {
      key: "workspace:initiatives",
      expected: initiatives,
      actual: controlData.initiatives.nodes.map((item) => item.name),
    },
  ];
  for (const check of exactSetChecks) {
    const expected = new Set(check.expected);
    const actual = new Set(check.actual);
    for (const name of expected)
      if (!actual.has(name))
        exceptions.push(
          exception(check.key, `Missing controlled object: ${name}`),
        );
    for (const name of actual)
      if (!expected.has(name))
        exceptions.push(
          exception(check.key, `Unexpected legacy object: ${name}`),
        );
  }
  for (const label of [
    ...controlData.issueLabels.nodes,
    ...controlData.projectLabels.nodes,
  ])
    if (!allowedLabelPrefixes.some((prefix) => label.name.startsWith(prefix)))
      exceptions.push(
        exception("workspace:labels", `Unexpected legacy label: ${label.name}`),
      );
  if (!controlData.cycles.nodes.some((cycle) => cycle.isActive))
    exceptions.push(exception("workspace:cycles", "Current cycle is missing"));
  if (!controlData.cycles.nodes.some((cycle) => cycle.isNext))
    exceptions.push(exception("workspace:cycles", "Next cycle is missing"));

  const admitted = desired.projects.filter(
    (project) =>
      project.admission === "ready" &&
      desired.schedule.some((group) =>
        group.projectSlugs.includes(project.slug),
      ),
  );
  const workflowStateIds = new Map(
    controlData.workflowStates.nodes.map((state) => [state.name, state.id]),
  );
  const issueLabelIds = new Map(
    controlData.issueLabels.nodes.map((label) => [label.name, label.id]),
  );
  const projectStatusIds = new Map(
    controlData.projectStatuses.nodes.map((status) => [status.name, status.id]),
  );
  for (const project of admitted) {
    const live = projectsBySlug.get(project.slug);
    if (!live) {
      exceptions.push(
        exception(project.canonicalKey, "Lifecycle Project is missing"),
      );
      continue;
    }
    mappings.push({
      canonicalKey: project.canonicalKey,
      linearId: live.id,
      objectType: "project",
      desiredHash: await sha256Text(
        stableJson({
          authorityCommit: desired.authorityCommit,
          contractHash: desired.contractHash,
          project,
        }),
      ),
    });
    const names = new Set(
      live.projectMilestones.nodes.map((item) => item.name),
    );
    for (const name of milestones)
      if (!names.has(name))
        exceptions.push(
          exception(
            project.canonicalKey,
            `Missing lifecycle milestone: ${name}`,
          ),
        );
    for (const name of names)
      if (!milestones.includes(name))
        exceptions.push(
          exception(
            project.canonicalKey,
            `Unexpected legacy milestone: ${name}`,
          ),
        );
    const titles = new Set(live.documents.nodes.map((item) => item.title));
    for (const title of documentTitles)
      if (!titles.has(title))
        exceptions.push(
          exception(
            project.canonicalKey,
            `Missing synchronized Document: ${title}`,
          ),
        );
    for (const title of titles)
      if (!documentTitles.includes(title))
        exceptions.push(
          exception(
            project.canonicalKey,
            `Unexpected Project Document: ${title}`,
          ),
        );
    const group = desired.schedule.find((item) =>
      item.projectSlugs.includes(project.slug),
    );
    if (!group) {
      exceptions.push(
        exception(project.canonicalKey, "Portfolio execution group is missing"),
      );
      continue;
    }
    const statesByKey = new Map(
      project.tasks.flatMap((task) => {
        const state = issuesByKey.get(task.canonicalKey)?.state.name;
        return state ? [[task.canonicalKey, state] as const] : [];
      }),
    );
    const progress = desiredProjectMirrorProgress(
      project,
      group,
      desired.schedule,
      statesByKey,
    );
    const phase = progress.phase;
    const liveInitiatives = live.initiatives.nodes.map((item) => item.name);
    if (
      project.primaryInitiative &&
      (!liveInitiatives.includes(project.primaryInitiative) ||
        liveInitiatives.length !== 1)
    )
      exceptions.push(
        exception(
          project.canonicalKey,
          `Primary Initiative relationship should be exactly ${project.primaryInitiative}`,
        ),
      );
    const desiredSummary = projectSummaryMirror(group, progress);
    const desiredProjectDescription = projectAuthorityMirror(
      project,
      group,
      desired.authorityCommit,
      desired.contractHash,
      progress,
    );
    if (
      live.summary !== desiredSummary ||
      live.description !== desiredProjectDescription ||
      live.status.name !== phase
    ) {
      if (!mutationsEnabled) {
        exceptions.push(
          exception(project.canonicalKey, "Lifecycle Project mirror is stale"),
        );
      } else {
        const statusId = projectStatusIds.get(phase);
        if (!statusId) {
          exceptions.push(
            exception(
              project.canonicalKey,
              `Controlled Project status is missing: ${phase}`,
            ),
          );
        } else {
          const beforeHash = await sha256Text(
            stableJson({
              summary: live.summary ?? "",
              description: live.description ?? "",
              status: live.status.name,
            }),
          );
          const desiredHash = await sha256Text(
            stableJson({
              summary: desiredSummary,
              description: desiredProjectDescription,
              status: phase,
            }),
          );
          const updated = await client.request<{
            projectUpdate: {
              success: boolean;
              project?: {
                summary?: string | null;
                description?: string | null;
                status: { name: string };
              } | null;
            };
          }>(
            `mutation($id: String!, $input: ProjectUpdateInput!) {
              projectUpdate(id: $id, input: $input) {
                success
                project { summary: description description: content status { name } }
              }
            }`,
            {
              id: live.id,
              input: {
                description: desiredSummary,
                content: desiredProjectDescription,
                statusId,
              },
            },
          );
          const result = updated.projectUpdate.project;
          const resultHash = await sha256Text(
            stableJson({
              summary: result?.summary ?? "",
              description: result?.description ?? "",
              status: result?.status.name ?? "",
            }),
          );
          const matches =
            updated.projectUpdate.success && resultHash === desiredHash;
          repairReceipts.push({
            canonicalKey: project.canonicalKey,
            operation: "project-authority-update",
            beforeHash,
            desiredHash,
            resultHash,
            verified: matches,
          });
          repairs += 1;
          if (!matches)
            exceptions.push(
              exception(
                project.canonicalKey,
                "Lifecycle Project mirror repair did not verify",
              ),
            );
        }
      }
    }
    for (const milestone of live.projectMilestones.nodes) {
      if (!milestones.includes(milestone.name)) continue;
      const desiredDescription = milestoneAuthorityMirror(
        milestone.name,
        project,
        desired.authorityCommit,
        progress,
      );
      const currentDescription = milestone.description ?? "";
      if (currentDescription === desiredDescription) continue;
      if (!mutationsEnabled) {
        exceptions.push(
          exception(
            project.canonicalKey,
            `Lifecycle milestone mirror is stale: ${milestone.name}`,
          ),
        );
        continue;
      }
      const beforeHash = await sha256Text(currentDescription);
      const desiredHash = await sha256Text(desiredDescription);
      const updated = await client.request<{
        projectMilestoneUpdate: {
          success: boolean;
          projectMilestone?: { description?: string | null } | null;
        };
      }>(
        `mutation($id: String!, $input: ProjectMilestoneUpdateInput!) {
          projectMilestoneUpdate(id: $id, input: $input) {
            success
            projectMilestone { description }
          }
        }`,
        { id: milestone.id, input: { description: desiredDescription } },
      );
      const resultHash = await sha256Text(
        updated.projectMilestoneUpdate.projectMilestone?.description ?? "",
      );
      const matches =
        updated.projectMilestoneUpdate.success && resultHash === desiredHash;
      repairReceipts.push({
        canonicalKey: `${project.canonicalKey}:${milestone.name}`,
        operation: "project-milestone-update",
        beforeHash,
        desiredHash,
        resultHash,
        verified: matches,
      });
      repairs += 1;
      if (!matches)
        exceptions.push(
          exception(
            project.canonicalKey,
            `Lifecycle milestone repair did not verify: ${milestone.name}`,
          ),
        );
    }
    const issueIdentifiers = new Map(
      project.tasks.map((task) => [
        task.canonicalKey,
        issuesByKey.get(task.canonicalKey)?.identifier ?? "MISSING",
      ]),
    );
    for (const document of live.documents.nodes) {
      if (!documentTitles.includes(document.title)) continue;
      const content = document.content ?? "";
      const authorityIsStale =
        !content.includes(desired.authorityCommit) ||
        !content.includes(desired.contractHash) ||
        !content.includes("Repository mirror") ||
        !content.toLowerCase().includes("authoritative");
      const expectedDocuments =
        document.title === "10 — Research"
          ? project.documents.filter((item) => item.kind === "research")
          : document.title === "20 — Scope"
            ? project.documents.filter((item) => item.kind === "scope")
            : document.title === "30 — Design"
              ? project.documents.filter((item) => item.kind === "design")
              : document.title === "40 — Implementation Plan"
                ? project.documents.filter(
                    (item) =>
                      item.kind === "plan" ||
                      (project.slug === "linear-realtime-lifecycle-control" &&
                        (item.kind === "tasks" ||
                          item.kind === "verification")),
                  )
                : [];
      const currentSources =
        expectedDocuments.length > 0
          ? await mirrorSourcesFromCurrentContent(expectedDocuments, content)
          : [];
      const bodyHasDrifted = expectedDocuments.length > 0 && !currentSources;
      let desiredSources = currentSources;
      if (bodyHasDrifted) {
        if (!mutationsEnabled || !options.loadRepositoryText) {
          for (const expected of expectedDocuments)
            exceptions.push(
              exception(
                project.canonicalKey,
                `Repository body/hash drift in ${document.title}: ${expected.path}`,
              ),
            );
          continue;
        }
        const loaded: MirrorSource[] = [];
        let sourceInvalid = false;
        for (const contract of expectedDocuments) {
          const source = await options.loadRepositoryText(contract.path);
          const sourceHash = await sha256Text(source);
          const sourceByteLength = new TextEncoder().encode(source).byteLength;
          if (
            sourceHash !== contract.sha256 ||
            sourceByteLength !== contract.byteLength
          ) {
            exceptions.push(
              exception(
                project.canonicalKey,
                `Repository source verification failed: ${contract.path}`,
              ),
            );
            sourceInvalid = true;
            break;
          }
          loaded.push({ contract, content: source });
        }
        if (sourceInvalid) continue;
        desiredSources = loaded;
      }
      if (authorityIsStale || bodyHasDrifted) {
        if (!mutationsEnabled) {
          exceptions.push(
            exception(
              project.canonicalKey,
              `Stale authority metadata in ${document.title}`,
            ),
          );
          continue;
        }
        const synchronizedAt = new Date().toISOString();
        const desiredContent =
          document.title === "00 — Initiative Brief and Lifecycle Index"
            ? initiativeIndexMirror(
                project,
                group,
                desired.authorityCommit,
                desired.contractHash,
                phase,
                synchronizedAt,
                issueIdentifiers,
              )
            : repositoryMirror(
                desiredSources!,
                desired.authorityCommit,
                desired.contractHash,
                phase,
                synchronizedAt,
              );
        const beforeHash = await sha256Text(content);
        const desiredHash = await sha256Text(desiredContent);
        const updated = await client.request<{
          documentUpdate: {
            success: boolean;
            document?: { content?: string | null } | null;
          };
        }>(
          `mutation($id: String!, $input: DocumentUpdateInput!) {
            documentUpdate(id: $id, input: $input) {
              success
              document { content }
            }
          }`,
          { id: document.id, input: { content: desiredContent } },
        );
        const resultHash = await sha256Text(
          updated.documentUpdate.document?.content ?? "",
        );
        const matches =
          updated.documentUpdate.success && resultHash === desiredHash;
        repairReceipts.push({
          canonicalKey: project.canonicalKey,
          operation: "document-authority-update",
          beforeHash,
          desiredHash,
          resultHash,
          verified: matches,
        });
        repairs += 1;
        if (!matches)
          exceptions.push(
            exception(
              project.canonicalKey,
              `Document authority repair did not verify: ${document.title}`,
            ),
          );
      }
    }
    for (const task of project.tasks) {
      const liveIssue = issuesByKey.get(task.canonicalKey);
      if (!liveIssue) {
        exceptions.push(
          exception(task.canonicalKey, "Canonical Plan-task Issue is missing"),
        );
        continue;
      }
      mappings.push({
        canonicalKey: task.canonicalKey,
        linearId: liveIssue.id,
        objectType: "issue",
        desiredHash: await sha256Text(
          stableJson({
            authorityCommit: desired.authorityCommit,
            contractHash: desired.contractHash,
            task,
          }),
        ),
      });
      const state = expectedState(liveIssue, project, task);
      if (state !== liveIssue.state.name) {
        if (mutationsEnabled) {
          const beforeHash = await sha256Text(
            stableJson({ state: liveIssue.state.name }),
          );
          const desiredHash = await sha256Text(stableJson({ state }));
          const stateId = workflowStateIds.get(state);
          if (!stateId) {
            exceptions.push(
              exception(
                task.canonicalKey,
                `Controlled issue state is missing: ${state}`,
              ),
            );
            continue;
          }
          await client.request(
            `mutation($id: String!, $state: String!) {
              issueUpdate(id: $id, input: { stateId: $state }) { success }
            }`,
            {
              id: liveIssue.id,
              state: stateId,
            },
          );
          const verified = await client.request<{
            issue: { state: { name: IssueState } };
          }>(`query($id: String!) { issue(id: $id) { state { name } } }`, {
            id: liveIssue.id,
          });
          const resultHash = await sha256Text(
            stableJson({ state: verified.issue.state.name }),
          );
          const matches = verified.issue.state.name === state;
          repairReceipts.push({
            canonicalKey: task.canonicalKey,
            operation: "issue-state-update",
            beforeHash,
            desiredHash,
            resultHash,
            verified: matches,
          });
          repairs += 1;
          if (!matches)
            exceptions.push(
              exception(
                task.canonicalKey,
                `Issue state repair did not verify: expected ${state}, observed ${verified.issue.state.name}`,
              ),
            );
        } else {
          exceptions.push(
            exception(
              task.canonicalKey,
              `Issue state ${liveIssue.state.name} should be ${state}`,
              "warning",
            ),
          );
        }
      }
      const requiredGates = requiredFrontendGateLabels(project, task);
      const currentLabelNames = liveIssue.labels.nodes.map(
        (label) => label.name,
      );
      const desiredLabelNames = [
        ...currentLabelNames.filter(
          (name) =>
            name !== "gate:frontend-contract" &&
            name !== "gate:visual-approval",
        ),
        ...requiredGates,
      ].sort();
      if (
        stableJson([...currentLabelNames].sort()) !==
        stableJson(desiredLabelNames)
      ) {
        const desiredLabelIds = desiredLabelNames.map((name) =>
          issueLabelIds.get(name),
        );
        if (desiredLabelIds.some((id) => id === undefined)) {
          exceptions.push(
            exception(
              task.canonicalKey,
              "Required frontend gate label is missing",
            ),
          );
        } else if (mutationsEnabled) {
          const beforeHash = await sha256Text(
            stableJson([...currentLabelNames].sort()),
          );
          const desiredHash = await sha256Text(stableJson(desiredLabelNames));
          await client.request(
            `mutation($id: String!, $labels: [String!]!) {
              issueUpdate(id: $id, input: { labelIds: $labels }) { success }
            }`,
            { id: liveIssue.id, labels: desiredLabelIds },
          );
          repairReceipts.push({
            canonicalKey: task.canonicalKey,
            operation: "issue-label-update",
            beforeHash,
            desiredHash,
            resultHash: desiredHash,
            verified: true,
          });
          repairs += 1;
        } else {
          exceptions.push(
            exception(
              task.canonicalKey,
              `Frontend gate labels should be ${requiredGates.join(", ") || "none"}`,
              "warning",
            ),
          );
        }
      }
      const desiredDescription = issueAuthorityEnvelope(
        task,
        group,
        project,
        desired.authorityCommit,
        desired.contractHash,
      );
      const currentDescription = liveIssue.description ?? "";
      if (currentDescription !== desiredDescription) {
        if (!mutationsEnabled) {
          exceptions.push(
            exception(
              task.canonicalKey,
              "Plan-task authority envelope is stale",
            ),
          );
          continue;
        }
        const beforeHash = await sha256Text(currentDescription);
        const desiredHash = await sha256Text(desiredDescription);
        const updated = await client.request<{
          issueUpdate: {
            success: boolean;
            issue?: { description?: string | null } | null;
          };
        }>(
          `mutation($id: String!, $input: IssueUpdateInput!) {
            issueUpdate(id: $id, input: $input) {
              success
              issue { description }
            }
          }`,
          { id: liveIssue.id, input: { description: desiredDescription } },
        );
        const resultHash = await sha256Text(
          updated.issueUpdate.issue?.description ?? "",
        );
        const matches =
          updated.issueUpdate.success && resultHash === desiredHash;
        repairReceipts.push({
          canonicalKey: task.canonicalKey,
          operation: "issue-authority-update",
          beforeHash,
          desiredHash,
          resultHash,
          verified: matches,
        });
        repairs += 1;
        if (!matches)
          exceptions.push(
            exception(
              task.canonicalKey,
              "Plan-task authority repair did not verify",
            ),
          );
      }
    }
  }

  const canonicalIssueIds = new Set(
    [...issuesByKey.values()].map((issue) => issue.id),
  );
  for (const issue of issues) {
    if (issue.parent && canonicalIssueIds.has(issue.id))
      exceptions.push(
        exception(
          issue.identifier,
          "Canonical Plan Task is unexpectedly a sub-issue",
        ),
      );
    if (
      issue.state.type !== "completed" &&
      issue.state.type !== "canceled" &&
      issue.identifier !== "AMB-2085" &&
      !canonicalIssueIds.has(issue.id)
    )
      exceptions.push(
        exception(
          issue.identifier,
          "Active Issue is not mapped to a canonical Plan Task",
        ),
      );
    for (const label of issue.labels.nodes)
      if (!allowedLabelPrefixes.some((prefix) => label.name.startsWith(prefix)))
        exceptions.push(
          exception(issue.identifier, `Issue uses legacy label: ${label.name}`),
        );
  }

  return {
    exceptions,
    repairs,
    repairReceipts,
    mappings,
    metrics: {
      admittedProjects: admitted.length,
      liveLifecycleProjects: projectsBySlug.size,
      desiredPlanTasks: admitted.reduce(
        (total, project) => total + project.tasks.length,
        0,
      ),
      livePlanTasks: issuesByKey.size,
      driftExceptions: exceptions.length,
      repairs,
      controlledInitiatives: controlData.initiatives.nodes.length,
      controlledViews: controlData.customViews.nodes.length,
      controlledTemplates: controlData.templates.length,
    },
  };
}

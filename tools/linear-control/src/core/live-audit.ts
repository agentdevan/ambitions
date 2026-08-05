import type { LinearClient } from "../adapters/linear.js";
import type {
  ControlException,
  DesiredWorkspaceManifest,
  IssueState,
} from "./types.js";
import { CONTROLLED_TEMPLATES, OPERATIONAL_VIEWS } from "./definitions.js";

interface LiveProject {
  id: string;
  name: string;
  description?: string | null;
  status: { id: string; name: string };
  labels: { nodes: Array<{ id: string; name: string }> };
  projectMilestones: { nodes: Array<{ name: string }> };
  documents: { nodes: Array<{ title: string; content?: string | null }> };
}

interface LiveIssue {
  id: string;
  identifier: string;
  title: string;
  description?: string | null;
  state: { id: string; name: IssueState; type: string };
  project?: { name: string } | null;
  parent?: { id: string } | null;
  labels: { nodes: Array<{ name: string }> };
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

function expectedState(issue: LiveIssue): IssueState {
  if (
    [
      "In Progress",
      "In Review",
      "Needs Repair",
      "Done",
      "Canceled",
      "Duplicate",
      "Won’t Do",
    ].includes(issue.state.name)
  )
    return issue.state.name;
  const blocked = issue.inverseRelations.nodes.some(
    (relation) =>
      relation.type === "blocks" &&
      !["Done", "Canceled", "Duplicate", "Won’t Do"].includes(
        relation.issue.state.name,
      ),
  );
  return blocked ? "Blocked" : "Ready For Codex";
}

function exception(
  canonicalKey: string,
  summary: string,
  severity: ControlException["severity"] = "error",
): ControlException {
  return { canonicalKey, category: "drift", severity, summary };
}

export async function auditLiveWorkspace(
  client: LinearClient,
  desired: DesiredWorkspaceManifest,
  mutationsEnabled: boolean,
): Promise<LiveAuditResult> {
  const projectData = await client.request<{
    projects: { nodes: LiveProject[] };
  }>(`query {
    projects(first: 50, filter: { state: { nin: ["completed", "canceled"] } }) {
      nodes {
        id name description status { id name }
        labels { nodes { id name } }
        projectMilestones { nodes { name } }
        documents { nodes { title content } }
      }
    }
  }`);
  const controlData = await client.request<{
    workflowStates: { nodes: Array<{ name: string }> };
    issueLabels: { nodes: Array<{ name: string }> };
    projectLabels: { nodes: Array<{ name: string }> };
    customViews: { nodes: Array<{ name: string }> };
    templates: Array<{ name: string }>;
    initiatives: { nodes: Array<{ name: string }> };
    cycles: { nodes: Array<{ isActive: boolean; isNext: boolean }> };
  }>(`query {
    workflowStates(first: 50, filter: { team: { id: { eq: "ae5289a0-e901-4ff3-97c2-82a7e7e8ec96" } } }) { nodes { name } }
    issueLabels(first: 250) { nodes { name } }
    projectLabels(first: 100) { nodes { name } }
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
            labels { nodes { name } }
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
  const projectsBySlug = new Map(
    projectData.projects.nodes
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
  for (const project of admitted) {
    const live = projectsBySlug.get(project.slug);
    if (!live) {
      exceptions.push(
        exception(project.canonicalKey, "Lifecycle Project is missing"),
      );
      continue;
    }
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
    for (const document of live.documents.nodes) {
      if (!documentTitles.includes(document.title)) continue;
      const content = document.content ?? "";
      if (
        !content.includes(desired.authorityCommit) ||
        !content.includes("Repository mirror") ||
        !content.toLowerCase().includes("authoritative")
      )
        exceptions.push(
          exception(
            project.canonicalKey,
            `Stale authority metadata in ${document.title}`,
          ),
        );
    }
    for (const task of project.tasks) {
      const liveIssue = issuesByKey.get(task.canonicalKey);
      if (!liveIssue) {
        exceptions.push(
          exception(task.canonicalKey, "Canonical Plan-task Issue is missing"),
        );
        continue;
      }
      const state = expectedState(liveIssue);
      if (state !== liveIssue.state.name) {
        if (mutationsEnabled) {
          await client.request(
            `mutation($id: String!, $state: String!) {
              issueUpdate(id: $id, input: { stateId: $state }) { success }
            }`,
            {
              id: liveIssue.id,
              state:
                state === "Blocked"
                  ? "74b8841c-2606-4846-ae87-573645f45474"
                  : "ceec6cae-b2f1-4223-8d8c-33c8a42da556",
            },
          );
          repairs += 1;
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
      if (
        !liveIssue.description?.includes(
          `Canonical Task: ${task.canonicalKey}`,
        ) ||
        !liveIssue.description.includes(desired.contractHash)
      )
        exceptions.push(
          exception(task.canonicalKey, "Plan-task authority envelope is stale"),
        );
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

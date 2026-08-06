import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { LinearClient } from "./adapters/linear.js";
import {
  initiativeIndexMirror,
  issueAuthorityEnvelope,
  repositoryMirror,
} from "./core/mirrors.js";
import type {
  DesiredWorkspaceManifest,
  DocumentContract,
  IssueState,
} from "./core/types.js";

const token = process.env.LINEAR_API_TOKEN;
if (!token) throw new Error("LINEAR_API_TOKEN_REQUIRED");

const manifest = JSON.parse(
  await readFile(
    new URL("../generated/desired-workspace.json", import.meta.url),
    "utf8",
  ),
) as DesiredWorkspaceManifest;
const repositoryRoot = resolve(new URL("../../..", import.meta.url).pathname);
const client = new LinearClient(token, process.env.LINEAR_API_URL);
const projectData = await client.request<{
  projects: {
    nodes: Array<{
      id: string;
      name: string;
      documents: {
        nodes: Array<{ id: string; title: string; content: string }>;
      };
    }>;
  };
}>(`query {
  projects(first: 50, filter: { name: { startsWith: "Lifecycle — " } }) {
    nodes { id name documents { nodes { id title content } } }
  }
}`);

interface LiveIssue {
  id: string;
  identifier: string;
  title: string;
  state: { name: IssueState };
  project?: { name: string } | null;
}

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
        nodes { id identifier title state { name } project { name } }
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

function taskNumber(title: string): number | undefined {
  const match = /^(?:Plan Task\s+)?(?:\[?T)?(\d+)\]?/i.exec(title);
  return match ? Number(match[1]) : undefined;
}

const issuesByKey = new Map<string, LiveIssue>();
for (const issue of issues) {
  if (!issue.project?.name.startsWith("Lifecycle — ")) continue;
  const order = taskNumber(issue.title);
  if (order === undefined) continue;
  const slug = issue.project.name.replace(/^Lifecycle — /, "");
  issuesByKey.set(`${slug}:T${order}`, issue);
}

function lifecycleState(projectSlug: string): string {
  const states = [...issuesByKey.entries()]
    .filter(([key]) => key.startsWith(`${projectSlug}:T`))
    .map(([, issue]) => issue.state.name);
  if (states.length > 0 && states.every((state) => state === "Done"))
    return "Completed";
  if (
    states.some((state) =>
      ["In Progress", "In Review", "Needs Repair", "Done"].includes(state),
    )
  )
    return "Building";
  return "Grooming";
}

async function source(contract: DocumentContract): Promise<{
  contract: DocumentContract;
  content: string;
}> {
  return {
    contract,
    content: await readFile(resolve(repositoryRoot, contract.path), "utf8"),
  };
}

const synchronizedAt = new Date().toISOString();
let documentsSynchronized = 0;
let issuesSynchronized = 0;
for (const project of manifest.projects.filter(
  (item) =>
    item.admission === "ready" &&
    manifest.schedule.some((group) => group.projectSlugs.includes(item.slug)),
)) {
  const liveProject = projectData.projects.nodes.find(
    (item) => item.name === `Lifecycle — ${project.slug}`,
  );
  const group = manifest.schedule.find((item) =>
    item.projectSlugs.includes(project.slug),
  );
  if (!liveProject || !group)
    throw new Error(`LIVE_PROJECT_OR_GROUP_MISSING:${project.slug}`);
  const phase = lifecycleState(project.slug);
  const issueIdentifiers = new Map(
    project.tasks.map((task) => [
      task.canonicalKey,
      issuesByKey.get(task.canonicalKey)?.identifier ?? "MISSING",
    ]),
  );
  const contentByTitle = new Map<string, string>();
  contentByTitle.set(
    "00 — Initiative Brief and Lifecycle Index",
    initiativeIndexMirror(
      project,
      group,
      manifest.authorityCommit,
      manifest.contractHash,
      phase,
      synchronizedAt,
      issueIdentifiers,
    ),
  );
  for (const [title, kinds] of [
    ["10 — Research", ["research"]],
    ["20 — Scope", ["scope"]],
    ["30 — Design", ["design"]],
    [
      "40 — Implementation Plan",
      project.slug === "linear-realtime-lifecycle-control"
        ? ["plan", "tasks", "verification"]
        : ["plan"],
    ],
  ] as const) {
    const contracts = project.documents.filter((document) =>
      (kinds as readonly string[]).includes(document.kind),
    );
    contentByTitle.set(
      title,
      repositoryMirror(
        await Promise.all(contracts.map(source)),
        manifest.authorityCommit,
        manifest.contractHash,
        phase,
        synchronizedAt,
      ),
    );
  }
  for (const [title, content] of contentByTitle) {
    const document = liveProject.documents.nodes.find(
      (item) => item.title === title,
    );
    if (!document)
      throw new Error(`LIVE_DOCUMENT_MISSING:${project.slug}:${title}`);
    if (document.content === content) continue;
    await client.request(
      `mutation($id: String!, $input: DocumentUpdateInput!) {
        documentUpdate(id: $id, input: $input) { success }
      }`,
      { id: document.id, input: { content } },
    );
    documentsSynchronized += 1;
  }
  for (const task of project.tasks) {
    const issue = issuesByKey.get(task.canonicalKey);
    if (!issue) throw new Error(`LIVE_ISSUE_MISSING:${task.canonicalKey}`);
    const description = issueAuthorityEnvelope(
      task,
      group,
      project,
      manifest.authorityCommit,
      manifest.contractHash,
    );
    await client.request(
      `mutation($id: String!, $input: IssueUpdateInput!) {
        issueUpdate(id: $id, input: $input) { success }
      }`,
      { id: issue.id, input: { description } },
    );
    issuesSynchronized += 1;
  }
}

console.log(
  JSON.stringify({
    documentsSynchronized,
    issuesSynchronized,
    authorityCommit: manifest.authorityCommit,
    synchronizedAt,
  }),
);

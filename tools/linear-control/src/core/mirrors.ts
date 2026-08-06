import type {
  DocumentContract,
  ProjectContract,
  ScheduleGroup,
  TaskContract,
} from "./types.js";

export interface MirrorSource {
  contract: DocumentContract;
  content: string;
}

function textFence(content: string): string {
  const longest = Math.max(
    0,
    ...[...content.matchAll(/`+/g)].map((match) => match[0].length),
  );
  return "`".repeat(Math.max(3, longest + 1));
}

export function repositoryMirror(
  sources: readonly MirrorSource[],
  authorityCommit: string,
  contractHash: string,
  lifecycleState: string,
  synchronizedAt: string,
): string {
  if (sources.length === 0) throw new Error("MIRROR_SOURCE_REQUIRED");
  const primary = sources[0]!.contract;
  const sections = sources.map(({ contract, content }) => {
    const fence = textFence(content);
    return [
      `## Repository artifact: ${contract.path}`,
      "",
      `Content SHA-256: ${contract.sha256}`,
      "",
      `${fence}text`,
      content.replace(/\n$/, ""),
      fence,
    ].join("\n");
  });
  return [
    `Canonical repository path: ${primary.path}`,
    `Repository commit: ${authorityCommit}`,
    `Document revision: ${primary.sha256}`,
    `Contract SHA-256: ${contractHash}`,
    `Content SHA-256: ${primary.sha256}`,
    `Lifecycle state: ${lifecycleState}`,
    `Last synchronized: ${synchronizedAt}`,
    "Repository mirror — do not edit authority-bearing content.",
    "Repository content is authoritative; Linear is an execution mirror.",
    "",
    ...sections,
  ].join("\n");
}

export function initiativeIndexMirror(
  project: ProjectContract,
  group: ScheduleGroup,
  authorityCommit: string,
  contractHash: string,
  lifecycleState: string,
  synchronizedAt: string,
  issueIdentifiers: ReadonlyMap<string, string>,
): string {
  const peers = group.projectSlugs.filter((slug) => slug !== project.slug);
  return [
    `Canonical repository path: ${project.folder}/`,
    `Repository commit: ${authorityCommit}`,
    `Document revision: ${contractHash}`,
    `Contract SHA-256: ${contractHash}`,
    `Lifecycle state: ${lifecycleState}`,
    `Last synchronized: ${synchronizedAt}`,
    "Repository mirror — do not edit authority-bearing content.",
    "Repository content is authoritative; Linear is an execution mirror.",
    "",
    "# Initiative Brief and Lifecycle Index",
    "",
    `- Primary Initiative: ${project.primaryInitiative ?? "Linear Initiative relationship is authoritative for portfolio ownership"}`,
    `- Execution group: ${group.id}`,
    `- Portfolio prerequisites: ${project.projectDependencies.join(", ") || "none"}`,
    `- Parallel-safe peers: ${peers.join(", ") || "none"}`,
    `- Frontend contract: ${project.frontendAudit.status}`,
    `- Visual gate: ${project.frontendAudit.visualGate}`,
    `- First frontend task: ${project.frontendAudit.firstFrontendTaskKey ?? "none"}`,
    `- Lifecycle: M0 Research PASS; M1 Scope PASS; M2 Design PASS; M3 Groomed PASS; current phase ${lifecycleState}`,
    "",
    "## Canonical document hashes",
    "",
    ...project.documents.map(
      (document) => `- ${document.path}: ${document.sha256}`,
    ),
    "",
    "## Plan-task issue map",
    "",
    ...project.tasks.map(
      (task) =>
        `- ${task.id}: ${issueIdentifiers.get(task.canonicalKey) ?? "MISSING"}`,
    ),
    "",
    "Issue relations enforce execution blocking. Frontend-affecting tasks remain blocked until every declared frontend and visual gate is satisfied.",
  ].join("\n");
}

export function issueAuthorityEnvelope(
  task: TaskContract,
  group: ScheduleGroup,
  project: ProjectContract,
  authorityCommit: string,
  contractHash: string,
): string {
  const fence = textFence(task.body);
  const peers = group.projectSlugs.filter((slug) => slug !== project.slug);
  return [
    `Portfolio execution group: ${group.id}`,
    `Global portfolio rank: ${task.globalRank}`,
    `Parallel-safe peer Projects: ${peers.join(", ") || "none"}`,
    `Canonical repository path: ${project.folder}/implementation/tasks.md`,
    `Repository authority commit: ${authorityCommit}`,
    `Manifest contract SHA-256: ${contractHash}`,
    `Canonical Task: ${task.canonicalKey}`,
    `Frontend impact: ${task.frontendImpact}`,
    `Visual gate: ${task.visualGate}`,
    "",
    "Canonical Plan task body — repository mirror:",
    "",
    `${fence}text`,
    task.body.replace(/\n$/, ""),
    fence,
  ].join("\n");
}

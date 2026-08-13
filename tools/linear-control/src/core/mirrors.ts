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

export interface ProjectMirrorProgress {
  phase: string;
  terminalTasks: number;
  verifiedTasks: number;
  totalTasks: number;
  reviewTasks?: number;
  blockedTasks?: number;
  nextTask?: TaskContract;
  groupOrdinal: number;
  totalGroups: number;
  projectOrdinal: number;
}

export function projectSummaryMirror(
  group: ScheduleGroup,
  progress: ProjectMirrorProgress,
  project?: ProjectContract,
  p0Active = false,
): string {
  if (project?.executionLane === "p0")
    return "P0 • UFP active • external ledger sync required • phase/task/progress withheld";
  if (p0Active && project?.executionLane === "normal") {
    const closureOnly =
      progress.terminalTasks > 0 || (progress.reviewTasks ?? 0) > 0;
    return [
      "P0 hold",
      closureOnly ? "closure-only" : `staged ${group.id}`,
      `${progress.terminalTasks}/${progress.totalTasks} terminal`,
      ...(progress.reviewTasks ? [`${progress.reviewTasks} in review`] : []),
      ...(progress.blockedTasks ? [`${progress.blockedTasks} blocked`] : []),
    ].join(" • ");
  }
  if (project?.executionLane === "control")
    return [
      "G00 active control lane",
      progress.phase,
      `${progress.terminalTasks}/${progress.totalTasks} terminal`,
      ...(progress.reviewTasks ? [`${progress.reviewTasks} in review`] : []),
      ...(progress.blockedTasks ? [`${progress.blockedTasks} blocked`] : []),
    ].join(" • ");
  const next = progress.nextTask ? ` • next ${progress.nextTask.id}` : "";
  return `${group.id} • ${progress.phase} • ${progress.terminalTasks}/${progress.totalTasks} terminal • ${progress.verifiedTasks} verified on current main${next}`;
}

export function projectAuthorityMirror(
  project: ProjectContract,
  group: ScheduleGroup,
  authorityCommit: string,
  contractHash: string,
  progress: ProjectMirrorProgress,
  p0Active = false,
): string {
  const peers = group.projectSlugs.filter((slug) => slug !== project.slug);
  const fullyVerified = progress.verifiedTasks === progress.totalTasks;
  const terminallyClosed = progress.phase === "Completed";
  const repositoryUrl = `https://github.com/agentdevan/ambitions/tree/${authorityCommit}/${project.folder}`;
  return [
    "# Lifecycle Project",
    "",
    `Repository authority: [${repositoryUrl}](<${repositoryUrl}>)`,
    "",
    `* Canonical folder: ${project.folder}/`,
    `* Repository commit: ${authorityCommit}`,
    `* Lifecycle contract SHA-256: ${contractHash}`,
    `* Lifecycle phase: ${progress.phase}`,
    `* Primary Initiative: ${project.primaryInitiative ?? "Linear Initiative relationship is authoritative for portfolio ownership"}`,
    `* Portfolio execution group: ${group.id} of ${progress.totalGroups}`,
    `* Portfolio order: ${String(progress.groupOrdinal).padStart(2, "0")}.${String(progress.projectOrdinal).padStart(2, "0")}`,
    `* Cross-Project prerequisites: ${project.projectDependencies.join(", ") || "none"}`,
    `* Parallel-safe peers: ${peers.join(", ") || "none"}`,
    `* Implementation-plan tasks: ${progress.totalTasks}`,
    `* Progress: ${progress.terminalTasks} of ${progress.totalTasks} Plan Tasks terminal; ${progress.verifiedTasks} verified on current main`,
    `* Next Plan Task: ${progress.nextTask?.canonicalKey ?? "none"}`,
    `* Milestones: M0-M3 passed; M4 ${fullyVerified ? "passed" : terminallyClosed ? "closed without implementation proof" : "in progress"}; M5 ${fullyVerified ? "passed" : terminallyClosed ? "closed without validation proof" : "pending"}; M6 ${terminallyClosed ? "closed" : "pending"}`,
    `* Frontend contract: ${project.frontendAudit.status}`,
    `* Visual gate: ${project.frontendAudit.visualGate}${project.frontendAudit.firstFrontendTaskKey ? `; first frontend task ${project.frontendAudit.firstFrontendTaskKey}` : ""}`,
    ...(project.executionLane === "p0"
      ? [
          "* Execution control: P0 highest-priority active delivery lane",
          "* Operational state authority: external PROGRAM.json; one-way projection only",
          "* External ledger status: unavailable to this runtime; phase/task/progress withheld",
        ]
      : p0Active && project.executionLane === "normal"
        ? [
            "* Execution control: P0 hold; no new starts",
            "* Closure exception: existing review/repair work may close without scope expansion",
          ]
        : project.executionLane === "control"
          ? ["* Execution control: G00 control lane; concurrent with P0"]
          : []),
    "",
    "Repository content is authoritative. Linear is the execution mirror and portfolio dependency surface.",
  ].join("\n");
}

export function milestoneAuthorityMirror(
  name: string,
  project: ProjectContract,
  authorityCommit: string,
  progress: ProjectMirrorProgress,
  p0Active = false,
): string {
  const fullyVerified = progress.verifiedTasks === progress.totalTasks;
  const terminallyClosed = progress.phase === "Completed";
  if (name === "M0 — Research Passed")
    return `PASS — Research approved and repository mirror refreshed at current main ${authorityCommit}. No implementation proof is implied.`;
  if (name === "M1 — Scope Passed")
    return `PASS — Scope approved and repository mirror refreshed at current main ${authorityCommit}. No implementation proof is implied.`;
  if (name === "M2 — Design Passed")
    return `PASS — Design approved and repository mirror refreshed at current main ${authorityCommit}.${project.frontendAudit.visualGate === "required" ? ` Frontend visual approval remains required before ${project.frontendAudit.firstFrontendTaskKey ?? "the first frontend task"}.` : ""}`;
  if (name === "M3 — Groomed for Implementation")
    return `PASS — Implementation plan groomed and synchronized at current main ${authorityCommit}.`;
  if (name === "M4 — Implementation Complete")
    if (project.executionLane === "p0")
      return "PENDING / LEDGER SYNC BLOCKED — terminal task count must come only from PROGRAM.json; no value is inferred.";
    else if (p0Active && project.executionLane === "normal")
      return `${progress.terminalTasks > 0 || (progress.reviewTasks ?? 0) > 0 ? "IN PROGRESS" : "NOT STARTED"} / P0 HOLD — ${progress.terminalTasks}/${progress.totalTasks} terminal; no new implementation start is authorized.`;
    else
      return fullyVerified
        ? `PASS — ${progress.verifiedTasks} of ${progress.totalTasks} canonical Plan Tasks are verified on current main.`
        : terminallyClosed
          ? `CLOSED — ${progress.terminalTasks} of ${progress.totalTasks} canonical Plan Tasks are terminal, but only ${progress.verifiedTasks} are verified on current main. No implementation-complete proof is claimed.`
          : `IN PROGRESS — ${progress.terminalTasks} of ${progress.totalTasks} canonical Plan Tasks are terminal; ${progress.verifiedTasks} are verified on current main. ${progress.nextTask ? `${progress.nextTask.id} is next in portfolio order.` : "No executable next task is currently identified."}`;
  if (name === "M5 — Validation and Merge")
    return fullyVerified
      ? "PASS — Project-level validation and current-main merge proof are complete."
      : terminallyClosed
        ? "CLOSED — Terminal dispositions are recorded. No project-level validation or current-main merge proof is claimed."
        : "PENDING — Project-level validation and merge closes only after all implementation tasks and required proof pass.";
  return terminallyClosed
    ? fullyVerified
      ? "PASS — Every canonical Plan Task is verified on current main and repository/Linear closeout is synchronized."
      : "CLOSED — Every canonical Plan Task has a terminal disposition and repository/Linear closeout is synchronized. No implementation or validation proof is implied."
    : "PENDING — Closeout requires every canonical Plan Task terminal, all visual gates resolved, and repository/Linear convergence.";
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
    `* Primary Initiative: ${project.primaryInitiative ?? "Linear Initiative relationship is authoritative for portfolio ownership"}`,
    `* Execution group: ${group.id}`,
    `* Portfolio prerequisites: ${project.projectDependencies.join(", ") || "none"}`,
    `* Parallel-safe peers: ${peers.join(", ") || "none"}`,
    `* Frontend contract: ${project.frontendAudit.status}`,
    `* Visual gate: ${project.frontendAudit.visualGate}`,
    `* First frontend task: ${project.frontendAudit.firstFrontendTaskKey ?? "none"}`,
    `* Lifecycle: M0 Research PASS; M1 Scope PASS; M2 Design PASS; M3 Groomed PASS; current phase ${lifecycleState}`,
    "",
    "## Canonical document hashes",
    "",
    ...project.documents.map(
      (document) => `* ${document.path}: ${document.sha256}`,
    ),
    "",
    "## Plan-task issue map",
    "",
    ...project.tasks.map(
      (task) =>
        `* ${task.id}: ${issueIdentifiers.get(task.canonicalKey) ?? "MISSING"}`,
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

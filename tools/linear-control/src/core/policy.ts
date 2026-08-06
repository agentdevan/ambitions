import type {
  CurrentIssue,
  DeletionEvidence,
  IssueState,
  LifecyclePhase,
  ProjectContract,
  ScheduleGroup,
  TaskContract,
} from "./types.js";

export const ISSUE_STATES: readonly IssueState[] = [
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

export const MILESTONES = [
  "M0 — Research Passed",
  "M1 — Scope Passed",
  "M2 — Design Passed",
  "M3 — Groomed for Implementation",
  "M4 — Implementation Complete",
  "M5 — Validation and Merge",
  "M6 — Closeout",
] as const;

export const CONTROLLED_ISSUE_LABEL_PREFIXES = [
  "area:",
  "work:",
  "proof:",
  "risk:",
  "gate:",
  "acceptance:",
] as const;

export const CONTROLLED_PROJECT_LABELS = [
  "lifecycle:managed",
  "phase:research",
  "phase:scope",
  "phase:design",
  "phase:grooming",
  "phase:implementation",
  "phase:validation",
  "sync:stale",
  "acceptance:yellow",
] as const;

export function desiredIssueState(issue: CurrentIssue): IssueState {
  if (
    issue.state === "Canceled" ||
    issue.state === "Duplicate" ||
    issue.state === "Won’t Do"
  )
    return issue.state;
  if (issue.requiredProofFailed) return "Needs Repair";
  if (
    issue.frontendAffected &&
    (!issue.frontendContractPassed ||
      (issue.visualGateRequired && !issue.visualGateApproved))
  )
    return issue.state === "Done" ||
      issue.state === "In Progress" ||
      issue.state === "In Review" ||
      issue.mergedToMain
      ? "Needs Repair"
      : "Blocked";
  if (issue.blockedBy.length > 0) return "Blocked";
  if (issue.mergedToMain && issue.proofPassed) return "Done";
  if (issue.pullRequestUrl || issue.mergedToMain) return "In Review";
  if (issue.branchName) return "In Progress";
  return "Ready For Codex";
}

export function desiredProjectPhase(
  states: readonly IssueState[],
  docsPassed: boolean,
): LifecyclePhase {
  if (!docsPassed) return "Designing";
  if (
    states.length > 0 &&
    states.every(
      (state) =>
        state === "Done" || state === "Canceled" || state === "Won’t Do",
    )
  )
    return "Completed";
  if (states.some((state) => state === "In Review" || state === "Needs Repair"))
    return "Validating";
  if (states.some((state) => state === "In Progress" || state === "Done"))
    return "Building";
  return "Grooming";
}

export function deletionIsSafe(evidence: DeletionEvidence): boolean {
  return Boolean(
    (evidence.replacementKey || evidence.zeroUniqueValue) &&
    evidence.commentsInspected &&
    evidence.attachmentsInspected &&
    evidence.descendantsInspected &&
    evidence.inboundRelationsInspected &&
    evidence.referencesRepaired &&
    evidence.activeWorkPreserved &&
    evidence.canonicalTruthPreserved,
  );
}

export function scheduleProjects(
  projects: readonly ProjectContract[],
): ScheduleGroup[] {
  const ready = projects.filter((project) => project.admission === "ready");
  const projectBySlug = new Map(
    ready.map((project) => [project.slug, project]),
  );
  const indegree = new Map(ready.map((project) => [project.slug, 0]));
  const outgoing = new Map(
    ready.map((project) => [project.slug, new Set<string>()]),
  );
  for (const project of ready) {
    for (const dependency of project.projectDependencies) {
      if (!projectBySlug.has(dependency)) continue;
      indegree.set(project.slug, (indegree.get(project.slug) ?? 0) + 1);
      outgoing.get(dependency)?.add(project.slug);
    }
  }
  const groups: ScheduleGroup[] = [];
  const emitted = new Set<string>();
  while (emitted.size < ready.length) {
    const eligible = ready
      .filter(
        (project) =>
          !emitted.has(project.slug) && (indegree.get(project.slug) ?? 0) === 0,
      )
      .sort((left, right) => left.slug.localeCompare(right.slug));
    if (eligible.length === 0) throw new Error("PROJECT_DEPENDENCY_CYCLE");
    const selected: ProjectContract[] = [];
    for (const project of eligible) {
      if (selected.length === 2) break;
      const conflicts = selected.some((other) =>
        project.sharedPaths.some((path) => other.sharedPaths.includes(path)),
      );
      if (!conflicts) selected.push(project);
    }
    if (selected.length === 0) selected.push(eligible[0]!);
    const groupNumber = groups.length + 1;
    const tasks = selected.flatMap((project) =>
      project.tasks.length > 0 ? [project.tasks[0]!.canonicalKey] : [],
    );
    groups.push({
      id: `G${String(groupNumber).padStart(2, "0")}`,
      projectSlugs: selected.map((p) => p.slug),
      taskKeys: tasks,
    });
    for (const project of selected) {
      emitted.add(project.slug);
      for (const dependent of outgoing.get(project.slug) ?? [])
        indegree.set(dependent, (indegree.get(dependent) ?? 1) - 1);
    }
  }
  return groups;
}

export function assignTaskRanks(
  tasks: readonly TaskContract[],
  groups: readonly ScheduleGroup[],
): TaskContract[] {
  const groupByTask = new Map(
    groups.flatMap((group) =>
      group.taskKeys.map((key) => [key, group.id] as const),
    ),
  );
  return [...tasks]
    .sort(
      (left, right) =>
        left.projectSlug.localeCompare(right.projectSlug) ||
        left.order - right.order,
    )
    .map((task, index) => ({
      ...task,
      globalRank: index + 1,
      ...(groupByTask.has(task.canonicalKey)
        ? { parallelGroup: groupByTask.get(task.canonicalKey)! }
        : {}),
    }));
}

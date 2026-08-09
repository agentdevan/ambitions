import { readFile, readdir } from "node:fs/promises";
import { basename, join, relative } from "node:path";
import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import {
  MANIFEST_SCHEMA_VERSION,
  type DesiredWorkspaceManifest,
  type DocumentContract,
  type ProjectContract,
  type TaskContract,
} from "./types.js";
import { sha256Bytes, sha256Text, stableJson } from "./hash.js";
import type { ScheduleGroup } from "./types.js";

const REQUIRED = [
  "research.md",
  "scope.md",
  "design.md",
  "implementation/plan.md",
  "implementation/tasks.md",
  "implementation/verification.md",
] as const;
const RESEARCH_FRONTEND_FIELDS = [
  "Potential frontend impact",
  "Existing surfaces investigated",
  "Evidence and unknowns",
] as const;
const FRONTEND_MATRIX_FIELDS = [
  "Surface impact",
  "IA/navigation",
  "Assets/iconography",
  "Visual language",
  "Motion",
  "Copy/localization",
  "Accessibility",
  "Visual proof",
] as const;
const FRONTEND_MATCH_FIELDS = FRONTEND_MATRIX_FIELDS.slice(0, 5);

function gitBlobOid(bytes: Uint8Array): string {
  return createHash("sha1")
    .update(`blob ${bytes.byteLength}\0`)
    .update(bytes)
    .digest("hex");
}

function frontmatter(text: string): Record<string, string> {
  const match = /^\+\+\+\r?\n([\s\S]*?)\r?\n\+\+\+/.exec(text);
  if (!match) return {};
  return Object.fromEntries(
    match[1]!
      .split(/\r?\n/)
      .map((line) => /^([a-z_]+)\s*=\s*"(.*)"$/.exec(line))
      .filter((item): item is RegExpExecArray => item !== null)
      .map((item) => [item[1]!, item[2]!]),
  );
}

function fieldValue(text: string, field: string): string | undefined {
  const escaped = field.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  return new RegExp(`^-\\s*${escaped}\\s*:\\s*(\\S.*)$`, "im")
    .exec(text)?.[1]
    ?.trim()
    .toLowerCase();
}

function validateFrontendDocuments(
  research: string,
  scope: string,
  design: string,
  blockers: string[],
): boolean {
  const before = blockers.length;
  for (const field of RESEARCH_FRONTEND_FIELDS)
    if (!fieldValue(research, field))
      blockers.push(`research.md:frontend-field=${field}:missing`);
  for (const field of FRONTEND_MATRIX_FIELDS) {
    const scopeValue = fieldValue(scope, field);
    const designValue = fieldValue(design, field);
    if (!scopeValue) blockers.push(`scope.md:frontend-field=${field}:missing`);
    if (!designValue)
      blockers.push(`design.md:frontend-field=${field}:missing`);
    if (
      FRONTEND_MATCH_FIELDS.includes(field) &&
      scopeValue &&
      designValue &&
      scopeValue !== designValue
    )
      blockers.push(`design.md:frontend-field=${field}:mismatch`);
  }
  if (!fieldValue(design, "Visual gate"))
    blockers.push("design.md:frontend-field=Visual gate:missing");
  return blockers.length === before;
}

function taskContracts(slug: string, text: string): TaskContract[] {
  const starts = [...text.matchAll(/^(\d+)\.\s+(.+)$/gm)];
  return starts.map((match, index) => {
    const start = match.index;
    const end = starts[index + 1]?.index ?? text.length;
    const body = text.slice(start, end).trim();
    const order = Number(match[1]);
    const dependenciesText =
      /Dependency:\s*([^.]+)\./i.exec(body)?.[1]?.trim() ?? "none";
    const dependencies =
      dependenciesText.toLowerCase() === "none"
        ? []
        : [
            ...dependenciesText.matchAll(/Task(?:s)?\s*([0-9–,—\s]+)/gi),
          ].flatMap((item) =>
            item[1]!
              .split(/[^0-9]+/)
              .filter(Boolean)
              .map((id) => `${slug}:T${id}`),
          );
    const sharedPaths = [...body.matchAll(/`([^`]+)`/g)]
      .map((item) => item[1]!)
      .filter((path) => path.includes("/") || path.endsWith(".yml"));
    const validationCommands = [...body.matchAll(/Tests?:\s*([^\n]+)/gi)].map(
      (item) => item[1]!.trim(),
    );
    const rollback =
      /Rollback\/stop:\s*([^\n]+)/i.exec(body)?.[1]?.trim() ??
      "Stop and preserve the last verified state.";
    const title = match[2]!
      .split(/\.\s+(?:Dependency|Trace|Acceptance|Proof|Rollback|Tests):/)[0]!
      .trim();
    const frontend = /\bFrontend:\s*(none|affected)\b/i
      .exec(body)?.[1]
      ?.toLowerCase();
    const visualGate = /\bVisual gate:\s*(not-required|required|approved)\b/i
      .exec(body)?.[1]
      ?.toLowerCase();
    return {
      id: `T${order}`,
      canonicalKey: `${slug}:T${order}`,
      title,
      body,
      projectSlug: slug,
      order,
      dependencies,
      sharedPaths: [...new Set(sharedPaths)].sort(),
      proof: { required: ["audit"], validationCommands, rollback },
      frontendImpact:
        frontend === "none" || frontend === "affected"
          ? frontend
          : "unclassified",
      visualGate:
        frontend === "none"
          ? "not-required"
          : visualGate === "not-required" ||
              visualGate === "required" ||
              visualGate === "approved"
            ? visualGate
            : "unclassified",
    };
  });
}

function designVisualGate(
  text: string,
): ProjectContract["frontendAudit"]["visualGate"] {
  const value = /^-\s*Visual gate:\s*(not-required|required|approved)\s*$/im
    .exec(text)?.[1]
    ?.toLowerCase();
  return value === "not-required" ||
    value === "required" ||
    value === "approved"
    ? value
    : "unclassified";
}

function inferProjectDependencies(tasks: readonly TaskContract[]): string[] {
  return [
    ...new Set(
      tasks.flatMap((task) =>
        task.dependencies
          .map((key) => key.split(":T")[0]!)
          .filter((slug) => slug !== task.projectSlug),
      ),
    ),
  ].sort();
}

export async function compileRepository(
  root: string,
  authorityCommit?: string,
): Promise<DesiredWorkspaceManifest> {
  const lifecycleRoot = join(root, "docs/product-development");
  const slugs = (await readdir(lifecycleRoot, { withFileTypes: true }))
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name)
    .sort();
  const projects: ProjectContract[] = [];
  for (const slug of slugs) {
    const folder = join(lifecycleRoot, slug);
    const documents: DocumentContract[] = [];
    const blockers: string[] = [];
    let tasks: TaskContract[] = [];
    let researchText = "";
    let scopeText = "";
    let designText = "";
    for (const path of REQUIRED) {
      try {
        const bytes = await readFile(join(folder, path));
        const text = bytes.toString("utf8");
        const meta = frontmatter(text);
        const kind =
          path === "implementation/plan.md"
            ? "plan"
            : path === "implementation/tasks.md"
              ? "tasks"
              : path === "implementation/verification.md"
                ? "verification"
                : (basename(path, ".md") as "research" | "scope" | "design");
        const status =
          meta.status ??
          (path.startsWith("implementation/") ? "groomed" : "missing");
        if (!path.startsWith("implementation/") && status !== "approved")
          blockers.push(`${path}:status=${status}`);
        documents.push({
          kind,
          path: relative(root, join(folder, path)),
          revision: meta.revision ?? "1",
          status,
          sha256: await sha256Bytes(bytes),
          byteLength: bytes.byteLength,
          gitBlobOid: gitBlobOid(bytes),
        });
        if (path === "implementation/tasks.md")
          tasks = taskContracts(slug, text);
        if (path === "research.md") researchText = text;
        if (path === "scope.md") scopeText = text;
        if (path === "design.md") designText = text;
      } catch {
        blockers.push(`${path}:missing`);
      }
    }
    if (tasks.length === 0) blockers.push("implementation/tasks.md:no-tasks");
    for (const task of tasks) {
      if (task.frontendImpact === "unclassified")
        blockers.push(
          `implementation/tasks.md:${task.id}:frontend-unclassified`,
        );
      if (
        task.frontendImpact === "affected" &&
        task.visualGate === "unclassified"
      )
        blockers.push(
          `implementation/tasks.md:${task.id}:visual-gate-unclassified`,
        );
    }
    const frontendDocumentsValid = validateFrontendDocuments(
      researchText,
      scopeText,
      designText,
      blockers,
    );
    const visualGate = designVisualGate(designText);
    if (visualGate === "unclassified")
      blockers.push("design.md:frontend-contract-missing");
    for (const task of tasks)
      if (
        task.frontendImpact === "affected" &&
        task.visualGate !== "unclassified" &&
        visualGate !== "unclassified" &&
        task.visualGate !== visualGate
      )
        blockers.push(
          `implementation/tasks.md:${task.id}:visual-gate-mismatch`,
        );
    const firstFrontendTask = tasks.find(
      (task) => task.frontendImpact === "affected",
    );
    const sharedPaths = [
      ...new Set(tasks.flatMap((task) => task.sharedPaths)),
    ].sort();
    projects.push({
      slug,
      canonicalKey: `project:${slug}`,
      name: `Lifecycle — ${slug
        .split("-")
        .map((word) => word[0]!.toUpperCase() + word.slice(1))
        .join(" ")}`,
      folder: relative(root, folder),
      ...(slug === "linear-realtime-lifecycle-control"
        ? { primaryInitiative: "Ambitions Product Canon + Operating Model" }
        : {}),
      documents,
      tasks,
      projectDependencies: inferProjectDependencies(tasks),
      sharedPaths,
      frontendAudit: {
        status:
          frontendDocumentsValid &&
          visualGate !== "unclassified" &&
          tasks.every(
            (task) =>
              task.frontendImpact !== "unclassified" &&
              (task.frontendImpact === "none" ||
                task.visualGate === visualGate),
          )
            ? "passed"
            : "blocked",
        visualGate,
        ...(firstFrontendTask
          ? { firstFrontendTaskKey: firstFrontendTask.canonicalKey }
          : {}),
      },
      admission: blockers.length === 0 ? "ready" : "pending",
      admissionBlockers: blockers,
    });
  }
  const sequence = JSON.parse(
    await readFile(
      join(root, "tools/linear-control/config/portfolio-order.json"),
      "utf8",
    ),
  ) as { excludedSlugs: string[]; groups: string[][] };
  const operationalProjects = projects.filter(
    (project) =>
      project.admission === "ready" &&
      !sequence.excludedSlugs.includes(project.slug),
  );
  const configured = new Set(sequence.groups.flat());
  const missing = operationalProjects
    .map((project) => project.slug)
    .filter((slug) => !configured.has(slug));
  const unknown = [...configured].filter(
    (slug) => !operationalProjects.some((project) => project.slug === slug),
  );
  if (missing.length > 0 || unknown.length > 0)
    throw new Error(
      `PORTFOLIO_ORDER_DRIFT:missing=${missing.join(",")};unknown=${unknown.join(",")}`,
    );
  const schedule: ScheduleGroup[] = sequence.groups.map((slugs, index) => {
    if (slugs.length === 0 || slugs.length > 2)
      throw new Error(`INVALID_GROUP_WIDTH:${index + 1}`);
    return {
      id: `G${String(index).padStart(2, "0")}`,
      projectSlugs: slugs,
      taskKeys: slugs.flatMap(
        (slug) =>
          projects
            .find((project) => project.slug === slug)
            ?.tasks.map((task) => task.canonicalKey) ?? [],
      ),
    };
  });
  let globalRank = 1;
  for (const group of schedule) {
    const groupProjects = group.projectSlugs.map((slug) =>
      projects.find((project) => project.slug === slug)!,
    );
    const maximumTasks = Math.max(
      ...groupProjects.map((project) => project.tasks.length),
    );
    for (let taskIndex = 0; taskIndex < maximumTasks; taskIndex += 1) {
      for (const project of groupProjects) {
        const task = project.tasks[taskIndex];
        if (task) {
          (
            task as TaskContract & { globalRank: number; parallelGroup: string }
          ).globalRank = globalRank;
          (
            task as TaskContract & { globalRank: number; parallelGroup: string }
          ).parallelGroup = group.id;
          globalRank += 1;
        }
      }
    }
  }
  const commit =
    authorityCommit ??
    execFileSync("git", ["rev-parse", "HEAD"], {
      cwd: root,
      encoding: "utf8",
    }).trim();
  const semantic = {
    schemaVersion: MANIFEST_SCHEMA_VERSION,
    authorityCommit: commit,
    projects,
    schedule,
  };
  return { ...semantic, contractHash: await sha256Text(stableJson(semantic)) };
}

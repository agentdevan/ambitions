import { createHash } from "node:crypto";
import { mkdtemp, mkdir, readFile, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import { compileRepository } from "../src/core/compiler.js";

async function repository(task: string, visualGate: string): Promise<string> {
  const root = await mkdtemp(join(tmpdir(), "ambitions-frontend-contract-"));
  const folder = join(root, "docs/product-development/example");
  await mkdir(join(folder, "implementation"), { recursive: true });
  const common = (kind: string, upstream: string, body: string) =>
    `+++\ninitiative = "example"\ndocument_type = "${kind}"\nstatus = "approved"\nupstream = "${upstream}"\n+++\n${body}\n`;
  await writeFile(
    join(folder, "research.md"),
    common(
      "research",
      "",
      "## Frontend impact investigation\n\n- Potential frontend impact: certain\n- Existing surfaces investigated: You\n- Evidence and unknowns: Existing route evidence.",
    ),
  );
  const matrix =
    "- Surface impact: new-child\n- IA/navigation: none\n- Assets/iconography: system-only\n- Visual language: unchanged\n- Motion: unchanged\n- Copy/localization: Existing patterns.\n- Accessibility: Native semantics.\n- Visual proof: One fixture.";
  await writeFile(
    join(folder, "scope.md"),
    common("scope", "research.md", `## Frontend impact contract\n\n${matrix}`),
  );
  await writeFile(
    join(folder, "design.md"),
    common(
      "design",
      "scope.md",
      `## Frontend experience specification\n\n${matrix}\n- Visual gate: ${visualGate}`,
    ),
  );
  await writeFile(join(folder, "implementation/plan.md"), "# Plan\n\nPlan.\n");
  await writeFile(
    join(folder, "implementation/tasks.md"),
    `# Tasks\n\n${task}\n`,
  );
  await writeFile(
    join(folder, "implementation/verification.md"),
    "# Verification\n\nVerify.\n",
  );
  await mkdir(join(root, "tools/linear-control/config"), { recursive: true });
  await writeFile(
    join(root, "tools/linear-control/config/portfolio-order.json"),
    JSON.stringify({ excludedSlugs: [], groups: [["example"]] }),
  );
  return root;
}

describe("frontend contract compilation", () => {
  it("matches the exact current verification document identity fixture", async () => {
    const manifest = await compileRepository(
      join(process.cwd(), "../.."),
      "199889e24a1f7aac39493d5a2b74be8da611bd47",
    );
    const contract = manifest.projects
      .find(
        (project) => project.slug === "cross-taxonomy-relationship-authority",
      )
      ?.documents.find((document) => document.kind === "verification");

    expect(contract).toMatchObject({
      gitBlobOid: "1896ae5793486b7ef47ad01f71e8272d2a6e877f",
      byteLength: 5866,
      sha256:
        "4cec51ecd1c24df65205c0d434324a77d8fb0b7f5e4351b8f7b458ab1903b919",
    });
  });

  it("records Git blob identity and preserves SHA-256 content authority", async () => {
    const root = await repository(
      "1. Build service. Dependency: none. Frontend: none.",
      "not-required",
    );
    const path = join(
      root,
      "docs/product-development/example/implementation/verification.md",
    );
    const bytes = await readFile(path);
    const expectedOid = createHash("sha1")
      .update(`blob ${bytes.byteLength}\0`)
      .update(bytes)
      .digest("hex");
    const expectedSha256 = createHash("sha256").update(bytes).digest("hex");

    const manifest = await compileRepository(root, "authority");
    const contract = manifest.projects[0]!.documents.find(
      (document) => document.kind === "verification",
    );

    expect(contract).toMatchObject({
      gitBlobOid: expectedOid,
      byteLength: bytes.byteLength,
      sha256: expectedSha256,
    });
  });

  it("identifies the first frontend task and blocks required visual approval", async () => {
    const root = await repository(
      "1. Build view. Dependency: none. Frontend: affected — REQ-001. Visual gate: required.",
      "required",
    );

    const manifest = await compileRepository(root, "authority");
    const project = manifest.projects[0]!;

    expect(project.frontendAudit).toEqual({
      status: "passed",
      visualGate: "required",
      firstFrontendTaskKey: "example:T1",
    });
    expect(project.tasks[0]!.frontendImpact).toBe("affected");
    expect(project.tasks[0]!.visualGate).toBe("required");
  });

  it("keeps unclassified tasks admission-pending", async () => {
    const root = await repository(
      "1. Build service. Dependency: none.",
      "not-required",
    );
    await writeFile(
      join(root, "tools/linear-control/config/portfolio-order.json"),
      JSON.stringify({ excludedSlugs: ["example"], groups: [] }),
    );

    const manifest = await compileRepository(root, "authority");

    expect(manifest.projects[0]!.admission).toBe("pending");
    expect(manifest.projects[0]!.admissionBlockers).toContain(
      "implementation/tasks.md:T1:frontend-unclassified",
    );
  });

  it("keeps incomplete frontend document matrices admission-pending", async () => {
    const root = await repository(
      "1. Build view. Dependency: none. Frontend: affected — REQ-001. Visual gate: required.",
      "required",
    );
    const scopePath = join(root, "docs/product-development/example/scope.md");
    const scope = await readFile(scopePath, "utf8");
    await writeFile(scopePath, scope.replace("- Motion: unchanged\n", ""));
    await writeFile(
      join(root, "tools/linear-control/config/portfolio-order.json"),
      JSON.stringify({ excludedSlugs: ["example"], groups: [] }),
    );

    const manifest = await compileRepository(root, "authority");

    expect(manifest.projects[0]!.admissionBlockers).toContain(
      "scope.md:frontend-field=Motion:missing",
    );
    expect(manifest.projects[0]!.frontendAudit.status).toBe("blocked");
  });
});

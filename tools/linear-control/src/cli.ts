#!/usr/bin/env node
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { compileRepository } from "./core/compiler.js";
import { stableJson } from "./core/hash.js";

const here = dirname(fileURLToPath(import.meta.url));
const repositoryRoot = resolve(here, "../../..");
const generatedPath = resolve(here, "../generated/desired-workspace.json");

async function main(): Promise<void> {
  const command = process.argv[2] ?? "check";
  if (command === "compile") {
    const manifest = await compileRepository(repositoryRoot);
    await mkdir(dirname(generatedPath), { recursive: true });
    await writeFile(generatedPath, `${JSON.stringify(manifest, null, 2)}\n`);
    console.log(
      JSON.stringify({
        status: "compiled",
        authorityCommit: manifest.authorityCommit,
        contractHash: manifest.contractHash,
        projects: manifest.projects.length,
        admitted: manifest.projects.filter(
          (project) => project.admission === "ready",
        ).length,
        pending: manifest.projects.filter(
          (project) => project.admission === "pending",
        ).length,
        scheduleGroups: manifest.schedule.length,
      }),
    );
    return;
  }
  const manifest = JSON.parse(await readFile(generatedPath, "utf8")) as Awaited<
    ReturnType<typeof compileRepository>
  >;
  if (command === "check" || command === "plan") {
    const fresh = await compileRepository(
      repositoryRoot,
      manifest.authorityCommit,
    );
    const matches = stableJson(fresh) === stableJson(manifest);
    console.log(
      JSON.stringify(
        {
          status: matches ? "converged" : "drift",
          authorityCommit: manifest.authorityCommit,
          contractHash: manifest.contractHash,
          projects: manifest.projects.length,
          admitted: manifest.projects.filter(
            (project) => project.admission === "ready",
          ).length,
          pending: manifest.projects.filter(
            (project) => project.admission === "pending",
          ).length,
        },
        null,
        2,
      ),
    );
    if (!matches) process.exitCode = 2;
    return;
  }
  if (command === "explain") {
    const key = process.argv[3];
    const project = manifest.projects.find(
      (item) => item.slug === key || item.canonicalKey === key,
    );
    const task = manifest.projects
      .flatMap((item) => item.tasks)
      .find((item) => item.canonicalKey === key);
    console.log(
      JSON.stringify(project ?? task ?? { error: "NOT_FOUND", key }, null, 2),
    );
    if (!project && !task) process.exitCode = 1;
    return;
  }
  if (command === "apply" || command === "replay")
    throw new Error(`${command.toUpperCase()}_REQUIRES_HOSTED_LEDGER`);
  throw new Error(`UNKNOWN_COMMAND:${command}`);
}

await main();

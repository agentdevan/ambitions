import { readFile } from "node:fs/promises";
import { LinearClient } from "./adapters/linear.js";
import type { DesiredWorkspaceManifest } from "./core/types.js";

const token = process.env.LINEAR_API_TOKEN;
if (!token) throw new Error("LINEAR_API_TOKEN_REQUIRED");

const manifest = JSON.parse(
  await readFile(
    new URL("../generated/desired-workspace.json", import.meta.url),
    "utf8",
  ),
) as DesiredWorkspaceManifest;
const client = new LinearClient(token, process.env.LINEAR_API_URL);
const data = await client.request<{
  projects: {
    nodes: Array<{
      name: string;
      documents: {
        nodes: Array<{ id: string; title: string; content: string }>;
      };
    }>;
  };
}>(`query {
  projects(first: 50, filter: { name: { startsWith: "Lifecycle — " }, state: { nin: ["completed", "canceled"] } }) {
    nodes { name documents { nodes { id title content } } }
  }
}`);

const synchronizedAt = new Date().toISOString();
const updates = data.projects.nodes.flatMap((project) =>
  project.documents.nodes
    .filter((document) => /^\d\d — /.test(document.title))
    .map((document) => ({
      id: document.id,
      content: document.content
        .replace(
          /^Repository commit: .*$/m,
          `Repository commit: ${manifest.authorityCommit}`,
        )
        .replace(
          /^Last synchronized: .*$/m,
          `Last synchronized: ${synchronizedAt}`,
        ),
    }))
    .filter(
      (update) =>
        update.content !==
        project.documents.nodes.find((document) => document.id === update.id)
          ?.content,
    ),
);

for (const update of updates)
  await client.request(
    `mutation($id: String!, $input: DocumentUpdateInput!) {
      documentUpdate(id: $id, input: $input) { success }
    }`,
    { id: update.id, input: { content: update.content } },
  );

console.log(
  JSON.stringify({
    documentsSynchronized: updates.length,
    authorityCommit: manifest.authorityCommit,
    synchronizedAt,
  }),
);

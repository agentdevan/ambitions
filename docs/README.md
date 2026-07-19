# Ambitions documentation router

`docs/canon/` is the sole normative repository authority.

## Read order

1. [canon/generated/CODEX_START_HERE.md](canon/generated/CODEX_START_HERE.md)
2. The bounded task pack generated for the current request
3. The exact Constitution, specifications, standards, and requirement IDs named by that pack
4. [../AGENTS.md](../AGENTS.md)
5. Relevant live source, tests, and current proof

Use [canon/MANIFEST.toml](canon/MANIFEST.toml) for the closed normative and
generated-file inventory. Use [canon/generated/INDEX.md](canon/generated/INDEX.md)
for deterministic discovery.

The former `truth/` and `constitution/` trees remain temporarily present as
non-normative migration inputs pending the governed purge. They are not active
routers and must not override `docs/canon/`.

Build, release, and validation support remains subordinate to canon and current
evidence. ChatGPT, Project Instructions, skills, intake, task packs, envelopes,
receipts, and local proof are procedural inputs only and cannot authorize work
or merge.

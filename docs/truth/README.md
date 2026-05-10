# Ambitions Truth Files

Status: Active repo authority index  
Scope: Product/design, implementation, release/proof, Codex process, and historical policy  
Applies to: Humans, Codex, and any AI agent working in the Ambitions repo

`docs/truth/` is the active authority layer for Ambitions. Start here before reading canon, status docs, `.codex`, `.agents`, batch-train material, or historical notes.

## Mandatory read order

1. `PRODUCT_DESIGN_TRUTH.md` — product/design authority.
2. `IMPLEMENTATION_TRUTH.md` — implementation/source authority.
3. `RELEASE_TRUTH.md` — validation, proof, release, and claim authority.
4. `CODEX_PROCESS_TRUTH.md` — Codex operating authority.
5. `HISTORICAL_POLICY.md` — historical extraction, quarantine, archive, and deletion policy.
6. `AGENTS.md`.
7. `README.md`.
8. `docs/README.md`.
9. `project.yml`.
10. `Package.swift`.
11. Relevant source, tests, scripts, release/build docs.
12. Relevant `.codex` / `.agents` files only after the truth files.

## Conflict resolution

| Conflict Type | Winner |
|---|---|
| Product/design direction | `PRODUCT_DESIGN_TRUTH.md` |
| Implementation/source status | Live source/project/test/script evidence, read through `IMPLEMENTATION_TRUTH.md` |
| Release/readiness/proof claim | Current proof/log evidence, read through `RELEASE_TRUTH.md` |
| Codex process behavior | `CODEX_PROCESS_TRUTH.md` |
| Historical/old-canon conflict | Active truth files |
| README/docs index conflict | Active truth files |
| `.codex`/`.agents` conflict | Active truth files |

## Supporting material

These areas are useful, but they do not override `docs/truth/*`:

- `docs/AmbitionsCanon/`
- `docs/status/`
- `docs/codex/`
- `.codex/`
- `.agents/`
- historical batch-train, audit, handoff, and closeout files

Use older material only when compatible with the truth files or explicitly classified by `HISTORICAL_POLICY.md`.

## What this directory does not prove

The truth files define authority and standards. They do not by themselves prove:

- implementation completeness
- local build success
- test success
- visual quality
- accessibility conformance
- performance validation
- physical-device validation
- TestFlight/App Store readiness
- release approval

Those claims require evidence through `RELEASE_TRUTH.md` and current proof artifacts.

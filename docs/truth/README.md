# Ambitions Truth Files

Status: Active repo authority index  
Scope: Product/design, implementation, release/proof, Codex process, and historical policy  
Applies to: Humans, Codex, and any AI agent working in the Ambitions repo

`docs/truth/` is the active authority layer for Ambitions. Start here before reading canon, status docs, `.codex`, `.agents`, batch-train material, or historical notes.

## Mandatory read order

1. `PRODUCT_DESIGN_TRUTH.md` — product/design authority.
2. `PRODUCT_MOAT_TRUTH.md` — moat strategy and anti-commodity guardrails (subordinate to active product/design truth).
3. `IMPLEMENTATION_TRUTH.md` — implementation/source authority.
4. `RELEASE_TRUTH.md` — validation, proof, release, and claim authority.
5. `CODEX_PROCESS_TRUTH.md` — Codex operating authority.
6. `HISTORICAL_POLICY.md` — historical extraction, quarantine, archive, and deletion policy.
7. `AGENTS.md`.
8. `README.md`.
9. `docs/README.md`.
10. `project.yml`.
11. `Package.swift`.
12. Relevant source, tests, scripts, release/build docs.
13. Relevant `.codex` / `.agents` files only after the truth files.

## Conflict resolution

| Conflict Type | Winner |
|---|---|
| Product/design direction | `PRODUCT_DESIGN_TRUTH.md` |
| Moat strategy and anti-commodity claims | `PRODUCT_MOAT_TRUTH.md` |
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

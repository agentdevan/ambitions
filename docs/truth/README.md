# Ambitions Truth Files

Status: Active repo authority index  
Scope: Product/design, moat, implementation, release/proof, Codex process, and repo retention  
Applies to: Humans, Codex, and any AI agent working in the Ambitions repo

`docs/truth/` is the active authority layer for Ambitions. Start here before reading supporting docs, source-adjacent notes, retained skills, scripts, or historical references.

## Mandatory Read Order

1. `PRODUCT_DESIGN_TRUTH.md` - product/design authority.
2. `PRODUCT_MOAT_TRUTH.md` - moat strategy and anti-commodity guardrails.
3. `IMPLEMENTATION_TRUTH.md` - implementation/source authority.
4. `IMPLEMENTATION_ACCEPTANCE_TRUTH.md` - rendered-product acceptance, split status, and visual proof authority.
5. `RELEASE_TRUTH.md` - validation, proof, release, and claim authority.
6. `CODEX_PROCESS_TRUTH.md` - Codex operating authority.
7. `HISTORICAL_POLICY.md` - repo retention and stale-file deletion authority.
7. `AGENTS.md`.
8. `README.md`.
9. `docs/README.md`.
10. `project.yml`.
11. `Package.swift`.
12. Relevant source, tests, retained scripts, build docs, and current local logs.
13. Relevant retained `.agents/skills/*/SKILL.md` files only after truth files.

## Active Product Law

```text
Persistent surfaces: Today / Goals / Time / You
Global composer: Capture
Behavior layer: Motion
Trust layer: Proof / Source / Privacy / History / Receipts
```

Motion is behavior, not a root destination. Capture is global composition, not a tab.

## Conflict Resolution

| Conflict Type | Winner |
|---|---|
| Product/design direction | `PRODUCT_DESIGN_TRUTH.md` |
| Moat strategy and anti-commodity claims | `PRODUCT_MOAT_TRUTH.md` |
| Implementation/source status | Live source/project/test/script evidence, read through `IMPLEMENTATION_TRUTH.md` |
| Rendered product acceptance | `IMPLEMENTATION_ACCEPTANCE_TRUTH.md` plus current reviewable screenshots and target rubric |
| Release/readiness/proof claim | Current proof/log evidence, read through `RELEASE_TRUTH.md` |
| Codex process behavior | `CODEX_PROCESS_TRUTH.md` |
| Historical/old-canon conflict | Active truth files and `HISTORICAL_POLICY.md` retention rules |
| README/docs index conflict | Active truth files |
| Skill/script/support-material conflict | Active truth files |

## Retained Supporting Material

Retained non-source material is intentionally small:

- `docs/README.md`
- `docs/native-build-and-release.md`
- root `AGENTS.md`
- root `README.md`
- retained build, validation, privacy, claim, copy, and canon-drift scripts
- at most three repo skills under `.agents/skills/`

Generated Codex state, old artifacts, prompts, trains, stale batch docs, backup truth files, and historical proof matrices are not retained in-repo.

## What Truth Files Do Not Prove

Truth files define authority and standards. They do not by themselves prove implementation completeness, local build success, test success, visual quality, accessibility conformance, performance validation, physical-device validation, TestFlight/App Store readiness, or release approval.

Those claims require current evidence through `RELEASE_TRUTH.md`.

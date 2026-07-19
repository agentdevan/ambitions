# Repo Retention Truth

Status: Active retention authority  
Scope: Historical material, stale non-source files, generated artifacts, prompts, trains, skills, scripts, and repo control-plane junk  
Applies to: All non-source files in the Ambitions repo

This file replaces the old historical archive policy. Ambitions does not retain historical junk in-repo.

## Codex digest
- Read when: work touches docs cleanup, retention, historical material, generated artifacts, prompts, trains, stale skills, stale scripts, or repo control-plane files.
- Owns: what non-source material stays, is rewritten, or is deleted.
- Does not own: active product canon, implementation proof, release proof, or source architecture.
- Hard red: retaining stale Motion-root/Capture-tab canon, generated Codex state, old proof as current proof, or historical docs as active authority.
- Proof/closeout impact: cleanup must preserve current useful authority and remove or update stale non-source material without moving canon into historical docs.

## Rule

Non-source files stay only when they are accurate to current canon and directly help build, validate, ship, or govern Ambitions toward App Store readiness.

Default action for stale non-source files is deletion, not quarantine.

## Current Canon

```text
Persistent surfaces: Today / Goals / Time / You
Global composer: Capture
Behavior layer: Motion
Trust layer: Proof / Source / Privacy / History / Receipts
```

Motion is not a tab or destination. Capture is not a tab.

## Keep

Keep these categories when current:

- truth files under `docs/truth/`
- root `AGENTS.md`
- root `README.md`
- `docs/README.md`
- `docs/native-build-and-release.md`
- source-adjacent docs that are accurate and required to build or validate source
- docs-local Figma/UI production gate skills under `docs/skills/`, when subordinate to `docs/truth/FIGMA_PRODUCTION_GATE_ADDENDUM.md`
- source, tests, fixtures used by tests, resources, entitlements, privacy manifests, project config, package config, and CI/build config that still runs
- small scripts that are current, dry-run/build useful, and free of stale IA/control-plane assumptions
- the five retained `.agents` skills registered in `.agents/skills/README.md`: source-truth authority, architecture-tree enforcement, iOS quality gate, release proof honesty, and runtime contract engineering
- no non-retained `.agents` skill files; any further retained skill requires explicit truth-file approval and proof that the need cannot be covered by the retained skills or `docs/truth/CODEX_START_HERE.md`

## Delete

Delete these categories unless a future active truth file explicitly reintroduces them:

- tracked `.codex/` state, logs, archives, generated run files, and temporary control-plane files
- tracked `artifacts/` proof from old work
- prompts and train manifests
- old object-stage trains, release-recovery, autopilot, and one-off batch material
- old audit ledgers, stale validation docs, backup truth files, old screenshots, and proof matrices
- stale scripts and workflows that only support old control planes
- stale skills and skill packs
- non-source files that promote Motion as a current root IA surface

## Generated State

Local/generated state may be created for active validation, but it must remain ignored unless explicitly scoped as current release proof. Old proof is not current App Store proof.

## Rewrite Or Delete

If a retained non-source file becomes inaccurate, choose one:

1. Rewrite it so it is current and useful.
2. Delete it.

Do not keep historical context for nostalgia, searchability, or future speculation.

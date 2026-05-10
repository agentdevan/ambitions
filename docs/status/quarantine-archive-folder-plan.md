# Quarantine / Archive Folder Plan

Status: Green for T07b planning-only pass  
Date: 2026-05-09

## Authority

Active repo authority starts in `docs/truth/README.md`. If this plan conflicts with `docs/truth/*`, the truth files win.

Phase 11 reconciliation note, 2026-05-10: this plan remains proposed
quarantine/archive structure only. It does not authorize moves by itself.
Current archive/delete gates live in
`docs/status/archive-and-stale-material-ledger.md`.

## Scope

T07b is a planning-only pass.

No Swift source changes, app implementation changes, deletes, file moves, archive operations, build/test/device validation, or release/readiness claims were made.

## Purpose

Define the proposed archive/quarantine folder structure and move batches for future cleanup, while preserving traceability and preventing accidental loss of useful Codex operating history.

This plan does not authorize file moves by itself. Each move batch needs explicit approval, an inbound reference check, replacement authority, and rollback notes.

## Proposed Folder Structure

```text
docs/archive/
  README.md
  legacy-canon/
    README.md
    ambitions-3-0/
    ambitions-4-0/
    pxos-acui-si/
  codex-history/
    README.md
    old-prompts/
    old-operating-systems/
    old-batch-trains/
    old-context-packs/
  handoff-history/
    README.md
  audit-history/
    README.md
  release-history/
    README.md

.agents/quarantine/
  README.md
  provider-skills/
    supabase/
    supabase-postgres-best-practices/
```

## Folder Rules

| Folder | Purpose | Rule |
| --- | --- | --- |
| `docs/archive/legacy-canon/` | Older Ambitions 3.0 / 4.0 / PXOS / ACUI / SI canon retained for traceability | Historical only; cannot override `docs/truth/*`. |
| `docs/archive/codex-history/old-prompts/` | Copy/paste prompts and resume prompts that are no longer current | Do not use as current prompts; extract durable rules first. |
| `docs/archive/codex-history/old-operating-systems/` | Old Codex OS docs superseded by `docs/truth/CODEX_PROCESS_TRUTH.md`, `AGENTS.md`, `.codex/README.md` | Supporting history only. |
| `docs/archive/codex-history/old-batch-trains/` | Old train manifests/registries/closeouts that are not active | Preserve if they explain historical implementation decisions. |
| `docs/archive/handoff-history/` | Handoff records no longer needed as front-door docs | Preserve traceability; not implementation proof by default. |
| `docs/archive/audit-history/` | Old audits and scans | Preserve if they support historical decisions. |
| `docs/archive/release-history/` | Old release/App Store/TestFlight/readiness material | Must carry no current release-readiness claim. |
| `.agents/quarantine/provider-skills/` | External provider skill packages | Do not auto-load for Ambitions core work. |

## Proposed Move Batches

### T07c — Provider Skill Quarantine Move

Candidate moves:

```text
.agents/skills/supabase/ -> .agents/quarantine/provider-skills/supabase/
.agents/skills/supabase-postgres-best-practices/ -> .agents/quarantine/provider-skills/supabase-postgres-best-practices/
```

Preconditions:

- Owner approval.
- Update `docs/status/codex-agents-skill-inventory.md`.
- Update `docs/status/cleanup-decision-register.md`.
- Update `.codex/manifests/skills-routing-map.yml` forbidden roots.
- Confirm no current automation expects these exact old paths.

Rollback:

- Move folders back to `.agents/skills/` and restore routing references.

### T07d — Historical Prompt Archive Move

Candidate folders/files:

```text
docs/codex/MASTER_AMBITIONS_3_0_CODEX_PROMPT.md
docs/codex/FAANG_HANDOFF_REPO_CLEANUP_PROMPT.md
other one-off prompt docs identified by inbound ledger
```

Target:

```text
docs/archive/codex-history/old-prompts/
```

Preconditions:

- Extract durable current process rules into `docs/truth/CODEX_PROCESS_TRUTH.md`, `AGENTS.md`, or a supporting active status doc if not already present.
- Update inbound links or leave redirect stubs if needed.
- Confirm archived prompts are not used by current batch-train resume docs.

Rollback:

- Restore prompt files to original paths and revert link updates.

### T07e — Legacy Canon Archive Move

Candidate groups:

```text
docs/canon/Ambitions_3_0*
docs/canon/Ambitions_4_0*
docs/canon/*PXOS*
docs/canon/*ACUI*
docs/canon/*SI*
```

Target:

```text
docs/archive/legacy-canon/ambitions-3-0/
docs/archive/legacy-canon/ambitions-4-0/
docs/archive/legacy-canon/pxos-acui-si/
```

Preconditions:

- Do not move any file still serving as a live compatibility reference unless a replacement pointer exists.
- Keep `docs/AmbitionsCanon/` in place.
- Verify all moved files have headers or are covered by classification overrides.
- Update docs that intentionally reference the old files.

Rollback:

- Move files back to `docs/canon/` and restore links.

### T07f — Codex History Archive Move

Candidate areas:

```text
docs/codex/FREE_WORKFLOW_OPERATING_SYSTEM.md
docs/codex/MASTER_CODEX_SYSTEM.md
docs/codex/old context/index docs with stale 3.0-active routing
.codex/context-packs/ stale packs
.codex/reports/ old closeouts
.codex/improvement/ old loops
```

Target:

```text
docs/archive/codex-history/old-operating-systems/
docs/archive/codex-history/old-context-packs/
docs/archive/codex-history/old-batch-trains/
```

Preconditions:

- Confirm not required by `AGENTS.md`, `.codex/README.md`, `docs/codex/CODEX_OS_INDEX.md`, current batch state, or active EFC overlay.
- Do not move active skill, validation, manifest, or report files without an explicit routing replacement.

Rollback:

- Restore old paths and revert link updates.

### T07g — Audit / Handoff Archive Move

Candidate areas:

```text
docs/audits/ old one-time scans
docs/handoff/ old handoff packets
docs/status/ older cleanup reports superseded by truth/status files
```

Targets:

```text
docs/archive/audit-history/
docs/archive/handoff-history/
docs/archive/release-history/
```

Preconditions:

- Preserve any file that is still cited by active release evidence or implementation status.
- Extract durable current findings into `docs/status/*` before moving.
- Do not move raw proof logs if they are the only evidence for a claim.

Rollback:

- Restore files to original folders and restore links.

## Files / Areas Not To Move In T07

Do not move or delete:

```text
docs/truth/
README.md
docs/README.md
AGENTS.md
docs/status/current-implementation-map.md
docs/status/release-evidence-packet.md
docs/status/cleanup-decision-register.md
docs/status/reference-dependency-scan-cleanup-plan.md
docs/status/large-doc-classification-overrides.md
docs/native-build-and-release.md
docs/AmbitionsCanon/
Native/
Sources/
AppUI/
project.yml
Package.swift
scripts/
resources, entitlements, privacy manifests, test targets, extension targets
```

## Required Move-Pass Checklist

Each future move pass must include:

1. exact file list
2. old path -> new path map
3. reason for each move
4. inbound reference search results
5. replacement authority
6. link update list
7. rollback plan
8. no-claim statement
9. validation statement
10. explicit owner approval if moving provider skills, batch-train material, proof/release records, or anything large/truncated through connector reads

## Hard Red Blocks

Stop the move pass if:

- a file body is truncated and the operation requires whole-file replacement
- an inbound reference cannot be updated or intentionally preserved
- a current front door would break
- an active truth/status file would be moved
- app source, build config, package manifests, scripts, tests, resources, entitlements, or privacy files would be touched without explicit implementation scope
- cleanup would imply release readiness, device validation, accessibility conformance, backend activation, or hosted CI proof
- provider/backend material would become easier to auto-load by accident

## T07b Decision

Recommended first destructive-capable pass is T07c only if approved:

```text
Move quarantined Supabase provider skills from `.agents/skills/` to `.agents/quarantine/provider-skills/` and update references.
```

This is the cleanest first move because the provider skills are already quarantined, externally sourced, and not active Ambitions architecture.

## Validation

- This file was created through the GitHub connector.
- No Markdown/link checker was run.
- No `xcodegen`, `xcodebuild`, unit test, UI test, archive, accessibility, performance, physical-device, TestFlight, or App Store validation was run.

## Next Recommended Step

T07c — Provider Skill Quarantine Move, only after explicit approval to move `.agents/skills/supabase*` into `.agents/quarantine/provider-skills/` and update references.

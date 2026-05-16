# Reference Dependency Scan And Cleanup Execution Plan

Status: Train D / Phase 11 YELLOW non-destructive scan  
Date: 2026-05-16  
Authority: Subordinate to `docs/truth/*`, `docs/status/README.md`, `docs/status/archive-and-stale-material-ledger.md`, and `docs/status/archive-delete-candidate-register.md`.

This plan governs archive/delete/move preparation after Trains A-C. It replaces older T06/T07 wording with the current repo-governance cleanup train state.

## Scope

Phase 11 is a non-destructive dependency and cleanup planning pass only.

No Swift source changes, app implementation changes, deletes, file moves, archive operations, build/test/device validation, or release/readiness claims are made by this plan.

## Current prerequisites

Completed before this pass:

- Train A: authority foundation and old-canon classification index.
- Train B: partial historical header quarantine, accepted Yellow.
- Train C: active surface hygiene routing, generated-report classification, scanner scripts, accepted Yellow.

Relevant current docs:

- `docs/status/repo-governance-master-cleanup-plan.md`
- `docs/status/old-canon-classification-index.md`
- `docs/status/train-b-historical-header-quarantine-receipt-2026-05-16.md`
- `docs/status/train-c-active-surface-hygiene-receipt-2026-05-16.md`
- `docs/status/generated-report-classification.md`
- `docs/audits/README.md`
- `prompts/README.md`
- `docs/codex/batches/README.md`
- `docs/codex/batch-trains/README.md`

## Search inputs inspected in Train D

Representative targeted searches were run for:

- `Ambitions_2_0_Master_Plan.md`
- `MASTER_AMBITIONS_3_0_CODEX_PROMPT.md`
- `PXOS_Empty_Edge_And_Degraded_States.md`

These searches showed inbound references from active/supporting ledgers, historical inventories, audits, old canon files, Codex routing docs, and Train B receipts. This confirms candidate families are not safe for broad deletion or archive movement yet.

## Dependency findings

| Area | Dependency status | Current decision |
|---|---|---|
| `docs/canon/Ambitions_2_0_*` | Representative inbound refs remain. | Retain; no archive/delete in Phase 11. |
| `docs/codex/Ambitions_2_0_*` | Representative inbound refs remain. | Retain; no archive/delete in Phase 11. |
| `docs/canon/Ambitions_3_0_*` | Useful copy/privacy/QA/design decisions and inbound refs remain. | Retain; continue header/extraction before movement. |
| `docs/codex/MASTER_AMBITIONS_3_0_CODEX_PROMPT.md` | Inbound refs remain from status/Codex/audit contexts. | Retain; archive only after stubs/routing updates. |
| `docs/canon/Ambitions_4_0_*` | Train B connector-blocked files and External Brain references remain. | Retain; local safer patch/extraction first. |
| `docs/canon/PXOS_*` | Representative inbound refs remain from PXOS handoff/index/audits/status. | Retain; archive only after PXOS family stubs/routing. |
| `docs/codex/batches/*`, `prompts/batches/*` | Prompt routing installed, but family refs likely remain. | Retain pending prompt-family scan. |
| `docs/codex/batch-trains/*` | README demoted, but train files likely retain references. | Retain pending family-specific scan. |
| `docs/audits/*` | Audit routing installed; receipts remain proof-adjacent/historical. | Retain pending evidence-retention pass. |
| `docs/handoff/*` | Likely historical references remain. | Retain pending handoff-family scan. |
| `build/reports/*` | Generated report classification installed, but safe delete requires ownership/regeneration proof. | Retain pending generated-artifact scan. |

## Archive/delete candidate register

The current candidate register is:

- `docs/status/archive-delete-candidate-register.md`

It is the current Phase 11 candidate table. It records that no deletions and no archive moves are approved yet.

## Required sequence before any archive movement

1. Select one family only.
2. Run local `rg` inbound-reference scan.
3. Record replacement authority.
4. Extract durable decisions into active truth/status docs or explicitly retain them as historical.
5. Prepare stubs/redirects for referenced paths.
6. Record rollback path.
7. Move only that family.
8. Re-run reference scan and update ledgers.

## Required sequence before any deletion

1. Confirm the file has no active/supporting inbound references.
2. Confirm durable value has already been extracted or intentionally discarded with approval.
3. Confirm release/proof/audit value is not needed.
4. Confirm regeneration path if generated.
5. Record rollback method.
6. Delete only after owner approval.

## Hard Red blocks

Stop immediately if a cleanup pass would:

- touch Swift/source files;
- touch `project.yml`, `Package.swift`, entitlements, app resources, privacy manifests, or scripts without explicit implementation scope;
- delete or move `docs/truth/*`;
- delete current implementation/release evidence docs;
- break root front-door routing;
- remove batch history without an extraction record;
- remove raw proof/evidence logs;
- make release/readiness/accessibility/device claims;
- imply Supabase/backend/provider architecture is active;
- move/delete generated reports without regeneration/ownership proof.

## Accepted Yellow limitations

- GitHub connector search is not a full static link graph.
- No local `rg` output was captured here.
- No markdown link checker was run.
- No scripts were run locally.
- No build/test validation was run.

## Current Phase 11 result

Phase 11 is Yellow complete for direct GitHub API purposes.

It provides a non-destructive candidate register and updated reference plan. It does not authorize archive migration, deletion, or final cleanup closeout.

## Next recommended train step

Before Phase 12 archive migration, run a local/Antigravity reference pass for the Ambitions 2.0 family and prepare stubs. If local proof is unavailable, keep Phase 12 blocked and do not move files.

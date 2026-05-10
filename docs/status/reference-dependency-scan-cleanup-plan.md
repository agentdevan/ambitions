# Reference Dependency Scan And Cleanup Execution Plan

Status: Green for T06 non-destructive scan / Yellow for exhaustive certainty  
Date: 2026-05-09

## Authority

Active repo authority starts in `docs/truth/README.md`. If this plan conflicts with `docs/truth/*`, the truth files win.

Phase 11 reconciliation note, 2026-05-10: this plan remains a non-destructive
supporting scan. Current stale/archive/delete routing lives in
`docs/status/archive-and-stale-material-ledger.md`; repo question routing lives
in `.codex/REPO_INVENTORY.md`.

## Scope

T06 is a non-destructive planning pass only.

No Swift source changes, app implementation changes, deletes, file moves, archive operations, build/test/device validation, or release/readiness claims were made.

## Scan Inputs

- `docs/truth/*`
- `docs/status/cleanup-decision-register.md`
- `docs/status/codex-agents-skill-inventory.md`
- `docs/status/large-doc-classification-overrides.md`
- GitHub search for stale authority phrases and provider/backend references.
- High-risk large-doc behavior observed through connector reads.

## Search Findings

### Stale 3.0-active phrasing still exists

Search for `"Ambitions 3.0 is the active"` found retained references in:

- `docs/codex/FREE_WORKFLOW_OPERATING_SYSTEM.md`
- `docs/codex/MASTER_CODEX_SYSTEM.md`
- `docs/codex/README.md`
- `docs/codex/MASTER_AMBITIONS_3_0_CODEX_PROMPT.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/audits/faang-handoff-internal-identifier-scan.txt`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/codex/FAANG_HANDOFF_REPO_CLEANUP_PROMPT.md`

Decision: keep as historical/supporting context until a safe rewrite/archive pass. Do not treat these references as active authority.

### Older AmbitionsCanon-first routing still exists in supporting/history areas

Search for AmbitionsCanon/source-truth routing found retained references in:

- `docs/status/repo-cleanup-index.md`
- `docs/status/repo-wide-cleanup-report.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/audits/gq01-global-queue-maturity-report.md`
- `docs/audits/ambitions-canon-pack-repo-phase-0-orientation-audit.md`
- `docs/AmbitionsCanon/Archive/README.md`
- `docs/status/current-implementation-map.md`

Decision: front doors have already been rewired to `docs/truth/*`; retained supporting/history references are not deletion-safe until link and purpose checks run.

### Provider/backend references are contained but quarantined

Search for Supabase/Postgres/backend/provider wording found the expected quarantined provider skill roots plus truth/status files that explicitly classify them:

- `.agents/skills/supabase/`
- `.agents/skills/supabase-postgres-best-practices/`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/status/cleanup-decision-register.md`

Decision: provider skill roots remain quarantine. Do not delete until durable generic safety lessons are extracted or owner approves removal.

## Dependency Decisions

| Area | Dependency Status | Cleanup Decision |
| --- | --- | --- |
| `docs/truth/` | Active authority | Keep. Never archive/delete in cleanup pass. |
| `README.md`, `docs/README.md`, `AGENTS.md` | Active front doors | Keep. Already truth-first. |
| `docs/status/current-implementation-map.md` | Active supporting implementation map | Keep. |
| `docs/status/release-evidence-packet.md` | Active supporting proof/release posture | Keep. |
| `docs/status/cleanup-decision-register.md` | Active cleanup classifier | Keep. |
| `docs/status/large-doc-classification-overrides.md` | Active override for large files | Keep until physical headers are safely applied. |
| `docs/AmbitionsCanon/` | Supporting product/design canon | Keep; not an archive target as a whole. |
| `docs/codex/` current operating files | Supporting Codex operating system | Keep; targeted stale-file cleanup only. |
| `.codex/skills/` | Supporting operating skill library | Keep; active/candidate classification already recorded. |
| `.agents/skills/supabase*` | Quarantine | Retain for now; T07 may move to quarantine/archive only with owner approval. |
| old `docs/canon/Ambitions_3_0*` / 4.0 / PXOS / ACUI / SI material | Historical/supporting | Archive candidates after link checks and extraction. |
| `docs/audits/` and `docs/handoff/` | Historical/supporting evidence | Keep until an evidence-retention pass identifies duplicates. |
| stale tracked inventories / one-off prompts / duplicate closeouts | Deletion candidates | No deletion until replacement authority and inbound links are proven. |

## T07 Proposed Safe Execution Order

T07 should not be a mass delete. Run as small PR-sized passes:

1. **T07a — Link Map And Inbound Reference Ledger**
   - Create a generated or manually curated table of inbound links to historical/quarantine candidates.
   - No moves/deletes.

2. **T07b — Quarantine Folder Plan**
   - Propose target folders only, for example `docs/archive/`, `docs/archive/codex-history/`, `docs/archive/handoff-history/`, `docs/archive/legacy-canon/`, and `.agents/quarantine/`.
   - No moves/deletes without approval.

3. **T07c — Provider Skill Quarantine Move**
   - Move `.agents/skills/supabase*` only if the owner approves.
   - Update references to point to `docs/status/codex-agents-skill-inventory.md` and the new quarantine path.
   - No app/source changes.

4. **T07d — Historical Prompt Archive Move**
   - Move old copy/paste prompt files after extracting durable process rules.
   - High priority candidates: `docs/codex/MASTER_AMBITIONS_3_0_CODEX_PROMPT.md`, old workflow prompts, one-off FAANG cleanup prompts.

5. **T07e — Legacy Canon Archive Move**
   - Move only Ambitions 3.0/4.0/PXOS/ACUI/SI files with no current inbound authority dependency.
   - Do not move `docs/AmbitionsCanon/` active/supporting canon.

6. **T07f — Duplicate Report Cleanup Plan**
   - Compare closeout reports/audits for unique evidence.
   - Mark deletion candidates only after extracting unique decisions and preserving proof links.

## Hard Red Blocks For Cleanup

Stop immediately if a cleanup pass would:

- touch Swift/source files
- touch `project.yml`, `Package.swift`, entitlements, app resources, privacy manifests, or scripts without explicit implementation scope
- delete or move `docs/truth/*`
- delete current implementation/release evidence docs
- break root front-door routing
- remove batch history without an extraction record
- remove raw proof/evidence logs
- make release/readiness/accessibility/device claims
- imply Supabase/backend/provider architecture is active

## Accepted Yellow Limitations

- GitHub search is useful but not a full static link graph.
- Some large files return truncated connector contents, so physical header edits remain unsafe through this connector.
- No markdown link checker was run.
- No build/test validation was run because this is docs/control-plane only.

## Next Recommended Step

T07a — create an inbound reference ledger for proposed archive/quarantine candidates. No files should be moved or deleted until T07a proves which candidates are still referenced and what replacement authority exists.

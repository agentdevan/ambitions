# AMB-660 / PLOS-027 - 20-Year Compaction and Annual Snapshot Policy

Status: Green for scoped policy documentation after validation
Date: 2026-06-12
Linear issue: AMB-660
PLOS label: PLOS-027
Parent: AMB-610 / PLOS-M02
Scope: Define long-horizon local data compaction, retention tiers, annual snapshot behavior, exportability, and storage-cost guardrails.
Out of scope: Compaction engine implementation, SwiftData schema migration, archive UX, export UX, CloudKit sync behavior, R2 behavior, privacy manifest changes, release claims, performance claims, accessibility claims, and device claims.

## Source Authority Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotService.swift`
- `Native/Ambitions/Persistence/SwiftDataStore.swift`
- `Native/Ambitions/Persistence/PersistenceContracts.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/Ambitions/Domain/RuntimeSnapshotLedgerModels.swift`
- `Native/Ambitions/Domain/EntityRevisionTombstoneModels.swift`
- Prior M02 reports: PLOS-020 through PLOS-026.

## Validation Evidence

- Required search: `rg -n "snapshot|archive|compaction|retention" .`
  - Output: `artifacts/personal-life-os/validation/PLOS-027-compaction-snapshot-required-search-log.txt`
  - Lines: 22,040
- Focused search over persistence, domain, services, support, tests, truth/docs, and M02 reports for snapshot/archive/compaction/retention/annual/tombstone/receipt/export/reset/delete/SwiftData/CloudKit/R2/privacy/storage-cost terms.
  - Output: `artifacts/personal-life-os/validation/PLOS-027-focused-compaction-snapshot-search-log.txt`
  - Lines: 14,755
- `git diff --check`: pass
- `python3 scripts/codex/plos-readiness-validate.py`: pass
- `scripts/codex/program-preflight.sh plos`: pass
- `scripts/codex/program-phase-gate.sh plos M02`: pass
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-027-20-year-compaction-annual-snapshot-policy.md`: pass
- `bash scripts/codex/program-proof-index.sh plos`: pass
- `git diff --cached --check`: pass

## Current Source Facts

Current source supports local portable snapshot/export contracts, receipt history, tombstone lineage, runtime snapshot ledger records, and reset behavior. It does not implement a 20-year compaction engine or annual snapshot scheduler.

- `PortableExportCategory` currently defines export categories for goals/plans, captures, proof, receipts, memory, and settings. Receipts include goal feedback, canonical action receipts, revision tombstones, and redacted lineage views.
- `PortableAppSnapshot` carries metadata, manifest, goals, drafts, progress evidence, feedback, action receipt history, entity revision tombstones, redacted lineage views, captures, teaching signals, and app state.
- `PortableSnapshotService.exportSnapshot(selection:)` loads receipts and tombstones, maps tombstones through export-safe projections, and includes them only when the receipts category is selected.
- `PortableSnapshotService.loadEntityRevisionTombstones()` currently uses `fetchRecent(limit: .max)`, which is export-complete but not long-horizon scale proof.
- `EntityRevisionTombstone` distinguishes delete, supersede, replace, reset, conflict recovery, lifecycle state, local-only posture, privacy class, lineage, and export-safe redaction.
- `RuntimeSnapshotLedgerEnvelope` stores local-only source, receipt, replay, recommendation input, proof input, and lineage references with field redactions, checksum, provenance hash, and export-safe projection status.
- `RuntimeSnapshotLedgerEnvelope.afepReadBudget` defines a bounded read budget of 4 for runtime snapshot ledger reads, but this is a contract, not measured long-horizon performance proof.
- `AmbitionsPersistenceStore.resetAllData()` hard-deletes goals, drafts, evidence, feedback, captures, reminders, teaching signals, event ledger, command execution, side-effect ledger, tombstones, app state, action receipt history, runtime snapshot ledger records, life context, graph projections, graph proof, and graph operational records.

## Policy Decision

Ambitions should treat long-horizon data as a user-owned local history with compaction tiers, not as dark retention and not as loss-prone cleanup. Compaction may reduce detail and denormalize summaries, but it may not erase required exportability, proof continuity, tombstone/lineage safety, reset/delete semantics, or user-owned explanation paths.

The 20-year model is:

| Tier | Approximate age | Default posture | Compaction rule | Export rule |
|---|---:|---|---|---|
| Active working set | 0-90 days | Full-fidelity local records | No automatic loss of detail; indexes and queries optimize current execution. | Full category-selected export. |
| Recent history | 90 days-2 years | Full-fidelity records with bounded query surfaces | Detail remains local; UI/repository reads should page and prefer summaries for broad scans. | Full category-selected export. |
| Annual history | 2-20 years | Annual snapshot plus retained lineage/proof anchors | Compress derived views into annual summaries while preserving original user-owned export data unless the user deletes/resets. | Export must include either original records or an explicit annual snapshot representation plus lineage/manifest. |
| Finalized tombstone/lineage layer | Indefinite while needed for anti-resurrection/proof integrity | Minimal local lineage and receipt-safe state | Keep only the minimum needed to explain deletion, prevent false resurrection, preserve proof integrity, and support conflict/replay review. | Export safe lineage/tombstone view; private links redacted by policy. |
| Reset-deleted state | After explicit full reset | Hard-deleted local data | Reset may delete snapshot, tombstone, receipt, runtime ledger, learning, and graph records after explicit confirmation. | No export after reset unless the user exported before reset. |

## Annual Snapshot Strategy

Annual snapshots are a future local compaction product object, not a remote archive and not an App Store/privacy proof artifact. They should be generated locally, under user-owned storage, and treated as a compact index into the user's year.

Each annual snapshot must include:

- year and schema version
- generated-at timestamp
- local-only trust posture
- category manifest for goals/plans, captures, proof, receipts, memory, and settings
- counts and date ranges per category
- receipt/proof continuity summary
- tombstone/lineage summary with redacted private links
- checksum/provenance hash for replay and migration review
- compatibility status for future imports
- storage estimate before and after compaction
- explicit list of excluded/private fields
- export-mode indicator showing whether the snapshot is summary-only or paired with original records

Annual snapshots must not include:

- raw private user text inside public or R2-bound material
- R2 object keys derived from user goals, schedules, captures, receipts, or proof
- analytics, telemetry, crash, support, or hosted backend identifiers
- cloud LLM inputs or outputs
- hidden learning state without reset/delete/export controls

## Exportability and Delete/Reset Rules

PLOS-027 accepts the PLOS-024 receipt policy and PLOS-022 lifecycle policy:

- Compaction may never turn user-owned data into non-exportable internal-only history.
- Annual summaries may accelerate export preview, but full export must still disclose whether it includes original records, compacted records, annual summaries, tombstones, or redacted projections.
- Delete may replace detail with minimal tombstone/lineage only when needed for anti-resurrection, proof integrity, import/merge conflict safety, or sync conflict safety.
- Full reset may remove compacted snapshots, annual summaries, receipt history, tombstones, and runtime snapshot ledgers after explicit confirmation.
- Export before reset is the user-owned escape hatch. After reset, Ambitions must not pretend deleted local state can be recovered.
- R2 is not a compaction/archive destination for private annual snapshots or user export packages.
- Future CloudKit may sync user-owned compacted records only under private user database rules from PLOS-021 and M23 proof.

## Storage-Cost Guardrails

Long-horizon local storage is Yellow until implementation measures real size and query behavior. Future implementation must prove:

- no unbounded `.max` scans on hot paths or export preview paths without paging/streaming
- bounded indexes for date, category, goal/path, lifecycle, receipt/proof, and tombstone retrieval
- annual snapshot generation runs locally and can pause/resume safely
- compaction is idempotent and repairable through manifest/checksum validation
- import/restore can detect old snapshot schema and unsupported compatibility states
- storage estimates are user-facing before destructive compaction, delete, or reset
- compaction does not mutate current recommendations silently
- runtime snapshot ledger export uses export-safe projections or explicit review-only state

## Privacy and Cloud Boundary

The compaction model stays local-first:

- Private annual snapshots are local/user-owned data.
- CloudKit eligibility is future-owned and private-database only.
- R2 eligibility is blocked for private annual snapshots, exports, receipts, proof, local learning, user mini-packs, diagnostics, and support bundles.
- Diagnostics/support bundles remain future-owned and must use opt-in, redacted, non-default behavior.
- Current checked-in privacy manifest remains unchanged by this report.

## Follow-Up Owners

- M23 / AMB-632: CloudKit/iCloud sync hardening for compacted snapshots, tombstones, schema compatibility, and no-resurrection behavior.
- M24 / AMB-633: Diagnostics/support/export UX for export preview, support bundle redaction, and user-visible storage estimates.
- M25 / AMB-634: App Review/compliance reconciliation for final privacy labels, permission prompts, legal/privacy review, and support copy.
- M26 / AMB-635: Full certification gauntlets for long-horizon storage, import/export, reset, performance, accessibility, device, and release proof.
- Source-changing implementation phase: add concrete annual snapshot model, compaction manifest, repository paging, and tests under current owners before claiming runtime behavior.

## Red / Yellow / Green

Green for this issue:

- Long-horizon storage model documented.
- Annual snapshot strategy explicit.
- Required search executed and preserved.
- Exportability, reset/delete, local-first, R2 exclusion, CloudKit future ownership, and storage-cost guardrails documented.

Yellow / future-owned:

- No compaction engine exists.
- No annual snapshot model exists in source.
- No SwiftData migration/index/paging change was made.
- No measured 20-year storage cost proof exists.
- No export UX, reset UX, or archive UX was changed.
- No CloudKit compacted-record transport was implemented.
- No privacy/legal/App Store/release/device/accessibility/performance proof was produced.

Red blockers avoided:

- No private user data was assigned to R2.
- No custom hosted user-data backend was introduced.
- No cloud LLM dependency was introduced.
- No app source changed.
- No release, privacy approval, accessibility, performance, or device claim was made.

## Closeout

PLOS child closeout: AMB-660 / PLOS-027
Parent issue: AMB-610 / PLOS-M02
Green/Yellow/Red status: Green for scoped documentation/control-plane policy; Yellow for future implementation, storage/performance proof, CloudKit/R2 proof, privacy/legal/release proof, accessibility proof, and device proof.
Pushed to main: pending at report validation time
Push hash: pending at report validation time
PLOS-M00 executed: no; PLOS-M00 was already complete before this child and was not re-executed in AMB-660.
Linear identifiers used: AMB-660 child issue; AMB-610 parent issue.
Validation run: required `rg`; focused `rg`; `git diff --check`; JSON parse for PLOS queue/map; `python3 scripts/codex/plos-readiness-validate.py`; `scripts/codex/program-preflight.sh plos`; `scripts/codex/program-phase-gate.sh plos M02`; `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-027-20-year-compaction-annual-snapshot-policy.md`; `bash scripts/codex/program-proof-index.sh plos`; `git diff --cached --check`.
Red blockers: none for scoped AMB-660 documentation/control-plane policy after validation.
Yellow limits: no compaction engine; no annual snapshot source model; no SwiftData migration/index/paging; no export/reset/archive UX; no CloudKit or R2 implementation; no measured storage/performance proof; no privacy/legal approval; no release/TestFlight/App Store readiness; no accessibility proof; no device proof; no PLOS-M03+ execution.
Owner approval claimed: no.
Release/TestFlight/App Store readiness claimed: no.
Next recommended action: after AMB-660 is committed, pushed to `main`, moved to Done in Linear, and all live-resolved M02 children are verified Done, run AMB-610 / PLOS-M02 parent acceptance gate.

Files changed:

- `artifacts/personal-life-os/reports/PLOS-027-20-year-compaction-annual-snapshot-policy.md`
- `artifacts/personal-life-os/validation/PLOS-027-compaction-snapshot-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-027-focused-compaction-snapshot-search-log.txt`
- PLOS run-state, queue, issue map, changelog, decisions, risk register, goal, proof ledger, and proof index artifacts.

Why the change was needed:

AMB-660 required a source-backed policy for 20-year retention, compaction, annual snapshots, exportability, reset/delete semantics, and long-horizon storage cost before future runtime implementation.

App source changed: no.
Runtime features implemented: no.
Privacy manifest changed: no.
Release status changed: no.
Next eligible gate: AMB-610 / PLOS-M02 parent acceptance after verifying all live-resolved M02 children AMB-653 through AMB-660 are Done in Linear and the parent gate passes.

# Archive / Delete Candidate Register

Status: Active supporting cleanup register — non-destructive  
Created: 2026-05-16  
Authority: Subordinate to `docs/truth/*`, `docs/status/README.md`, and `docs/status/archive-and-stale-material-ledger.md`.

This register records archive/delete candidates discovered during Train D / Phase 11. It does **not** approve moving, archiving, or deleting files.

## Phase 11 rule

No archive, move, or delete action is allowed until all of the following are true:

1. inbound references are checked;
2. replacement authority is recorded;
3. durable value is extracted or explicitly retained;
4. stubs/redirects are planned for referenced paths;
5. rollback method is recorded;
6. owner approval exists for destructive action.

## Candidate families

| Candidate family | Current classification | Inbound reference result | Replacement authority | Safe to archive now? | Safe to delete now? | Stub required? | Rollback method | Phase 11 decision |
|---|---|---|---|---|---|---|---|---|
| `docs/canon/Ambitions_2_0_*` | Historical / archive-candidate | Representative file `Ambitions_2_0_Master_Plan.md` still referenced by supporting/historical docs, tracked inventories, and cleanup ledgers. | `docs/truth/*`, `docs/status/current-implementation-map.md`, `frontend/README.md` | No | No | Yes for high-link files | Restore from git | Retain; prepare family-level archive plan later. |
| `docs/codex/Ambitions_2_0_*` | Historical process artifact / archive-candidate | Still referenced by old canon docs, audits, status ledgers, and tracked inventories. | `docs/truth/CODEX_PROCESS_TRUTH.md`, `codex-os/README.md`, `.codex/README.md` | No | No | Likely | Restore from git | Retain; prompt/process routing must be updated first. |
| `docs/canon/Ambitions_3_0_*` | Historical/supporting / partial quarantine | Individual files retain useful privacy, copy, QA, design, and migration decisions; broad inbound references remain. | `docs/truth/*`, `frontend/README.md`, `docs/status/current-implementation-map.md` | No | No | Likely | Restore from git | Retain; continue header/local patch and extraction first. |
| `docs/codex/MASTER_AMBITIONS_3_0_CODEX_PROMPT.md` | Historical process artifact / quarantine | Representative search found inbound refs from status docs, Codex README/context, tracked inventories, and archive ledgers. | `docs/truth/CODEX_PROCESS_TRUTH.md`, `prompts/README.md`, `docs/codex/batches/README.md` | No | No | Yes | Restore from git | Retain; archive only after stubs and routing updates. |
| `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md` | Historical process artifact / quarantine | Not exhaustively scanned in this pass; classified by old-canon index as high-risk process artifact. | `docs/truth/CODEX_PROCESS_TRUTH.md`, `codex-os/README.md` | No | No | Likely | Restore from git | Retain pending focused scan. |
| `docs/canon/Ambitions_4_0_*` | Historical/supporting / partial quarantine | Some files were connector-blocked in Train B; broad External Brain references remain in audits, review boards, and batch reports. | `docs/truth/PRODUCT_MOAT_TRUTH.md`, `docs/runtime/PRIVATE_LIFE_RUNTIME_PROOF_SPEC.md` | No | No | Likely | Restore from git | Retain; local safer patch/extraction first. |
| `docs/canon/PXOS_*` | Historical/supporting / partial quarantine | Representative `PXOS_Empty_Edge_And_Degraded_States.md` is still referenced by PXOS handoff/package, product experience index, audits, and status ledgers. | `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `frontend/README.md`, active visual encyclopedia | No | No | Yes | Restore from git | Retain; archive only after PXOS family routing/stubs. |
| `docs/codex/batches/PX*` and `prompts/batches/PX*` | Historical prompt artifacts | Not fully enumerated; classified as historical execution artifacts with possible inbound refs. | `docs/truth/CODEX_PROCESS_TRUTH.md`, `prompts/README.md`, `docs/codex/batches/README.md` | No | No | Possibly | Restore from git | Retain pending prompt family scan. |
| `docs/codex/batch-trains/*` | Historical/supporting train artifacts | README has been demoted, but train files likely retain many inbound references. | `docs/truth/CODEX_PROCESS_TRUTH.md`, `docs/codex/batch-trains/README.md` | No | No | Possibly | Restore from git | Retain pending family-specific scan. |
| `docs/audits/*` | Historical/supporting audit receipts | Audit README now routes receipts; many audits are referenced by status/truth/old inventory docs. | `docs/audits/README.md`, `docs/truth/RELEASE_TRUTH.md`, current proof evidence | No | No | No for retained receipts; yes if moved | Restore from git | Retain pending evidence-retention pass. |
| `docs/handoff/*` | Historical/supporting handoff trail | Not exhaustively scanned; likely referenced by reports and tracked inventories. | `docs/truth/*`, `docs/status/cleanup-decision-register.md` | No | No | Possibly | Restore from git | Retain pending handoff-family scan. |
| `build/reports/*` | Generated report material / quarantine pending classification | Classified by `generated-report-classification.md`; deletion requires ownership and regeneration proof. | `docs/status/generated-report-classification.md`, owning scripts, current rerun output | No | No | No if regenerated; yes if moved | Regenerate or restore from git | Retain pending generated-artifact scan. |
| `docs/audits/tracked-files.txt` | Generated inventory / historical-supporting | Still appears in representative searches. | regenerate from `git ls-files`, `docs/status/archive-and-stale-material-ledger.md` | No | No | No | Regenerate or restore from git | Retain for now. |

## Deletion status

Approved deletions: **none**.

Reason: all candidate families either retain inbound references, historical value, proof-adjacent context, or unresolved replacement/stub requirements.

## Archive status

Approved archive moves: **none**.

Reason: archive targets and stubs are not yet prepared, and broad family moves would break discoverability without a local/reference-aware move plan.

## Next required work

1. Create or update a quarantine/archive folder plan.
2. Run local `rg`/link checks for one family at a time.
3. Prepare stubs before movement.
4. Move only one family per pass.
5. Update this register after every move/delete decision.

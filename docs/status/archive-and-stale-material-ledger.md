<!-- markdownlint-disable MD013 -->

# Archive And Stale Material Ledger

Status: Active stale/archive/delete safety ledger — Train D Phase 11 Yellow  
Date updated: 2026-05-16

## Authority

This ledger is subordinate to `docs/truth/*`, especially `docs/truth/HISTORICAL_POLICY.md`. It records stale, historical, archive, delete-candidate, and large-file override decisions. It is not product truth, implementation proof, release proof, or approval to delete by itself.

Current Phase 11 candidate register: `docs/status/archive-delete-candidate-register.md`.

Current Phase 11 reference plan: `docs/status/reference-dependency-scan-cleanup-plan.md`.

Current Train D receipt: `docs/status/train-d-reference-dependency-scan-receipt-2026-05-16.md`.

## Current destructive-action status

Approved deletions: **none**.  
Approved archive moves: **none**.  
Approved broad family moves: **none**.

Reason: representative Train D searches showed that old canon, prompt, PXOS, audit, generated-report, and tracked-inventory families still retain active/supporting/historical references or unresolved replacement/stub requirements.

## Stale Inventory Policy

`docs/audits/tracked-files.txt` was regenerated from `git ls-files` on 2026-05-10.

Current status:

- Provider roots are absent from active `.agents/skills/` paths.
- `docs/audits/tracked-files.txt` no longer contains deleted provider skill paths.
- `docs/status/cleanup-decision-register.md` records provider deletion.
- `docs/status/codex-agents-skill-inventory.md` records provider deletion.
- `.codex/manifests/skills-routing-map.yml` keeps both provider roots forbidden.

Rule: `docs/audits/tracked-files.txt` is current tracked-file inventory only. It is not implementation proof, CI proof, release proof, or skill-routing truth.

## Large File Override Policy

| File | Classification | Override source | Action |
| --- | --- | --- | --- |
| `docs/codex/BATCH_REGISTRY.md` | Operational status registry / supporting Codex process context | `docs/status/large-doc-classification-overrides.md`, `.codex/BATCH_TRAIN_REGISTRY.md` | Do not rewrite wholesale; patch only with local evidence. |
| `MASTER_PRODUCT_SPEC.md` | Historical / supporting product-spec context | `docs/status/large-doc-classification-overrides.md` | Not active product truth. |
| `docs/canon/Ambitions_3_0_Documentation_System_Index.md` | Historical / supporting documentation-system context | `docs/status/large-doc-classification-overrides.md` | Not active routing truth. |
| Large train files under `docs/codex/batch-trains/` | Supporting/planned/historical by train family | `.codex/BATCH_TRAIN_REGISTRY.md`, `docs/codex/batch-trains/README.md` | Do not move/delete until inbound refs and replacement authority are recorded. |

## Historical Prompt Policy

Old copy/paste prompts are historical or supporting unless refreshed by current truth routing or explicitly selected by a current user instruction.

Examples:

- `docs/codex/MASTER_AMBITIONS_3_0_CODEX_PROMPT.md`
- `docs/codex/BATCH_TRAIN_*_PROMPT.md`
- `docs/codex/*PROMPT*`
- older `.codex/templates/*prompt*`
- `prompts/batches/*`

Rule: old prompts must not be used as active truth when they skip `docs/truth/*` or revive superseded hierarchy.

## Batch Train Archive/Delete Ledger

| Path / family | Train family | Classification | Replacement authority | Safe to delete? | Safe to archive? | Inbound refs | Rollback |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md` | PX | Historical complete / do not rerun | `docs/truth/*`, `docs/codex/batch-trains/README.md` | No | Later, after refs/stubs | Not complete in Train D | Restore from git |
| `docs/codex/batch-trains/F03_5_*.md`, `F04_F06_*`, `F07_F09_*`, `F10_F12_*`, `F13_F14_*`, `F15_F16_F16_5_*`, `F17_F30_*`, `F17_Shell_*` | F-series | Historical/supporting | `docs/truth/*`, `docs/codex/batch-trains/README.md` | No | Later, after refs/stubs | Not complete in Train D | Restore from git |
| `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md` | EFC | Active/supporting proof overlay | EFC overlay docs + global train | No | No | Active/supporting | Restore from git |
| PK/SA/LDI/AOS/FCP/PFC/RHC/SIG train files | active/planned/deferred mix | Active/supporting | `.codex/GLOBAL_BATCH_TRAIN.md`, `.codex/BATCH_TRAIN_REGISTRY.md` | No | No | Active/supporting | Restore from git |

## Archive Candidate Ledger

| Candidate path | Classification | Inbound references | Replacement authority | Safe to move? | Stub needed? | Rollback |
| --- | --- | --- | --- | --- | --- | --- |
| `docs/canon/Ambitions_2_0_*` | Historical/archive-candidate | Representative inbound refs remain | `docs/truth/*`, `docs/status/current-implementation-map.md`, `frontend/README.md` | No | Yes for high-link files | Restore from git |
| `docs/codex/Ambitions_2_0_*` | Historical process artifact | Representative inbound refs remain | `docs/truth/CODEX_PROCESS_TRUTH.md`, `codex-os/README.md`, `.codex/README.md` | No | Likely | Restore from git |
| `docs/canon/Ambitions_3_0_*` | Historical/supporting/quarantine | Broad inbound refs and durable decisions remain | `docs/truth/*`, `frontend/README.md` | No | Likely | Restore from git |
| `docs/codex/MASTER_AMBITIONS_3_0_CODEX_PROMPT.md` | Historical process artifact/quarantine | Representative inbound refs remain | `docs/truth/CODEX_PROCESS_TRUTH.md`, `prompts/README.md`, `docs/codex/batches/README.md` | No | Yes | Restore from git |
| `docs/canon/Ambitions_4_0_*` | Historical/supporting/quarantine | External Brain refs and Train B blocks remain | `docs/truth/PRODUCT_MOAT_TRUTH.md`, `docs/runtime/PRIVATE_LIFE_RUNTIME_PROOF_SPEC.md` | No | Likely | Restore from git |
| `docs/canon/PXOS_*` | Historical/supporting/quarantine | Representative inbound refs remain | `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `frontend/README.md` | No | Yes | Restore from git |
| Old prompt docs under `docs/codex/*PROMPT*` and `prompts/batches/*` | Historical/supporting | Dense historical/supporting references remain | `prompts/README.md`, `docs/codex/batches/README.md` | No | Yes if future focused archive pass moves a single alias family | Restore from git |
| Historical train docs under `docs/codex/batch-trains/*` | Historical/supporting | Dense historical/supporting references likely remain | `docs/codex/batch-trains/README.md` | No | Yes if future focused archive pass moves a single train family | Restore from git |
| `docs/audits/tracked-files.txt` | Current generated inventory | Still appears in representative searches | This ledger + status docs | No | No | Regenerate with `git ls-files` |
| `build/reports/*` | Generated/historical report material | Needs generated artifact scan/regeneration proof | `docs/status/generated-report-classification.md`, owning scripts | No | Maybe, after regeneration proof | Regenerate or restore from git |

## Delete Candidate Ledger

No file is approved for deletion from the control-plane cleanup.

Resolution: candidate files have retained historical/supporting value, inbound references, proof-adjacent context, or unresolved replacement/stub requirements. Future delete proposals require a new focused owner-approved pass.

## Link Hygiene Ledger

| Finding | Status | Action |
| --- | --- | --- |
| Stale provider paths in `docs/audits/tracked-files.txt` | Resolved | Inventory regenerated from `git ls-files`; provider roots no longer appear. |
| Old prompt/resume docs that skip `docs/truth/*` | Retained | Kept as historical/supporting because inbound refs remain; prompt routing READMEs now subordinate them. |
| Large historical docs with active-sounding language | Yellow partial | Governed by old-canon index and Train B receipt; several full-preservation updates remain blocked for local patching. |
| Generated reports under `build/reports/*` | Classified, not deleted | `generated-report-classification.md` governs future action. |
| Markdown/link check | Advisory | No current Train D markdown/link checker was run. |

## Provider Deletion Closeout

Provider skills deleted from active paths:

- `.agents/skills/supabase/`
- `.agents/skills/supabase-postgres-best-practices/`

Deleted provider roots remain listed only as forbidden roots or historical deletion records. They must not recreate provider/backend/cloud architecture. `.codex/manifests/skills-routing-map.yml` keeps those roots forbidden.

## Files That Must Not Be Deleted

- `docs/truth/*`
- `README.md`
- `docs/README.md`
- `AGENTS.md`
- `.codex/README.md`
- `docs/codex/CODEX_OS_INDEX.md`
- active `.codex/*.md` control-plane files
- `.codex/state/*`
- `.codex/reports/current*`
- `docs/status/current-implementation-map.md`
- `docs/status/release-evidence-packet.md`
- `docs/status/archive-delete-candidate-register.md`
- app source/runtime/project/package/test/resource/entitlement/privacy-manifest files

## Train D Phase 11 Result

Train D Phase 11 result: Yellow, safe retain.

No files were moved, archived, or deleted in Phase 11 because candidate families failed destructive-action safety gates after representative inbound-reference checks.

Reason:

- Candidate old-canon/prompt/PXOS files have inbound references and retained historical/process value.
- Generated reports need owner/regeneration proof before deletion or archive decisions.
- No local `rg`/link-check proof or stubs were prepared.

Approved destructive actions: none.

Rollback: no rollback needed because no destructive action was performed.

Next required action: local/Antigravity inbound-reference scan for one family at a time, starting with Ambitions 2.0, then stubs/replacement authority before any archive movement.

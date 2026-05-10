<!-- markdownlint-disable MD013 -->

# Archive And Stale Material Ledger

Status: Active stale/archive/delete safety ledger
Date updated: 2026-05-10

## Authority

This ledger is subordinate to `docs/truth/*`, especially
`docs/truth/HISTORICAL_POLICY.md`. It records stale, historical, archive,
delete-candidate, and large-file override decisions. It is not product truth,
implementation proof, release proof, or approval to delete by itself.

## Stale Inventory Policy

`docs/audits/tracked-files.txt` was regenerated from `git ls-files` on
2026-05-10.

Current status:

- Provider roots are absent from active `.agents/skills/` paths.
- `docs/audits/tracked-files.txt` no longer contains deleted provider skill
  paths.
- `docs/status/cleanup-decision-register.md` records provider deletion.
- `docs/status/codex-agents-skill-inventory.md` records provider deletion.
- `.codex/manifests/skills-routing-map.yml` keeps both provider roots forbidden.

Rule: `docs/audits/tracked-files.txt` is current tracked-file inventory only.
It is not implementation proof, CI proof, release proof, or skill-routing truth.

## Large File Override Policy

| File | Classification | Override source | Action |
| --- | --- | --- | --- |
| `docs/codex/BATCH_REGISTRY.md` | Operational status registry / supporting Codex process context | `docs/status/large-doc-classification-overrides.md`, `.codex/BATCH_TRAIN_REGISTRY.md` | Do not rewrite wholesale; patch only with local evidence. |
| `MASTER_PRODUCT_SPEC.md` | Historical / supporting product-spec context | `docs/status/large-doc-classification-overrides.md` | Not active product truth. |
| `docs/canon/Ambitions_3_0_Documentation_System_Index.md` | Historical / supporting documentation-system context | `docs/status/large-doc-classification-overrides.md` | Not active routing truth. |
| Large train files under `docs/codex/batch-trains/` | Supporting/planned/historical by train family | `.codex/BATCH_TRAIN_REGISTRY.md` | Do not move/delete until inbound refs and replacement authority are recorded. |

## Historical Prompt Policy

Old copy/paste prompts are historical or supporting unless refreshed by
`.codex/SESSION_BOOTSTRAP.md` or explicitly selected by a current truth-routed
batch.

Examples:

- `docs/codex/MASTER_AMBITIONS_3_0_CODEX_PROMPT.md`
- `docs/codex/BATCH_TRAIN_*_PROMPT.md`
- `docs/codex/*PROMPT*`
- older `.codex/templates/*prompt*`

Rule: old prompts must not be used as active truth when they skip `docs/truth/*`
or revive superseded hierarchy.

## Batch Train Archive/Delete Ledger

| Path / family | Train family | Classification | Replacement authority | Safe to delete? | Safe to archive? | Inbound refs | Rollback |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md` | PX | Historical complete / do not rerun | `docs/truth/*`, `.codex/GLOBAL_BATCH_TRAIN.md` | No | Later, after refs | Not checked in Phase 9 | Restore from git |
| `docs/codex/batch-trains/F03_5_*.md`, `F04_F06_*`, `F07_F09_*`, `F10_F12_*`, `F13_F14_*`, `F15_F16_F16_5_*`, `F17_F30_*`, `F17_Shell_*` | F-series | Historical/supporting | `docs/truth/*`, `.codex/GLOBAL_BATCH_TRAIN.md` | No | Later, after refs | Not checked in Phase 9 | Restore from git |
| `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md` | EFC | Active proof overlay | EFC overlay docs + global train | No | No | Active/supporting | Restore from git |
| PK/SA/LDI/AOS/FCP/PFC/RHC/SIG train files | active/planned/deferred mix | Active/supporting | `.codex/GLOBAL_BATCH_TRAIN.md`, `.codex/BATCH_TRAIN_REGISTRY.md` | No | No | Active/supporting | Restore from git |

## Archive Candidate Ledger

| Candidate path | Classification | Inbound references | Replacement authority | Safe to move? | Stub needed? | Rollback |
| --- | --- | --- | --- | --- | --- | --- |
| Old prompt docs under `docs/codex/*PROMPT*` | Historical/supporting | Checked by `rg` on 2026-05-10; dense historical and active-supporting references remain | `.codex/SESSION_BOOTSTRAP.md` | No | Yes if a future focused archive pass moves a single alias family | Restore from git |
| Historical Ambitions 3.0/F-series train docs | Historical/supporting | Checked by `rg` on 2026-05-10; dense historical and active-supporting references remain | `docs/truth/*`, global registry | No | Yes if a future focused archive pass moves a single train family | Restore from git |
| `docs/audits/tracked-files.txt` | Current generated inventory | Checked by `rg` on 2026-05-10; referenced by truth/status/audit docs | This ledger + status docs | No | No | Regenerate with `git ls-files` |

## Delete Candidate Ledger

No file is approved for deletion from the control plane cleanup.

Resolution: candidate files have retained historical/supporting value or active
references. Future delete proposals require a new focused owner-approved pass.

## Link Hygiene Ledger

| Finding | Status | Action |
| --- | --- | --- |
| Stale provider paths in `docs/audits/tracked-files.txt` | Resolved | Inventory regenerated from `git ls-files`; provider roots no longer appear. |
| Old prompt/resume docs that skip `docs/truth/*` | Resolved | Retained as historical/supporting because inbound refs remain; active bootstrap wins. |
| Large historical docs with active-sounding language | Resolved | Governed by large-doc overrides, truth files, and repo inventory. |
| Markdown/link check | Advisory | `scripts/run-doc-qa.sh` exit `0` on 2026-05-10 with broad advisory findings. |

## Provider Deletion Closeout

Provider skills deleted from active paths:

- `.agents/skills/supabase/`
- `.agents/skills/supabase-postgres-best-practices/`

Deleted provider roots remain listed only as forbidden roots or historical
deletion records. They must not recreate provider/backend/cloud architecture.
`.codex/manifests/skills-routing-map.yml` keeps those roots forbidden.

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
- app source/runtime/project/package/test/resource/entitlement/privacy-manifest files

## Phase 9 Gate Result

Phase 9 result: Green.

EFC applicability: invoked for governance and release-claim boundary routing.
No archive/delete/move action was performed.

Resolved follow-up:

- Archive/delete candidates were checked for inbound references and retained
  because they have dense historical/supporting links.
- Large batch train files remain classified, not moved, because registry and
  override routing is sufficient.
- `docs/audits/tracked-files.txt` is regenerated current inventory and no
  longer contains deleted provider roots.

## Phase 10 Prune / Archive / Delete Pass

Phase 10 result: Green, safe retain.

No files were moved, archived, or deleted in Phase 10 because candidate files
failed deletion/archive safety gates after inbound-reference checks.

Reason:

- Candidate prompt/train files have dense inbound references and retained
  historical/process value.
- `docs/audits/tracked-files.txt` is current generated inventory after
  regeneration.
- Deleting or moving old prompts/train docs would break traceability or active
  navigation without a larger stub/update pass.

Approved destructive actions: none.

Rollback: no rollback needed because no destructive action was performed.

Next optional action: a future focused archive pass may move one candidate
family at a time only after stubs and reference updates are prepared.

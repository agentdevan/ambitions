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

`docs/audits/tracked-files.txt` is historical/stale inventory evidence. It
contains deleted provider skill paths:

- `.agents/skills/supabase/`
- `.agents/skills/supabase-postgres-best-practices/`

Current status:

- Provider roots are absent from active `.agents/skills/` paths.
- `docs/status/cleanup-decision-register.md` records provider deletion.
- `docs/status/codex-agents-skill-inventory.md` records provider deletion.
- `.codex/manifests/skills-routing-map.yml` keeps both provider roots forbidden.

Rule: do not use `docs/audits/tracked-files.txt` as current file existence or
skill-routing truth.

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
| Old prompt docs under `docs/codex/*PROMPT*` | Historical/supporting | Not fully checked | `.codex/SESSION_BOOTSTRAP.md` | Not yet | Likely yes for common aliases | Restore from git |
| Historical Ambitions 3.0/F-series train docs | Historical/supporting | Not fully checked | `docs/truth/*`, global registry | Not yet | Likely yes | Restore from git |
| `docs/audits/tracked-files.txt` | Stale inventory | Not fully checked | This ledger + status docs | Not yet | Maybe no if references are updated | Restore from git |

## Delete Candidate Ledger

No file is approved for deletion in Phase 9.

Potential future delete candidates require:

1. inbound-reference search
2. replacement authority
3. historical value check
4. rollback note
5. owner approval for destructive action
6. path-limited commit

## Link Hygiene Ledger

| Finding | Status | Action |
| --- | --- | --- |
| Stale provider paths in `docs/audits/tracked-files.txt` | Yellow | Keep classified as stale inventory; do not use as active path evidence. |
| Old prompt/resume docs that skip `docs/truth/*` | Yellow | Classify as historical/supporting before archive or header pass. |
| Large historical docs with active-sounding language | Yellow | Govern by large-doc overrides and truth files. |
| Markdown/link check | Advisory | `scripts/run-doc-qa.sh` exit `0` on 2026-05-10 with broad advisory findings. |

## Provider Deletion Closeout

Provider skills deleted from active paths:

- `.agents/skills/supabase/`
- `.agents/skills/supabase-postgres-best-practices/`

Stale references remain docs-only and must not recreate provider/backend/cloud
architecture. `.codex/manifests/skills-routing-map.yml` keeps those roots
forbidden.

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

Phase 9 result: Green with accepted Yellow items.

EFC applicability: invoked for governance and release-claim boundary routing.
No archive/delete/move action was performed.

Accepted Yellow:

- Inbound-reference checks for actual archive/delete candidates remain future
  work.
- Large batch train files remain classified, not moved.
- Stale inventory files remain in place but cannot impersonate current truth.

## Phase 10 Prune / Archive / Delete Pass

Phase 10 result: Yellow, safe no-op.

No files were moved, archived, or deleted in Phase 10.

Reason:

- The ledger identifies stale and historical candidates, but broad inbound-reference checks and replacement stubs were not completed in this pass.
- Several candidates remain useful as historical/process evidence.
- Deleting or moving old prompts/train docs without a reference map could break traceability or active navigation.

Approved destructive actions: none.

Rollback: no rollback needed because no destructive action was performed.

Next safe action: run a focused inbound-reference pass per candidate family,
then archive in small batches only when replacement authority and rollback are
recorded.

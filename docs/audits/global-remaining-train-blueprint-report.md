# Global Remaining Train Blueprint Report

Status: Green
Batch ID: GLOBAL-REMAINING-TRAIN-BLUEPRINT-01
Starting HEAD: eceb7e5a3579259433da8b3f8a8f4fb0bbf1df5d
Ending HEAD: uncommitted working tree pending runner final gate

## Objective

Create a repo-backed remaining-train blueprint, canonical prompt coverage, queue
validators, and implementation instructions for the remaining global batch
train without changing app behavior or making release/readiness claims.

## Files changed

- `prompts/batches/*.md` for canonical remaining-batch prompt coverage
- `prompts/templates/AMBITIONS_REMAINING_BATCH_EXECUTION_STANDARD.md`
- `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
- `docs/codex/AMB_REMAINING_BATCH_REFERENCE.json`
- `docs/codex/AMB_REMAINING_BATCH_REFERENCE.md`
- `docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md`
- `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md`
- `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json`
- `docs/codex/AMB_GLOBAL_TRAIN_CONSOLIDATION_AND_MODIFICATION_PLAN.md`
- `docs/codex/AMB_GLOBAL_TRAIN_CODEX_IMPLEMENTATION_INSTRUCTIONS.md`
- `docs/audits/global-remaining-train-blueprint-report.md`
- `scripts/ambitions-queue-snapshot.py`
- `scripts/ambitions-control-plane-check.py`
- `scripts/ambitions-source-atlas-title-check.py`
- `scripts/ambitions-final-report-gate.py`

Current `git status --short` also shows untracked `.codex/runs/**` runner
artifacts, including the current
`.codex/runs/GLOBAL-REMAINING-TRAIN-BLUEPRINT-01/20260511T124053Z/` run
directory and prior local runner logs. These are operational evidence/artifacts,
not app behavior changes. They must be staged or cleaned only by explicit
path-limited runner-evidence policy, never by broad `git add .` or broad clean.

## Files intentionally not changed

- `Native/**`
- `AppUI/**`
- `Sources/**`
- `Package.swift`
- `project.yml`
- `.github/**`
- signing, entitlement, generated Xcode, release, TestFlight, App Store, and
  device-proof files
- `.codex/state/**` and `.codex/reports/**`; active state already preserved
  PK17 as next eligible

## Queue evidence

- Canonical queue: `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
- Remaining reference: `docs/codex/AMB_REMAINING_BATCH_REFERENCE.json`
- Blueprint JSON: `docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json`
- Queue count: 146 records
- Reference count: 146 records
- Blueprint count: 146 records
- Duplicate IDs: none
- First record: PK04
- Last record: PX20

## Remaining record count

146

## Completed batches confirmed not reactivated

Records classified `historical_complete_do_not_run`, `absorbed_as_overlay`, or
`conditional_trigger_only` received canonical coverage prompts with explicit
do-not-run or overlay-only boundaries. They were not marked implementation
complete, not reactivated, and not moved in queue order.

## PK17 next eligible evidence

`.codex/state/active-batch.yml` identifies `PK17 Today Read Model Extraction`
as the next eligible batch, and `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
classifies PK17 as `executable_now`.

## PK17-PK41 preservation evidence

PK17-PK41 remain separate canonical IDs in queue order. The generated prompts
preserve one file per ID under `prompts/batches/<ID>.md`; no PK batch collapse
or renumbering occurred.

## PK21 typo repair evidence

`prompts/batches/PK21.md` exists and contains:

```text
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
```

The bad casing string is absent from `prompts/batches`, `docs/codex/batches`,
`prompts/templates`, and `docs/codex`.

## Prompt coverage table

- Remaining records: 146
- Prompt coverage: 146 / 146
- Canonical executable prompt path: `prompts/batches/<ID>.md`
- Do-not-run / overlay prompt coverage: 57
- Active runnable prompts audited by `make prompt-audit`: 160
- Support/eval/template/historical prompt-like files classified: 800

## Prompt files rewritten

Existing tracked prompt files were not bulk rewritten. The saved
`prompts/batches/GLOBAL-REMAINING-TRAIN-BLUEPRINT-01.md` was repaired to remove
the bad casing string from active content.

## Prompt files created

Created missing canonical prompt coverage for remaining queue IDs, including
PK17-PK41, SA07-SA32, LDI15-LDI22, AOS24-AOS30, FCP27-FCP30, PFC31-PFC40,
EFC01-EFC18, RHC01-RHC06, CS compatibility records, and PX01-PX20.

## Prompt files marked historical/do-not-run

Prompts for records classified as `historical_complete_do_not_run`,
`absorbed_as_overlay`, or `conditional_trigger_only` include an explicit
do-not-run boundary and must not be used as implementation prompts unless a
future approved control-plane batch updates active source truth.

## Prompt files intentionally not changed

Tracked pre-existing runnable prompts outside this batch were left intact
unless they were represented by newly created missing canonical coverage.

## Source Atlas title normalization evidence

SA11-SA32 titles were normalized from generic ID-only labels to canonical titles
from `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`.
The strict title checker passes after repair.

## AIR fold-in assessment

AIR remains a fold-in obligation routed through owning batches. This batch did
not create a standalone AIR train or authorize AIR to override source truth.

## EFC proof-boundary assessment

EFC remains an active proof overlay for unfinished work. Generated prompts
require EFC applicability notes where user-facing behavior, user data,
intelligence, side effects, source/freshness, accessibility, performance,
release posture, or public claims are touched.

## RHC sequencing assessment

RHC remains queued and owner-mapped. Broad cleanup was not pulled early.

## DPTG terminal assessment

DPTG remains terminal-only by rule. The authoritative 146-record queue ends at
PX20 and does not currently include a DPTG00 record; generated prompts preserve
the DPTG terminal rule and do not make DPTG executable.

## CS compatibility seam assessment

CS records preserve compatibility seam retirement and rollback expectations.
They do not modify route behavior, top-level IA, or production app source.

## PX/product-experience assessment

PX prompts were created as product-experience implementation prompts with
visual/proof gates where UI-facing source changes are made. This batch did not
modify UI or claim visual approval.

## Validation commands and exit codes

- `git diff --check` - exit 0
- `python3 -m json.tool docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json >/tmp/ambitions-global-queue-json-check.txt` - exit 0
- `python3 -m json.tool docs/codex/AMB_REMAINING_BATCH_REFERENCE.json >/tmp/ambitions-remaining-batch-reference-json-check.txt` - exit 0
- `python3 -m json.tool docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json >/tmp/ambitions-global-remaining-train-blueprint-json-check.txt` - exit 0
- `python3 scripts/ambitions-queue-snapshot.py` - exit 0
- `python3 scripts/ambitions-control-plane-check.py` - exit 0
- `python3 scripts/ambitions-source-atlas-title-check.py --strict` - exit 0 after repair
- `make prompt-audit` - exit 0, Yellow advisory classification only
- `make batch-self-check` - exit 0
- `python3 scripts/ambitions-final-report-gate.py docs/audits/global-remaining-train-blueprint-report.md --strict` - exit 0 after report repair
- Phase 03 defect-string scan over canonical prompts, implementation guide, blueprint JSON, and report - exit 1, no matches
- `grep -R "bypAS[S]ES" prompts/batches docs/codex/batches prompts/templates docs/codex` - exit 1, no bad casing found
- `grep -R "DIRECT_CODEX_EXECUTION" prompts/batches/PK21.md` - exit 0

## Defects found

- Initial runner phase failed Red because the Spark patch exceeded context
  while attempting broad prompt-system generation.
- Required validator scripts were missing.
- `prompts/templates/AMBITIONS_REMAINING_BATCH_EXECUTION_STANDARD.md` was
  missing.
- `prompts/batches/PK21.md` was missing, so the hypothesized PK21 header typo
  could not be repaired in place.
- The saved blueprint prompt carried the bad casing string in active text.
- SA11-SA32 used generic ID-only titles in queue/reference files.
- The first generated report omitted required final-report phrases.

## Defects repaired

- Added read-only queue/control-plane/source-title/final-report validators.
- Added the remaining-batch execution standard template.
- Created canonical prompt coverage for all 146 remaining records.
- Rewrote canonical prompt coverage with per-batch implementation instructions, candidate owner files, and batch-specific proof expectations.
- Created `prompts/batches/PK21.md` with the correct runner header.
- Removed the bad casing string from scoped prompt/control-plane paths.
- Normalized SA11-SA32 titles from active SA train authority.
- Regenerated blueprint JSON and implementation instructions after title repair.
- Replaced placeholder `Files likely involved` entries with concrete candidate owner paths for every remaining record.
- Repaired the audit report to include required closeout fields.

## Defects deferred

- No product implementation was performed.
- No prompt-specific instruction defect remains from Phase 03 review.
- DPTG00 is not materialized because it is not present in the authoritative
  146-record queue; terminal DPTG rules are preserved instead.
- No app build, UI test, visual proof, device proof, release proof, or
  accessibility proof was run because this batch is prompt/governance tooling.

## Accepted Yellow rationale

No Accepted Yellow remains for the prompt-system core. Phase 04 repaired the prompt-specific instruction defect by replacing generic implementation lines in all 146 canonical prompt files and replacing placeholder file guidance in the global implementation guide. `make prompt-audit` may still report its exit-0 Yellow advisory for classified support/eval/template/historical prompt-like files; no active runnable prompt is missing runner metadata.

## Phase 04 repair evidence

- Repaired 146 canonical prompt files under `prompts/batches/<ID>.md` to remove the generic implementation instruction called out in Phase 03.
- Repaired `docs/codex/AMB_GLOBAL_TRAIN_CODEX_IMPLEMENTATION_INSTRUCTIONS.md` so every remaining batch has concrete candidate owner paths instead of placeholder `Files likely involved` text.
- Preserved do-not-run, overlay-only, and conditional records as non-executable metadata coverage.
- Preserved PK17 as next eligible and preserved PK17-PK41 as separate IDs.

## Claims made

- Queue, prompt, blueprint, and validator coverage only.
- PK17 remains next eligible from active repo truth.

## Claims not made

- App behavior changed
- PK17 implementation completed
- Global train completed
- Production readiness
- TestFlight readiness
- App Store readiness
- Device proof
- Public accessibility conformance
- VoiceOver verification
- Dynamic Type verification
- Reduce Motion verification
- Performance validation
- Privacy/legal/security approval
- Sync/cloud readiness
- DPTG00 remains terminal-only until all pre-device gates and terminal prerequisites close.
- External/cloud LLMs are part of core architecture

## Rollback notes

Rollback this batch's working tree changes with path-limited restore/clean
rather than broad destructive reset if preserving unrelated local work:

```bash
git restore docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json docs/codex/AMB_REMAINING_BATCH_REFERENCE.json docs/codex/AMB_REMAINING_BATCH_REFERENCE.md docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md
git clean -f docs/audits/global-remaining-train-blueprint-report.md docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md docs/codex/AMB_GLOBAL_TRAIN_CODEX_IMPLEMENTATION_INSTRUCTIONS.md docs/codex/AMB_GLOBAL_TRAIN_CONSOLIDATION_AND_MODIFICATION_PLAN.md prompts/templates/AMBITIONS_REMAINING_BATCH_EXECUTION_STANDARD.md scripts/ambitions-queue-snapshot.py scripts/ambitions-control-plane-check.py scripts/ambitions-source-atlas-title-check.py scripts/ambitions-final-report-gate.py
git clean -f prompts/batches/AOS24.md prompts/batches/AOS25.md prompts/batches/AOS26.md prompts/batches/AOS27.md prompts/batches/AOS28.md prompts/batches/AOS29.md prompts/batches/AOS30.md prompts/batches/CS02C.md prompts/batches/CS03C.md prompts/batches/CS04C.md prompts/batches/CS05C.md prompts/batches/CS06C.md prompts/batches/CS09C.md prompts/batches/EFC01.md prompts/batches/EFC02.md prompts/batches/EFC03.md prompts/batches/EFC04.md prompts/batches/EFC05.md prompts/batches/EFC06.md prompts/batches/EFC07.md prompts/batches/EFC08.md prompts/batches/EFC09.md prompts/batches/EFC10.md prompts/batches/EFC11.md prompts/batches/EFC12.md prompts/batches/EFC13.md prompts/batches/EFC14.md prompts/batches/EFC15.md prompts/batches/EFC16.md prompts/batches/EFC17.md prompts/batches/EFC18.md prompts/batches/FCP27.md prompts/batches/FCP28.md prompts/batches/FCP29.md prompts/batches/FCP30.md prompts/batches/GLOBAL-REMAINING-TRAIN-BLUEPRINT-01.md prompts/batches/LDI15.md prompts/batches/LDI16.md prompts/batches/LDI17.md prompts/batches/LDI18.md prompts/batches/LDI19.md prompts/batches/LDI20.md prompts/batches/LDI21.md prompts/batches/LDI22.md prompts/batches/PFC31.md prompts/batches/PFC32.md prompts/batches/PFC33.md prompts/batches/PFC34.md prompts/batches/PFC35.md prompts/batches/PFC36.md prompts/batches/PFC37.md prompts/batches/PFC38.md prompts/batches/PFC39.md prompts/batches/PFC40.md prompts/batches/PK04.md prompts/batches/PK05.md prompts/batches/PK06.md prompts/batches/PK07.md prompts/batches/PK08.md prompts/batches/PK09.md prompts/batches/PK10.md prompts/batches/PK11.md prompts/batches/PK12.md prompts/batches/PK13.md prompts/batches/PK17.md prompts/batches/PK18.md prompts/batches/PK19.md prompts/batches/PK20.md prompts/batches/PK21.md prompts/batches/PK22.md prompts/batches/PK23.md prompts/batches/PK24.md prompts/batches/PK25.md prompts/batches/PK26.md prompts/batches/PK27.md prompts/batches/PK28.md prompts/batches/PK29.md prompts/batches/PK30.md prompts/batches/PK31.md prompts/batches/PK32.md prompts/batches/PK33.md prompts/batches/PK34.md prompts/batches/PK35.md prompts/batches/PK36.md prompts/batches/PK37.md prompts/batches/PK38.md prompts/batches/PK39.md prompts/batches/PK40.md prompts/batches/PK41.md prompts/batches/PX01.md prompts/batches/PX02.md prompts/batches/PX03.md prompts/batches/PX04.md prompts/batches/PX05.md prompts/batches/PX06.md prompts/batches/PX07.md prompts/batches/PX08.md prompts/batches/PX09.md prompts/batches/PX10.md prompts/batches/PX11.md prompts/batches/PX12.md prompts/batches/PX13.md prompts/batches/PX14.md prompts/batches/PX15.md prompts/batches/PX16.md prompts/batches/PX17.md prompts/batches/PX18.md prompts/batches/PX19.md prompts/batches/PX20.md prompts/batches/RHC01.md prompts/batches/RHC02.md prompts/batches/RHC03.md prompts/batches/RHC04.md prompts/batches/RHC05.md prompts/batches/RHC06.md prompts/batches/SA07.md prompts/batches/SA08.md prompts/batches/SA09.md prompts/batches/SA10.md prompts/batches/SA10A.md prompts/batches/SA10B.md prompts/batches/SA10C.md prompts/batches/SA11.md prompts/batches/SA12.md prompts/batches/SA13.md prompts/batches/SA14.md prompts/batches/SA15.md prompts/batches/SA16.md prompts/batches/SA17.md prompts/batches/SA18.md prompts/batches/SA19.md prompts/batches/SA20.md prompts/batches/SA21.md prompts/batches/SA22.md prompts/batches/SA23.md prompts/batches/SA24.md prompts/batches/SA25.md prompts/batches/SA26.md prompts/batches/SA27.md prompts/batches/SA28.md prompts/batches/SA29.md prompts/batches/SA30.md prompts/batches/SA31.md prompts/batches/SA32.md
```

Do not broadly clean `.codex/runs/**`; it contains current and prior local
runner evidence. Remove or stage runner artifacts only with an explicit
path-limited evidence decision.

## Next eligible implementation batch

PK17 Today Read Model Extraction

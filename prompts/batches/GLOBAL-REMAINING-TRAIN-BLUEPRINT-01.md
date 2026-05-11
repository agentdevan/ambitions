<!-- AMBITIONS_RUNNER_REQUIRED: true -->

<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->

<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# GLOBAL-REMAINING-TRAIN-BLUEPRINT-01 — Complete Remaining Batch Inventory, Prompt Upgrade, And Global Execution Blueprint

## Batch ID

GLOBAL-REMAINING-TRAIN-BLUEPRINT-01

## Runner command

```bash
scripts/ambitions-codex-train.sh GLOBAL-REMAINING-TRAIN-BLUEPRINT-01 prompts/batches/GLOBAL-REMAINING-TRAIN-BLUEPRINT-01.md
```

Equivalent:

```bash
make batch BATCH=GLOBAL-REMAINING-TRAIN-BLUEPRINT-01 PROMPT=prompts/batches/GLOBAL-REMAINING-TRAIN-BLUEPRINT-01.md
```

## Operating mode

Run through the Ambitions runner only:

```text
GPT-5.5 plan → GPT-5.3-Codex-Spark bounded patch → GPT-5.5 review/repair/final commit
```

Direct Codex execution is forbidden unless the user explicitly bypasses the Ambitions runner.

You are the Ambitions Senior Operating Council acting as:

* senior product architect
* iOS architecture lead
* design systems director
* QA/release lead
* privacy/safety reviewer
* Codex OS control-plane engineer
* repo-governance lead
* batch-train sequencing lead

## Objective

Create the definitive, repo-backed, implementation-ready global batch train blueprint for every remaining Ambitions batch from current live state through terminal device proof.

This batch must:

1. Read the complete live repo queue truth.
2. Detail and analyze every remaining batch record, expected to be 146 records unless repo truth proves otherwise.
3. Classify every remaining batch by train, owner, type, dependency, risk, validation class, proof class, and implementation posture.
4. Generate exact Codex-ready implementation instructions for every remaining incomplete batch.
5. Upgrade, modify, consolidate, remove, or enhance planned prompts where repo truth supports it.
6. Preserve canonical IDs and queue order.
7. Keep PK17 as the next eligible implementation batch unless active repo truth proves otherwise.
8. Preserve PK17-PK41 as separate executable batch IDs.
9. Fix the known `PK21.md` runner-header typo.
10. Supersede the prior Accepted Yellow direct pass for `GLOBAL-PROMPT-REBUILD-REMAINING-01`.
11. Produce both human-readable and machine-readable global train execution artifacts.
12. Produce a strict final audit report.

This is a prompt-system, queue-governance, implementation-blueprint, and Codex-control-plane batch. It may rewrite prompt files and governance docs, but it must not implement app product behavior.

## Current known state to verify, not blindly trust

Treat the following as hypotheses to verify against active repo truth:

* PK16 Trust History Query is Green.
* PK17 Today Read Model Extraction is next eligible.
* Remaining inventory has 146 records.
* Later work spans PK, IR, SA, LDI, AOS, FCP/PFC, EFC, RHC, CS, PX, and terminal DPTG.
* `GLOBAL-PROMPT-REBUILD-REMAINING-01` exists but is Accepted Yellow.
* PK17-PK41 prompts were materialized in a compact inherited format.
* `prompts/templates/AMBITIONS_REMAINING_BATCH_EXECUTION_STANDARD.md` exists.
* `prompts/batches/PK21.md` may have a casing typo in its runner header; verify
  the required canonical value:
  `forbidden_unless_user_explicitly_bypasses_runner`
* Active top-level IA is Today / Goals / Capture / Time / You.
* Plan is superseded as a top-level destination.
* Core intelligence is local-first and deterministic.
* External/cloud LLMs are not part of core architecture.
* DPTG00 is terminal only.
* Release/TestFlight/App Store/device/accessibility/performance/privacy/legal claims require proof.

If repo truth contradicts any of these, document the contradiction and stop Red unless the correct source of authority is unambiguous.

## Active source truth to inspect first

Inspect these before editing:

```text
docs/truth/README.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
AGENTS.md
.codex/state/active-batch.yml
.codex/reports/current-batch-train-state.md
.codex/reports/current-run-state.md
.codex/state/global-train-attempt-ledger.md
docs/codex/BATCH_REGISTRY.md
docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json
docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md
docs/codex/AMB_REMAINING_BATCH_REFERENCE.md
docs/codex/AMB_REMAINING_BATCH_REFERENCE.json
docs/codex/AMB_GLOBAL_BATCH_TRAIN_SEQUENCE.md
docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md
docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md
docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md
docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md
docs/codex/AMB_CONTROL_PLANE_GATE_INDEX.md
docs/codex/CODEX_AGENT_PROTOCOL.md
docs/codex/ambitions-hybrid-runner.md
prompts/templates/AMBITIONS_REMAINING_BATCH_EXECUTION_STANDARD.md
prompts/batches/GLOBAL-PROMPT-REBUILD-REMAINING-01.md
docs/audits/global-prompt-rebuild-remaining-report.md
docs/codex/batch-trains/**
docs/codex/batches/**
prompts/batches/**
prompts/templates/**
scripts/ambitions-queue-snapshot.py
scripts/ambitions-control-plane-check.py
scripts/ambitions-source-atlas-title-check.py
scripts/ambitions-final-report-gate.py
scripts/ambitions-batch-scope-guard.py
```

Also inspect any additional queue, manifest, prompt, batch-prep, source-atlas, AIR, EFC, RHC, CS, PX, DPTG, or train-state files discovered under allowed scope.

## Allowed scope

You may modify:

```text
prompts/batches/**
prompts/templates/**
docs/codex/**
docs/audits/**
scripts/**
.codex/reports/current-batch-train-state.md
.codex/reports/current-run-state.md
.codex/state/active-batch.yml
.codex/state/global-train-attempt-ledger.md
```

Restrictions:

* `scripts/**` may be modified only for prompt validators, queue validators, report validators, or read-only audit tooling.
* `.codex` state/report files may be modified only to record prompt-system or queue-state truth, never to falsely mark implementation complete.
* Do not touch production app behavior.

## Forbidden scope

Do not modify:

```text
Native/**
AppUI/**
Sources/**
Package.swift
project.yml
.github/**
entitlements
signing
generated Xcode project files
production Swift behavior
persistence/schema/model behavior
top-level IA changes
release artifact generation
TestFlight/App Store/device proof
```

Also forbidden:

* production app implementation
* app source refactors
* package moves
* generated Xcode project churn
* broad repo cleanup
* broad RHC cleanup pulled early
* standalone AIR train
* broad standalone EFC train
* restoring Plan as a top-level destination
* external/cloud LLM core behavior
* release/readiness claims without proof

## Required preflight

Run before editing:

```bash
git status --short
git diff --check
python3 -m json.tool docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json >/tmp/ambitions-global-queue-json-check.txt
python3 -m json.tool docs/codex/AMB_REMAINING_BATCH_REFERENCE.json >/tmp/ambitions-remaining-batch-reference-json-check.txt
python3 scripts/ambitions-queue-snapshot.py || true
python3 scripts/ambitions-control-plane-check.py || true
python3 scripts/ambitions-source-atlas-title-check.py --strict || true
make prompt-audit || true
make batch-self-check || true
```

Record actual command results and exit codes. Do not hide failures behind `|| true`; the command may continue, but the final report must record the real result.

## Required work phases

### Phase 1 — Repair immediate known prompt defect

Fix the known PK21 runner-header typo if present.

Required exact replacement:

```text
forbidden_unless_user_explicitly_bypasses_runner
```

must become:

```text
forbidden_unless_user_explicitly_bypasses_runner
```

Then verify:

```bash
grep -R "bypAS[S]ES" prompts/batches docs/codex/batches prompts/templates docs/codex || true
grep -R "DIRECT_CODEX_EXECUTION" prompts/batches/PK21.md
```

Hard Red if the typo remains after this batch.

### Phase 2 — Build full remaining-batch inventory

Do not rely on partial connector-visible output. Read the full repo files directly.

Create or update:

```text
docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md
docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json
```

The JSON must contain one record per remaining batch.

For every remaining batch record, include:

```json
{
  "id": "",
  "title": "",
  "train": "",
  "status": "",
  "queue_position": 0,
  "canonical_order_source": "",
  "prompt_path": "",
  "prompt_exists": true,
  "prompt_action": "rewrite_in_place | create_missing | do_not_run_header_only | no_change",
  "owner_scope": "",
  "batch_type": "",
  "dependency_gate": "",
  "hard_preconditions": [],
  "allowed_scope_summary": "",
  "forbidden_scope_summary": "",
  "validation_class": "",
  "proof_class": "",
  "risk_class": "",
  "source_atlas_applicability": "",
  "air_applicability": "",
  "efc_applicability": "",
  "fet_fvq_applicability": "",
  "rhc_applicability": "",
  "dptg_applicability": "",
  "consolidation_recommendation": "",
  "modification_recommendation": "",
  "removal_recommendation": "",
  "exact_codex_instruction_summary": "",
  "final_report_path": "",
  "next_handoff": ""
}
```

The Markdown blueprint must group records by train:

```text
PK
IR
SA
LDI
AOS
FCP
PFC
EFC
RHC
CS
PX
DPTG
Other discovered train(s)
```

For each group, include:

* purpose
* dependency posture
* what can be consolidated
* what must remain separate
* what should be added
* what should be removed or archived
* what should be modified
* exact Codex implementation posture
* required proof gates

Hard Red if the JSON record count does not match the repo’s authoritative remaining-batch count unless the report explains a valid repo-backed reason.

### Phase 3 — Locate and classify prompt files

For each remaining batch:

1. Resolve canonical prompt path by this priority:

   * `prompts/batches/<ID>.md`
   * existing `docs/codex/batches/*<ID>*Prompt.md`
   * existing train-local prompt content
   * materialize a new prompt only if no executable prompt exists
2. Record prompt location in the JSON blueprint.
3. Classify prompt action:

   * `rewrite_in_place`
   * `create_missing`
   * `do_not_run_header_only`
   * `no_change`
4. Do not duplicate prompts into parallel canonical locations unless existing repo truth says that location is canonical.

Hard Red if the batch creates duplicate executable prompts for the same ID without documenting the canonical winner and marking the duplicate historical/do-not-run.

### Phase 4 — Upgrade every remaining incomplete prompt

For every remaining incomplete prompt, rewrite or create the prompt so it includes:

```text
required runner header
Batch ID
runner command
operating mode
objective
active source truth
queue rule
allowed scope
forbidden scope
batch-specific implementation instructions
batch-specific validation
Source Atlas gate if applicable
AIR fold-in gate if applicable
EFC proof gate if applicable
FET/FVQ visual proof gate if applicable
RHC cleanup limit if applicable
DPTG terminal rule if applicable
Accepted Yellow policy
Hard Red conditions
rollback expectations
final report requirements
next-batch handoff
claims not made
```

Do not make every prompt generic. Every prompt must include exact implementation instructions specific to its batch.

For example:

* PK17 must instruct Today read-model extraction.
* PK18 must instruct Today command-handler extraction.
* SA07 must instruct Source Atlas claim state machine work.
* SA10 must instruct freshness/risk model implementation.
* LDI15 must instruct Living Plan Recompiler work.
* CS01 must instruct compatibility seam registry and risk map.
* RHC01 must instruct repo hygiene triage and owner map.
* PX01 must instruct Product Experience OS canon and surface hierarchy.
* DPTG00 must remain terminal and not executable until all pre-device gates close.

### Phase 5 — Source Atlas title normalization

Use active SA manifest and `scripts/ambitions-source-atlas-title-check.py` as title authority.

Repair generic Source Atlas labels where canonical titles exist.

Forbidden generic labels where canonical title exists:

```text
Source 1
Source 2
Doc
Document
Reference
Untitled
Generic Source
Placeholder Source
SA item
source TBD
SA11
SA12
SA13
SA14
SA15
SA16
SA17
SA18
SA19
SA20
SA21
SA22
SA23
SA24
SA25
SA26
SA27
SA28
SA29
SA30
SA31
SA32
```

If an ID is the batch ID itself, it may remain as an ID, but title fields must use canonical descriptive titles.

Run:

```bash
python3 scripts/ambitions-source-atlas-title-check.py --strict || true
```

Hard Red if Source Atlas generic labels remain where canonical titles exist.

### Phase 6 — Consolidation, addition, modification, removal recommendations

Create or update:

```text
docs/codex/AMB_GLOBAL_TRAIN_CONSOLIDATION_AND_MODIFICATION_PLAN.md
```

Include:

## Safe consolidations

Only governance consolidation is allowed by default:

* shared inherited execution standard
* shared final-report template
* shared validation matrix
* shared prompt-rewrite machinery
* shared queue snapshot and inventory tools

## Unsafe consolidations

Explicitly forbid:

* collapsing PK17-PK41
* turning AIR into standalone train
* turning EFC into broad implementation stream
* pulling RHC broad cleanup early
* making DPTG00 non-terminal
* duplicating canonical prompt paths
* using Plan as top-level destination
* introducing external/cloud LLM core behavior

## Additions to implement

Recommend only repo-backed additions, such as:

* complete non-PK prompt runnerization
* stricter prompt path canonicalization
* queue prompt coverage audit
* final-report schema consistency
* Source Atlas title normalization audit
* prompt duplicate detector
* stale Accepted Yellow retirement ledger

## Modifications to implement

Recommend exact modifications per train:

* PK: tighten implementation instructions, fix PK21, preserve PK17-PK41 sequence.
* SA: canonicalize titles, add freshness/provenance proof gates.
* LDI/AOS: fold AIR obligations into existing batches only.
* FCP/PFC/PX: strengthen visual/release-proof gates.
* CS: preserve compatibility seam retirement and proof/rollback expectations.
* RHC: keep terminal and owner-mapped.
* DPTG: terminal-only, device-proof only after all pre-device gates close.

## Removal/archive candidates

Do not delete in this batch unless active repo truth explicitly marks safe deletion. Prefer marking obsolete prompt files with do-not-run headers.

### Phase 7 — Generate exact implementation instructions by train

Create or update:

```text
docs/codex/AMB_GLOBAL_TRAIN_CODEX_IMPLEMENTATION_INSTRUCTIONS.md
```

This must be the start-to-finish guide Codex can use after this prompt-system rebuild.

Include:

1. Global execution command.
2. Current next batch.
3. Queue order.
4. Per-train execution gates.
5. Per-batch implementation expectations.
6. Validation map.
7. Final report map.
8. Recovery protocol.
9. Accepted Yellow retirement protocol.
10. Stop conditions.
11. Rollback expectations.
12. No-claim policy.

For every remaining batch, include an entry with:

```text
Batch ID:
Title:
Purpose:
Start condition:
Primary implementation action:
Files likely involved:
Files forbidden:
Tests/proof required:
Final report path:
Green definition:
Accepted Yellow allowance:
Red stop:
Next handoff:
```

If the full 146 records make the file large, keep it structured and complete. Do not summarize away individual batch instructions.

### Phase 8 — Prompt-system final validation

Run:

```bash
git status --short
git diff --check
python3 -m json.tool docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json >/tmp/ambitions-global-queue-json-check.txt
python3 -m json.tool docs/codex/AMB_REMAINING_BATCH_REFERENCE.json >/tmp/ambitions-remaining-batch-reference-json-check.txt
python3 -m json.tool docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json >/tmp/ambitions-global-remaining-train-blueprint-json-check.txt
make prompt-audit || true
make batch-self-check || true
python3 scripts/ambitions-queue-snapshot.py || true
python3 scripts/ambitions-control-plane-check.py || true
python3 scripts/ambitions-source-atlas-title-check.py --strict || true
python3 scripts/ambitions-final-report-gate.py docs/audits/global-remaining-train-blueprint-report.md --strict || true
```

If any validation cannot run, explain why and classify Green / Accepted Yellow / Red honestly.

## Required final audit report

Create:

```text
docs/audits/global-remaining-train-blueprint-report.md
```

It must include:

```text
Status: Green / Accepted Yellow / Red
Batch ID: GLOBAL-REMAINING-TRAIN-BLUEPRINT-01
Objective
Files changed
Files intentionally not changed
Queue evidence
Remaining record count
Completed batches confirmed not reactivated
PK17 next eligible evidence
PK17-PK41 preservation evidence
PK21 typo repair evidence
Prompt coverage table
Prompt files rewritten
Prompt files created
Prompt files marked historical/do-not-run
Prompt files intentionally not changed
Source Atlas title normalization evidence
AIR fold-in assessment
EFC proof-boundary assessment
RHC sequencing assessment
DPTG terminal assessment
CS compatibility seam assessment
PX/product-experience assessment
Validation commands and exit codes
Defects found
Defects repaired
Defects deferred
Accepted Yellow rationale, if any
Claims made
Claims not made
Rollback notes
Next eligible implementation batch
```

## Batch-specific hard Red conditions

Stop Red if:

* PK21 runner-header typo remains.
* PK17 is no longer next eligible without active repo evidence.
* completed batches are reactivated.
* canonical IDs are renumbered.
* queue order changes without evidence.
* PK17-PK41 are collapsed.
* any production app file is touched.
* any package/project/workflow/signing file is touched.
* external/cloud LLM core behavior is authorized.
* Plan is restored as a top-level destination.
* Source Atlas generic titles remain where canonical titles exist.
* AIR becomes standalone.
* EFC becomes broad sprawl.
* RHC broad cleanup is pulled early.
* DPTG00 becomes non-terminal.
* prompt duplicates are created without canonical path resolution.
* release/readiness claims are made without proof.
* final audit report omits validation failures.
* JSON output is invalid.

## Accepted Yellow policy

Accepted Yellow is allowed only if:

* all prompt-system core files are created/rewritten correctly,
* PK17 remains executable,
* completed batches remain non-reactivated,
* canonical IDs and queue order remain intact,
* no production app files are touched,
* no release/readiness claims are made,
* the remaining defect is non-blocking and fully documented.

Accepted Yellow is forbidden for:

```text
PK21 header typo remaining
invalid JSON
queue corruption
completed-batch reactivation
Source Atlas title failure
DPTG terminal failure
external/cloud LLM core authorization
production file mutation
release/readiness overclaim
```

## Rollback expectations

The final report must explain how to rollback:

* prompt file rewrites,
* newly created prompt files,
* blueprint docs,
* JSON blueprint,
* state/report updates,
* script validator changes if any.

Rollback must not delete completed-batch evidence, historical reports, or user-authored work.

## Claims not to make

Do not claim:

* app behavior changed
* PK17 implementation completed
* global train completed
* app is production-ready
* app is TestFlight-ready
* app is App Store-ready
* app is device-proven
* app is accessibility-compliant
* app meets performance targets
* privacy/legal/security compliance is proven
* sync/cloud readiness is proven
* DPTG00 can run now
* external/cloud LLMs are part of core architecture

## Final response requirements

End with:

```text
Status: Green / Accepted Yellow / Red
Files changed
Remaining record count
Prompt coverage result
PK21 repair result
Validation commands and exit codes
Defects found
Defects repaired
Defects deferred
Claims not made
Rollback notes
Next eligible implementation batch
```

The next eligible implementation batch should remain:

```text
PK17 Today Read Model Extraction
```

unless active repo truth proves otherwise.

<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HBI00 — Historical Baseline Active Train Install

Batch ID: HBI00

Runner command:

```bash
scripts/ambitions-codex-train.sh HBI00 prompts/batches/HBI00-HISTORICAL-BASELINE-ACTIVE-TRAIN-01.md
```

## Objective

Install Historical Baseline as active global batch-train scope and create the authority, queue, validator, and proof scaffolding needed for Codex to autonomously complete it through later bounded implementation batches.

Historical Baseline means Ambitions can build a reviewed current-state model from selected existing life evidence without treating life as starting on install day.

HBI00 is control-plane and documentation scaffolding. It must not claim runtime implementation is complete.

## Active source truth to inspect

Read in this order:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `.codex/GLOBAL_BATCH_TRAIN.md`
9. `docs/codex/BATCH_REGISTRY.md`
10. `docs/codex/HBI_HISTORICAL_BASELINE_GLOBAL_TRAIN_INSERT.md`
11. `docs/codex/AMB_GLOBAL_BATCH_TRAIN_SEQUENCE.md`
12. `.codex/state/active-batch.yml`
13. `.codex/reports/current-batch-train-state.md`

## Required HBI train shape

Create or update active queue material so Codex can discover this train:

- HBI00: active train install, authority, queue, validator, proof scaffolding.
- HBI01: source records, evidence vault, and canonical baseline object model.
- HBI02: selected-source adapters and import preview contracts.
- HBI03: candidate claims, confidence, freshness, and contradiction policy.
- IRQ01: import review queue, correction fold, and review actions.
- HBI04: current state snapshot and life map compiler.
- PRI01: runtime inspection and Why This source influence receipts.
- RHE01: recommendation humility and influence suppression policy.
- PPL01: export, delete, restore, and proof portability.
- MGP01: monetization boundaries for baseline depth without paywalling trust controls.
- RRE01: release/readiness evidence packet for Historical Baseline claims.

## Allowed scope

HBI00 may edit only:

- `docs/truth/*` for authority wording if needed.
- `docs/codex/*` for queue, registry, order, and train documentation.
- `.codex/*` for sequencing, state, reviewer, or advisory wiring.
- `prompts/batches/*` for HBI runner prompts.
- `scripts/*` only for non-mutating advisory validators.
- `docs/status/*` or `docs/audits/*` for HBI00 closeout evidence.

## Forbidden scope

HBI00 must not edit:

- production Swift source
- tests that imply runtime implementation exists
- persistence schema or migrations
- `project.yml`, `Package.swift`, generated project files, signing, entitlements, workflows, or CI
- dependencies
- cloud/backend/provider code
- AI/cloud LLM runtime code
- app UI implementation

## Product constraints for all later HBI batches

Later HBI implementation must preserve these constraints:

- No long intake form as the primary baseline experience.
- No automatic active-goal creation from imported evidence.
- No unreviewed source context steering Start Here.
- No cloud AI requirement in core Historical Baseline behavior.
- Source provenance, confidence, freshness, correction, export, delete, and receipt inspection are required for recommendation-influencing facts.
- Active IA remains exactly Today / Goals / Capture / Time / You.

## Validation expectations

HBI00 must run or create a non-mutating validator that checks for:

- HBI train insert exists.
- HBI00 prompt exists and has the runner-required header.
- active global-train or registry material references HBI.
- no HBI file claims production implementation complete.
- no HBI file claims release, device, sync, App Store, public accessibility, or legal/privacy approval.

Run existing claim/doc validation if available. If no safe validator exists, create `scripts/ambitions-historical-baseline-validate.py` as advisory-only and run it.

## Visual proof expectations

No visual proof is required for HBI00 because HBI00 must not touch UI implementation.

Future UI-touching HBI batches require screenshots, Dynamic Type coverage, VoiceOver/reduced-motion notes, and FET/AFI visual-quality gates.

## Hard Red stop conditions

Stop and report Red if:

- any production source or UI file is touched in HBI00
- HBI is marked implemented without source/test/proof evidence
- direct Codex execution bypasses the runner
- a cloud provider, hosted sync, telemetry, or external LLM becomes core Historical Baseline infrastructure
- active IA changes away from Today / Goals / Capture / Time / You
- release/readiness/privacy/accessibility/device/App Store claims are made without current raw proof
- validation contradicts the closeout status

## Rollback expectations

Rollback must be limited to HBI00-created or HBI00-edited docs, prompts, scripts, and closeout artifacts. Do not revert unrelated queue, registry, source, or user work.

## Required closeout artifact

Create:

`docs/audits/hbi00-historical-baseline-active-train-closeout.md`

It must include:

- changed files
- HBI queue placement
- validation commands and results
- what HBI00 proves
- what HBI00 does not prove
- next recommended batch
- rollback notes

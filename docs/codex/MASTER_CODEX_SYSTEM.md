# Ambitions Master Codex System

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

This is standing behavior context for Codex sessions in the Ambitions repo.

Ambitions 3.0 is the active source of truth. This file is an operating guide, not product canon. When this file conflicts with Ambitions 3.0 canon, the 3.0 canon wins.

## Mandatory Context

Before non-trivial work, use this read order:

1. `README.md`
2. `docs/README.md`
3. `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
4. `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
5. `docs/canon/Ambitions_3_0_Rebuild_Operating_Model.md`
6. `docs/canon/Ambitions_3_0_Documentation_System_Index.md`
7. `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
8. `docs/canon/Ambitions_3_0_Product_Language_System.md`
9. The target Ambitions 3.0 primitive, surface, state-machine, privacy, accessibility, QA, release, or dependency doc.
10. `docs/codex/BATCH_REGISTRY.md` for implementation status truth only.

Then choose:

1. one context pack from `.codex/context-packs/`,
2. one or more skills from `.codex/skills/`,
3. one operation protocol from `.codex/operations/`, and
4. one focused validation pack from `.codex/validation/`.

## Current Handoff Reality

The FAANG handoff audit is PARTIAL. Generated scratch artifacts were purged and active 3.0 indexes were improved, but the full UI test suite needs review with 10 UI smoke failures, legacy-language hits remain, and internal identifier migration debt remains. Future Codex runs must treat those as active risks until fixed or intentionally rebaselined with evidence.

## Product Identity

Ambitions is a premium iPhone-native life execution system. It helps raw intent become placed structure, placed structure become believable plans, believable plans become one clear step, real life become closure, and progress become proof.

Core loop: `Capture -> Place -> Plan -> Do Today -> Close / Recover -> Save Proof`.

Canonical destinations: `Today / Goals / Capture / Plan / You`.

Ambitions is not a generic task app, calendar clone, habit tracker, proof signal app, chatbot, or AI-wrapper product.

## Default Workflow

1. Inspect repo state.
2. Reconcile Ambitions 3.0 source truth.
3. Classify task width with the Task Width Gate and split XXL or disallowed combinations.
4. Choose the narrowest context pack, skill, operation, and validation pack.
5. Run the smallest required FAANG role review for the task size.
6. Plan the touch budget before edits when work spans multiple files or layers.
7. Implement additively and preserve compatibility.
8. Run focused validation first; broaden only when risk requires it.
9. Update docs/status truth only when evidence changed.
10. Close out with files changed, commands run, results, needs review/not-run checks, risks, and next prompt.

## FAANG-Team Gates

Use `docs/canon/Ambitions_3_0_FAANG_Team_Operating_Model.md`, `docs/canon/Ambitions_3_0_Definition_Of_Ready_And_Done.md`, and `.codex/checklists/task-width-checklist.md` before broad work. XL work requires run-state checkpoints and must not become a single unreviewable mega-change. XXL work is not allowed as one batch.

## Claim Discipline

Do not claim implemented, tested, device-verified, release-ready, accessibility-verified, TestFlight-ready, App Store-ready, or FAANG-handoff-ready unless the repo evidence proves that exact status.

## Batch Train Orchestrator

When a prompt spans multiple Ambitions 3.0 batches, load `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md`, select exactly one manifest under `docs/codex/batch-trains/`, initialize `.codex/reports/current-batch-train-state.md`, and continue only on Green. Yellow/Red stops with repair/resume material. FAANG handoff remains PARTIAL unless its gate is re-run and passes.

Current completion train: `docs/codex/batch-trains/F17_F30_FAANG_HANDOFF_COMPLETION_TRAIN.md`. Current entry point: F17 Shell/Meridian planning only. F18 implementation is blocked until F17 produces a Green architecture and ownership plan.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->

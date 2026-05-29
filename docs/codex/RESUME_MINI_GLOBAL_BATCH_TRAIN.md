# Resume Mini Global Batch Train

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Alias phrase: `resume mini global batch train`
Status: active Codex operating alias.
Scope: cost-efficient global batch-train continuation under Mini Execution Tier rules.

## Purpose

When the user says `resume mini global batch train`, Codex must continue Ambitions global execution as a Mini-safe autonomous implementation train. The run should move fast through bounded batches, repair scoped failures, and defer senior-only work instead of guessing.

This alias is intended for `gpt-5.4-mini` or an operator-declared Mini-tier run.

## Required First Read

Before doing any work, read:

1. `README.md`
2. `AGENTS.md`
3. `docs/codex/MODEL_TIER_EXECUTION_POLICY.md`
4. `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md`
5. `docs/codex/RESUME_MINI_GLOBAL_BATCH_TRAIN.md`
6. `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md`
7. `.codex/reports/current-run-state.md`
8. `.codex/reports/current-batch-train-state.md`
9. `docs/codex/BATCH_REGISTRY.md`
10. `docs/codex/CONTEXT_INDEX.md`
11. `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
12. target batch prompt and source truth

If these files disagree, Mini must not resolve the conflict by judgment. It may repair stale dependent artifacts only when repo evidence is clear. Otherwise stop Red or defer to Senior if non-blocking.

## Model Declaration

At the start of the run, record one of:

- `model tier: Mini Execution Tier / actual gpt-5.4-mini`
- `model tier: Mini Execution Tier / operator-declared`
- `model tier: unknown / Mini-safe restrictions applied`

Do not claim to know the model if the active Codex surface does not expose it.

## Mini Continuation Rule

Mini continues automatically through:

- Green batches with proof
- accepted Yellow batches with owner, safety reason, follow-up, recheck condition, and no-claim boundary
- non-blocking senior-only deferrals recorded in `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md`

Mini stops on:

- Hard Red
- unknown dirty tree
- source-truth conflict requiring judgment
- blocking senior-only prerequisite
- unsupported release/device/accessibility/legal/privacy/platform claim risk
- forbidden file boundary need
- broad refactor need outside the active batch
- repeated same-root failure after two scoped repair attempts

## Mini Batch Intake Checklist

Before editing, Mini must classify the target batch:

- Mini-safe: yes / no / unknown
- Senior-only gates: none / listed
- Blocking prerequisites: none / listed
- Allowed files:
- Forbidden files:
- Required focused validation:
- Required report/state updates:

If Mini-safe is `no` and the batch is non-blocking, defer. If Mini-safe is `no` and blocking, stop Red for Senior.

## Per-Batch Execution Contract

For each Mini-safe batch:

1. confirm repo state
2. read source truth
3. name exact allowed and forbidden files before edits
4. execute the smallest safe slice
5. run focused validation first
6. run required broader checks only where scoped
7. repair failures in loop
8. write/update the batch report
9. update registry/context/current-state/order files where safe
10. record model tier and Mini-safe classification in the report
11. commit with a batch-specific message
12. select the next eligible batch from repo evidence
13. continue until complete, deferred, or Red

## Deferral Contract

When Mini defers:

1. do not make app/source changes for that batch unless already safely reverted or explicitly evidence-only
2. add a ledger entry in `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md`
3. state `Deferred by Mini; Senior train required`
4. record why skipping is safe or stop if it is not safe
5. preserve no-claim boundaries
6. continue only when a later batch is independently safe

## Final Response Shape

At each visible checkpoint, report:

- Model tier used
- Batch status: Green / accepted Yellow / Deferred / Red
- Current train state before the batch
- Files changed
- Implementation summary
- Tests/checks run
- Proof artifacts
- Senior-only gates encountered
- Deferrals created or closed
- Hard Reds, if any
- Yellow advisories, if any
- Registry/context/current-state updates
- Next eligible global batch
- Whether the train is continuing or stopped

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

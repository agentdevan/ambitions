# Codex Batch Train Protocol

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active Codex OS batch-train protocol.
Date: 2026-05-08

## Continuation

- Continue through Green.
- Continue through accepted Yellow only when owner, safety reason, and no-claim boundary are recorded.
- Do not stop on accepted Yellow when those fields are present and the next batch is safe.
- Stop on hard Red.
- When model tier matters, follow `docs/codex/MODEL_TIER_EXECUTION_POLICY.md` before ordinary continuation.

## Model-Tier Continuation

Mini Execution Tier may continue through:

- Green Mini-safe batches with evidence
- accepted Yellow Mini-safe batches with owner, safety reason, follow-up, recheck condition, and no-claim boundary
- non-blocking senior-only deferrals recorded in `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md`

Mini Execution Tier must stop instead of continuing when:

- the next batch is senior-only and blocking
- source-truth conflict requires judgment
- a route/raw-value, persistence/schema, dependency, signing, entitlement, workflow, sync/cloud, backend, hosted AI, release, device, accessibility, legal/privacy, or founder-acceptance boundary is crossed without explicit authorization
- a senior-only gate would need to be closed Green
- a deferral ledger entry is required but not created

Senior Judgment Tier must inspect `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md` before closeout or judgment-heavy continuation and resolve blocking deferrals before ordinary global-order progress.

## Mandatory Stops

- Unknown dirty tree.
- Destructive conflict or overwrite need.
- Privacy/security/legal ambiguity.
- Unsupported release/device/accessibility/legal/privacy claim.
- Repeated same-root Red after two repair attempts.
- Unowned dependency gap.
- Missing route/source owner for the next batch.
- Mini attempting to close or bypass a senior-only gate.
- Unknown model tier attempting a senior-only decision.
- Blocking model-tier deferral without Senior resolution.

## No Double Work

Before starting a batch, search owner docs, prompts, audit reports, source files, skills, scripts, and maps for existing equivalents. Extend or reconcile owners instead of creating duplicates.

## Model-Tier Batch Intake

Before starting any batch under Mini-tier, Senior-tier, or unknown-tier execution, classify:

- Model tier used:
- Model-tier source: actual / operator-declared / unknown
- Mini-safe: yes / no / unknown / not applicable
- Senior-only gates:
- Blocking prerequisites:
- Allowed files:
- Forbidden files:
- Required focused validation:
- Required report/state/ledger updates:

Mini may proceed only when Mini-safe is `yes`. Mini may defer only when Mini-safe is `no` or `unknown` and the batch is non-blocking. Mini must stop when Mini-safe is `no` or `unknown` and the batch is blocking.

## Deferral Before Skip

A skipped senior-only batch is invalid unless it is recorded as a model-tier deferral.

A valid Mini deferral requires:

- ledger entry in `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md`
- clear senior-only gate
- blocking status
- safe-to-continue reason
- explicit no-claim boundary
- required Senior action

Do not call a deferred batch complete. Do not mark a deferred batch Green. Do not bury a deferral inside ordinary Yellow notes.

## Commit Cadence

Use one logical commit per batch or Codex OS upgrade. Do not mix product implementation and Codex OS governance in one commit unless the user explicitly scopes it that way.

Model-tier policy, alias, and ledger changes are Codex OS governance changes and should commit separately from product implementation.

## Restartability

Every interruption point must produce or preserve enough state to restart:

- selected route
- active batch
- model tier and model-tier source when relevant
- Mini-safe classification when relevant
- senior-only gates encountered
- model-tier deferrals opened or resolved
- allowed/forbidden files
- files touched
- commands and exit codes
- raw log paths
- Green/Yellow/Deferred/Red classification
- next eligible action

## Final Report Additions

Every batch report created after model-tier policy adoption must include:

- Model tier used
- Model-tier source
- Mini-safe classification
- Senior-only gates encountered
- Deferrals created or closed
- Why continuing is safe, or why stopping is required

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

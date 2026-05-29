# Batch Throughput Operating Model

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, status-expedite
> Dispositions: clarify-status-before-use, merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Purpose

This is a Codex OS operating model for speeding safe queue movement while preserving
source-truth discipline and proof honesty. It exists for non-product batch infrastructure work.

## Fastest-safe model

1. **One canonical write lane**
   - `GPT-5.5` (plan/decision/review/final gate) executes through `make batch`.
2. **Many read-only prep lanes**
   - GPT-5.4-mini/unknown-tier model work is limited to prep notes, classification,
     validation routing, and deterministic script-assisted reporting.
3. **GPT-5.4-mini bounded execution**
   - `GPT-5.5` approves every hard decision.
4. **Repair desk ownership**
   - Non-Green outcomes route to repair/finalization as repair prompts only.
5. **No run-time feature drift**
   - This model owns no product behavior changes.

## Exact command flow

```bash
git pull --ff-only
git status --short --branch
make batch-self-check
make prompt-audit
make autonomous-train-status
make autonomous-train-next
make autonomous-train-run-current
make autonomous-train
make repair-status
make repair-next
make repair-current
```

## Batch execution command policy

- Standard run:
  - `make batch BATCH=<BATCH_ID> PROMPT=prompts/batches/<BATCH_ID>.md`
- Review or staging-safe draft:
  - `make batch-no-commit BATCH=<BATCH_ID> PROMPT=prompts/batches/<BATCH_ID>.md`
- Explicit push by owner only:
  - `AUTO_PUSH=1 make batch BATCH=<BATCH_ID> PROMPT=prompts/batches/<BATCH_ID>.md`

Auto-push is discouraged until several clean eligible batches close consecutively with no
new unresolved continuation gates in active state.

## Model and lane boundary

- GPT-5.5 owns planning, source-truth judgment, canonical proof interpretation,
  and final commit eligibility.
- GPT-5.4-mini implements only the bounded patch requested by an approved Phase 01 boundary.
- All runners, autonomous commands, repair lanes, and queue tooling remain read-only
  unless in the approved batch command lane.
- EFC, queue truth, and current-state posture are never relaxed to improve throughput.

## Continuation

- If next executable batch is now known, lane choice comes from queue truth and active
  train state (not stale memoized status).
- If PK/other command files are missing or stale, prep notes must remain candidate-only
  and cannot be used for implementation decisions.

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

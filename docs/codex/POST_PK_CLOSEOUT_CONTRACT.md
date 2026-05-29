# Post-PK Closeout Contract

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: active after PK41  
Authority: supporting process contract

## Contract

Every post-PK batch should close in one eligible commit whenever practical:

1. implementation / docs / prompt changes,
2. focused tests or proof-light evidence,
3. closeout report,
4. state advancement,
5. queue advancement,
6. next-batch handoff.

## Required Closeout Fields

Closeout reports must include:

- status (`Green`, `Accepted Yellow`, or `installed_unverified`),
- source truth inspected,
- files changed,
- validation commands and exit codes,
- EFC applicability,
- claims not made,
- rollback notes,
- next handoff.

## State Advancement

Use:

```bash
python3 scripts/ambitions-advance-batch-state.py --completed <BATCH> --next <NEXT> --status <green|accepted_yellow|installed_unverified> --commit <SHA> --report <REPORT> --write
python3 scripts/ambitions-state-advance-validate.py
```

## Coalescing Commit

Use:

```bash
python3 scripts/ambitions-closeout-coalesce.py --batch <BATCH>
python3 scripts/ambitions-closeout-coalesce.py --batch <BATCH> --stage
```

Only stage after scope review.

## Rule

Do not finish a batch unless the next executable batch is already set.

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

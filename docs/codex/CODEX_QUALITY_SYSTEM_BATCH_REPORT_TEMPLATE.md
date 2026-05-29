# Codex Quality System Batch Report Template

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Use this template for CQS-enhanced batch reports.

```markdown
# <Batch ID> <Batch Name> Report

Date:
Result: Green / Accepted Yellow / Recoverable Red / Hard Red
Train:
Batch ID:

## Result

## Source Truth Used

## Files Read

## Files Changed

## What Changed

## Why

## Alternatives Considered

## Product Decisions Preserved

## Caveats Preserved

## Candidate Items Touched Or Avoided

## CQS Reviewers Applied

## Gate Result Manifest

Required for every CQS-enhanced batch unless explicitly not applicable.

- Manifest path: `docs/audits/gate-results/<batch-id>-gate-result.json`
- Schema: `gate-result-manifest.v1`
- Validation command: `python3 scripts/validate-gate-result-manifest.py docs/audits/gate-results/<batch-id>-gate-result.json`
- Strict/advisory mode:
- Gate families invoked:
- Yellow/Red items represented in manifest:

## Commit Provenance

- Base SHA before batch:
- Head SHA after batch:
- Commit SHA:
- Commit author if available:
- Commit timestamp if available:
- Branch:
- Remote main SHA at validation:
- Working tree clean at closeout: yes / no

## AQOS Impact Classification

## FVQ Rendered Proof Classification

Use one of: not applicable / inherited / produced / operator checklist /
Recoverable Red / Hard Red.

Required for UI-affecting batches:

- visible surfaces touched
- primary object owner
- screenshot or rendered preview evidence path
- freshness proof
- visual score impact
- accessibility/readability impact
- Reduce Motion impact
- privacy-sensitive rendering impact
- dashboard/card-stack/prototype drift result
- FVQ repair decision

## Accessibility / Reduced Motion Impact

## Privacy / Legal / App Store Impact

## Performance / Battery Impact

## Validation Commands

## Validation Results

## Advisory / Strict Gate Results

Record:

- CQS advisory scripts run
- Source Atlas advisory scripts run, if relevant
- CQS_STRICT value
- warnings accepted as Yellow
- hard failures, if any

## Repairs Attempted

## Remaining Yellow Items

## Red Classification

## Rollback Path

## Next Eligible Batch

## Continuation Decision
```

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

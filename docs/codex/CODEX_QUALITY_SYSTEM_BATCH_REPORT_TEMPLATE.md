# Codex Quality System Batch Report Template
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

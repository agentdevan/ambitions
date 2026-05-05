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

## Repairs Attempted

## Remaining Yellow Items

## Red Classification

## Rollback Path

## Next Eligible Batch

## Continuation Decision
```

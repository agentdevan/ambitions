# Evidence-Gated Quality Reviewer Skill

## Purpose

Use this skill to enforce AQOS on every batch.

The reviewer does not ask whether the batch looks convincing. It asks whether the batch produced the exact evidence required for the domains it touched.

## Review Steps

1. Read the batch diff or intended files.
2. Run or simulate `AQOS_BATCH_IMPACT_CLASSIFIER` from docs.
3. Map touched domains to `AQOS_REQUIRED_EVIDENCE_MATRIX`.
4. Confirm evidence exists in durable paths.
5. Confirm report uses AQOS Green Taxonomy.
6. Identify missing evidence.
7. Classify missing evidence as Accepted Yellow, Recoverable Red, or Hard Red.
8. Require repair batch for recoverable Red.

## Pass Standard

Pass only when:

- touched domains are classified;
- required evidence is produced or safely deferred;
- Green type is specific;
- no Hard Red remains;
- no generic Green language hides partial proof.

## Common Failure Modes

- UI changed but no rendered screenshot.
- Accessibility label exists but no Dynamic Type/VoiceOver order proof.
- Privacy-sensitive content touched but no leak scan.
- Schema touched but no migration proof.
- Performance-sensitive visual touched but no budget.
- Release wording used without claim-truth evidence.
- Architecture changed but no boundary/file-size review.

## Output

Return:

- Result
- Missing evidence
- Required repair
- Can continue: yes/no

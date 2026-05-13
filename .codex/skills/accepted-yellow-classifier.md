# Accepted Yellow Classifier Skill

Status: Active speed skill  
Purpose: Decide quickly whether a non-Green batch result may proceed as Accepted Yellow or must stop Red.

## Use when

Use after any failed, degraded, optional, or partially completed validation command.

## Fast command

```bash
python3 scripts/ambitions-red-repair-router.py --json < failure.log
```

## Accepted Yellow may proceed only when

```text
non-blocking
fully documented
safe for data/persistence/queue/source integrity
safe for HBI/MRI applicability
not a release/readiness claim
not a forbidden-scope mutation
final report explicitly allows next batch to proceed
```

## Hard Red, do not proceed

```text
unknown dirty user work
canonical queue corruption
completed-batch reactivation
HBI guard failure
MRI routing conflict
forbidden file mutation
broad unrelated staging
external/cloud LLM core behavior
custom hosted user-data backend
unproven release/device/App Store/TestFlight/accessibility/privacy/legal claim
```

## Procedure

1. Classify the failure text.
2. If repairable in scope, repair and validate.
3. If Yellow candidate, document exact reason and proof boundary.
4. If hard Red, stop and report.
5. Never downgrade a true Red to Yellow for speed.

## Claim boundary

This skill accelerates classification only. It does not override active source truth, final report gates, HBI/MRI guards, or release proof requirements.

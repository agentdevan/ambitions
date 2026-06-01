# AFEP-013 Time Pressure Packet

Batch: `AFEP-013`
Date: `2026-06-01`

## What Changed

- Extended `TimeLifeSuiteShapeState` with deterministic schedule pressure, protected time, capacity, proof opportunity, provenance, and privacy labels.
- Surfaced those labels in `TimeLifeShapeFieldItem` accessibility text and inspection copy.
- Kept the projection local-only, qualitative, and non-calendar-clone in wording.

## Validation

- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-013`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-013 --prompt prompts/batches/AFEP-013.md --batch-type source-changing --allow-yellow`
- `xcodegen generate`
- `make xcode-build-for-testing BATCH=AFEP-013`
- `make xcode-focused-test BATCH=AFEP-013 TEST=AmbitionsTests/TimeFeatureServiceTests`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-013 --prompt prompts/batches/AFEP-013.md --changed-from 9de6dfed67a03613935a290840e8af85e650e666 --batch-type source-changing --allow-yellow`
- `git diff --check`

## Proof Notes

- The focused Time test lane passed after the tuple comparison was simplified to string projections.
- The projection is deterministic across repeated loads from the same repository snapshot.
- No goals or captures were mutated by the new projection test.
- The copy stays away from `calendar grid`, `%`, score language, and silent mutation language.

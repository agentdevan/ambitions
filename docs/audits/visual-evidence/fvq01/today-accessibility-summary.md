# FVQ01 Today Accessibility Summary
<!-- markdownlint-disable MD013 -->

Result: Accepted Yellow
Date: 2026-05-05

## Evidence

- Screenshot: `docs/audits/visual-evidence/fvq01/today-default.png`
- Focused UI proof: `testTodaySurfaceShowsDominantHeroAndPrimaryAction`
  passed with 1 test and 0 failures.
- Focused Today unit proof: `TodayViewModelTests` passed with 37 tests and
  0 failures.

## Accessibility Notes

- Today still exposes the stable `today.screen`, `TodayRealityRail`,
  `TodayRealityRailPrimaryAction`, `TodayRealityRailNowSection`,
  `TodayRealityRailNextSection`, and `TodayRealityRailLaterSection`
  identifiers.
- Start Here is visible at the top of the first viewport after FVQ01 repair.
- The visual rail no longer depends on the removed explanatory composition
  panel for meaning.
- Manual VoiceOver traversal, measured contrast, physical-device proof,
  Dynamic Type screenshot proof, and Reduce Motion screenshot proof were not
  completed in FVQ01 and remain accepted Yellow evidence gaps.

## Reduced Motion Notes

- FVQ01 did not alter motion semantics.
- Existing Reduce Motion policy remains code-owned by the Today rail and shared
  motion primitives.
- A durable Reduce Motion screenshot fixture is still missing and should be
  owned by a future visual fixture batch.

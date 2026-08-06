# Verification

## Exact automated and build checks

```bash
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
scripts/ambitions-xcode-test-focused.sh --batch PDL-GOAL-PATH --test AmbitionsTests/GoalPathGenerationModelsTests --test AmbitionsTests/GoalPathCandidateMaterializerTests --test AmbitionsTests/GoalPathGenerationCoordinatorTests --test AmbitionsTests/AcceptGoalPathVersionCommandTests
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
make xcode-build-for-testing BATCH=PDL-GOAL-PATH
git diff --check
```

## Required evidence

- Automated: requirement grammar, candidate completeness/order, source/unknown
  ceilings, edit/invalidation, one-current-path CAS, idempotency, prior-version
  lineage, replay, migration, and comparison handoff cover REQ-001 to REQ-016.
- Runtime: stable Goal entry, generate/review/edit/refresh/defer/reject/accept,
  offline resume, concurrent revision failure, projection catch-up, and separate
  schedule handoff.
- Accessibility: direct ordered route semantics, VoiceOver, assistive controls,
  keyboard, largest Dynamic Type, contrast, reduced effects, non-diagram parity,
  and stale/error focus on a supported physical iPhone.
- Privacy: Goal, Capability, constraints, Proof, candidates, assumptions, and
  rationale remain local; public requests use allowlisted artifact IDs only.
- Migration: empty review-draft schema, direct-upgrade fixtures, crash/rerun,
  unknown draft quarantine, accepted-path preservation, backup/restore, replay.
- Performance: measure materialization, graph validation, explanation,
  projection, and replay at representative route sizes; set environment-bound
  thresholds before merge.
- Build/device: build-for-testing and physical rendered/interaction evidence.
  Success probability, destination change, schedule fit, external acceptance,
  release, and App Store proof are N/A.

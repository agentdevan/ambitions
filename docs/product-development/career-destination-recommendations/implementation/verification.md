# Verification

## Exact automated and build checks

```bash
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/source-atlas-no-private-graph-egress-audit.py
python3 scripts/ambitions-runtime-direct-write-audit.py
scripts/ambitions-xcode-test-focused.sh --batch PDL-CAREER --test AmbitionsTests/CareerRecommendationModelsTests --test AmbitionsTests/CareerEligibilityPolicyTests --test AmbitionsTests/CareerCandidateComposerTests --test AmbitionsTests/CareerExplorationCoordinatorTests --test AmbitionsTests/CareerPreferenceCommandServiceTests
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
make xcode-build-for-testing BATCH=PDL-CAREER
git diff --check
```

## Required evidence

- Automated: lane separation, permutation determinism, sparse/unknown source,
  sensitive-output suppression, correction/dismissal, preference lifecycle,
  replay, migration, and typed adoption handoff cover REQ-001 through REQ-013.
- Runtime: explicit entry, input review, both lanes, source inspection, save,
  correction, dismiss/exclude/reset, offline relaunch, stale refresh, and handoff.
- Accessibility: direct VoiceOver, assistive controls, keyboard, largest Dynamic
  Type, contrast, reduced effects, non-color lane/state, and focus recovery.
- Privacy: pairwise private-context egress tests prove fixed public requests and
  no Capability, direction, candidate, rationale, dismissal, location, schedule,
  protected output, or derived key reaches any prohibited boundary.
- Migration: empty preference store, crash/rerun, unsupported version quarantine,
  backup/restore, deletion, and replay equivalence.
- Performance: measure composition, classification, ordering, projection, and
  cancellation at representative bounded candidate/capability/reference sizes;
  set thresholds with device/OS/build metadata.
- Build/device: build-for-testing plus physical-iPhone rendered/interaction and
  assistive-technology evidence. Hiring, licensing, placement, release, and App
  Store proof remain N/A.

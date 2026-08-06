# Verification

## Exact automated and build checks

```bash
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/source-atlas-no-private-graph-egress-audit.py
scripts/ambitions-xcode-test-focused.sh --batch PDL-HOBBY --test AmbitionsTests/HobbyRecommendationModelsTests --test AmbitionsTests/HobbyDestinationEligibilityPolicyTests --test AmbitionsTests/HobbyCandidateWindowPolicyTests --test AmbitionsTests/HobbyExplorationCoordinatorTests
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
make xcode-build-for-testing BATCH=PDL-HOBBY
git diff --check
```

## Required evidence

- Automated: exhaustive family/gate matrix, 0/1/2/4/5+ candidate permutations,
  neutral ordering, overflow, protected suppression, static-diagnostic equality,
  memory cleanup, and zero persistence cover REQ-001 through REQ-015.
- Runtime: explicit entry, disclosure, temporary inputs, results, overflow,
  correction, dismissal, None, unrelated exploration, source inspection,
  unavailable/error, background/termination, and empty relaunch.
- Accessibility: direct VoiceOver/assistive controls/keyboard, largest Dynamic
  Type, RTL, contrast, reduced effects, semantic ordering, and focus recovery.
- Privacy: assert no private choice, Capability, consent, protected fact,
  candidate, rationale, suppression, count, duration, category, correlation,
  dismissal, or session key enters storage, learning, logs, telemetry, caches,
  feedback, support, R2, Account, Source Atlas request, or hosted AI.
- Migration: N/A because no user/session persistence is permitted. Verify only
  incompatible policy/corpus schema fails quiet and existing stores are unchanged.
- Performance: measure certificate validation, local filtering/classification,
  neutral ordering, recomputation, cancellation, and cleanup at bounded fixture
  sizes; set regression thresholds with environment metadata.
- Build/device: build-for-testing and physical-iPhone rendered/accessibility
  evidence. Real corpus authority, provider safety, release, and App Store proof
  are outside this initiative.

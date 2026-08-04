# Verification

## Exact automated and build checks

```bash
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
scripts/ambitions-xcode-test-focused.sh --batch PDL-PATH-COMPARE --test AmbitionsTests/PathComparisonModelsTests --test AmbitionsTests/PathDifferenceEngineTests --test AmbitionsTests/PathComparisonCoordinatorTests --test AmbitionsTests/PathComparisonHandoffTests
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
make xcode-build-for-testing BATCH=PDL-PATH-COMPARE
git diff --check
```

## Required evidence

- Automated: permutation/equivalence, complete consequences, unknowns, bridge
  alternatives, non-ranking, edit/invalidation, checkpoint recovery, CAS,
  replay, migration, and one handoff cover REQ-001 through REQ-016.
- Runtime: compare two-to-four candidates, detail, edit, refresh, pause/defer,
  reject, select, background/terminate/resume, stale path, and owner rejection.
- Accessibility: VoiceOver, assistive controls, keyboard, largest Dynamic Type,
  ordered nonvisual parity, contrast, reduced effects, and focus recovery.
- Privacy: route candidates, Goal, Capability, Proof, constraints, decision,
  rationale, and draft state remain local; public claim fetches stay fixed-ID.
- Migration: empty draft collection, crash/rerun, unknown schema quarantine,
  backup/restore, draft deletion, and no accepted-path reinterpretation.
- Performance: measure difference/equivalence, explanation, projection, and
  checkpoint recovery at representative bounded route graphs; set thresholds.
- Build/device: build-for-testing and physical rendered/assistive evidence.
  Canonical adoption is proven only by Goal Path owner tests; schedule, Life
  Branch, success, release, and App Store claims are N/A.

# Verification

## Exact automated and build checks

```bash
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
scripts/ambitions-xcode-test-focused.sh --batch PDL-CONTEXT-FIT --test AmbitionsTests/ContextFitModelsTests --test AmbitionsTests/ContextFitPolicyTests --test AmbitionsTests/ContextObservationCoordinatorTests --test AmbitionsTests/ContextFitComparisonCoordinatorTests --test AmbitionsTests/ProtectedStepPlacementPolicyTests
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
make xcode-build-for-testing BATCH=PDL-CONTEXT-FIT
git diff --check
```

## Required evidence

- Automated: context matrices, surrounding commitment/transition/recovery,
  place/tools/interruption, protected rules, unknowns, observation lifecycle,
  stale races, replay, migration, and placement-owner handoff cover REQ-001 to
  REQ-014.
- Runtime: compare pre-work/post-gym and other fixture windows, inspect reasons,
  correct/disable observations, preview, cancel, confirm placement, recover from
  concurrent schedule change, offline relaunch, and projection delay.
- Accessibility: direct VoiceOver/assistive controls/keyboard, largest Dynamic
  Type, ordered reasons, non-color fit states, protected warning, reduced effects,
  and focus recovery on a physical iPhone.
- Privacy: Step/window/commitment/location/tool/recovery/observation context stays
  local and cannot influence public requests, logs, telemetry, diagnostics,
  support, R2, Account, or hosted AI beyond approved static codes.
- Migration: empty observation store, crash/rerun, version quarantine,
  correction/deletion, backup/restore, protected-consent expiry, and replay.
- Performance: measure comparison, impact-cone refresh, projection, and large-
  text rendering with representative calendars; set latency/memory/energy budgets.
- Build/device: build-for-testing and physical rendered/assistive proof.
  Clinical inference, optimality, automatic scheduling, release, and App Store
  readiness remain unclaimed.

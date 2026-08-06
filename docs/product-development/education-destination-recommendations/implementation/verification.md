# Verification

## Exact automated and build checks

```bash
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/source-atlas-no-private-graph-egress-audit.py
python3 scripts/ambitions-runtime-direct-write-audit.py
scripts/ambitions-xcode-test-focused.sh --batch PDL-EDUCATION --test AmbitionsTests/EducationRecommendationModelsTests --test AmbitionsTests/EducationEligibilityPolicyTests --test AmbitionsTests/EducationOptionComposerTests --test AmbitionsTests/EducationExplorationCoordinatorTests --test AmbitionsTests/EducationPreferenceCommandServiceTests
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
make xcode-build-for-testing BATCH=PDL-EDUCATION
git diff --check
```

## Required evidence

- Automated: every route form/authority lane, classification-versus-requirement,
  transfer/accreditation/acceptance ceilings, consent, unknown/conflict, ordering,
  lifecycle, replay, and handoff covers REQ-001 through REQ-019.
- Runtime: explicit education entry, input/consent, compare, source inspection,
  correction, save/dismiss/defer, offline resume, stale refresh, and handoff.
- Accessibility: physical-iPhone VoiceOver, Voice Control, Switch Control,
  keyboard, largest Dynamic Type, contrast, reduced effects, semantic authority
  order, and error/focus recovery.
- Privacy: private education history, Capability, protected facts, option,
  rationale, consent, dismissal, and derived keys never enter public requests,
  caches, telemetry, logs, diagnostics, support, R2, Account, or hosted AI.
- Migration: empty collections, crash/rerun, schema quarantine, backup/restore,
  consent expiry, deletion, and pre/post replay equivalence.
- Performance: measure public-claim adaptation, local composition, classification,
  projection, cancellation, and store rebuild at representative sizes; set
  regression thresholds with environment metadata.
- Build/device: build-for-testing and direct rendered/interaction evidence.
  Admission, transfer, financial, licensing, provider, release, and App Store
  outcomes are explicitly not proven.

# Ambitions 3.0 Testing And Release Proof

Status: Active engineer handoff packet
Last updated: 2026-05-01

## Current Verified Evidence

Latest full local test proof:

```text
scripts/test-local.sh
output/logs/test-local-20260501-220744.log
```

Result:

- Unit tests: 779 tests, 0 failures.
- UI tests: 29 tests, 0 failures.
- Goal Detail trust/memory proof passed in the full suite after F28
  rebaseline.

Latest local build proof:

```text
scripts/build-local.sh
output/logs/build-local-20260501-224535.log
```

Result:

- Build succeeded on `iPhone 17` simulator destination.

F27/F28/F27.5 gate evidence:

- `docs/audits/ambitions-3-0-final-faang-handoff-readiness-report.md`
- `docs/audits/ambitions-3-0-f28-faang-handoff-repair-report.md`
- `docs/audits/ambitions-3-0-f27-5-human-made-codebase-maintainability-audit.md`

## Recommended Validation Ladder

For code changes:

```bash
scripts/validate-dev-tools.sh || true
scripts/build-local.sh
scripts/test-local.sh
git diff --check
```

For docs-only changes:

```bash
scripts/run-doc-qa.sh || true
git diff --check
```

For SwiftUI architecture-sensitive changes:

```bash
scripts/swiftui-architecture-scan.sh || true
scripts/build-local.sh
```

For train operations:

```bash
scripts/batch-train-preflight.sh || true
scripts/batch-train-gate-check.sh || true
```

## Advisory Backlog

These are known and do not become release claims:

- Markdownlint/doc QA backlog remains advisory unless a batch worsens touched
  files or claims docs are fully clean.
- SwiftUI architecture scan reports pre-existing large-file/extraction risks.
- Physical-device behavior is not verified.
- Rendered widget, Live Activity, Lock Screen, Dynamic Island, Shortcuts/Siri,
  and App Store surfaces are not verified on real platform surfaces.
- Manual VoiceOver, Dynamic Type, Reduce Motion, and accessibility conformance
  are not verified.

## Release Claims Not Yet Allowed

Do not claim:

- App Store submission readiness
- TestFlight distribution readiness
- final release approval
- final RC lock
- signed archive/App Store Connect validation
- physical-device QA
- public accessibility conformance
- rendered external-platform proof

The current truthful release posture remains evidence-bound and internal until
human/operator gates close.

## UI Smoke Notes

The current UI smoke suite is Green. The repaired Goal Detail test now proves:

- canonical Goals routing opens Goal Detail;
- strategic header remains first-layer;
- path filmstrip is reachable;
- `goal-detail.trust-whisper` is reachable below the strategic layer;
- `goal-detail.memory-narrative` is reachable below the strategic layer.

Avoid returning this test to nested full-hierarchy button/static-text queries
that can time out under full-suite load.

## Handoff Gate Rule

A future PASS claim must name:

- command run;
- log path;
- exact pass/fail summary;
- known advisory warnings;
- explicit claims not made.

If validation cannot be trusted, stop and classify the blocker instead of
continuing the train.

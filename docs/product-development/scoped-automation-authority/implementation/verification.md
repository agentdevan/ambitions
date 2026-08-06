# Verification

## Exact automated and build checks

```bash
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
scripts/ambitions-xcode-test-focused.sh --batch PDL-SCOPED-AUTOMATION --test AmbitionsTests/ScopedAutomationGrantModelsTests --test AmbitionsTests/ScopedAutomationAuthorityPolicyTests --test AmbitionsTests/ScopedAutomationAuthorityRepositoryTests --test AmbitionsTests/ScopedAutomationSchemaMigrationTests --test AmbitionsTests/ScopedAutomationCommandCodecTests --test AmbitionsTests/ScopedAutomationPreparationTests --test AmbitionsTests/ScopedAutomationAtomicCommitTests --test AmbitionsTests/ScopedAutomationRaceTests --test AmbitionsTests/ScopedAutomationReplayTests --test AmbitionsTests/ScopedAutomationAuthorityCoordinatorTests --test AmbitionsTests/ScopedAutomationAuthorityProjectionTests --test AmbitionsTests/ScopedAutomationViewModelTests --test AmbitionsTests/ScopedAutomationPolicyCenterProjectionTests --test AmbitionsTests/ScopedAutomationPrivacyBoundaryTests --test AmbitionsTests/ScopedAutomationPerformanceTests --test AmbitionsTests/ScopedAutomationReleaseGateTests
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
make xcode-build-for-testing BATCH=PDL-SCOPED-AUTOMATION
git diff --check
```

## Required evidence

- Automated: exhaustive action/policy/owner matrix; 0/1/5/6 target boundaries;
  exact payloads; seven-day and rolling-window clocks; deterministic IDs;
  inference canaries; atomicity, idempotency, replay, Pause/Revoke races, Undo,
  and external-surface denial mapped to REQ-001 through REQ-018.
- Build: generated project drift check and changed-scope build-for-testing pass.
  Approval of these documents supplies no build evidence.
- Runtime: simulator evidence for cancel/activate/run/continue/pause/resume/revoke,
  every hold, grouped confirmation fallback, interruption, projection delay,
  relaunch/no-auto-resume, and ordinary user-command parity.
- Accessibility: automated semantics plus VoiceOver, Voice Control, Switch
  Control, Full Keyboard Access, largest Dynamic Type, Bold Text, Button Shapes,
  contrast/non-color, Reduced Motion/Transparency, RTL, localization, and focus
  recovery on simulator and a supported physical iPhone.
- Privacy/security: target and Waiting private canaries are absent from network,
  Account/R2/Source Atlas, logs, crashes, diagnostics, model context,
  notifications, widgets, App Intents, Spotlight, and support outputs; claim
  tampering, actor/source spoofing, clock rollback, schema corruption, and
  command/grant splitting fail closed.
- Migration/replay: empty migration, every supported direct upgrade, crash at
  each transaction phase, replay/compaction during the rolling window,
  restore/import, purge, future/corrupt schema, downgrade, and terminal-state
  non-revival.
- Performance: measure five-target preparation, atomic commit, projection
  rebuild, and rolling-window lookup on supported devices; set thresholds before
  merge and prove no unbounded scan or main-actor storage/crypto work.
- Device/direct user: physical-device protected-data and foreground/background
  behavior plus direct-user comprehension, surprise, correction, prompt burden,
  aggregate limit, and Pause/Revoke evidence. Release/App Store approval remains
  N/A until every exact-revision gate passes.

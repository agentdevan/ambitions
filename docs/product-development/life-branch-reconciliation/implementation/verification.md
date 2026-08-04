# Verification

## Exact automated and build checks

```bash
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
scripts/ambitions-xcode-test-focused.sh --batch PDL-LIFE-BRANCH --test AmbitionsTests/LifeBranchModelsTests --test AmbitionsTests/LifeBranchStateStoreTests --test AmbitionsTests/LifeBranchSchemaMigrationTests --test AmbitionsTests/LifeBranchNecessityAssessorTests --test AmbitionsTests/LifeBranchCandidateMaterializerTests --test AmbitionsTests/BranchViabilityEvaluatorTests --test AmbitionsTests/LifeBranchPromotionTransactionTests --test AmbitionsTests/LifeBranchRecoveryTests
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
make xcode-build-for-testing BATCH=PDL-LIFE-BRANCH
git diff --check
```

## Required evidence

- Automated: threshold/scenario matrix, complete candidates, every certificate
  state, authority partitions, impact cones, one-slot races, failure injection
  at every transaction phase, idempotency, external outbox separation,
  stale/expired/rollback/compensation, migration, and replay cover REQ-001 to
  REQ-017.
- Runtime: full relocation fixture plus simpler-owner, existing-branch blocker,
  fragile/blocked/stale, defer/reject, commit, crash/relaunch, external failure,
  rollback, compensation, and History inspection.
- Accessibility: physical-iPhone VoiceOver, Voice Control, Switch Control,
  keyboard, largest Dynamic Type, ordered complete consequences, authority,
  blocker/recovery focus, contrast, non-color state, and reduced motion.
- Privacy: private branch graph, deltas, assumptions, certificates, conflicts,
  constraints, protected facts, review state, and lineage remain local; public
  refresh requests use fixed IDs and external intents contain minimum confirmed
  fields only.
- Migration: every direct-upgrade fixture, explicit empty slot, crash/rerun,
  ambiguous/multiple occupant quarantine, backup/restore, rollback, and pre/post
  replay equivalence.
- Performance: measure necessity assessment, materialization, impact traversal,
  certification, transaction preparation/commit, projection, and replay at the
  bounded scenario scale; establish latency/memory/energy/storage thresholds.
- Device: physical rendered/interaction/accessibility and interruption evidence
  is required. External acceptance, broader scenarios, release, and App Store
  readiness remain unproven.

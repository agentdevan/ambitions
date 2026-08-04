# Verification

## Exact automated and build checks

```bash
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
scripts/ambitions-xcode-test-focused.sh --batch PDL-DESTINATION --test AmbitionsTests/DestinationDirectionModelsTests --test AmbitionsTests/DestinationDirectionCommandServiceTests --test AmbitionsTests/DestinationDuplicateBranchTests --test AmbitionsTests/CreateProvisionalGoalFromDirectionTests --test AmbitionsTests/DestinationPivotSettlementTests
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
make xcode-build-for-testing BATCH=PDL-DESTINATION
git diff --check
```

## Required evidence

- Automated: complete four-branch matrix, one-Goal idempotency, same-versus-
  changed outcome, old-Goal choices, relationship meanings, partial results,
  replay, migration, deletion, and Life Branch handoff cover REQ-001 to REQ-014.
- Runtime: candidate/direction entry, keep, duplicate branches, adoption, pivot,
  interruption at every operation, projection delay, retry, reverse, and relaunch.
- Accessibility: direct VoiceOver/assistive controls/keyboard, largest Dynamic
  Type, consequence-specific labels, focus for open/relate/refine/distinct,
  partial recovery, contrast, and reduced effects on physical iPhone.
- Privacy: candidate, direction, duplicate, rationale, continuity, Goal links,
  checkpoints, exclusions, and settlement history remain local; fixed public
  references contain no private-derived requests or cache keys.
- Migration: empty store, legacy North Star non-import, crash/rerun, unknown
  version quarantine, deletion/redaction, backup/restore, and replay equivalence.
- Performance: measure duplicate pass, review projection, checkpoint recovery,
  command settlement, and replay at representative bounded graph sizes; set
  regression thresholds with environment metadata.
- Build/device: build-for-testing plus direct rendered/interaction evidence.
  External acceptance, route creation, multi-owner atomicity, release, and App
  Store proof remain unclaimed.

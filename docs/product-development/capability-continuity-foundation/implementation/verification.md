# Verification

## Exact automated and build checks

```bash
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
scripts/ambitions-xcode-test-focused.sh --batch PDL-CAPABILITY --test AmbitionsTests/CapabilityModelsTests --test AmbitionsTests/CapabilityStateStoreTests --test AmbitionsTests/CapabilitySchemaMigrationTests --test AmbitionsTests/CapabilityProposalPolicyTests --test AmbitionsTests/CapabilityCommandServiceTests --test AmbitionsTests/CapabilityCollectionProjectionTests
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
make xcode-build-for-testing BATCH=PDL-CAPABILITY
git diff --check
```

## Required evidence

- Automated: exhaustive lifecycle, provenance-facet, proposal, permission,
  correction, idempotency, replay, and ownership tests mapped to REQ-001 through
  REQ-016.
- Build: generated project drift check and Ambitions build-for-testing pass.
- Runtime: launch You and a completed-Goal proposal fixture; prove confirm,
  edit, detach, archive, Trash, restore, and relaunch use authoritative state.
- Accessibility: VoiceOver, Voice Control, Switch Control, keyboard, largest
  Dynamic Type, contrast, reduced motion, focus recovery, and non-color state on
  a supported physical iPhone. Automated audits supplement but do not replace it.
- Privacy: egress fixtures prove Capability names, evidence, permissions, and
  proposals never enter Source Atlas, R2, Account, hosted AI, telemetry, logs,
  cache keys, support payloads, or external projections.
- Migration: empty upgrade, every supported direct-upgrade version, crash at
  each phase, rerun idempotency, corrupt/unknown schema quarantine, backup and
  restore, and pre/post replay equivalence.
- Performance: measure migration, proposal evaluation, projection rebuild, and
  collection rendering at representative bounded sizes; record device/OS/build
  and set regression thresholds before merge.
- Device: physical-device rendered and interaction evidence is required for the
  You/Goals UI. Release and App Store readiness remain N/A for this initiative.

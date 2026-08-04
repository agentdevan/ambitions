# Verification

## Exact automated and build checks

```bash
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
scripts/ambitions-xcode-test-focused.sh --batch PDL-CAPABILITY-EXPORT --test AmbitionsTests/CapabilityExportModelsTests --test AmbitionsTests/CapabilityExportPolicyTests --test AmbitionsTests/CapabilityExportRecordStoreTests --test AmbitionsTests/CapabilityExportCommandServiceTests
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
make xcode-build-for-testing BATCH=PDL-CAPABILITY-EXPORT
git diff --check
```

## Required evidence

- Automated: selection, redaction, revision staleness, expiration, deletion,
  cancellation, duplicate delivery, replay, and rendered-byte absence cover all
  REQ-001 through REQ-014.
- Build: project drift and build-for-testing pass.
- Runtime: preview, cancel, share handoff, background/termination, stale-source
  return, expiry, deletion, relaunch, and no false delivery result.
- Accessibility: direct VoiceOver, assistive-control, keyboard, Dynamic Type,
  contrast, reduced-motion, redaction semantics, focus, and share-sheet return
  evidence on a supported physical iPhone.
- Privacy: scan rendered and retained bytes, state, events, projections, logs,
  diagnostics, caches, Spotlight, clipboard, backups, support payloads, Account,
  R2, Source Atlas, and hosted AI. Only the explicitly confirmed local export
  payload may reach the system share handoff.
- Migration: empty additive store, crash/rerun, unknown schema quarantine,
  backup/restore, deletion retention, and replay equivalence.
- Performance: measure policy/redaction and local rendering at representative
  selected-facet counts; record device/OS/build and set regression thresholds.
- Device: required for system share handoff and rendered accessibility proof;
  recipient delivery, acceptance, release, and App Store proof are N/A.

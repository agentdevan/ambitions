# Verification

## Exact automated and build checks

```bash
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
scripts/ambitions-xcode-test-focused.sh --batch PDL-PROFILE-IMPORT --test AmbitionsTests/ProfileArchiveImportModelsTests --test AmbitionsTests/ProfileArchiveTableParserSecurityTests --test AmbitionsTests/ProfileArchiveStagingServiceTests --test AmbitionsTests/ProfileArchiveImportStoreTests --test AmbitionsTests/ProfileClaimImportCommandServiceTests
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
make xcode-build-for-testing BATCH=PDL-PROFILE-IMPORT
git diff --check
```

## Required evidence

- Automated: supported/unsupported schema, encoding, huge/empty/malformed cells,
  formula/control characters, duplicates, every row decision, idempotency,
  cleanup, expiry, deletion, migration, and replay cover REQ-001 to REQ-015.
- Runtime: document picker, preview, row edit/accept/skip/reject/relate, cancel,
  background/kill/resume, stale duplicate, partial result, cleanup, and deletion.
- Accessibility: physical-iPhone VoiceOver/assistive controls/keyboard, table
  semantics, largest Dynamic Type, error summaries, non-color state, reduced
  effects, and row/failure focus recovery.
- Privacy/security: prove staged bytes use protected encrypted storage and are
  absent from logs, telemetry, diagnostics, caches, backups, Spotlight,
  clipboard, support, R2, Account, Source Atlas, hosted AI, and retained state
  after cleanup. Include parser fuzz and decompression/size exhaustion cases.
- Migration: empty stores, crash/rerun, unknown version quarantine, backup/
  restore of accepted claims only, expired-session cleanup, and replay.
- Performance: measure parse/normalize/preview/cleanup at bounded archive sizes;
  record device/OS/build, memory, energy, storage, and set regression limits.
- Build/device: build-for-testing and physical document-picker/rendered evidence.
  Provider sync, claim verification, external acceptance, release, and App Store
  proof remain N/A.

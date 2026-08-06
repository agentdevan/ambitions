# Verification

## Exact automated and build checks

```bash
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
scripts/ambitions-xcode-test-focused.sh --batch PDL-CREDENTIAL --test AmbitionsTests/CredentialModelsTests --test AmbitionsTests/CredentialArtifactVerifierTests --test AmbitionsTests/CredentialArtifactStagingServiceTests --test AmbitionsTests/CredentialStateStoreTests --test AmbitionsTests/CredentialCommandServiceTests --test AmbitionsTests/CredentialStatusRequestPolicyTests --test AmbitionsTests/CredentialStatusCheckServiceTests
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
make xcode-build-for-testing BATCH=PDL-CREDENTIAL
git diff --check
```

## Required evidence

- Automated/security: valid, invalid, unknown algorithm/key, wrong issuer,
  tampered, malformed, oversized, expired, revoked, status-unavailable,
  duplicate/superseded, relationship, cleanup, migration, and replay fixtures
  cover REQ-001 through REQ-015. Include parser fuzz, resource-exhaustion, HTTPS
  allowlist, DNS rebinding, private/reserved/IPv6 target, userinfo/auth, redirect,
  response-size/type, cancellation, ambiguous-result, and reconciliation tests.
- Runtime: picker, verify, full preview, accept/cancel, relate, offline status,
  stale refresh, duplicate, expiry/revocation, delete, interruption, and relaunch.
- Accessibility: physical-iPhone VoiceOver/assistive controls/keyboard, largest
  Dynamic Type, ordered trust layers, non-color validity, reduced effects, and
  error/recovery focus.
- Privacy: raw artifact and claims use protected encrypted storage and never
  enter logs, telemetry, diagnostics, public requests, R2, Account, hosted AI,
  Spotlight, clipboard, support, or unconfirmed external export.
- Migration: empty store, crash/rerun, unknown schema quarantine, backup/restore,
  artifact deduplication, deletion/redaction, and replay equivalence.
- Performance: measure parse/signature/status/preview/store/replay with bounded
  artifact sizes; record environment and establish latency/memory/energy budgets.
- Build/device: build-for-testing and physical picker/rendered/interaction proof.
  Competence, issuer quality, receiver acceptance, release, and App Store proof
  remain explicitly unproven.

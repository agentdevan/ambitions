# RELEASE_TRUTH.md

Status: Active validation/release/proof truth  
Scope: Build, tests, validation, release posture, allowed claims, forbidden claims, and proof requirements  
Applies to: Ambitions native iPhone repo  
Owner posture: Proof truth, not product vision and not implementation optimism  
Effective rule: If proof is absent, readiness is absent.

This file is intentionally conservative. Source code may exist without release proof. Tests may exist without passing. Scripts may exist without successful logs. A privacy manifest may exist without legal/privacy readiness. Product/design truth may exist without implementation or release proof.

## Codex digest
- Read when: work touches validation, build/test claims, release posture, account/R2/offline/privacy proof, accessibility/device/performance proof, TestFlight, App Store, or public readiness language.
- Owns: proof standard, allowed/forbidden release claims, release status, and evidence requirements.
- Does not own: product vision, implementation source status, or visual acceptance except through proof requirements.
- Hard red: release/device/accessibility/privacy/account/R2/TestFlight/App Store claim without current evidence, private user data to R2, hosted AI/cloud LLM core dependency, or hosted private life graph.
- Proof/closeout impact: if proof is absent, readiness is absent; closeout must list supported and unsupported claims.

---

## 1. Relationship to Other Truth Files

Truth hierarchy for release work:

1. `docs/truth/PRODUCT_DESIGN_TRUTH.md` defines product/design expectations. It does not prove release readiness.
2. `docs/truth/PRODUCT_EXPERIENCE_CANON.md` defines product-experience behavior and scenario gates. It does not prove implementation or release readiness.
3. `docs/truth/IMPLEMENTATION_TRUTH.md` defines current source implementation status. Source-present does not mean validated.
4. `docs/truth/RELEASE_TRUTH.md` defines validation and release proof.
5. `docs/truth/CODEX_PROCESS_TRUTH.md` defines Codex validation/reporting behavior.
6. `docs/truth/HISTORICAL_POLICY.md` deletes or demotes stale non-source files and old release claims.

Conflict rules:

- Current raw logs beat old reports.
- Current proof packets beat README/status wording.
- Release truth beats batch-train completion claims.
- No historical audit proves current release readiness unless tied to current commit/source/logs.
- If evidence is missing, release truth is missing.

---

## 2. Release Evidence Standard

Valid release evidence must include:

- branch
- commit SHA
- date/time
- machine or environment
- macOS version where relevant
- Xcode version
- XcodeGen version where relevant
- simulator/device name and OS version where relevant
- exact command or manual procedure
- full or summarized terminal output
- exit code
- artifact path when applicable
- pass/fail result
- known skipped checks
- non-claims
- human approval where required

Release evidence may include current terminal logs, `.xcresult` summaries, current screenshots, simulator/device recordings, archive/export logs, App Store Connect validation result, signed artifact metadata, manual QA checklist, accessibility QA checklist, privacy/legal signoff, and owner approval.

Release evidence may not be inferred from source presence, target configuration, old audit reports, old batch docs, old PR summaries, README language, design truth, Codex statements, expected script behavior, old generated project state, or screenshots not tied to current build/commit.

Proof automation outranks prose: current scripts, logs, artifacts, and required owner approvals set release claim status. Issue comments, truth-doc prose, and closeout summaries can only summarize those artifacts; they cannot upgrade absent, stale, failed, or not-run release proof.

### Proof-Claim Labels

Use these labels whenever a truth doc, issue, closeout, or status update discusses proof-sensitive claims. The label does not make the claim true; the linked evidence does.

| Label | Required current evidence |
|---|---|
| Release-proof claim | Current build/test/archive/release evidence with branch, commit SHA, environment, exact commands or procedure, exit codes, artifacts, skipped checks, supported claims, unsupported claims, rollback, and required owner approvals. |
| Device-proof claim | Current physical-device or explicitly scoped simulator/device evidence tied to build SHA, device/OS, procedure, artifact, result, and known limitations. Physical-device proof is required for device readiness and Visual Green. |
| Privacy-proof claim | Current source/request/data-flow evidence, privacy manifest review where relevant, no-private-life-graph boundary proof, account/R2/Source Atlas request-shape proof where relevant, and privacy/legal owner approval when release-facing. |
| Accessibility-proof claim | Current accessibility evidence for the scoped UI, including VoiceOver, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast or High Contrast where relevant, accessible actions, and device/simulator context. |
| Performance-proof claim | Current measured evidence for the scoped performance claim, including tool/procedure, device or simulator, OS, build SHA, thresholds, results, and regressions or skipped measurements. |

If the required evidence is absent, use `Implemented Yellow`, `Partial`, `Aspirational`, `Blocked`, or `Unknown` from `CODEX_START_HERE.md` instead of Green. Do not convert a proof-sensitive claim into Green by quoting doctrine.

---

## 3. Current Release Posture

Current release posture:

```text
Pre-release native iOS development.
Release readiness is not proven.
TestFlight readiness is not proven.
App Store readiness is not proven.
Physical-device readiness is not proven.
Public accessibility conformance is not proven.
Performance readiness is not proven.
Legal/privacy approval is not proven.
Ambitions Account readiness is not proven.
R2 / Source Atlas readiness is not proven.
Offline-with-no-account behavior is not proven by release evidence.
```

Allowed current claims, when phrased conservatively:

```text
Ambitions is under active native iOS development.
The repo contains a native SwiftUI iOS app target.
The repo uses XcodeGen project generation.
The repo contains local build/setup scripts.
The repo contains unit and UI test targets.
The repo contains SwiftData local persistence source.
The repo has a local-first/on-device-first source posture.
The product truth requires offline core behavior with no account.
The product truth requires custom Ambitions Accounts at launch using Sign in with Apple and Google Sign-In.
The product truth requires R2/Source Atlas as public/reference/freshness infrastructure only.
Release readiness is not yet claimed.
```

Allowed claims must not imply the app currently builds, tests pass, device behavior works, extensions work, account auth works, R2 works, App Store submission is ready, accessibility conformance is complete, privacy/legal review is complete, performance is acceptable, or final product design is fully implemented.

---

## 4. Forbidden Claims Without Current Proof

Forbidden current claims:

```text
production-ready
release-ready
App Store-ready
TestFlight-ready
signed release-ready
device-verified
physical-device validated
CI-proven
fully tested
fully accessible
VoiceOver verified
Dynamic Type verified
Reduce Motion verified
performance validated
memory safe
launch-time safe
scroll-performance safe
privacy approved
legally approved
App Review ready
store metadata ready
screenshots ready
support URL verified
privacy URL verified
iCloud sync validated
CloudKit sync validated
Ambitions Account implemented
Ambitions Account validated
Sign in with Apple validated
Google Sign-In validated
account recovery works
account entitlements work
account-gated R2 access works
R2 freshness implemented
R2 freshness validated
Source Atlas packs production-ready
R2 pack verification validated
R2 privacy boundary validated
offline behavior validated
offline with no account validated
migration validated
external surfaces validated
widget validated
Live Activity validated
share extension validated
App Intent validated
crash-free
production telemetry ready
human release-approved
```

Forbidden claims may become allowed only when current proof exists and this file is updated.

---

## 5. Build Evidence

Evidence paths may include:

```text
project.yml
scripts/build-local.sh
scripts/setup_macos_ios_dev.sh
docs/native-build-and-release.md
```

Required proof before claiming build success:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "<simulator>" build CODE_SIGNING_ALLOWED=NO
```

or equivalent `scripts/build-local.sh` output, with commit SHA, branch, Xcode version, destination, full/summarized log, exit code, and result.

Allowed wording before proof:

```text
Build path exists.
Build success is not claimed.
```

---

## 6. Test Evidence

Required proof before claiming tests pass:

- exact test command
- current commit SHA
- current branch
- simulator/device target
- exit code
- `.xcresult` or log summary when applicable

Do not infer test pass from source existence.

---

## 7. Accessibility and Visual Evidence

Product truth requires accessibility and flagship visual quality, but release truth requires proof.

Do not claim any of these without current evidence:

- VoiceOver verified
- Dynamic Type verified
- Reduce Motion verified
- Reduce Transparency verified
- Increase Contrast verified
- Differentiate Without Color verified
- real-device OLED graphite rendering verified
- keyboard/safe-area behavior verified
- screenshot parity achieved
- visual regression harness passed

Screenshots are useful proof artifacts, but screenshots alone do not prove accessibility, performance, privacy, release readiness, or device correctness.

---

## 8. Account / Sign-In / Entitlement Proof

Product truth requires custom Ambitions Accounts at launch using:

```text
Sign in with Apple
Google Sign-In
```

Release proof for account claims must include:

- current source paths for account/auth implementation
- entitlement/config review
- privacy manifest review
- sign-in flow test evidence
- failure/cancel/retry behavior
- offline no-account behavior proof
- entitlement-gated R2/reference access proof if claimed
- account recovery/support proof if claimed
- no private life graph backend proof boundary

Allowed wording before proof:

```text
Ambitions Account is product truth.
Ambitions Account implementation is not release-proven.
Offline core must remain available with no account.
```

Forbidden wording before proof:

```text
Sign in with Apple works.
Google Sign-In works.
Ambitions Account is ready.
Account recovery works.
Entitlements are validated.
```

---

## 9. R2 / Source Atlas Proof

Product truth makes R2 first-class Source Atlas/reference-freshness infrastructure.

Release proof for R2/Source Atlas claims must include:

- source path evidence
- request shape review proving no private user context is sent
- pack manifest/hash verification evidence if implemented
- cache/last-known-good behavior evidence if implemented
- quarantine/revocation behavior evidence if implemented
- entitlement-gated access proof if claimed
- offline fallback proof if claimed
- privacy/no-private-life-graph boundary review

Allowed wording before proof:

```text
R2/Source Atlas is product truth for public/reference/freshness packs.
R2 implementation is not release-proven.
R2 is not a user-data backend.
```

Forbidden wording before proof:

```text
R2 freshness works.
Source Atlas updates are production-ready.
R2 entitlement gating is validated.
R2 privacy boundary is validated.
```

---

## 10. Privacy / Local-First Proof

Local-first product truth does not prove privacy readiness.

Proof may require:

- privacy manifest source review
- data classification review
- account/R2 request boundary review
- local storage review
- export/delete/reset behavior proof where relevant
- no private-life-graph backend proof boundary
- legal/privacy owner approval where release-facing

No privacy/legal approval may be claimed without explicit evidence.

---

## 11. Release Green / Yellow / Red

Release status uses the split acceptance model in `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`.

Codex may not self-certify Release Green. Release Green requires Source Green, Runtime Green, Interaction Green, Visual Green, current device proof, accessibility proof, rollback proof, and umbrella closeout evidence.

### Green

Release claim may be Green only when the exact claim has current proof.

### Yellow

Yellow is allowed when source or process exists but validation is incomplete, unavailable, environment-limited, or not current.

Yellow or Accepted Yellow may defer release/device/privacy/legal risk only when
the risk is outside the issue's required implementation scope, the owner
explicitly accepts it, a linked blocker protects the future milestone or
release, and no Green claim depends on the unresolved work. Yellow is forbidden
as closure for incomplete required source/runtime/test remediation.

### Red

Red is required for:

- release claim without proof
- account/auth/R2 claim without proof
- private user data sent to R2
- hosted AI/cloud LLM core dependency
- private life graph backend under current canon
- TestFlight/App Store claim without current evidence
- accessibility or device claim without current evidence
- unsupported human-release approval claim

---

## 12. Final Release Reporting Contract

Every release-facing packet or report must include:

```text
Status: Green / Yellow / Red
Commit SHA:
Branch:
Environment:
Xcode version:
Simulator or device:
Commands/procedures:
Validation run:
Validation not run:
Exit code(s):
Artifact paths:
Proof artifacts:
Claims supported:
Claims not supported:
Known risks:
Next proof required:
Rollback plan:
```

Account/R2 release reports must additionally include:

```text
Offline core proof:
Account auth proof:
Entitlement proof:
R2 request privacy proof:
Private life graph backend avoided:
```

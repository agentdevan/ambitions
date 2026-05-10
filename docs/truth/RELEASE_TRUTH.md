# RELEASE_TRUTH.md

Status: Active validation/release/proof truth  
Scope: Build, tests, validation, release posture, allowed claims, forbidden claims, and proof requirements  
Applies to: Ambitions native iPhone repo  
Owner posture: Proof truth, not product vision and not implementation optimism  
Effective rule: If proof is absent, readiness is absent.

---

## 1. Purpose and Authority

This file is the validation/release/proof truth for Ambitions.

It answers:

- what can be claimed safely
- what cannot be claimed
- what validation exists
- what validation is missing
- what proof is required before release claims
- what blocks TestFlight/App Store claims
- what Codex must report honestly

This file is intentionally conservative.

Source code may exist without release proof. Tests may exist without passing. Scripts may exist without successful logs. A privacy manifest may exist without legal/privacy readiness. A generated archive path may exist without signed release readiness. A product/design truth file may exist without implementation or release proof.

---

## 2. Relationship to Other Truth Files

Truth hierarchy for release work:

1. `docs/truth/PRODUCT_DESIGN_TRUTH.md` defines product/design expectations. It does not prove release readiness.
2. `docs/truth/IMPLEMENTATION_TRUTH.md` defines current source implementation status. Source-present does not mean validated.
3. `docs/truth/RELEASE_TRUTH.md` defines validation and release proof.
4. `docs/truth/CODEX_PROCESS_TRUTH.md` defines Codex validation/reporting behavior.
5. `docs/truth/HISTORICAL_POLICY.md` demotes old release claims without proof.

Conflict rules:

- Current raw logs beat old reports.
- Current proof packets beat README/status wording.
- Release truth beats batch-train completion claims.
- No historical audit proves current release readiness unless tied to current commit/source/logs.
- If evidence is missing, the release truth is missing.

---

## 3. Release Evidence Standard

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

Release evidence may include:

- current terminal logs
- current `.xcresult` summaries
- current screenshots
- current simulator/device recordings
- current archive/export logs
- current App Store Connect validation result
- signed artifact metadata
- manual QA checklist
- accessibility QA checklist
- privacy/legal signoff
- owner approval

Release evidence may not be inferred from:

- source presence
- target configuration
- old audit reports
- old batch docs
- old PR summaries
- README language
- design truth
- Codex statements
- expected script behavior
- old generated project state
- stale workflow inventory
- screenshots not tied to current build/commit

---

## 4. Current Release Posture

Current release posture:

```text
Pre-release native iOS development.
Local validation path exists.
Release readiness is not proven.
TestFlight readiness is not proven.
App Store readiness is not proven.
Physical-device readiness is not proven.
Public accessibility conformance is not proven.
Performance readiness is not proven.
Legal/privacy approval is not proven.
```

Current evidence found:

- XcodeGen project config exists.
- Local setup/build scripts exist.
- Unit test target exists.
- UI test target exists.
- UI test source exists.
- Privacy manifest source exists.
- Entitlements source exists.
- Local build/test/archive commands are documented.
- Existing release status docs explicitly avoid release-ready claims.
- No active hosted CI workflow was found during inspection.
- No current raw validation logs were inspected proving build/test/archive success.

---

## 5. Allowed Claims

Allowed current claims, when phrased conservatively:

```text
Ambitions is under active native iOS development.
The repo contains a native SwiftUI iOS app target.
The repo uses XcodeGen project generation.
The repo contains local build/setup scripts.
The repo contains unit and UI test targets.
The repo contains SwiftData local persistence source.
The repo has a local-first/on-device-first source posture.
The repo includes a privacy manifest source.
The repo includes app/widget/share-extension target configuration.
Local validation paths exist.
Release readiness is not yet claimed.
TestFlight readiness is not yet claimed.
App Store readiness is not yet claimed.
Physical-device validation is not yet proven.
```

Allowed claims must not imply:

- the app currently builds
- tests currently pass
- device behavior works
- extension behavior works
- App Store submission is ready
- accessibility conformance is complete
- privacy/legal review is complete
- performance is acceptable
- final product design is fully implemented

---

## 6. Forbidden Claims

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
R2 freshness validated
offline behavior validated
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

## 7. Build Evidence

Evidence found:

```text
project.yml
scripts/build-local.sh
scripts/setup_macos_ios_dev.sh
docs/native-build-and-release.md
```

Release truth:

- XcodeGen config exists.
- Local build script exists.
- Local setup script exists.
- Build command is documented.
- Current build success is not proven.

Required proof before claiming build success:

```bash
xcodegen generate

xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -sdk iphonesimulator \
  -destination "generic/platform=iOS Simulator" \
  CODE_SIGNING_ALLOWED=NO \
  build
```

or equivalent `scripts/build-local.sh` output, with:

- commit SHA
- branch
- Xcode version
- destination
- full/summarized log
- exit code
- result

Allowed wording before proof:

```text
Local build path exists.
```

Forbidden wording before proof:

```text
The app builds.
Build passed.
Build is green.
```

---

## 8. Test Evidence

Evidence found:

```text
project.yml
Native/AmbitionsTests/
docs/native-build-and-release.md
```

Release truth:

- Unit test target exists.
- Unit test source exists.
- Current unit test pass/fail is not proven.

Required proof before claiming unit tests pass:

```bash
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -destination "platform=iOS Simulator,name=<available-simulator-name>" \
  -only-testing:AmbitionsTests \
  test
```

with current log and exit code.

Allowed wording before proof:

```text
Unit test target exists.
```

Forbidden wording before proof:

```text
Unit tests pass.
Tests are green.
```

---

## 9. UI Test Evidence

Evidence found:

```text
project.yml
Native/AmbitionsUITests/AmbitionsUITests.swift
docs/native-build-and-release.md
```

Release truth:

- UI test target exists.
- Substantial UI test source exists.
- UI tests use preview/demo bootstrap paths.
- Current UI test pass/fail is not proven.
- Source inspection found naming drift risk: UI tests expect `Plan` tab buttons in places while app source maps the plan tab title to `Time`.

Required proof before claiming UI tests pass:

```bash
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -destination "platform=iOS Simulator,name=<available-simulator-name>" \
  -only-testing:AmbitionsUITests \
  test
```

with current log, exit code, simulator details, and failure triage.

Allowed wording before proof:

```text
UI test target and source exist.
```

Forbidden wording before proof:

```text
UI tests pass.
The shell is UI-test validated.
The Time/Plan migration is validated.
```

---

## 10. Visual QA Evidence

Evidence found:

- SwiftUI previews exist in source files.
- Visual QA fixture test source appears in test inventory/search.
- Design-system previews exist in package source.

Release truth:

- Preview source exists.
- Rendered screenshot/snapshot proof was not found.
- No current visual QA proof packet was inspected.
- No device/simulator screenshot set tied to current commit was inspected.
- No human visual acceptance record was inspected.

Allowed wording:

```text
Preview fixtures/source exist.
```

Forbidden wording:

```text
Visual QA passed.
Screenshots are approved.
The UI meets flagship quality.
The Product Design Truth is visually implemented.
```

Required proof:

- current rendered screenshots
- commit SHA
- simulator/device
- light/dark mode where relevant
- Dynamic Type states where relevant
- failure/empty/loading states
- human review notes
- explicit non-claims

---

## 11. Accessibility Evidence

Evidence found:

- Many source files include accessibility identifiers/labels.
- Screens read accessibility environment values such as Reduce Motion.
- Accessibility-related unit test source appears in search results.

Release truth:

- Accessibility support exists at source level.
- Public accessibility conformance is not proven.
- Manual accessibility validation is not proven.
- VoiceOver validation is not proven.
- Dynamic Type validation is not proven.
- Reduce Motion validation is not proven.
- Increase Contrast validation is not proven.
- Touch-target validation is not proven.

Allowed wording:

```text
Accessibility hooks and source-level support exist.
```

Forbidden wording:

```text
Fully accessible.
VoiceOver verified.
Dynamic Type verified.
Reduce Motion verified.
Accessibility compliant.
```

Required proof:

- manual VoiceOver path validation
- Dynamic Type screenshots and/or logs
- Reduce Motion comparison
- Increase Contrast comparison
- minimum tap target audit
- keyboard/focus behavior where relevant
- known exceptions
- owner signoff

---

## 12. Dynamic Type Validation Evidence

Evidence found:

- Source previews for Dynamic Type exist in some screens.
- Design system uses semantic font tokens.

Release truth:

- Dynamic Type source/previews exist.
- Dynamic Type validation is not proven.

Required proof:

- rendered screenshots or recordings across representative sizes
- truncation/overlap audit
- primary object/action/trust path preserved
- failure notes if any

---

## 13. VoiceOver Validation Evidence

Evidence found:

- Source contains accessibility labels/values/identifiers in multiple surfaces.

Release truth:

- VoiceOver semantics exist in source.
- VoiceOver route validation is not proven.

Required proof:

- manual VoiceOver test of top-level surfaces
- object-level summary equivalence
- primary action discoverability
- closure/receipt/trust path discoverability
- known defects

---

## 14. Reduce Motion Validation Evidence

Evidence found:

- Screens use `@Environment(\.accessibilityReduceMotion)`.
- Theme provides reduced-motion-aware animation helpers.

Release truth:

- Reduce Motion source support exists.
- Reduce Motion validation is not proven.

Required proof:

- run with Reduce Motion enabled
- compare primary object/state transition clarity
- confirm motion is not sole relationship cue
- record defects

---

## 15. Privacy / Local-Only Validation Evidence

Evidence found:

```text
Native/Ambitions/Persistence/SwiftDataStore.swift
Native/Ambitions/Persistence/SwiftDataModels.swift
Native/Ambitions/Resources/PrivacyInfo.xcprivacy
Native/Ambitions/Support/Ambitions.entitlements
```

Release truth:

- Local SwiftData persistence source exists.
- Privacy manifest source exists.
- App Group entitlement source exists.
- No active custom hosted backend source was found during inspection.
- No active core external LLM source was found during inspection.
- Privacy/legal readiness is not proven.
- App Privacy answers are not proven.
- Binary privacy behavior is not proven.

Allowed wording:

```text
The source posture is local-first/on-device-first.
The repo includes a privacy manifest source.
```

Forbidden wording:

```text
Privacy-approved.
Legally approved.
App Privacy ready.
No data collection is validated.
Local-only behavior is fully verified.
```

Required proof:

- data-flow audit
- entitlement audit
- network/provider scan
- privacy manifest review against actual binary behavior
- App Privacy disclosure review
- legal/owner signoff

---

## 16. Apple Sync Validation Evidence

Evidence found:

- App Group entitlement source exists.
- No active iCloud/CloudKit entitlement/source was found during inspection.

Release truth:

- Apple sync/iCloud/CloudKit is not implemented or validated as current release truth.
- Apple sync remains an allowed future architecture exception only.

Allowed wording:

```text
Apple-native sync is allowed by product architecture if later scoped.
```

Forbidden wording:

```text
iCloud sync works.
CloudKit sync is implemented.
User data syncs across devices.
```

Required proof:

- iCloud/CloudKit entitlements
- source implementation
- conflict model
- account/device tests
- offline/merge tests
- privacy copy
- manual device proof

---

## 17. Cloudflare R2 Freshness Validation Evidence

Evidence found:

- No active R2/Cloudflare app-source implementation found during inspection.

Release truth:

- R2 freshness is not implemented or validated.
- R2 may only be future read-only public/non-personal reference data.
- R2 must not store or receive user-private life data.

Allowed wording:

```text
R2 is an allowed future public freshness/reference-pack source.
```

Forbidden wording:

```text
R2 freshness works.
R2 updates app requirements/dates/rules.
R2 is validated.
```

Required proof:

- source implementation
- anonymous/non-personal request proof
- cache policy
- offline fallback
- tests
- privacy review
- source labels in UI
- failure/degraded states

---

## 18. Offline Behavior Evidence

Evidence found:

- Local SwiftData source exists.
- Preview/in-memory modes exist.
- No explicit offline QA proof inspected.

Release truth:

- Offline-friendly source posture exists.
- Offline behavior is not validated.

Forbidden wording:

```text
Offline mode works.
Offline behavior is validated.
```

Required proof:

- airplane mode/manual offline QA
- launch offline
- create/edit local objects offline
- extension behavior offline where applicable
- R2 unavailable fallback if R2 exists later
- data integrity after reconnect

---

## 19. Migration / Data Integrity Evidence

Evidence found:

- SwiftData schema source exists.
- Storage schema/version/migration-related files/tests appear in inventory/search.
- Current migration test logs were not inspected.

Release truth:

- Migration/data integrity source may exist.
- Migration/data integrity is not release-proven.

Required proof:

- current migration test run
- old fixture to new schema proof
- unknown persisted value degradation proof
- backup/restore or corruption recovery proof if release requires it
- data reset proof
- App Group data consistency proof

---

## 20. Crash / Logging / Observability Evidence

Evidence found:

- Launch failure phase exists in bootstrapper source.
- No release-grade crash/logging/observability proof inspected.

Release truth:

- Crash/logging/observability readiness is not proven.
- No production crash-free claim is allowed.

Required proof:

- launch failure test
- crash/logging policy
- symbolication/release diagnostics plan
- privacy-safe logging review
- failure screenshots/logs
- owner signoff

---

## 21. CI / Workflow Evidence

Evidence found:

- Existing release/status docs say hosted CI is absent.
- Old tracked-file audit listed `.github/workflows/ios-validate.yml`.
- Direct fetch of `.github/workflows/ios-validate.yml` returned not found during inspection.
- Search found no active workflow evidence.

Release truth:

```text
No active hosted CI proof was found.
```

Allowed wording:

```text
Validation is local VM/Mac oriented.
```

Forbidden wording:

```text
CI is configured.
CI passed.
GitHub Actions validates Ambitions.
```

If hosted CI is added later, this file must record:

- provider
- expected cost model
- trigger policy
- artifact retention
- secrets/signing policy
- current workflow path
- current run evidence
- release-claim limits

---

## 22. Release Artifact Evidence

Evidence found:

- Unsigned archive command is documented.
- No current archive log/artifact/checksum was inspected.
- No signed archive/export proof was inspected.

Release truth:

- No current release artifact proof exists in inspected evidence.
- Unsigned archive path, if run, is not installable/TestFlight/App Store proof.
- Signed archive/App Store Connect validation is not proven.

Required proof:

- archive command
- archive log
- artifact path
- checksum where useful
- signing status
- export status
- App Store Connect validation result if claiming App Store readiness
- human approval

---

## 23. TestFlight Readiness

Current truth:

```text
Ambitions is not TestFlight-ready by current proof.
```

Blocked by missing:

- current successful build log
- current successful unit test log
- current successful UI test log or accepted exceptions
- signed archive
- provisioning profile proof
- export proof
- App Store Connect/TestFlight upload proof
- privacy metadata proof
- screenshot/demo data review where required
- device smoke proof
- owner approval

Forbidden wording:

```text
Ready for TestFlight.
Can ship to TestFlight.
TestFlight build is ready.
```

---

## 24. App Store Readiness

Current truth:

```text
Ambitions is not App Store-ready by current proof.
```

Blocked by missing:

- signed archive proof
- App Store Connect validation
- TestFlight/beta validation if required
- physical-device runtime proof
- accessibility proof
- performance proof
- privacy/legal signoff
- App Privacy disclosures
- support URL
- privacy URL
- screenshots
- metadata
- reviewer notes
- final owner/human approval

Forbidden wording:

```text
App Store-ready.
Ready to submit.
Production-ready.
Release candidate locked.
```

---

## 25. Manual QA Requirements

Before any release claim, manual QA must cover:

- first launch
- onboarding
- Today
- Goals
- Capture
- Time
- You
- create goal
- quick capture
- route capture
- close step/action closure
- receipt/proof visibility
- trust/memory controls
- appearance settings
- notification permission states
- calendar permission states if enabled
- offline launch and local persistence
- app relaunch persistence
- error/degraded states
- Dynamic Type
- VoiceOver
- Reduce Motion
- Increase Contrast
- light/dark mode if both supported
- widget/share/Live Activity/App Intent paths if included in release
- privacy-sensitive demo data review

Manual QA output must include:

- commit SHA
- device/simulator
- OS version
- app version/build
- pass/fail/skipped
- screenshots where useful
- defects
- non-claims

---

## 26. Screenshot / Preview Proof Requirements

Screenshot or preview proof must include:

- current commit
- simulator/device
- app mode/data mode
- surface name
- state name
- light/dark mode when relevant
- Dynamic Type size when relevant
- Reduce Motion state when relevant
- known rendering defects
- reviewer/owner decision

Required surfaces before visual/public claims:

- Today / Reality Meridian / Start Here
- Goals / Constellation Atlas
- Capture / Atmosphere Composer
- Time / LifeShape Field
- You / User System Profile
- error/loading/empty/recovery states
- receipt/proof/trust states
- extension surfaces if release includes them

Preview source alone is not screenshot proof.

---

## 27. Release Blockers

Current blockers:

1. No current build log.
2. No current project generation log.
3. No current package resolution log.
4. No current unit test log.
5. No current UI test log.
6. Possible UI test naming drift around Plan vs Time.
7. No current archive log.
8. No signed archive proof.
9. No provisioning/export proof.
10. No physical-device proof.
11. No widget device proof.
12. No Live Activity device proof.
13. No share extension device proof.
14. No App Intent/Shortcut device proof.
15. No notification runtime device proof.
16. No accessibility proof.
17. No performance proof.
18. No privacy/legal signoff.
19. No App Store metadata/screenshot proof.
20. No human release approval.

Any one of these blocks broad release readiness claims.

---

## 28. Proof Checklist Required Before Any Release Claim

Minimum proof packet before saying “release candidate”:

```text
[ ] Branch and commit SHA recorded.
[ ] Clean working tree or explicit diff scope recorded.
[ ] Xcode version recorded.
[ ] XcodeGen version recorded.
[ ] `xcodegen generate` passed.
[ ] Package resolution passed.
[ ] Simulator build passed.
[ ] Unit tests passed or exceptions approved.
[ ] UI tests passed or exceptions approved.
[ ] Unsigned Release archive sanity passed, if relevant.
[ ] Signed archive passed, if claiming TestFlight/App Store.
[ ] App Store Connect validation passed, if claiming App Store readiness.
[ ] Physical device smoke test passed.
[ ] Widget/Live Activity/share/App Intent paths validated if included.
[ ] Accessibility manual QA completed.
[ ] Dynamic Type manual QA completed.
[ ] VoiceOver manual QA completed.
[ ] Reduce Motion manual QA completed.
[ ] Performance launch/scroll/memory checks completed.
[ ] Privacy manifest reviewed against actual binary behavior.
[ ] App Privacy disclosures drafted/reviewed.
[ ] Support/privacy URLs verified.
[ ] Screenshots generated from privacy-safe data.
[ ] Legal/privacy/human approval recorded.
[ ] Claims not made recorded.
```

No checklist item may be checked from memory or plan.

---

## 29. Codex Reporting Rules

Every Codex validation/release report must include:

```text
Status: Green / Yellow / Red
Scope:
Branch:
Commit:
Files changed:
Commands run:
Commands not run:
Environment:
Evidence:
Passes:
Failures:
Skipped:
Unproven:
Claims allowed:
Claims forbidden:
Release blockers:
Next required proof:
```

Rules:

- “Not run” must be explicit.
- “Could not run” must include reason.
- “Passed previously” is not current proof.
- “Target exists” is not “test passed.”
- “Script exists” is not “build passed.”
- “Archive command exists” is not “archive passed.”
- “Privacy manifest exists” is not “privacy approved.”
- “Accessibility labels exist” is not “accessible.”
- “Simulator pass” is not “device pass.”
- “Unsigned archive” is not “signed release.”
- “Human approval required” means release is blocked until approval exists.

---

## 30. Codex Rules for Updating This File

Update this file whenever:

- build/test/release validation posture changes
- a current proof packet is added
- CI is added or removed
- signing/export proof is added
- device validation is completed
- accessibility proof is added
- performance proof is added
- privacy/legal status changes
- App Store/TestFlight status changes
- widget/share/Live Activity validation changes
- R2 freshness is implemented/validated
- Apple sync is implemented/validated
- release wording in README/docs changes

Update requirements:

1. Add exact evidence paths.
2. Add exact command/log references.
3. Add date/commit when proof is current.
4. Separate source/config from validation.
5. Preserve forbidden-claim list until proof removes specific items.
6. Do not weaken release standards to make a patch Green.
7. Do not convert historical audit success into current release proof.
8. If proof is missing, write “not proven.”

Final rule:

```text
If proof is absent, readiness is absent.
```

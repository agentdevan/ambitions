# REC02 Human Operator Release Proof Plan
<!-- markdownlint-disable MD013 -->

Date: 2026-05-02
Status: REC02 operator proof plan; proof not performed
Program: Ambitions 4.0 Execution Program

## Boundary

This plan defines human/operator proof required before Ambitions may make
release-adjacent claims. It does not perform, simulate, or claim any
human-only proof.

Current allowed repo claim:

- Ambitions 3.0 is complete by F30 train evidence.
- Ambitions 4.0 is the active post-3.0 execution program.
- REC02 created an operator proof plan.

Current blocked claims:

- physical-device verification
- public accessibility conformance
- TestFlight readiness
- App Store submission readiness
- final RC lock
- signed archive validation
- App Store Connect validation
- rendered widget, Live Activity, Shortcuts/Siri, App Intent, or external
  platform proof
- legal/privacy approval
- final release decision

## Operator Evidence Folder

Recommended local evidence folder:

```text
output/release-proof/REC02/
```

Recommended subfolders:

```text
physical-device/
simulator-review/
accessibility/
signed-archive/
app-store-connect/
testflight/
external-surfaces/
privacy-legal/
final-decision/
```

Keep screenshots, screen recordings, `.xcresult` bundles, archive logs,
App Store Connect validation screenshots, TestFlight screenshots, device logs,
and notes inside those folders or in an equivalent operator-controlled evidence
location. Do not commit private device logs, credentials, signing material, or
App Store Connect screenshots unless a later privacy review explicitly approves
the artifact.

## Proof Family 1: Physical-Device Smoke

Codex-verifiable before human proof:

- source truth for five-tab shell and release boundaries
- simulator build/test logs already recorded in repo evidence

Human/operator inputs:

- supported iPhone device
- release Mac with signing access if installing a signed build
- exact commit SHA and build identifier under review
- fresh-install capability

Operator steps:

1. Record commit SHA, date, device model, iOS version, and build identifier.
2. Install the candidate build on the physical device.
3. Fresh launch the app.
4. Confirm the five-tab shell: Today / Goals / Capture / Time / You.
5. Confirm Today loads and shows `Start here`.
6. Capture a loose thought and confirm input is not lost.
7. Confirm placement / Needs a Place behavior is understandable where visible.
8. Create or inspect a Goal and open Goal Detail.
9. Confirm Plan loads and denied-calendar fallback remains non-blocking.
10. Confirm You / Trust Center / What Ambitions Knows are reachable.
11. Check review/receipt visibility where implemented.
12. Record crashes, hangs, visual overlap, unreadable copy, broken navigation,
    or confusing state.

Expected evidence:

- device model and iOS version
- build identifier and commit SHA
- screenshot or screen recording of shell and core smoke path
- crash/log notes or explicit no-crash note
- operator name or initials and timestamp

Stop conditions:

- app cannot install or launch
- top-level shell differs from Today / Goals / Capture / Time / You
- Capture can lose input
- private details leak to external surfaces
- app behavior contradicts release claim boundaries

Claim allowed only after proof:

- physical-device smoke passed for the named device/build only

## Proof Family 2: Fresh Install And Returning User

Human/operator inputs:

- clean install path
- returning-user install path with representative local data if available
- privacy-safe fixture data

Operator steps:

1. Run a fresh install with no existing app data.
2. Record first-launch state and whether the app remains usable.
3. Create or inspect a small set of privacy-safe objects.
4. Relaunch the app and verify persistence where implemented.
5. Run a returning-user check with existing local data if available.
6. Check empty, no-data, and degraded states for non-shaming language.

Expected evidence:

- fresh-install notes
- returning-user notes
- screenshots for first launch and relaunch
- any data-loss, migration, or confusing-state notes

Stop conditions:

- data loss in a supported local path
- first launch blocks the user without recovery
- returning-user data is unreadable

## Proof Family 3: Accessibility And Manual UX Review

Codex-verifiable before human proof:

- accessibility source docs and automated UI tests where present
- copy guard and product-language scans

Human/operator inputs:

- device or simulator configured for VoiceOver
- Dynamic Type / Larger Accessibility Sizes
- Reduce Motion
- Increase Contrast
- Differentiate Without Color
- Button Shapes where applicable

Operator steps:

1. Traverse Today, Goals, Capture, Time, and You with VoiceOver.
2. Confirm primary controls have meaningful labels and reachable actions.
3. Increase text size and inspect top-level screens for clipping or overlap.
4. Enable Reduce Motion and confirm no essential meaning depends on motion.
5. Enable contrast/color differentiation settings and confirm no color-only
   state meaning blocks comprehension.
6. Check tap targets and visible gesture alternatives on primary flows.
7. Record any cognitive-load, shame-language, or confusing recovery issue.

Expected evidence:

- settings used
- surfaces reviewed
- issues found, severity, and screenshot/screen recording where useful
- explicit statement that public accessibility conformance is not claimed
  unless a formal conformance process is completed

Stop conditions:

- primary navigation unreachable
- primary action unreachable
- important state depends only on color
- Dynamic Type makes a primary flow unusable
- recovery language becomes shaming

## Proof Family 4: Signed Archive And Export

Codex-verifiable before human proof:

- unsigned build/archive sanity commands where available
- `project.yml` and XcodeGen source truth

Human/operator inputs:

- release Mac
- Apple Developer account access
- signing certificate and provisioning profile
- correct bundle identifier and team settings

Operator steps:

1. Regenerate the project with `xcodegen generate`.
2. Open `Ambitions.xcodeproj`.
3. Select the `Ambitions` scheme.
4. Select a generic iOS device destination.
5. Run `Product > Archive`.
6. Confirm signing identity, provisioning, entitlements, and bundle metadata.
7. Save archive result and Organizer validation notes.
8. Do not distribute unless validation and approval gates pass.

Expected evidence:

- archive timestamp
- Xcode version
- signing/provisioning status
- archive success or failure screenshot/log
- validation result if attempted

Stop conditions:

- archive fails
- signing identity/provisioning is wrong or unknown
- entitlement or bundle metadata mismatch
- distribution attempted before approval

## Proof Family 5: App Store Connect Validation

Human/operator inputs:

- App Store Connect access
- signed archive
- current privacy/support URLs if submission metadata is being validated
- current screenshots if store listing is being checked

Operator steps:

1. Upload or validate the signed archive through Organizer or Transporter.
2. Confirm bundle, version, build number, capabilities, and privacy manifest.
3. Check App Privacy disclosures against the submitted binary.
4. Confirm support and privacy URLs are live if they are used.
5. Confirm screenshots are current and privacy-safe if store assets are loaded.
6. Save validation result and any App Store Connect warnings.

Expected evidence:

- App Store Connect validation result
- screenshots of warnings or pass state
- privacy/support URL status
- exact build/version

Stop conditions:

- validation fails
- privacy disclosure mismatch
- support/privacy URL unavailable
- screenshots do not match the submitted build

## Proof Family 6: TestFlight Boundary

Human/operator inputs:

- uploaded build
- internal tester list
- truthful beta description
- known limitations
- feedback contact

Operator steps:

1. Confirm the signed build uploaded successfully.
2. Confirm internal tester access is configured.
3. Confirm beta description and feature list match current behavior.
4. Record known limitations and blocked claims.
5. Decide whether external tester review is in scope.
6. Do not use TestFlight-ready language until upload, metadata, tester
   configuration, and human approval are recorded.

Expected evidence:

- uploaded build identifier
- TestFlight processing state
- tester group status
- beta metadata screenshot or notes
- known limitations note

Stop conditions:

- build processing fails
- beta metadata overclaims behavior
- tester access is unclear
- privacy/support contact missing

## Proof Family 7: External Rendered Surfaces

Surfaces:

- widgets
- Live Activities
- Lock Screen
- Dynamic Island
- notifications
- Shortcuts/Siri
- App Intents
- installed-device app-group / shared-container behavior

Human/operator inputs:

- physical device with relevant OS capabilities
- enabled widgets/Live Activities/Shortcuts where applicable
- privacy-safe fixture data

Operator steps:

1. Confirm which external surfaces are enabled in the build.
2. Render each enabled surface on device or platform surface.
3. Confirm the surface is privacy-safe and not stale/misleading.
4. Confirm taps/routes return to the correct app destination.
5. Confirm unavailable surfaces are not claimed.
6. Record screenshots or screen recordings of each rendered proof.

Expected evidence:

- surface name
- device/OS version
- screenshot or recording
- route result
- privacy review note

Stop conditions:

- sensitive data appears casually
- route opens the wrong destination
- surface is stale or misleading
- unrendered surface is described as verified

## Proof Family 8: Legal / Privacy / Final Release Decision

Human/operator inputs:

- privacy policy
- support URL
- App Privacy disclosure
- final release notes
- final reviewer notes
- product-owner or release-owner signoff

Operator steps:

1. Reconcile privacy disclosures with actual build behavior.
2. Confirm support/privacy URLs are live.
3. Confirm final screenshots and release notes are truthful.
4. Confirm accessibility claims remain omitted unless manually proven.
5. Confirm external-platform claims remain omitted unless rendered proof exists.
6. Record final release decision separately from Codex validation.

Expected evidence:

- signoff owner and timestamp
- exact build/version
- live URL evidence
- final claim boundary
- decision: hold, TestFlight, submit, or do not release

Stop conditions:

- privacy/legal signoff missing
- final release owner not identified
- claim wording outruns proof
- support/privacy URL missing

## REC02 Operator Checklist

Before any release-posture upgrade, the operator must record:

- exact commit SHA and build number
- physical-device smoke result
- fresh install / returning-user result
- manual accessibility / UX result
- signed archive result
- App Store Connect validation result when applicable
- TestFlight upload/configuration result when applicable
- external rendered surface proof when any external surface is claimed
- privacy/legal/support URL status
- final human decision

## What This Plan Does Not Claim

This plan does not claim that any proof above has passed. It does not claim
release readiness, App Store readiness, TestFlight readiness, physical-device
verification, public accessibility conformance, signed archive validation, App
Store Connect validation, external-platform rendered proof, legal/privacy
approval, final RC lock, PXOS implementation, Product Depth implementation, or
AmbitionsOS implementation.


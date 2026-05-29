# Human Release Review Handoff

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Date: 2026-04-29

## Current Checkpoint

- Commit checkpoint: `3d3075d2`
- Branch: `main`
- Local/remote alignment: local `main` and `origin/main` align at `3d3075d20f3f8d57edd1abb191b396f1ac8f343d`
- Release posture: `Candidate prepared; human approval required`
- Current completion truth: D01-D26 complete for planning purposes; M01-M12 complete for planning purposes; R01-R05 complete for planning purposes.

## What Is Complete

- Design Constitution alignment layer: D01-D26 are complete for planning purposes.
- Maturity evidence layer: M01-M12 are complete for planning purposes.
- Release gate evidence layer: R01-R05 are complete for planning purposes.
- R01 records accessibility claims lock evidence and keeps public accessibility claims unpublished until manual proof exists.
- R03 records simulator/source device-readiness evidence and keeps TestFlight gated on physical-device smoke.
- R04 records App Store, privacy, release-note, marketing, and investor-demo draft truth without treating those drafts as submission proof.
- R05 records `Candidate prepared; human approval required` as the current release-candidate posture.

## What Is Not Claimed

- No TestFlight readiness claim.
- No App Store submission readiness claim.
- No final RC lock claim.
- No public accessibility verification claim.
- No real-device proof claim.
- No signed archive or App Store Connect validation claim.
- No rendered widget gallery, Live Activity lifecycle, notification delivery, Shortcuts/Siri invocation, or installed-device app-group I/O claim.
- No live support/privacy URL or final screenshot asset claim.

## Xcode Simulator Launch

Project file: `Ambitions.xcodeproj`

Scheme: `Ambitions`

Recommended simulator destination: `iPhone 17` on iOS 26.3

Bundle identifier: `com.ambitions.ios`

Operator steps:

1. Open `Ambitions.xcodeproj`.
2. Select the `Ambitions` app scheme.
3. Select an iPhone Simulator destination, preferably `iPhone 17`.
4. Click Run, or choose `Product > Run`.
5. Wait for the build to finish and Simulator to launch.
6. Use the app manually.
7. Stop the debug session when done.
8. If the simulator list is missing, open Xcode Settings and check Components / installed Simulator runtimes.
9. If build fails, open the Issue navigator and capture the first real error before chasing follow-on noise.

Command-line fallback:

```bash
xcodegen generate
xcrun simctl boot "iPhone 17"
open -a Simulator
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" build
```

If command-line launch is needed after a successful build, install and launch the built `.app` on the selected simulator, then keep Simulator open for manual review.

## Manual In-Simulator Playtest Checklist

- Fresh launch.
- Confirm the five-tab shell: Today / Goals / Capture / Time / You.
- Today loads and feels calm/readable.
- Goals loads and shows portfolio/goal modules.
- Goal Detail opens and lanes are understandable.
- Capture a loose thought.
- Smart Attachment / Needs a Place behavior is visible and understandable.
- Plan timeline works, including calendar-denied/no-calendar fallback.
- You / Trust Center / What Ambitions Knows are reachable and understandable.
- Review / receipt visibility is present where implemented.
- Export/import is checked if implemented in the visible app surface.
- Widget / Live Activity / App Intent behavior is checked only if visible/testable in this environment.
- Record any crash, hang, visual overlap, broken navigation, unreadable copy, or confusing state.

## Physical-Device Smoke Checklist

- Fresh install.
- Launch.
- Confirm the five-tab shell: Today / Goals / Capture / Time / You.
- Capture a loose thought.
- Smart Attachment / Needs a Place behavior.
- Create or inspect a Goal.
- Goal Detail lanes.
- Plan timeline / calendar-denied fallback.
- You / Trust Center / What Ambitions Knows.
- Review / receipt visibility.
- Export/import if implemented in the visible app surface.
- Widget / Live Activity / App Intent behavior only if available on device.
- Crash/log notes.

## Manual Accessibility Checklist

- VoiceOver traversal across top-level tabs and key detail surfaces.
- Dynamic Type / Larger Accessibility Sizes.
- Reduce Motion.
- Increase Contrast.
- Differentiate Without Color.
- Button Shapes.
- Tap targets.
- Gesture alternatives.
- Reading order.
- External surfaces if available.

## Signed Archive Checklist

- Regenerate the project with `xcodegen generate`.
- Open `Ambitions.xcodeproj`.
- Select the `Ambitions` scheme.
- Select a generic iOS device destination for archive.
- Run `Product > Archive`.
- Confirm signing identity and provisioning are correct on the release Mac.
- In Organizer, run `Validate App`.
- Do not distribute or upload until validation passes and human approval is recorded.

## TestFlight Readiness Checklist

- Signed archive exists.
- App Store Connect upload succeeds.
- Beta app description is current and truthful.
- Features to test are listed.
- Feedback email is set.
- Internal testers are selected.
- External tester review caveat is understood before external distribution.
- Known limitations are recorded.
- Privacy/support URLs are live and accurate.
- Screenshot status is current.

## App Store Submission Readiness Checklist

- Signed archive and App Store Connect validation pass.
- App Privacy disclosures match the submitted binary.
- Support URL and Privacy Policy URL are live.
- Current screenshots come from the final signed build and privacy-safe demo data.
- Reviewer notes match shipped behavior and enabled capabilities.
- Any permission-purpose strings match actual app behavior.
- Accessibility claims remain omitted unless manual proof has been recorded.
- External-surface claims remain omitted unless rendered device/platform proof has been recorded.
- Final human approval is recorded.

## Investor / Demo Readiness Checklist

- Use the current posture: `Candidate prepared; human approval required`.
- Demo the Golden Launch Loop only from behavior visible in the app.
- Avoid TestFlight, App Store, public accessibility, real-device, signed-archive, and final-RC claims unless separately proven.
- Prepare privacy-safe demo data.
- Keep support/privacy URL and screenshot gaps visible as release-operator work.
- Capture any confusing copy, visual overlap, broken navigation, or manual-review friction as follow-up notes.

## Blockers Before Posture Upgrade

- To upgrade to TestFlight candidate: complete physical-device smoke, signed archive, App Store Connect upload path, TestFlight metadata, known-limitations notes, privacy/support URL readiness, and human approval.
- To upgrade to App Store submission-ready: complete signed archive validation, App Store Connect validation, final metadata/screenshots, privacy-label review, live URLs, reviewer notes, external-platform proof for any claimed surfaces, and human approval.
- To publish accessibility claims: complete manual VoiceOver, Dynamic Type, Reduce Motion, contrast, motor/tap-target, reading-order, gesture-alternative, and external-surface accessibility proof.
- To claim real-device readiness: complete supported-iPhone fresh install, launch, core five-tab smoke, representative goal/capture/plan/review flows, device crash/log review, and any enabled external-surface device checks.
- To claim final RC lock: record explicit human approval after physical-device, manual accessibility, signed archive/App Store Connect, rendered external-platform, store asset/live URL, and release-material gates are closed.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->

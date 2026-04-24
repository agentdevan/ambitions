# Ambitions Launch Master Checklist

## A. Purpose And Scope

This document defines the canonical now-to-launch planning layer for Ambitions.

It supplements:

- the product roadmap
- the batch program
- the App Store release-compliance canon

It does not replace:

- current shipping product truth in `MASTER_PRODUCT_SPEC.md`
- active batch truth in `docs/codex/BATCH_REGISTRY.md`
- final App Store submission gating in `Ambitions_App_Store_Release_Compliance.md`
- the native build/archive workflow in `docs/native-build-and-release.md`

Its job is to answer a narrower operational question:

- what is the locked launch strategy, what doctrine constrains it, and what work remains from the current batch wave through launch and the first 14 post-launch days

This is a launch-planning document, not a guarantee of App Store approval.

## B. Locked Launch Strategy

The following decisions are treated as settled launch strategy unless canon is explicitly revised later.

### Platform And Scope

- Launch platform: iPhone only
- Launch orientation: portrait only
- Launch region: United States only
- Watch is the first planned post-launch expansion target
- iPad and Mac are later-platform work and are not required for first launch
- Widgets and Live Activities are in launch scope and are launch blockers while they remain in V1 scope

### Identity And Sync

- Ambitions ships with no Ambitions account at launch
- Ambitions ships with no in-app login at launch
- Apple-account-based sync only
- Local-first behavior remains primary, with sync treated as an enhancement rather than a prerequisite
- New-phone recovery is iCloud/CloudKit restore first, with manual export/import as the fallback path
- State continuity, sync trust, handoff, and degraded-sync language are governed by [Ambitions_State_Continuity_Mesh.md](Ambitions_State_Continuity_Mesh.md)
- If future authentication is ever required later, `Sign in with Apple` is the first acceptable direction

### Business Model

- Free at launch
- No paid upfront app at launch
- No subscription at launch
- No launch IAP at launch
- Future monetization remains explicitly deferred and out of launch scope

### Permissions And Data

- Notifications are in launch scope
- Calendar is in launch scope
- Reminders are in launch scope
- Health-like inputs are not in launch scope
- Permission asks must remain contextual and must not become first-boot permission spam

### Testing And Release Motion

- Internal beta first
- Small closed external beta second
- App Store submission third
- Accessibility Nutrition Labels are a launch goal
- Accessibility audit is mandatory before submission
- Claims must remain honest, evidence-backed, and device-specific

### Web And Presence

- The launch website should remain simple and premium rather than broad or overbuilt
- Launch web infrastructure must include:
  - home or marketing page
  - support page
  - privacy policy page
  - privacy choices page
  - accessibility page

### Minimum V1 Product Promise

Locked launch promise:

> Ambitions helps me know what matters now, shape a believable week, recover when life slips, and keep my long-term goals alive.

## C. Launch Doctrine

The following are launch doctrine, not suggestions:

- no Ambitions-operated personal-data backend at launch
- personal user data stays on device or in the user’s private iCloud or CloudKit storage
- no third-party analytics SDKs at launch
- Apple-only crash and reporting tooling at launch
- no public or shared cloud database for private life data
- export/import and local reset/delete should remain visible in the app
- a plain-English privacy promise must be published
- a Privacy Choices URL must be published
- no server-side AI processing of private user content at launch
- all permissions remain optional and contextual

## D. Source-Of-Truth Hierarchy

Use these sources together when planning toward launch:

1. `MASTER_PRODUCT_SPEC.md`
2. `docs/codex/BATCH_REGISTRY.md`
3. `docs/canon/Ambitions_Full_Frontend_Transformation_Program.md`
4. `docs/canon/Ambitions_App_Store_Release_Compliance.md`
5. this document
6. `docs/canon/Ambitions_Accessibility_Nutrition_Labels_Audit.md`
7. `docs/codex/Launch_Operator_Runbook.md`
8. `docs/native-build-and-release.md`
9. `docs/codex/Release_Candidate_Review_Checklist.md`

Interpretation rules:

- roadmap support is not the same as launch readiness
- active batch truth still comes from the registry
- App Store submission readiness still comes from the release-compliance canon
- this document coordinates launch strategy, tracks, phases, and operator timing across those sources

## E. Launch Tracks

### Product Completion

- Close the active transformation wave through Batch 60 without widening launch scope
- Preserve the locked V1 promise instead of adding speculative surfaces
- Keep iPhone-only, portrait-only, local-first behavior explicit through final scope review
- Treat widgets and Live Activities as launch blockers while they remain part of V1 scope

### Privacy And Trust

- Preserve the privacy-first launch doctrine through final release candidate
- Keep no-account and no-login launch truth stable
- Ensure export/import fallback and local reset/delete remain visible and truthful in-app
- Publish support, privacy policy, privacy choices, and plain-English privacy promise materials
- Reconcile App Privacy details with actual shipped behavior

### Accessibility

- Run the Accessibility Nutrition Labels audit honestly by supported launch device and common task flow
- Perform mandatory accessibility audit before submission
- Keep any launch accessibility claims constrained to what can be evidenced
- Review reduced-motion, readability, navigation clarity, and key surface access on real devices

### App Store Metadata And Assets

- Prepare final App Store Connect metadata
- Prepare screenshots, subtitle, keywords, promotional text, and reviewer notes
- Ensure metadata reflects iPhone-only, U.S.-only, portrait-only launch truth
- Ensure URLs are live and stable before metadata entry begins

### Beta And QA

- Run internal beta first
- Run small closed external beta second
- Treat beta as launch-readiness proof, not as open-ended feature exploration
- Capture device-specific regressions, permission trust issues, widget/Live Activity issues, and recovery issues

### Review Package

- Prepare reviewer notes
- Prepare privacy/trust explanations for permissions and local-first data posture
- Prepare reviewer-access notes showing no login is required
- Prepare any widget, Live Activity, or external-surface explanation needed for review

### External Surface Platform Review

- Verify Share Sheet presentation
- Verify Share Extension intake UX on real device or simulator where available
- Verify App Shortcuts discoverability
- Verify Quick Capture shortcut OS behavior
- Verify Quick Focus shortcut OS behavior
- Verify Quick Plan shortcut OS behavior
- Verify Quick Recovery shortcut OS behavior
- Verify Spotlight/Search landing where supported
- Verify external-create-to-app-shell handoff
- Verify origin/provenance behavior from `share_extension` and `app_intent`

### Website And Support Operations

- Publish the launch website pages required for submission and trust
- Keep support operations minimal but real
- Ensure support, privacy, privacy choices, and accessibility content remain aligned with actual shipped behavior

### Business / Legal / Conditional Gates

- Preserve free launch truth
- Keep monetization, subscriptions, and IAP outside launch scope
- Keep account deletion, login parity, and monetization as conditional gates only if scope changes later
- Review export compliance, privacy disclosures, and any Apple-side legal declarations truthfully before submission

## F. Now-To-Launch Phase Plan

### Phase A: Completed Through Batch 54

- Complete Profile / Trust / Context Vault and onboarding/degraded-state/trust continuity work queued through Batch 54
- Stabilize launch truth around no account, no in-app login, Apple-account-based sync only, local-first behavior, and the State Continuity Mesh contract
- Preserve truthful export/import fallback framing
- Keep Batch 52-54 work aligned to launch trust instead of speculative scale features

### Phase B: Active Batch 55 Through Batch 57

- Close widgets, Live Activities, notifications, Focus surface, App Intents, shortcuts, share extension, and cross-surface handoff work that remains in queued launch-facing scope
- Treat widgets and Live Activities as hard launch blockers while they remain in scope
- Consume the Batch 54 State Continuity Mesh contract without inventing separate continuity or sync-trust models
- Keep review package notes current for external and ambient surfaces
- Validate permission timing and external-surface honesty on real devices

### Phase C: Batches 58-60

- Close final surfaces, polish, accessibility, performance, and release-grade finish work
- Complete launch-website infrastructure and final support/privacy/accessibility content drafts
- Run the dedicated Accessibility Nutrition Labels audit
- Prepare final operator-owned metadata and reviewer-material drafts

### Phase D: Release Candidate

- Freeze scope to the locked launch strategy
- Run native release build, archive, and real-device verification
- Complete internal release-candidate review
- Reconcile app behavior, privacy disclosures, website claims, screenshots, and reviewer notes

### Phase E: Submission

- Complete App Store Connect metadata entry
- Complete privacy details and export-compliance declarations
- Complete reviewer notes and any reviewer access instructions
- Perform final operator signoff using the runbook and release-compliance canon

### Phase F: Launch Week

- Watch crash signals, user support intake, permission-friction reports, widget/Live Activity failures, and sync/recovery confusion
- Keep launch-week copy, support answers, and privacy/accessibility pages aligned to shipped behavior
- Avoid feature expansion during launch week except for true hotfix need

### Phase G: First 14 Days Post-Launch

- Monitor support load, crash trends, App Store reviews, permission confusion, export/import usage, and recovery friction
- Triage hotfixes first
- Preserve launch doctrine
- Use the first 14 days to decide whether Watch remains the next surface and whether any deferred conditional gates need future planning

## G. Hard Launch Blockers

Ambitions is not ready for launch if any of the following remain open:

- active launch-scope product work is unfinished through the required launch batches
- iPhone-only, portrait-only, or U.S.-only launch truth is contradicted in shipped behavior or metadata
- widgets or Live Activities remain in launch scope but are not submission-safe on real devices
- support, privacy policy, privacy choices, or accessibility URLs are missing or not functional
- App Privacy disclosures do not match shipped behavior
- no-account, no-login, Apple-account-based sync, and local-first launch truth is contradicted in app or website copy
- export/import fallback is absent, misleading, or not reviewable if sync/recovery is presented
- mandatory accessibility audit is incomplete
- Accessibility Nutrition Labels are claimed without honest audit evidence
- internal beta is incomplete
- small closed external beta is incomplete
- release candidate is not stable on real devices
- reviewer materials are incomplete for shipped permissions or external surfaces

## H. Conditional Gates

These are not launch requirements unless scope changes later:

- account deletion becomes a gate only if Ambitions later adds account creation
- reviewer credentials become a gate only if meaningful review later requires login
- login-service parity becomes a gate only if third-party or social login is later introduced
- monetization review becomes a gate only if subscriptions, IAP, or paid unlocks are later introduced
- health-like privacy review becomes a gate only if health-like inputs later enter scope

## I. Launch Asset Checklist

- App Store name, subtitle, keywords, and promotional text
- iPhone launch screenshots
- app icon and launch visual review
- support URL
- privacy policy URL
- privacy choices URL
- accessibility URL
- plain-English privacy promise
- reviewer notes
- export-compliance answers
- App Privacy answers
- support contact method
- internal beta build notes
- closed external beta invite and feedback path

## J. Submission Gate Summary

Submission should be attempted only when all of the following are true:

1. Roadmap work required for launch scope is complete enough to freeze the launch promise.
2. The locked launch strategy in this document still matches the release candidate.
3. The release-compliance canon gates are satisfied.
4. Real-device verification is complete for the iPhone launch band and all shipped external surfaces.
5. Website and support infrastructure is live.
6. Privacy disclosures, permission explanations, and accessibility claims are all truthful.
7. Internal beta and small closed external beta have completed with issues triaged.
8. Final operator signoff is recorded.

## K. Launch Week And First-14-Days Plan

### Launch Week

- Monitor Apple crash and stability reporting
- Monitor support intake and App Store review themes
- Watch for permission confusion, widget/Live Activity failures, and recovery misunderstandings
- Keep copy corrections, support articles, and policy pages synchronized with the shipped build
- Limit changes to support updates, metadata corrections if needed, and true hotfixes

### First 14 Days Post-Launch

- Triage hotfixes before any scope expansion
- Review export/import usage and new-phone recovery pain points
- Review whether local-first plus Apple-account-based sync is understandable in practice
- Review whether permission timing remained contextual and non-spammy
- Review whether the locked V1 promise matches user feedback
- Prepare a short launch retrospective before beginning post-launch expansion planning

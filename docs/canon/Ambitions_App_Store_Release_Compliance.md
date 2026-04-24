# Ambitions App Store Release Compliance

## Purpose And Scope

This document defines the release-candidate and App Store submission compliance layer for Ambitions.

It supplements the product roadmap and batch program.
It does not replace product scope, active-batch truth, or the native build/test runbook.

Its job is to answer a narrower question:

- what must still be true after roadmap implementation closes and before an App Store submission is treated as ready for operator review

This is a submission-gate document, not a guarantee of approval.

Related launch-planning documents:

- [Ambitions_Launch_Master_Checklist.md](Ambitions_Launch_Master_Checklist.md)
  Canonical locked launch strategy, doctrine, launch tracks, and now-to-launch phase plan.
- [Ambitions_State_Continuity_Mesh.md](Ambitions_State_Continuity_Mesh.md)
  Canonical continuity, sync-trust, handoff, return, and degraded-sync contract for external-surface inheritance.
- [Ambitions_Accessibility_Nutrition_Labels_Audit.md](Ambitions_Accessibility_Nutrition_Labels_Audit.md)
  Dedicated audit artifact for Accessibility Nutrition Labels and evidence-backed claim review.
- [../codex/Launch_Operator_Runbook.md](../codex/Launch_Operator_Runbook.md)
  Short operator execution runbook for App Store Connect, metadata, TestFlight, submission, and launch-day operations.

## Source Of Truth

Use these sources together:

- [../../MASTER_PRODUCT_SPEC.md](../../MASTER_PRODUCT_SPEC.md)
  Shipping product scope and current product truth.
- [Ambitions_OS_Master_Roadmap.md](Ambitions_OS_Master_Roadmap.md)
  Long-range platform and product direction.
- [Ambitions_Full_Frontend_Transformation_Program.md](Ambitions_Full_Frontend_Transformation_Program.md)
  Batch ownership for transformation work through Batch 60.
- [../codex/BATCH_REGISTRY.md](../codex/BATCH_REGISTRY.md)
  Active-vs-completed-vs-queued execution truth.
- [../native-build-and-release.md](../native-build-and-release.md)
  Current native build, test, archive, and local Apple-side validation workflow.
- [../codex/Release_Candidate_Review_Checklist.md](../codex/Release_Candidate_Review_Checklist.md)
  Short operator checklist derived from this compliance canon.

When these sources conflict:

- product scope comes from `MASTER_PRODUCT_SPEC.md`
- active batch truth comes from `BATCH_REGISTRY.md`
- final submission gating comes from this document
- execution steps come from `native-build-and-release.md` and the RC checklist

## Compliance Categories

### App Completeness And Reviewer Access

Classification: partially covered plus operational checklist item

Roadmap support:

- Batch 53 improves onboarding, permissions, degraded-state clarity, and reviewer-facing first-run comprehension.
- Batch 54 completed the State Continuity Mesh contract for continuity and trust before wider surface expansion.
- Batch 60 improves final finish quality and release polish.

Operational submission requirements:

- submission metadata must be complete
- all production URLs surfaced to reviewers must resolve and function
- the submitted build must be stable on real devices, not simulator-only
- if login is required for meaningful review, reviewer credentials or a truthful demo mode must be prepared
- incomplete, placeholder-heavy, or obviously broken review builds do not pass this gate

### Privacy, Data Disclosure, And Permission Trust

Classification: partially covered plus conditional gate plus operational checklist item

Roadmap support:

- Batch 52 contributes to trust, configuration, appearance, and context-vault foundations
- Batch 53 contributes to permission clarity, degraded-state explanation, and onboarding trust
- Batch 54 contributes the canonical State Continuity Mesh, sync-trust, handoff, return, and degraded-sync contract before external-surface widening
- Batch 60 contributes final polish and accessibility/stability closure

Operational submission requirements:

- a Privacy Policy URL must exist before submission
- App Privacy disclosures must match actual app and partner behavior at submission time
- permission-purpose strings and in-app explanations must match shipped behavior

Conditional Ambitions gate:

- if Ambitions ships privacy-sensitive inputs such as calendar, reminders, health-like signals, or personalization inputs, final disclosure and purpose-string review is mandatory before submission

### Account, Authentication, And Deletion

Classification: conditional / unresolved

Current repo truth:

- auth, account creation, and account deletion are not current shipping features in the native doc set

Conditional Ambitions gates:

- if Ambitions adds account creation, in-app account deletion becomes a submission gate
- if Ambitions requires login for core review flows, reviewer credentials or a truthful demo mode becomes a submission gate
- if Ambitions introduces third-party or social login as the primary account path, Apple login-service and equivalent-login requirements become a submission gate

This category remains unresolved until product/business scope defines whether accounts exist.

### External / Ambient Surface Compliance

Classification: roadmap-covered plus operational checklist item

Roadmap support:

- Batch 54 established continuity and trust before external widening through [Ambitions_State_Continuity_Mesh.md](Ambitions_State_Continuity_Mesh.md)
- Batch 55 covers widgets, Live Activities, notifications, and Focus Screenlet
- Batch 56 covers share extension, App Intents, shortcuts, routing, and external creation
- Batch 57 consolidates cross-surface command, recall, and ambient coherence
- Batch 60 closes finish quality and release polish

Operational submission requirements:

- Live Activities and other ambient surfaces must remain glanceable
- ambient surfaces must stay tied to tasks or events with a defined beginning and end
- sensitive information must not be exposed casually on glanceable surfaces
- ambient surfaces must avoid ads or promotional framing
- interactivity must remain limited to the essential controls the surface can explain safely
- widgets, notifications, App Intents, shortcuts, and related ambient routes require real-device review rather than simulator-only signoff

### Accessibility And Stability

Classification: roadmap-covered plus operational checklist item

Roadmap support:

- Batch 60 explicitly owns accessibility, performance, and release polish

Operational submission requirements:

- real-device stability must be reviewed on the intended supported device band
- key flows must remain readable, navigable, and reduced-motion-safe
- crashes, broken navigation, obvious layout failures, and dead controls block submission readiness

### Metadata And Submission Materials

Classification: operational checklist item

Roadmap support:

- none directly; this is a release-operator responsibility after product scope stabilizes

Operational submission requirements:

- complete App Store metadata
- complete and functional support/privacy URLs
- accurate screenshots and promotional text for the shipped build
- accurate reviewer notes for unusual review flows, permissions, or demo data setup

### Monetization / Business Model

Classification: conditional / unresolved

Current repo truth:

- monetization, subscriptions, and IAP are not committed as current shipping scope in the canonical stack

Conditional Ambitions gate:

- if Ambitions introduces subscriptions, digital unlocks, or in-app purchases, a separate business-model and IAP review gate is required before submission
- this includes product setup, submission copy, restore behavior, pricing presentation, and entitlement truth

No monetization readiness should be implied until the business model is explicitly defined.

### Final Real-Device Submission Gate

Classification: operational checklist item

This is the final release-candidate gate that happens after Batch 60 closes and before App Store submission is attempted.

It exists because roadmap completion does not equal submission readiness.

## Ambitions-Specific Conditional Gates

These gates remain conditional until the relevant feature exists in product scope:

- account creation requires in-app account deletion before submission
- login-required review flows require reviewer credentials or a truthful demo mode
- third-party or social login requires Apple login-service and equivalent-login review as applicable
- subscriptions, digital unlocks, or IAP require a separate business-model submission gate
- privacy-sensitive inputs such as calendar, reminders, health-like signals, or personalization require final privacy-disclosure and permission-purpose-string review
- widgets, Live Activities, notifications, App Intents, shortcuts, and related external routing require real-device ambient-surface review

## Roadmap Mapping

Use the roadmap batches as contribution layers, not as automatic compliance proof:

- Batch 52 contributes to trust/configuration/privacy readiness
- Batch 53 contributes to onboarding, permissions, reviewer clarity, and degraded-state explanation
- Batch 54 contributes to continuity/sync-trust before ambient widening through the State Continuity Mesh contract
- Batch 55 and Batch 56 contribute to widgets, Live Activities, notifications, App Intents, shortcuts, routing, and other external-surface review readiness
- Batch 57 contributes cross-surface coherence and external handoff truth
- Batch 60 contributes accessibility, performance, stability, and finish-quality closure

Even after those batches close, submission still requires:

- real-device verification
- complete metadata and reviewer materials
- final privacy disclosures
- conditional auth/account/deletion decisions
- conditional monetization decisions
- reviewer-access readiness

## Final RC Submission Gate

Ambitions does not treat App Store submission as ready until all of the following are true after Batch 60:

1. Registry and product truth are stable enough that the submitted build matches the documented product scope.
2. The native release workflow in [../native-build-and-release.md](../native-build-and-release.md) is completed for the intended release candidate, including release archive validation on the real release machine.
3. Real-device manual review is completed for the shipping app and any shipped external or ambient surfaces.
4. Submission metadata, screenshots, privacy policy URL, and support URLs are complete and functional.
5. App Privacy disclosures and permission-purpose strings are reviewed against the actual release candidate.
6. Any active conditional gates are resolved:
   account deletion, reviewer credentials/demo mode, third-party login parity, or monetization/IAP review.
7. Final operator signoff is recorded using [../codex/Release_Candidate_Review_Checklist.md](../codex/Release_Candidate_Review_Checklist.md).

If any item above remains open, the build may be roadmap-complete but is not App Store submission-ready.

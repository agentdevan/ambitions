# Ambitions 3.0 App Store Truth Packet

Status: Drafted from current repo evidence; not submission approval
Owner: Product Marketing / App Store Lead
Last updated: 2026-05-01

## Purpose

This packet turns current Ambitions 3.0 repo evidence into public-facing draft language without upgrading the release posture. It is safe for internal review and demo preparation. It is not a substitute for signed archive validation, App Store Connect validation, final screenshots, live support/privacy URLs, human privacy review, physical-device proof, or final approval.

## Current Public Posture

Ambitions is a premium native iOS life execution system that helps people capture what matters, give it a place, plan what can hold, start one clear step, recover when reality changes, and save proof of what counted.

Allowed posture:

- Draft public copy is prepared from current evidence.
- Investor/internal demo story is prepared with limitations.
- App Store submission, TestFlight distribution, final release approval, public accessibility claims, and physical-device/platform claims remain blocked until their named evidence gates pass.

## App Store Subtitle Candidates

Use one of these only after final human review:

- Organize life into clear next steps
- Capture, plan, start, and recover
- Make real life easier to act on

Do not use subtitles that imply automation, coaching certainty, health treatment, productivity scoring, cloud sync, account sync, public accessibility verification, or release readiness.

## App Store Value Proposition

Draft:

Ambitions helps you capture what is on your mind, shape it into a believable goal or step, plan the week around real constraints, start where it makes sense today, and close the loop when life changes.

Evidence:

- Canonical IA: Today, Goals, Capture, Plan, You.
- Golden Launch Loop: Capture, Place, Plan, Do Today, Close / Recover, Save Proof.
- Current release truth packet: `Native/Ambitions/Support/ReleaseExternalTruthReadinessPacket.swift`.
- F22-F25 reports: active baseline, accessibility/ADHD QA, privacy/trust QA, and simulator/source edge/performance QA.

Limit:

- Do not imply App Store submission approval, device verification, public accessibility verification, expert advice, autonomous scheduling, cloud sync, or account-backed continuity.

## Screenshot Truth Plan

Screenshots may tell this story only from the final signed build and privacy-safe demo data:

1. Start here: one recommended step in Today.
2. What needs a place: Capture intake.
3. Does this hold together: Plan week shape.
4. Still Counts: recovery without shame.
5. Proof saved: receipt/proof peek.
6. You are in control: What Ambitions Knows and trust controls.

Blocked screenshot claims:

- Real-device quality until physical-device review is complete.
- Public accessibility verification until manual accessibility proof is complete.
- External-platform behavior until rendered widget, Live Activity, Shortcuts/Siri, notification, and app-group behavior are verified where claimed.
- Account, subscription, trial, sync, or cloud behavior unless explicitly implemented and reviewed.

## Preview Video Truth

Allowed concept:

Show the Golden Launch Loop using the canonical demo goal `Release 3 songs by August 1`: Capture, Grow into Goal, Plan, Start here, Step Detail, Close the loop, Still Counts, Proof saved, Review, and What Ambitions Knows.

Required caveat for internal scripts:

- Use privacy-safe fixture data.
- Show only behavior visible in the current app.
- Do not narrate future roadmap behavior as shipped.
- Do not imply App Store, TestFlight, device, accessibility, or platform readiness.

## Privacy Claims

Allowed draft:

Ambitions is designed around local-first trust. The current native app does not require an Ambitions account, does not claim cloud sync, and keeps external-surface content privacy-scoped by current source/test evidence.

Evidence:

- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `Native/Ambitions/Support/ReleaseExternalTruthReadinessPacket.swift`
- `docs/audits/ambitions-3-0-f24-privacy-trust-qa-report.md`

Limit:

- App Store privacy labels must be reconciled against the final submitted binary and App Store Connect taxonomy.
- Legal/privacy review remains human-owned.

## ADHD And Accessibility Positioning

Allowed draft:

Ambitions is designed to reduce cognitive load with one clear next step, recovery language, source/freshness labels, privacy controls, and visible alternatives to silent automation.

Evidence:

- `docs/audits/ambitions-3-0-f23-accessibility-adhd-qa-report.md`
- `docs/canon/Ambitions_3_0_Accessibility_Conformance_Plan.md`
- `Sources/Accessibility/AccessibilityNutrition.swift`

Limit:

- Do not claim medical benefit, ADHD treatment, full accessibility conformance, manual VoiceOver proof, or public accessibility nutrition facts from current evidence alone.

## Subscription / Trial / Pricing Truth

Current draft posture:

- No subscription, trial, paid unlock, or in-app purchase claim is approved for current App Store copy.
- If monetization enters scope later, pricing, entitlement, restore, disclosure, and purchase-flow review become a separate submission gate.

## Reviewer Notes Draft

Draft for human completion:

Ambitions does not require login for the current review path. Calendar-style planning remains optional and manual planning remains available if permissions are unavailable. Review should focus on the native app surfaces Today, Goals, Capture, Plan, and You. External surfaces should only be evaluated if enabled in the submitted build and covered by the final review notes.

Human-owned placeholders:

- exact build number
- enabled capabilities
- supported device band
- support URL
- privacy URL
- demo data setup
- known limitations

## Not Allowed In Public Copy Yet

- App Store submission approval or readiness
- TestFlight readiness
- final release approval
- physical-device verification
- full accessibility verification
- medical, therapeutic, or ADHD-treatment claims
- autonomous calendar writing
- hidden personalization
- account sync, cloud sync, or Apple-first sync
- subscription, trial, or IAP claims
- productivity score or fake certainty

## F26 Result

This packet is truthful for internal marketing and release-operator preparation. It keeps final public submission blocked until the release evidence gates close.

# Ambitions 2.0 Accessibility Nutrition

## Purpose

Accessibility is product trust infrastructure for Ambitions 2.0. Batch 64 establishes the internal checklist, audit model, documentation, and code-backed support needed to verify accessibility consistently before any user-facing Accessibility Nutrition Facts appear.

This document is not a public claim. It is the internal source of truth for what must be checked, how claim status is recorded, and what Batch 88 must prove before `You -> Accessibility` can publish a summary.

## Batch 64 Current Status

Batch 64 creates the internal layer only.

- The canonical checklist is documented here.
- The code-backed checklist model lives in `Sources/Accessibility/AccessibilityNutrition.swift`.
- Focused checklist tests live in `Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift`.
- All checklist categories default to `unverified` for user-facing summary purposes.
- No final `You -> Accessibility` screen is shipped by this batch.
- No user-facing accessibility support claim is verified by this batch.

## Internal Accessibility Nutrition Checklist

For every audited screen, sheet, widget, Live Activity, or external entry point, record the following:

- screen name and route
- owning feature or system
- audited date
- audited build or commit
- device and OS version when manually audited
- auditor
- Dynamic Type result
- VoiceOver result
- Reduce Motion result
- contrast result in dark and light modes
- color-not-only meaning result
- tap target result
- gesture alternative result
- keyboard/focus support result where relevant
- error recovery result
- cognitive load result
- one-handed use result
- plain-language label result
- no-shame/no-guilt language result
- privacy/trust clarity result for intelligent recommendations
- verified claims
- partially supported claims with tested scope
- unverified claims
- not-applicable categories with rationale
- remediation items
- related batch or owner
- evidence references

The machine-checkable category list is:

- Dynamic Type
- VoiceOver
- Reduce Motion
- contrast
- color-not-only meaning
- tap target size
- gesture alternatives
- keyboard/focus support where relevant
- error recovery
- cognitive load
- one-handed usability
- plain-language labels
- no shame/guilt states
- privacy/trust clarity for intelligent recommendations
- verified user-facing claims

## Screen-Level Audit Template

Use this template for internal screen audits. Keep incomplete categories explicit as `Unverified`; do not omit them.

```md
## Screen

- Route:
- Owner:
- Audit date:
- Build/commit:
- Device / OS:
- Auditor:

## Results

- Dynamic Type:
- VoiceOver:
- Reduce Motion:
- Contrast:
- Color-not-only meaning:
- Tap targets:
- Gesture alternatives:
- Keyboard/focus support:
- Error recovery:
- Cognitive load:
- One-handed use:
- Plain-language labels:
- No shame/guilt states:
- Privacy/trust clarity:

## Claims

- Verified:
- Partially supported:
- Unverified:
- Not applicable:
- Must not claim:

## Evidence

- Screenshots / videos:
- Test runs:
- Manual notes:

## Follow-up

- Required fixes:
- Related batch:
- Owner:
```

## Verification Status Model

Use these statuses in docs, tests, and future You summaries:

- `Verified`: tested against the current implementation, named build or commit, relevant device/OS, and category-specific criteria.
- `Partially supported`: some support exists, but the tested scope, limits, and missing proof are named.
- `Unverified`: support may exist in code, but it is not proven enough to claim to users.
- `Not applicable`: the category does not materially apply to the audited surface; the reason is recorded.

All categories default to `Unverified` until evidence promotes them. Historical release-candidate notes, old audits, code inspection, or expected SwiftUI behavior may inform risk, but they do not become current user-facing claims by themselves.

## Verified vs Unverified Claim Rules

- Public claims require current evidence.
- A claim must name the tested scope when scope is narrower than the whole app.
- Partial support must not be phrased as full support.
- Unverified means "do not claim as shipped."
- Not applicable must be rare and justified.
- Release notes, App Store copy, website copy, onboarding, Profile/You copy, and support docs must not imply verified accessibility support before Batch 88 signoff.
- Accessibility-related rich panel states must show verified/unverified status with text or icon support, never color alone.

## User-Facing You -> Accessibility Summary Requirements

The user-facing summary may appear only after Batch 88 verification.

It must show:

- what was verified
- what remains partially supported
- what remains unverified
- what is not applicable and why
- verification date or version
- tested device/OS scope when relevant
- plain-language limitations
- no marketing exaggeration
- route or link to relevant settings when useful
- a feedback/support path if available by release hardening

It must not show:

- broad "fully accessible" language
- unsupported Apple Accessibility Nutrition Label claims
- vague "optimized for accessibility" claims without evidence
- internal audit/debug terminology
- claims based only on Batch 60 historical notes

## Dynamic Type Requirements

- Text must not clip at large accessibility sizes.
- Primary actions remain visible or reachable.
- Hero panels may reflow but must preserve the main decision.
- Segmented controls, chips, and buttons must support multiline or adaptive layout.
- Horizontal scrollers must not become the only way to understand critical content.
- Dense detail screens must preserve save, cancel, recovery, and disclosure affordances.

## VoiceOver Requirements

- Panels expose purpose, state, and primary action.
- Decorative visuals are hidden from accessibility output.
- Progress, confidence, schedule, sync, and verification states have meaningful accessibility values.
- Reading order matches visual decision order.
- Buttons have useful labels and hints when the consequence is not obvious.
- Grouping must reduce repetition without hiding actionable controls.

## Reduce Motion Requirements

- Large route, completion, recovery, and panel animations must have reduced-motion alternatives.
- State changes remain understandable without animation.
- Haptics must not be the only confirmation.
- Motion must clarify state, never compensate for unclear hierarchy.

## Contrast Requirements

- Dark and light modes require verification.
- Warm charcoal and off-white palettes must still preserve readable contrast.
- Disabled, secondary, and calendar-derived states remain legible.
- Semantic risk, caution, trust, and verification states require readable foreground and supporting non-color encoding.

## Color-Not-Only Meaning Requirements

- Use text, icon, shape, position, or pattern in addition to color.
- Risk, success, warning, calendar-derived, sync, and verified/unverified states must be distinguishable without color.
- Charts, rails, chips, panels, and badges need labels or values that carry the same meaning as color.

## Tap Target Requirements

- Primary actions and repeated controls must meet comfortable iPhone tap sizes.
- Dense detail screens may be compact but still tappable.
- Adjacent destructive or high-impact actions need separation.
- Custom controls should use the shared minimum tap target helper or an equivalent hit area.

## Gesture Alternative Requirements

- Swipe, drag, long-press, scrub, and gesture-only interactions need visible alternatives.
- Calendar scheduling and recovery actions must be possible without precision gestures.
- If a gesture accelerates a workflow, the visible alternative must still expose the same outcome.

## Keyboard And Focus Support Requirements

- Text entry and form flows must preserve logical focus order.
- Hardware-keyboard-relevant actions must remain reachable where iOS exposes them.
- Sheet and modal focus must not strand the user without a clear close, cancel, or commit path.
- Focus behavior is especially relevant for Capture, goal creation, Plan edits, search, memory, and settings.

## Cognitive Load Requirements

- Top-level screens show one main decision.
- Avoid simultaneous hero actions.
- Use progressive disclosure for audit, review, and explanation detail.
- Recovery language must be calm and non-punitive.
- Avoid presenting raw logs, source tables, dense histories, or debug terminology on top-level screens.

## One-Handed Use Requirements

- Frequent Today, Capture, Plan, and recovery actions should be reachable.
- Bottom controls must not conflict with tab or compose affordances.
- Long forms need stable save/cancel/commit affordances.
- Important escape hatches should not live only in upper-right toolbar actions.

## Error Recovery Requirements

- Failed, empty, denied-permission, degraded, and offline/local-only states need a clear next step.
- Recovery states must preserve user agency and avoid blame.
- Destructive or irreversible actions require explicit separation and confirmation where appropriate.
- Calendar, sync/export, recommendation, and memory limitations must degrade truthfully.

## ADHD-Supportive UX Requirements

- Reduce decision load before adding detail.
- Prefer one best next move, with secondary actions clearly subordinate.
- Do not use streak pressure, guilt, or shame for missed work.
- Provide smaller-step, later, stuck, and recovery paths where the owning batch supports them.
- Keep labels concrete and adult, not cute or punitive.
- Preserve re-entry: returning users should understand what changed and what action follows.
- Avoid forcing long uninterrupted flows when a safe save, defer, or capture path is appropriate.

## Privacy And Trust Clarity Requirements

- Intelligent recommendations must disclose enough basis to be trusted without exposing debug detail.
- Calendar-derived context must be named as calendar-derived when shown.
- Local-only, sync, export/import, and memory states must not imply unavailable cloud behavior.
- Accessibility claims must not be used as marketing cover for unverified support.

## Rich Panel Accessibility Reporting

Rich panels should report accessibility support by:

- exposing purpose, state, and primary action through VoiceOver labels/values
- pairing semantic color with icon and text
- preserving Dynamic Type hierarchy
- honoring Reduce Motion
- meeting tap target expectations for actions
- using `AccessibilityNutritionCategory` when future audits record screen-level coverage
- marking accessibility verification state as `Unverified` until audited

Batch 63 panel primitives include semantic accessibility verification states, but those states are readiness hooks only. They are not proof that any screen has been verified.

## Release Verification Checklist

Before release or public Accessibility Nutrition Facts, audit:

- all five top-level tabs: Today, Goals, Capture, Plan, You
- Goal Detail
- goal creation
- Capture triage
- Plan calendar permission flow
- `Why This` and `Why Changed` sheets when they exist
- Reviews
- You -> Accessibility summary
- sync/export/import trust surfaces when they exist
- onboarding, empty, degraded, and returning-user states
- widgets and Live Activity v1 when they exist
- App Intents and external entry routing when they are in release scope
- dark and light mode
- Dynamic Type accessibility sizes
- VoiceOver
- Reduce Motion
- contrast
- color-not-only meaning
- tap targets
- gesture alternatives
- manual evidence references

Record verified and unverified claims before release notes, App Store copy, or support docs are written.

## Batch 88 Verification Handoff Criteria

Batch 88 may build and publish the user-facing `You -> Accessibility` summary only when:

- the code-backed checklist still covers every required category
- each public claim has current evidence
- every top-level tab has a completed screen-level audit
- Goal Detail, Capture triage, Plan calendar permission flow, Reviews, and trust/sync/export surfaces have audits if they exist in the product
- manual VoiceOver and Dynamic Type verification are recorded for the supported launch device band
- Reduce Motion and contrast checks are recorded
- unverified and partially supported categories remain visible internally and are not hidden from release decision-making
- App Store Accessibility Nutrition Label decisions are reconciled with `docs/canon/Ambitions_Accessibility_Nutrition_Labels_Audit.md`
- release notes and product copy avoid unsupported claims

If any evidence is incomplete, Batch 88 must keep the user-facing summary conservative or defer publication.

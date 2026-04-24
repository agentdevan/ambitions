# Ambitions 2.0 Accessibility Nutrition

## Purpose

Accessibility is product trust infrastructure. Ambitions 2.0 requires internal verification before user-facing claims.

## Internal Accessibility Nutrition Checklist

For every audited screen record:

- screen name and route
- audited date
- audited build or commit
- Dynamic Type result
- VoiceOver result
- Reduce Motion result
- contrast result
- color-not-only meaning result
- tap target result
- gesture alternative result
- cognitive load result
- one-handed use result
- verified claims
- unverified claims
- remediation items

## Screen-Level Audit Template

```md
## Screen

- Route:
- Owner:
- Audit date:
- Build/commit:
- Auditor:

## Results

- Dynamic Type:
- VoiceOver:
- Reduce Motion:
- Contrast:
- Color-not-only meaning:
- Tap targets:
- Gesture alternatives:
- Cognitive load:
- One-handed use:

## Claims

- Verified:
- Not verified:
- Must not claim:

## Follow-up

- Required fixes:
- Related batch:
```

## User-Facing You -> Accessibility Summary Requirements

The user-facing summary may appear only after verification exists.

It must show:

- what was verified
- what remains unverified
- date or version of verification
- plain-language limitations
- no marketing exaggeration
- link or route to relevant settings when useful

## Verified vs Unverified Claim Rules

- Verified means tested in the current implementation or explicitly documented validation environment.
- Not verified means do not claim support as shipped.
- Partial verification must name the tested scope.
- Historical RC notes cannot become current claims without re-verification.

## Dynamic Type Requirements

- Text must not clip at large accessibility sizes.
- Primary actions remain visible or reachable.
- Hero panels may reflow but must preserve the main decision.
- Segmented controls, chips, and buttons must support multiline or adaptive layout.

## VoiceOver Requirements

- Panels expose purpose, state, and primary action.
- Decorative visuals are hidden from accessibility output.
- Progress and schedule state have meaningful accessibility values.
- Reading order matches visual decision order.

## Reduce Motion Requirements

- Large route, completion, recovery, and panel animations must have reduced-motion alternatives.
- State changes remain understandable without animation.
- Haptics must not be the only confirmation.

## Contrast Requirements

- Dark and light modes require verification.
- Warm charcoal and off-white palettes must still preserve readable contrast.
- Disabled, secondary, and calendar-derived states remain legible.

## Color-Not-Only Meaning Requirements

- Use text, icon, shape, position, or pattern in addition to color.
- Risk, success, warning, calendar-derived, sync, and verified/unverified states must be distinguishable without color.

## Tap Target Requirements

- Primary actions and repeated controls must meet comfortable iPhone tap sizes.
- Dense detail screens may be compact but still tappable.
- Adjacent destructive or high-impact actions need separation.

## Gesture Alternative Requirements

- Swipe, drag, long-press, scrub, and gesture-only interactions need visible alternatives.
- Calendar scheduling and recovery actions must be possible without precision gestures.

## Cognitive Load Requirements

- Top-level screens show one main decision.
- Avoid simultaneous hero actions.
- Use progressive disclosure for audit, review, and explanation detail.
- Recovery language must be calm and non-punitive.

## One-Handed Use Requirements

- Frequent Today, Capture, Plan, and recovery actions should be reachable.
- Bottom controls must not conflict with tab or compose affordances.
- Long forms need stable save/cancel/commit affordances.

## Release Verification Checklist

- Audit all five top-level tabs.
- Audit Goal Detail.
- Audit Capture triage.
- Audit Plan calendar permission flow.
- Audit `Why This` and `Why Changed` sheets.
- Audit Reviews and You -> Accessibility summary.
- Audit widgets and Live Activity v1 when they exist.
- Recheck dark and light mode.
- Record verified and unverified claims before release notes are written.

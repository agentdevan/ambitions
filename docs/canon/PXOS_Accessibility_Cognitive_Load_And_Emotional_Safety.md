# Accessibility Cognitive Load And Emotional Safety
<!-- markdownlint-disable MD013 -->

Status: PXOS future canon; PX12 complete; not current app implementation truth
Date: 2026-05-02

## Purpose

PXOS must support tired, overwhelmed, ADHD, anxious, low-energy, distracted, or cognitively overloaded users.

Rules: Dynamic Type support for future UI, clear VoiceOver path for every major surface, Reduce Motion alternatives, no color-only meaning, obvious next action, progressive disclosure, no shame language, non-punitive recovery, optional explanations, non-interruptive receipts unless attention is needed, skippable/recoverable setup, non-gesture alternatives for critical actions, clear interactive row labels, non-visual equivalents for rails, and emotional-safety review for recovery states.

Accessibility is product architecture in PXOS. It must shape future surfaces
before visual implementation, not arrive as cleanup after a screen already
exists.

## Universal Requirements

Every future PXOS UI batch must specify:

- primary object and primary action;
- VoiceOver name, value, hint, and order for primary controls;
- Dynamic Type behavior for primary actions and dense rows;
- Reduce Motion equivalent for meaningful motion;
- non-color state indicators through text, icon, shape, or hierarchy;
- one-handed touch target posture;
- visible alternative for gestures;
- privacy-safe summaries for sensitive items;
- cognitive-load reason when information is shown on a top-level surface.

Future UI batches that cannot provide this evidence are not Green.

## VoiceOver And Non-Visual Structure

Rails, maps, lanes, progress shapes, proof markers, and visual vitality states
need non-visual summaries. The summary should explain state and next action
without requiring a user to traverse every decorative or secondary item.

Examples:

- Today: one recommended step, one closure needed, next protected block.
- Goals: active ambitions, pressure/risk posture, next drill-down.
- Capture: current private item, placement preview, confirmation state.
- Plan: capacity/pressure state, protected/free time, next reflow decision.
- You: setup/trust posture, controls needing review, data ownership state.

VoiceOver should not expose diagnostic noise or repeated decorative labels.

## Dynamic Type And Layout

Primary actions must remain discoverable at large text sizes. If a compact
visual rail, map, lane, or grouped panel cannot fit at larger sizes, the future
implementation should collapse to readable rows rather than truncating meaning.

Dense top-level dashboards are not an acceptable Dynamic Type fallback. The
fallback should preserve the primary object, source labels, and the next action.

## Motion, Haptics, And Reduce Motion

Meaningful motion needs a static equivalent:

- proof saved -> text/status confirmation;
- plan adjusted -> stable before/after summary;
- moved/rescheduled -> explicit destination and consequence;
- closed as Still Counts -> receipt/proof state;
- rail/map movement -> current position label and next action.

Haptics may reinforce user-confirmed changes, but cannot be the only proof that
something happened.

## Non-Color Meaning

No PXOS state may rely on color alone.

Use:

- labels for waiting, blocked, protected, private, source needs review;
- shape/icon differences for proof, receipt, closure, decision;
- hierarchy and grouping for priority;
- explicit text for sensitive/private states.

## Touch And Gesture Alternatives

Tiny visual nodes are indicators, not primary targets. Rows, buttons, panels,
or named controls should be the accessible targets.

Any swipe, drag, long press, chart exploration, rail manipulation, or map
gesture needs a visible alternative with the same outcome.

## Cognitive Load Rules

Top-level surfaces should ask for one meaningful decision at a time. Secondary
proof, history, diagnostics, receipts, and detailed explanation belong behind
drill-downs unless they are necessary for immediate trust or action.

Every overloaded state should offer a lighter path, such as:

```text
Make this lighter
```

Future surfaces should answer quickly:

- what is this?
- what matters here?
- what can I do next?
- what can wait?

## Emotional Safety

Recovery, blocked states, long-gap returns, proof gaps, stale sources, missed
plans, and setup incompleteness must not shame the user.

Use:

- `Needs recovery`
- `Still Counts`
- `Review later`
- `Waiting`
- `Blocked`
- `Not needed`
- `Moved`
- `Source needs review`

Avoid character judgments, streak pressure, hidden penalty language, urgency
theater, and success/failure framing for ordinary life drift.

## Per-Surface Acceptance Criteria

Today passes when the Reality Rail has a readable non-visual summary, tappable
rows, clear `Start here` action, non-color readiness states, and recovery
language that remains humane.

Goals passes when Mission Control has plain vitality/path/proof labels, no
KPI-only or chart-only meaning, and drill-downs for detail.

Capture passes when input, privacy state, placement preview, and confirmation
are understandable without color or gesture dependence.

Plan passes when capacity, pressure, protected/free time, and reflow decisions
remain readable, non-shaming, and reachable without calendar-clone overload.

You passes when grouped controls, setup, trust, source/freshness labels,
pause/delete/change actions, and data ownership are readable and reachable.

## Public Proof Boundary

PX12 defines future accessibility and cognitive-load canon. It does not prove
manual VoiceOver traversal, Dynamic Type screenshots, physical-device
behavior, public accessibility conformance, or App Store accessibility
readiness. Future implementation batches must produce scope-appropriate
evidence before claiming accessibility acceptance.

## Required Source Stack

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/canon/Ambitions_Beyond_3_0_Continuity_Rules.md`
- `docs/canon/Ambitions_Product_Experience_OS_Index.md`
- `docs/canon/AmbitionsOS_Index.md`
- `docs/codex/PXOS_TRAIN_CONTROL_SYSTEM.md`
- `docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`

## Gates

- Product Decision Lock Gate: major choices must be locked by source truth or recorded as open/deferred.
- Surface Ownership Gate: every future UI change names Today, Goals, Capture, Plan, You, or a drill-down owner.
- Deep-Not-Wide Gate: deepen existing surfaces before creating new surface area.
- Accessibility / Cognitive Load Gate: future UI must specify Dynamic Type, VoiceOver, Reduce Motion, no color-only meaning, and cognitive-load expectations.
- Release Claim Gate: no release/platform/AI/personalization claim without evidence.
- ME Gate: no large UI expansion in known large-file zones without extraction review.
- CS Gate: no route/raw-value/external-surface/persistence breakage.

## Implementation Boundary

This is future canon and process guidance only. It does not implement app behavior, change production Swift, start PXOS, start AOS/ME/CS/REC02, retire compatibility seams, add dependencies, change workflows, add backend/sync/cloud/model runtime, or create release/platform readiness claims.

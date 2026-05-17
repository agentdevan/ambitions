# Ambitions 4.0 State Transformation Motion Primitives

Status: Historical supporting canon; subordinate to `docs/truth/*`

## Primitive Template

Every primitive must include:

- purpose;
- visual anatomy;
- source state;
- destination state;
- allowed surfaces;
- forbidden surfaces;
- Reduce Motion equivalent;
- VoiceOver behavior;
- Dynamic Type consideration;
- preview requirement;
- performance risk;
- validation requirement.

## Primitive Specifications

### CaptureToReceiptMorph

Purpose: show a captured thing becoming a placed receipt. Anatomy: composer
field, route chip, receipt panel, proof/source label. Source: unplaced capture.
Destination: placed receipt. Allowed: Capture, Trust. Forbidden: task boards.
Reduce Motion: instant receipt with source label. VoiceOver: announce placement
and undo availability. Dynamic Type: receipt wraps. Preview: routed capture.
Risk: layout thrash. Validation: Capture tests/build plus motion scan.

### HeroToSessionExpansion

Purpose: show Start here becoming execution context. Anatomy: hero card, step
title, session header, closure action. Source: recommended step. Destination:
Step Session. Allowed: Today/Step. Forbidden: unrelated surfaces. Reduce
Motion: direct navigation with stable title. VoiceOver: announce session open.
Dynamic Type: title wraps. Preview: large type. Risk: navigation jank.
Validation: Today/Step tests.

### RailRowToStepDetailTransition

Purpose: preserve row-to-detail continuity. Anatomy: row title, status, detail
header. Source: rail row. Destination: Step Detail. Allowed: Today/Step.
Forbidden: shell tabs. Reduce Motion: fade/instant. VoiceOver: focus detail
title. Dynamic Type: row/detail adapt. Preview: rail detail. Risk: matched
geometry overdraw. Validation: UI route smoke.

### PlanBlockToTodayTransition

Purpose: show plan intent becoming today's visible step. Anatomy: plan block,
capacity marker, Today rail entry. Source: plan block. Destination: Today step.
Allowed: Plan/Today. Forbidden: calendar writes. Reduce Motion: receipt copy.
VoiceOver: announce surfaced step. Dynamic Type: no clipping. Preview:
plan-to-today. Risk: semantic overclaim. Validation: Plan tests and no calendar
write scan.

### GoalLaneFocusTransition

Purpose: focus a Mission Control lane into goal detail. Anatomy: lane card,
detail section, proof/risk/step focus. Source: lane. Destination: detail focus.
Allowed: Goals/Goal Detail. Forbidden: OKR dashboards. Reduce Motion: direct
scroll/focus. VoiceOver: focus selected section. Dynamic Type: lane stacks.
Preview: goal with proof/blocker. Risk: dense UI. Validation: Goals tests.

### EvidenceToRecallBloom

Purpose: show proof/evidence becoming recall context. Anatomy: evidence label,
source, freshness, recall card. Source: evidence. Destination: recall. Allowed:
Memory/Trust/Goals. Forbidden: magical AI claims. Reduce Motion: static source
card. VoiceOver: source/freshness/control. Dynamic Type: source labels wrap.
Preview: stale/rejected memory. Risk: creepiness. Validation: trust/privacy
scan.

### ReceiptStackSettle

Purpose: show multiple changes settling into an auditable stack. Anatomy:
receipt cards, proof icon, undo/correction. Source: active receipts.
Destination: settled stack. Allowed: Trust/Capture/Goals. Forbidden: decorative
toasts. Reduce Motion: static grouped stack. VoiceOver: ordered receipts.
Dynamic Type: receipts wrap. Preview: trust stack. Risk: overdraw. Validation:
receipt tests/build.

### OverloadToRecoveryCollapse

Purpose: turn overload into recovery choices without shame. Anatomy: pressure
band, collapsed plan/day, recovery options. Source: overload. Destination:
recovery. Allowed: Today/Plan. Forbidden: failure states. Reduce Motion:
static before/after recovery card. VoiceOver: announce choices. Dynamic Type:
actions wrap. Preview: overloaded day. Risk: hidden action. Validation:
recovery tests.

### ProofPulseSettle

Purpose: confirm proof saved without gamification. Anatomy: proof pulse,
evidence label, saved state. Source: new proof. Destination: saved proof.
Allowed: Today/Goals/Trust. Forbidden: streaks. Reduce Motion: static proof
saved label. VoiceOver: "Proof saved" and source. Dynamic Type: label wraps.
Preview: proof state. Risk: pulse loops. Validation: motion scan.

### QuietCommandFocus

Purpose: focus command input while preserving user control. Anatomy: command
surface, mic/plus, route suggestion. Source: unfocused command. Destination:
focused command. Allowed: Capture/shell. Forbidden: chatbot-first UI. Reduce
Motion: instant focus state. VoiceOver: focus field and route choice. Dynamic
Type: field wraps. Preview: command focus. Risk: keyboard layout. Validation:
command route tests.

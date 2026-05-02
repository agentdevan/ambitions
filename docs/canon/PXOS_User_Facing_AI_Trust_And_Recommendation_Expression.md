# PXOS User-Facing Intelligence Trust And Recommendation Expression
<!-- markdownlint-disable MD013 -->

Status: PXOS future canon; not current app implementation truth
Date: 2026-05-02

## Purpose

PXOS defines how intelligence appears without making Ambitions a chatbot, AI wrapper, fake certainty engine, or generic productivity dashboard. Recommendations appear as product-native surfaces: rails, owned rows, proof-aware detail, source labels, and small explanation affordances. They do not appear as a chat-first layer by default.

The user-facing promise is not "the model knows." The promise is "Ambitions can show why this is useful now, what it is based on, what it is not sure about, and how the user can change it."

This is future user-facing canon only. It does not implement app behavior, start AmbitionsOS, expose model/runtime behavior, add hosted AI, add backend/sync/cloud capability, or claim personalization is active beyond existing repo evidence.

## Expression Law

Recommendations must be:

- source-grounded;
- qualitative rather than scored;
- correctable;
- privacy-safe;
- clear about missing or stale context;
- owned by a surface;
- recoverable when wrong;
- calm rather than sycophantic;
- useful without requiring the user to understand internal systems.

## Approved User-Facing Patterns

| Pattern | Use | Required contents | Forbidden drift |
| --- | --- | --- | --- |
| `Start here` | Today primary daily recommendation | one recommended step or review action, source/freshness label, visible alternatives | best-step claim, priority score, command language |
| `Recommended step` | Step-level recommendation | source facts, fit reason, correction path | `AI recommends`, model confidence, optimization language |
| `Why this?` | Compact explanation affordance | source, context, assumption, consequence, user control | system-defense essay, model internals, hidden scoring |
| `Based on...` | Source/context label | plain source such as plan, goal, recent correction, schedule, proof, or user setting | vague intelligence claim, unsupported personalization |
| `May need review` | Stale or uncertain source state | source age or missing context, safe next action | shame, blame, false certainty |
| `Not enough context` | Degraded recommendation state | what is missing and how to continue safely | dead end, generic error, hidden fallback |
| `You can change this` | Control/correction language | edit, move, make smaller, review later, do not suggest in this context when supported | one-way automation or invisible learning |

## Recommendation Anatomy

Every future user-facing recommendation needs this minimum anatomy before implementation:

- recommended object or action;
- owner surface;
- source facts;
- freshness state;
- privacy posture;
- assumption when relevant;
- visible consequence if accepted;
- correction route;
- fallback when evidence is missing;
- receipt/proof behavior when accepting changes matters.

This anatomy can be compact. It does not all need to sit on the top-level surface. Top-level surfaces show the orientation object and the smallest useful explanation; detail belongs in the owned drill-down.

## Surface Expression

### Today

Today expresses recommendations through `Start here`, `Recommended step`, and `Why this?`. Today should not show a wall of algorithmic rationale. The rail should answer: why this, why now, what source, what if wrong.

Allowed examples:

- `Start here`
- `Recommended because this fits the open window.`
- `Based on your plan.`
- `May need review: schedule changed.`
- `Make this lighter.`

Forbidden examples:

- `AI chose the optimal next step.`
- `98% confidence.`
- `Best possible move.`
- `The algorithm decided.`

### Goals

Goals expresses intelligence as path clarity, tradeoff explanation, proof-aware progress, and Mission Control recommendations. It must not become an analytics dashboard or confidence leaderboard.

Goals recommendation copy should name the source Goal/Path, the reason the suggestion matters, and the correction route. Strategic uncertainty should be framed as reviewable assumptions, not model weakness.

### Capture

Capture expresses intelligence as placement preview and safe fallback. It may suggest a destination, but it must show the consequence before confirmation and preserve `Needs a place` when evidence is insufficient.

Capture must not imply hidden automatic routing, hidden memory creation, or unsupported source gathering.

### Plan

Plan expresses intelligence through feasibility, capacity, pressure, and reflow suggestions. It may say a plan may not hold together, but it must show source context and require confirmation before meaningful timing changes.

Plan must not silently write calendar changes, treat away time as free time, or present a recommendation as an obligation.

### You

You expresses intelligence as control and trust: what Ambitions knows, what it is using, freshness, correction, pause/delete posture where supported, and receipt/proof review. You is the place for memory/source review, not a full AI console.

## AOS Boundary

AmbitionsOS owns future internal recommendation, source-truth, proof-trust, privacy, fallback, local-language, and adaptation kernels. PXOS owns how those results may someday appear to the user.

PXOS may document expression rules before AOS implementation, but it must not claim:

- AOS kernels are implemented;
- recommendations are powered by a live model;
- personalization is active beyond current evidence;
- hosted AI, backend intelligence, cloud memory, or sync exists;
- source truth has been externally verified;
- future recommendation UI is ready for production.

If AOS evidence is missing, user-facing language must degrade to plain source boundaries:

- `Based on your plan.`
- `Not enough context yet.`
- `May need review.`
- `You can change this.`

## Privacy And Trust Boundaries

Recommendations may use or display sensitive context only when the future owner surface has a privacy-safe projection and a correction path. Sensitive source detail should be redacted on top-level surfaces and inspectable only in an owned detail or trust surface.

Memory-influenced recommendations need source and freshness labels. They must not imply invisible surveillance, hidden learning, or irreversible personalization.

## Copy Guard

Future user-facing recommendation copy must avoid:

- `AI confidence`;
- model confidence;
- confidence percentage;
- optimization score;
- productivity score;
- algorithm decided;
- best possible;
- guaranteed;
- assistant/chatbot framing as the default product experience;
- fake certainty;
- shame language;
- hidden automation.

Prefer:

- `Recommended because`;
- `Based on`;
- `Why this?`;
- `You can change this`;
- `May need review`;
- `Not enough context`;
- `Make this lighter`;
- `Review later`;
- `Proof saved` when proof actually exists.

## Future Acceptance Checklist

Any future implementation batch that exposes recommendations must prove:

- source and freshness labels are present;
- correction or review path exists;
- degraded states are honest;
- sensitive details are redacted by default;
- no model/confidence/productivity-score copy appears in normal UI;
- recommendations do not silently mutate plans, goals, proof, memory, or schedules;
- AOS dependencies are either implemented and validated or explicitly treated as unavailable;
- accessibility copy explains the recommendation without relying only on color, motion, or spatial layout;
- top-level surfaces remain visual orientation surfaces, not stacked explanation panels.

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

## PX16 Evidence Status

PX16 may claim this future-canon recommendation expression system is documented after its batch evidence is committed. It may not claim recommendations are implemented, AmbitionsOS is active, a model is running, personalization is proven, PXOS is implemented, or release/platform readiness exists.

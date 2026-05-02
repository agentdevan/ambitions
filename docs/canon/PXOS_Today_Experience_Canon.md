# Today Experience Canon
<!-- markdownlint-disable MD013 -->

Status: PXOS future canon; PX02 complete; not current app implementation truth
Date: 2026-05-02

## Purpose

Today is the daily operating surface: the obvious place to start, a calm orientation for the day, and a premium execution surface. It is not a task dump, feed, generic schedule, chatbot landing screen, or motivational dashboard.

Today owns Hero Step Panel, Start here, Recommended step, Why this?, context labels, duration source, day progress, time remaining, Start now, Open step, Adjust plan, Now / Next / Later rail, connected dots, Step Detail, Step Session, Action Closure prompts, soft recovery prompts, receipts, plan adjustment prompts, protected-time awareness, capacity awareness, early-completion reflow, late-start recovery, no-step-available, and stale-recommendation states.

Normal Today is compact. It expands only for explanation, recovery, closure, or ambiguity. Rail row tap opens lightweight Step Detail first. Start now launches Step Session. Step Session may include a secondary timer but is not timer-first by default.

## PX02 Top-Level Orientation Surface

Today answers one question first:

```text
What should I do now?
```

The first viewport should orient around one dominant object: the Reality Rail /
Ambitions Day Rail. The Hero Step Panel is the lead state inside that object,
not a separate stacked card above the rail by default. It carries `Start here`,
the recommended step, why it matters, duration/source context, and the primary
action.

The top-level Today composition is:

1. Compact context header: day shape, availability, and trust posture.
2. Reality Rail: Hero Step Panel plus Now / Next / Later orientation.
3. One contextual prompt only when relevant: closure, recovery, proof, or plan
   adjustment.
4. Secondary content only below the first viewport and only when it does not
   duplicate the rail.

Today must not expose proof archives, diagnostics, full history, all tasks, or
all schedule detail at the top level. Those belong behind deliberate taps.

## Primary Object And Action

Primary object: the recommended step in the Reality Rail.

Primary action: `Start now` when the step is actionable and safe. If the step is
blocked, protected, stale, private, or needs review, the primary action becomes
the honest next ownership action such as `Open step`, `Adjust plan`, `Close the
loop`, or `Review`.

Today should show one primary action at a time. Secondary actions are quieter
and route to owned drill-downs:

- `Why this?` opens source/recommendation explanation.
- `Open step` opens Step Detail.
- `Adjust plan` opens a Plan-owned reflow or planning decision surface.
- `Close the loop` opens Action Closure.
- `Proof saved` opens a receipt/proof peek or history drill-down.

## Drill-Down Ownership

Today owns orientation and the next calm execution path. Detail belongs here:

| Detail | Owner | Top-level Today behavior |
| --- | --- | --- |
| Step explanation | Step Detail | show a compact reason; open detail for source facts |
| Step execution | Step Session | start only from explicit user action |
| Closure | Action Closure | show soft prompt; never shame or auto-complete |
| Still Counts | Action Closure / Proof | expose as closure option, not a score |
| Proof preview | Proof & Receipt Ledger | show compact proof state; open receipt/proof detail |
| Recovery | Today / Plan | show one recovery prompt; route plan decisions to Plan |
| Source labels | Recommendation / Source Truth | show freshness/source labels; open explanation |
| Full schedule | Plan | show fit/availability only; route schedule detail to Plan |

## State And Degraded Behavior

Today has these future PXOS states:

- Ready: one recommended step is actionable.
- Protected: time, energy, or commitment context says not to start now.
- Needs plan adjustment: the day no longer holds together.
- Needs closure: an earlier step needs a non-shaming outcome.
- Proof available: something counted and can be reviewed.
- No step available: Ambitions cannot honestly recommend a step yet.
- Stale recommendation: source facts changed or freshness is uncertain.
- Private redacted: sensitive details are hidden until opened intentionally.

Degraded states use direct, calm copy:

- `No silent changes`
- `Based on your plan`
- `Needs review`
- `This may need a place first`
- `You are in control`

Today must not pretend certainty when sources are stale, private, missing, or
conflicting.

## Privacy, Trust, And Proof

Today may summarize private or sensitive work, but the top-level surface should
redact sensitive titles when needed and preserve source/freshness labels. It may
say that a step is private, blocked, protected, or based on older context. It
must not expose sensitive proof, memory, receipt, or source detail without a
deliberate drill-down.

Meaningful changes must stay user-visible:

- no silent rescheduling;
- no hidden completion;
- no hidden proof creation;
- no automatic plan rewrite from Today;
- no release/platform or production intelligence claim.

## Visual Orientation Examples

Good Today:

- one large Reality Rail object;
- one visible `Start here` decision;
- Now / Next / Later shown as rhythm, not a task list;
- closure/proof shown as a small contextual prompt;
- muted source/freshness labels;
- secondary detail behind taps.

Bad Today:

- a stack of unrelated cards above the fold;
- all tasks, all schedule items, all proof, and all diagnostics visible at once;
- multiple equally loud CTAs;
- calendar timeline as the primary object;
- chatbot prompt as the landing state;
- productivity score, streak, or shame recovery.

## Accessibility And Cognitive Load

Today must support Dynamic Type, VoiceOver labels for the recommended step and
primary action, Reduce Motion alternatives for rail animation, no color-only
meaning, visible alternatives for gestures, and a first viewport that asks for
no more than one meaningful decision.

The 3-second glance test passes only when the user can identify the recommended
step, its actionability, and the next safe action without reading every label.

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

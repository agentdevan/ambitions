# Action Closure Recovery Canon
<!-- markdownlint-disable MD013 -->

Status: PXOS future canon; PX07 complete; not current app implementation truth
Date: 2026-05-02

## Purpose

Action Closure replaces binary success/failure. Supported states: Completed, Still Counts, Moved, Skipped / Not Needed, Blocked, Waiting, Needs Recovery, and Needs Review.

PXOS defines these states across Today, Step Detail, Step Session, Plan, Goals, You/history, receipts, and recovery sheets. Unclosed prior steps appear as soft closure prompts rather than stale Today items. Still Counts appears in closure/recovery sheets and relevant prompts, not everywhere.

Recovery language is calm, direct, and lightly supportive. The system must not
shame the user, create guilt loops, treat all unfinished work as failure, or
remove agency.

## PX07 Closure Model

Action Closure answers one question:

```text
What actually happened, and what should Ambitions do next?
```

The closure surface is not a verdict on the user. It is a reality-resolution
step that turns a planned action into one of these user-controlled outcomes:

- `Completed`
- `Still Counts`
- `Rescheduled`
- `Not needed`
- `Blocked`
- `Waiting`
- `Needs Recovery`
- `Needs Review`
- `Review later`

`Close the loop` is the primary action label. It should appear where the user
is already resolving work, such as Today, Step Session, Step Detail, Plan
recovery, Goal Detail, and relevant review flows. It should not become a new
top-level destination.

## Surface Placement

| Surface | Closure role | Detail placement |
| --- | --- | --- |
| Today | Shows soft closure prompts for unclosed prior steps and one visible way to close today's current step. | Outcome choice and detail entry live in the closure sheet or Step Session, not the top-level rail. |
| Step Session | Owns the most direct `Close the loop` path after an action. | Outcome details, blocked/waiting context, and Still Counts proof preview live in the session closure sheet. |
| Step Detail | Explains why the step is here and offers a visible closure/review entry when relevant. | Secondary explanation, source, and receipt preview remain behind detail or sheet surfaces. |
| Plan | Owns recovery and reflow review after reality changes. | Reschedule, capacity, and consequence details belong in Plan recovery/reflow review, not silent calendar changes. |
| Goal Detail | Shows closure effects on path, proof, decisions, and risks. | Proof/history and decision details belong in Mission Control lanes. |
| You | Owns receipts/history and correction review. | Long-term receipt, proof, and correction trails belong in You drill-downs and trust surfaces. |

## Outcome Meaning

| Outcome | Meaning | Required control |
| --- | --- | --- |
| Completed | The planned action happened as intended. | Save proof or receipt only within current implementation truth. |
| Still Counts | The user's real action was meaningful even if it differed from the plan. | Let the user name what counted; avoid fake completion. |
| Rescheduled | The action still matters but needs a new time or plan position. | Show consequences and require confirmation before schedule changes. |
| Not needed | The action no longer belongs. | Preserve optional receipt/reason without shame. |
| Blocked | The action cannot move because of a dependency or constraint. | Name the blocker and offer a visible next safe alternative. |
| Waiting | The action depends on another person, event, or external response. | Keep waiting state visible without nagging or silent escalation. |
| Needs Recovery | The plan no longer holds together. | Offer recovery paths, smaller next steps, or Plan review. |
| Needs Review | The system needs user judgment before changing direction. | Route to review with source/context, not automation. |
| Review later | The user defers closure for now. | Preserve the item without marking failure. |

## Receipt And Proof Boundary

Closure may preview receipts and proof, but PX07 does not claim new persistence
or a broader Proof/Receipt Ledger implementation. Future UI should label receipt
and proof previews by source, outcome, destination/consequence, and whether
confirmation is required.

Use the receipt pattern:

```text
[Result] · [Object] · [Destination or consequence]
```

Examples:

```text
Still Counts · Saved as proof
Rescheduled · Friday
Blocked · Waiting on reply
```

## Recovery And No-Silent-Change Rules

Recovery must preserve agency:

- no shame language;
- no hidden automation;
- no silent calendar writes;
- no automatic goal-path rewrite;
- no binary success/failure framing;
- no proof claim without source;
- no persistence/export/platform claim without evidence.

Every meaningful recovery change should show what changed, why, and how to
review or undo where supported. If Ambitions cannot safely resolve the state, it
should say so and route to review rather than pretend certainty.

## Accessibility And Cognitive Load

Future closure UI must support Dynamic Type, clear VoiceOver labels for outcome
choices, non-color-only status meaning, visible alternatives to gestures, and
Reduce Motion behavior for any transition that explains plan change. Outcome
choices should be grouped by meaning so the user can resolve reality quickly
without scanning a dense archive.

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

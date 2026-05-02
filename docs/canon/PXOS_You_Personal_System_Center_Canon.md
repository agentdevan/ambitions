# You Personal System Center Canon
<!-- markdownlint-disable MD013 -->

Status: PXOS future canon; PX06 complete; not current app implementation truth
Date: 2026-05-02

## Purpose

You is the Personal System Center: where Ambitions becomes yours. It is not just settings, a social profile, or vanity analytics.

You owns profile, settings, preferences, history, analytics, reviews, trust, memory/preferences, schedule and availability, planning defaults, vacation/away time, automation and trust, receipts, proof history, privacy controls, data controls, integration permissions, personalization, setup completeness, system health, grouped navigation, iOS Settings-style drill-downs, release/product truth where relevant, automation level, source/trust review, and sensitive goal preferences.

Top of You should use a restrained iOS Settings-style `UserSystemProfilePanel`.
High section: Schedule & Availability, Planning Defaults, Vacation / Away
Time, Automation & Trust. Default automation level is Guided.

## PX06 Top-Level Orientation Surface

The You top-level surface answers one question first:

```text
What does Ambitions know, and what can I control?
```

The dominant object is the user's Personal System Center, not a settings list.
Its first viewport should orient around:

- top status: `You are in control`;
- current trust/memory posture;
- the most important review-needed source or control;
- one primary action, such as `Review what Ambitions knows`;
- grouped navigation into trust, memory, receipts, privacy, setup, and support.

Secondary details belong behind grouped navigation rows, drill-downs, review
surfaces, receipts/history, setup flows, and privacy/data controls.

## Owned Sections

| Section | Purpose | User control boundary |
| --- | --- | --- |
| What Ambitions Knows | Shows memory categories, source, freshness, and correction controls. | User can review, correct, pause learning, delete where supported, and see how memory shapes recommendations. |
| Automation & Trust | Shows automation level, safe-vs-blocked controls, and no-silent-change posture. | Guided is the default; stronger automation requires explicit future proof and approval. |
| Schedule & Availability | Holds availability and planning constraints that shape Plan and Today. | Plan may use these only as user-owned planning context, not silent calendar authority. |
| Planning Defaults | Holds planning preferences, density, recovery defaults, and review cadence. | Changes are user-controlled and inspectable. |
| Vacation / Away Time | Holds away-state planning context and recovery expectations. | No automatic rescheduling without confirmation. |
| Receipts & History | Shows meaningful changes, proof, corrections, and user-approved actions. | Corrections and undo paths must remain visible where supported. |
| Privacy & Data Controls | Explains local-first posture, export/import posture, permissions, and sensitive data boundaries. | Export/import claims remain bounded by current evidence; unsupported platform proof is not implied. |
| System Health & Support | Shows setup completeness, blocked capabilities, support, and release/product truth where relevant. | States must be qualitative and evidence-bound, not readiness claims. |

## What Ambitions Knows

`What Ambitions Knows` is the primary memory surface inside You. It should show
memory categories with:

- source labels, such as `You told Ambitions this` or `Based on recent choices`;
- freshness labels: `Current`, `May Need Review`, and `Based on Older Context`;
- ownership labels for user-confirmed, inferred, corrected, deleted, or paused memory;
- correction, deletion, and pause/resume controls where supported;
- receipts for meaningful correction or deletion actions.

Memory and personalization are local-first and user-controlled unless a future
batch changes that truth with evidence. Older context must not appear equally
trusted to current confirmed context.

## Safe-Vs-Blocked Controls

You must make system capability boundaries visible without turning into a data
console. Use qualitative status sections, not a numerical Trust Score.

Safe controls:

- guided suggestions;
- inspectable memory;
- correction and review;
- explicit permission setup;
- confirmation before external writes or destructive changes;
- receipt-backed meaningful changes.

Blocked controls:

- hidden automation;
- silent rescheduling;
- unreviewable personalization;
- platform/release readiness claims without proof;
- model-confidence or AI-settings jargon;
- internal Profile naming retirement before CS gates.

## Profile Compatibility Boundary

The user-facing surface is `You`. Internal code may still use `Profile` where
compatibility requires it. Any internal rename, route/raw-value retirement,
external-surface change, persistence change, App Intent change, widget change,
or import/export change must wait for CS proof and cannot be implied by PX06.

## Accessibility And Cognitive Load

Future You UI must support Dynamic Type, VoiceOver-friendly grouped navigation,
Reduce Motion alternatives for any trust-state motion, no color-only status
meaning, and visible alternatives for gesture-only controls. The first viewport
should show one primary control path, then group secondary settings by meaning
instead of exposing a dense settings dump.

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

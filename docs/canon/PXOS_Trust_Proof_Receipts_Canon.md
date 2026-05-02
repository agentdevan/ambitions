# Trust Proof Receipts Canon
<!-- markdownlint-disable MD013 -->

Status: PXOS future canon; PX08 complete; not current app implementation truth
Date: 2026-05-02

## Purpose

PXOS makes trust visible without making Ambitions bureaucratic. Trust surfaces
include subtle receipt toasts, inline receipts, proof rail, evidence labels,
Why this? explanations, undo, change history, source labels, privacy
boundaries, review prompts, visible certainty boundaries, what changed, why it
changed, what triggered it, source used, source missing, assumptions, and
uncertainty.

Receipts are subtle by default. Full detail lives in drill-down/history. Trust layers: quick surface-level reason, optional Why this?, full proof/receipt detail, and history/review under You.

## PX08 Trust Layers

Trust appears in layers so top-level tabs stay calm:

- surface-level reason: one short source or consequence label;
- optional `Why this?`: a compact explanation of the source, assumption, and
  current certainty boundary without model jargon;
- receipt/proof detail: what happened, what changed, who approved it, and
  whether undo or correction is available;
- history/review: longer receipt, proof, correction, export/import, and privacy
  context under You and owned review surfaces.

Top-level surfaces may show one proof/receipt preview when it helps orientation.
Dense history, full proof detail, correction trails, export/import posture, and
privacy controls belong in drill-downs, receipts/history, proof detail, review
flows, and You.

## Receipt Anatomy

A future receipt should include:

- what happened;
- what changed;
- why it changed;
- source or trigger;
- whether the user approved it;
- undo availability, if safe;
- correction availability, if relevant;
- timestamp or freshness posture where useful;
- privacy/redaction state for sensitive content.

Receipts are not legal proof, platform proof, sync proof, or release proof.
They must not claim external sync, signed archive, device verification, App
Store Connect, TestFlight, public accessibility, or integration status.

## Proof Boundary

Proof means evidence that progress or reality-sync occurred. It should be
source-bound and honest about scope:

- `Proof saved` only when current implementation truth supports that proof path;
- `Stored on this device` only when the storage claim is supported;
- `No silent changes` when the user approved the meaningful change;
- `Needs confirmation` when the proof or receipt is only a preview;
- `Source needs review` when source freshness or certainty is limited.

PX08 does not expand persistence, sync, export/import, platform integration, or
Proof/Receipt Ledger behavior. It defines future expression and gate criteria
only.

## Source, Freshness, And Correction

Every source-sensitive trust claim should show source and freshness posture:

- source labels: `Changed by you`, `Suggested by Ambitions`, `You approved this`,
  `Based on recent choices`, `Source missing`, or similar approved language;
- freshness labels: `Current`, `May Need Review`, and `Based on Older Context`
  where memory or personalization is involved;
- correction affordances: `Correction available`, `Undo available`, review
  route, or blocked-state explanation.

Correction is not the same as undo. Undo reverses a safe local change when
possible; correction teaches Ambitions what was wrong and should create an
appropriate receipt when supported.

## Privacy, Redaction, Export, And Import

Sensitive receipts and proof should hide detail by default on top-level
surfaces. Private items should show a privacy-safe label, source/freshness
posture, and a route to inspect only when the user has chosen to reveal detail.

Export/import posture must stay evidence-bound:

- do not claim export or import support beyond current implementation truth;
- do not imply legal, tax, medical, employment, or compliance proof;
- do not imply cloud sync or external backup without proof;
- show what is included, excluded, blocked, or needs human action where future
  export/import surfaces exist.

## Accessibility And Cognitive Load

Future trust/proof/receipt UI must support Dynamic Type, VoiceOver-readable
source and outcome labels, no color-only trust state, visible alternatives to
gesture-only detail reveal, and Reduce Motion alternatives for any proof pulse
or receipt transition. Trust should be glanceable first and inspectable second.

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

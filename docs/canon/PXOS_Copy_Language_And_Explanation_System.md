# Copy Language And Explanation System
<!-- markdownlint-disable MD013 -->

Status: PXOS future canon; PX09 complete; not current app implementation truth
Date: 2026-05-02

## Purpose

PXOS language makes Ambitions feel calm, precise, human, and source-grounded.
It explains what Ambitions is doing through objects, sources, context,
consequences, and user control instead of model performance, productivity
jargon, or fake certainty.

Language should be human, calm, direct, premium, non-sycophantic, specific,
transparent, not over-explained, not cutesy, not corporate, not manipulative,
and not falsely certain.

## Preferred Phrase System

Core phrases:

- `Start here`
- `Recommended step`
- `Start now`
- `Open step`
- `Adjust plan`
- `Why this?`
- `Close the loop`
- `Still Counts`
- `Proof saved`
- `You are in control`

Surface and object phrases:

- `What needs a place?`
- `Does this hold together?`
- `Needs recovery`
- `Needs review`
- `Protected time`
- `Free time`
- `Planning setup`
- `Personal System Center`
- `Schedule & Availability`
- `Planning Defaults`
- `Vacation / Away Time`
- `Automation & Trust`
- `Proof`
- `Receipt`
- `Source`
- `Review`
- `Moved`
- `Waiting`
- `Blocked`
- `Skipped / Not Needed`
- `Life Shape`
- `Mission Control`
- `Step Detail`
- `Step Session`

## Explanation Patterns

Explanations should be compact, inspectable, and grounded:

- `Based on your plan`
- `Based on your schedule`
- `Based on recent choices`
- `Changed by you`
- `You approved this`
- `Source needs review`
- `May need review`
- `Stored on this device`
- `No silent changes`
- `Needs confirmation`

Use `Why this?` to explain the source, assumption, consequence, and available
control. Do not use it as a system-defense essay or model-performance display.

## Recommendation Language

Recommendation copy should describe why something is useful now without
overclaiming certainty:

- use `Recommended step`, not "best next move";
- use `Start here`, not optimization or ranking language;
- use `Based on...` labels for source and context;
- show `Needs review` when source freshness is limited;
- keep user control visible through `Adjust plan`, `Review later`, or
  correction routes.

Recommendations must not use model jargon, hidden personalization claims,
confidence scores, guaranteed outcomes, or fully automated language.

## Recovery And Closure Language

Recovery language should protect agency:

- `Close the loop`
- `Still Counts`
- `Needs recovery`
- `Review later`
- `Blocked`
- `Waiting`
- `Not needed`
- `Moved`
- `What counted?`
- `What changed?`

Avoid success/failure framing for ordinary life drift. A missed plan is a
reality state to resolve, not a character judgment.

## Empty, Edge, And Degraded States

Fallback copy should be clear about what Ambitions can and cannot know:

- first day: explain what to do next without a tutorial wall;
- no source: say the source is missing or needs review;
- stale source: say it may need review;
- unavailable feature: say what still works and what needs human action;
- sensitive/private item: show privacy-safe labels and a route to inspect only
  when appropriate.

## Release-Safe Messaging

PXOS product language may describe future canon after evidence is committed.
It must not claim shipped behavior, production readiness, App Store readiness,
TestFlight readiness, physical-device proof, public accessibility proof,
signed archive proof, App Store Connect proof, platform integration, backend
sync, or AmbitionsOS/Product Depth/PXOS implementation.

## Avoided Language

Avoid:

- `Your best next move`
- `next best move`
- `failed`
- `failure`
- `lazy`
- `behind`
- `streak broken`
- `crushing it`
- `boss mode`
- `AI magic`
- `fully automated`
- `guaranteed`
- unsupported `always` / `never`
- `production ready`
- `App Store ready`
- `TestFlight ready`
- `chatbot`
- generic `command center` / `dashboard`
- productivity jargon
- enterprise OKR jargon
- hustle / grind language
- `maximize yourself`
- casual autopilot language

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

# Trust Explainability and Correction UX Spec

## Purpose

Define the consumer-facing trust model for recommendations, assumptions, freshness, contradictions, corrections, and audit depth.

For continuity, sync-trust, handoff, return, and degraded-sync doctrine, use [../Ambitions_State_Continuity_Mesh.md](../Ambitions_State_Continuity_Mesh.md).

## Core Trust Posture

- calm
- factual
- low-ego
- legible
- progressively disclosed

The app should feel like it is exposing useful reasoning, not defending itself.

## Trust Layers

### Layer 1: Whisper

Default in-line trust hints:

- why this
- based on
- may need confirmation
- updated recently

Trust Whisper must behave like quiet embedded clarity.
It should be present enough to lower doubt and absent enough that the screen never reads like instrumentation.

### Layer 2: Reasoning

Expanded explanation sheet:

- why now
- why this recommendation won
- what was considered
- what remains uncertain

### Layer 3: Audit and correction

Deeper surfaces:

- source context
- contradictions
- recent corrections
- what changed
- freshness or stale-input details

## Confidence Presentation

- confidence must be plain-language first
- examples:
  - strong fit
  - likely fit
  - needs confirmation

Avoid numeric scoring as the primary consumer-facing form.

## Freshness Presentation

- freshness should answer whether the recommendation reflects newer input
- use restrained labels like:
  - updated recently
  - based on older plan context
  - waiting on newer input

Freshness signals may also travel through the Continuity Ribbon when stale truth changes the current best action across surfaces.

## Contradiction Presentation

- contradictions must feel resolvable, not accusatory
- show:
  - what conflicts
  - why it matters
  - what the user can correct

## Correction Flow

### Steps

1. user opens correction or teach action
2. app states the current assumption
3. user changes or confirms the truth
4. app confirms what changed
5. app offers return to the owning context

### Tone

- "Update this"
- "That changes the plan"
- "Use this instead"

Never:

- "Model corrected"
- "Training updated"

## Source Audit Posture

- source audit exists but is not a default visible module on top-level screens
- audit language must remain consumer-grade
- source lists should privilege relevance over raw dump order

## Why Now

Why-now explanations should reference:

- time left
- available room
- pressure
- momentum
- recent drift or recovery if relevant

When surfaced from Quiet Command Sheet, "why now" should open into the owning surface context rather than becoming a detached explanation panel.

## What Changed

This flow should show:

- changed recommendation or plan state
- reason for change
- whether the user, schedule, or new information drove it

## What Assumptions Exist

Assumptions should be grouped by user impact:

- time assumption
- scope assumption
- priority assumption
- freshness assumption

## What Needs Reconciling

When reconciliation is needed, the UI should state:

- what is conflicting
- what outcome depends on it
- what quick action resolves it

## Placement Rules

- Today: whisper only by default
- Goal Detail: whisper plus reasoning plus audit depth
- Plan: whisper plus shaping rationale
- Insights: reflective trust, not technical trust
- Profile: trust center and sync pulse

## Cross-Surface Trust Rules

- Trust Whisper may appear inline, in a continuity ribbon, or inside a shallow sheet depending on urgency and surface density.
- If a trust issue changes the recommended action, the trust signal must be visible before the user commits.
- trust signals must remain consumer-readable inside widgets, notifications, and other external surfaces.
- sync and continuity trust must stay local-first, Apple-account-based for launch direction, and must not imply an Ambitions account, in-app login, third-party analytics, server-side AI over private content, or a public/shared private-data cloud database.

## Correction and Calm Explanation Rules

- explanation should follow action readiness, not precede it
- Recovery Bloom should show the safer path first and the explanation second
- contradiction review should preserve the feeling that truth is being clarified, not litigated

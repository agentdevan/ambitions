# Ambitions State Continuity Mesh

## Purpose And Scope

This document is the Batch 54 continuity contract for Ambitions.

It governs how state, sync trust, provenance, handoff, return, and degraded continuity should behave before external-surface widening.

It does not implement sync, widgets, Live Activities, notifications, App Intents, shortcuts, share extension, Watch, TV, iPad, Mac, or future-device surfaces.

## Source-Of-Truth Position

Use this document with:

- [Ambitions_Full_Frontend_Transformation_Program.md](Ambitions_Full_Frontend_Transformation_Program.md)
- [design/cross-device-surface-roles-spec.md](design/cross-device-surface-roles-spec.md)
- [design/trust-explainability-correction-spec.md](design/trust-explainability-correction-spec.md)
- [../codex/BATCH_REGISTRY.md](../codex/BATCH_REGISTRY.md)

When continuity wording conflicts, use the standing precedence in [../codex/CONTEXT_INDEX.md](../codex/CONTEXT_INDEX.md).

## Core Doctrine

State continuity must stay calm, explicit, and non-admin-heavy.

Ambitions should make continuity feel like preserved context, not like the user is managing infrastructure.

Required doctrine:

- local-first behavior remains the launch posture
- Apple-account-based sync is the launch sync direction, not a Batch 54 backend implementation
- no Ambitions account at launch
- no in-app login at launch
- no third-party analytics at launch
- no server-side AI processing of private user content at launch
- no public or shared cloud database for private life data at launch
- no Ambitions-operated personal-data backend at launch
- personal user data stays on device or in the user's private iCloud or CloudKit storage when Apple sync is later productized
- provenance must survive handoffs without breadcrumb clutter

The current app runtime remains local-first and explicit about local-only sync capability until a later implementation batch changes shipped behavior.

## Continuity Primitives

### Now State Lease

The `Now State Lease` is the bounded claim that a surface may make about the user's current state.

It answers:

- what the app believes matters now
- when that belief was last refreshed
- whether a newer correction, schedule change, or sync state could change the recommendation
- what the safest visible action is if the lease is stale or uncertain

Rules:

- a surface may display current-state truth only while it can explain the state in consumer language
- stale state should degrade into a safer next step, not a technical warning
- external and ambient surfaces must treat Now State as leased, not permanent
- the lease must not expose private content casually on glanceable surfaces
- a lease may be refreshed by local app activity, later Apple-account-based sync, or a preserved handoff, but not by an Ambitions account at launch

Preferred language:

- "Updated recently"
- "Based on your last local plan"
- "This may be older"
- "Open Ambitions to confirm"

Avoid:

- raw timestamps as the first layer
- debug sync states
- claims that imply a hidden cloud account

### Continuity Receipts

`Continuity Receipts` are user-readable confirmations that context survived a handoff, return, correction, or external action.

They answer:

- what moved
- where it came from
- where the user landed
- whether anything changed on the way back

Rules:

- receipts should be brief and momentary unless the state affects the next decision
- receipts should preserve object identity for goals, captures, plan blocks, focus sessions, corrections, and review objects
- receipts should explain source and return context without becoming an audit log
- receipts must not become a notification stack
- receipts should be available to later widgets, Live Activities, notifications, share flows, shortcuts, iPad, Mac, Watch, and TV through the same semantic contract

Preferred language:

- "Returned to the goal you opened from Today"
- "Capture saved locally"
- "Plan changed after your correction"
- "Opened from the latest local state"

### Sync Health Strip

The `Sync Health Strip` is a restrained continuity-health indicator for Profile, Trust, handoff points, and future external surfaces.

It answers:

- whether continuity is local-only, current, pending, stale, unavailable, conflicting, or recovered
- whether the user needs to act before trusting the visible state
- whether Apple-account-based sync, once implemented, is helping or blocked

Rules:

- the strip is not an admin dashboard
- show one important continuity state at a time
- keep the first layer consumer-readable
- use Profile / Trust for deeper sync explanation
- do not imply an Ambitions account, private-data backend, or third-party sync provider
- do not require sync for core local use

Preferred language:

- "Local-first and stable"
- "Waiting to update across devices"
- "This surface may be behind"
- "A newer version needs confirmation"
- "Continuity restored"

### Semantic Conflict Language

Semantic conflict language explains continuity conflicts as user-impacting truth, not storage mechanics.

It answers:

- what is different
- why it matters
- what safe action resolves it

Rules:

- conflicts must feel resolvable, not accusatory
- conflict copy should preserve the user's sense of control
- avoid merge, revision, record, tombstone, server winner, client winner, or other implementation-first wording
- if the conflict changes the recommended action, show the signal before the user commits

Preferred language:

- "A newer correction changed this plan"
- "This version may be older"
- "These two updates need confirmation"
- "Use the newer plan"
- "Keep this local version"
- "Review before continuing"

## Handoff And Return Rules

### Origin Chip

Use an `Origin Chip` when the user lands somewhere from a meaningful source surface.

Rules:

- show source in compact language such as "From Today", "From Plan", or "From Focus"
- never use it as a desktop breadcrumb trail
- remove or collapse it once the source no longer affects confidence or return behavior

### Context Ribbon

Use a `Context Ribbon` when one active continuity signal needs to travel across surfaces.

Rules:

- carry one signal only
- use it for active focus context, recovery posture, critical goal pressure, week-believability carryover, recent correction, or stale-truth reminders
- keep it dismissible when informational and sticky only when structurally important
- never turn it into a scrolling alert stack

### Return Stack Memory

Use `Return Stack Memory` when the app should remember the user's meaningful prior context without showing persistent navigation chrome.

Rules:

- preserve where the user came from and what object they were acting on
- return to the owning context after correction, explanation, capture promotion, external open, or deep-link handoff
- keep return behavior predictable even when the visual breadcrumb is absent
- if state changed during the trip, pair the return with a Continuity Receipt

## Degraded-Sync States

Continuity states should be expressed with these consumer-facing meanings:

- `Local-first`: current app truth is usable from on-device state; sync is not required for core use.
- `Pending`: a local change is waiting to appear elsewhere once Apple-account-based sync exists.
- `Stale`: a visible surface may be older than the owning app state.
- `Unavailable`: continuity cannot refresh right now; local use should continue where possible.
- `Conflicting`: two meaningful versions need confirmation before the app treats either as settled.
- `Recovered`: continuity was restored and the user can trust the visible state again.

These states govern language and behavior.
They do not require Batch 54 to add persistence fields, CloudKit, or runtime sync implementation.

## Surface Rules

- Shell: owns visible continuity pacing, return confidence, and one active Context Ribbon when needed.
- Today: may show the strongest Now State Lease and only the continuity signal that changes today's safest action.
- Goals and Goal Detail: preserve object identity, source, corrections, and return context without breadcrumb clutter.
- Plan: preserves week-shaping provenance and makes stale or changed plan truth clear before commitment.
- Insights: treats continuity as reflective context, not technical sync status.
- Profile / Trust: owns deeper sync posture, local-first explanation, export/import fallback, and future Apple-account-based sync explanation.
- Ambient and external surfaces: inherit this contract later and may not invent separate truth models.

## Batch Ownership

Batch 54 governs:

- State Continuity Mesh doctrine
- Now State Lease semantics
- Continuity Receipt semantics
- Sync Health Strip semantics
- semantic conflict language
- provenance-preserving handoff and return rules
- degraded-sync language and presentation expectations
- local-first plus Apple-account-based sync launch truth
- continuity inheritance rules for shell, ambient, and future-device work

Batch 54 does not implement:

- backend sync
- CloudKit runtime behavior
- Ambitions account or login
- widgets, Live Activities, notifications, or Focus Screenlet
- share extension
- App Intents or shortcuts
- Watch or TV surfaces
- iPad or Mac surfaces
- future-device transport or persistence

## Deferred Batch Mapping

- Batch 55 consumes this contract for widgets, Live Activities, notifications, and Focus Screenlet.
- Batch 56 consumes this contract for share extension, App Intents, shortcuts, routing, and external creation.
- Batch 57 may refine cross-surface command, recall, and ambient coherence, but must not redefine the continuity primitives.
- Batch 58 applies the contract to iPad and Mac surface architecture and first implementation.
- Batch 59 applies the contract to Watch and Apple TV ambient architecture and first implementation.
- Batch 60 validates finish quality, accessibility, performance, and release readiness without reopening this doctrine unless a real implementation contradiction is found.

## Validation Expectations

Batch 54 validation is docs/control validation only unless product code changes are made.

Required checks:

- docs truth and cross-reference review
- registry and program status consistency
- local-first and Apple-account-based sync wording consistency
- no Ambitions account or in-app login contradiction
- no backend, analytics, server-side AI, or shared cloud database contradiction
- deferred external-surface and future-device boundaries remain explicit

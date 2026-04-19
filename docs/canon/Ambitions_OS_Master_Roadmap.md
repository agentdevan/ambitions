# Ambitions OS — Master Roadmap (Ambitions 2.0)

## Status

Ambitions 1.0 is complete through registry Batch 18. That work remains the historical foundation: native SwiftUI app, domain services, persistence, planning/recovery/time foundations, ambient surfaces, sync-trust boundary, life graph/path systems, learning, shared-life context, runtime separation, and a narrow dedicated-device prototype seam.

Ambitions 2.0 is the next major program. It is not a minor patch line and it does not renumber or rewrite the completed Ambitions 1.0 history.

## Mission

Ambitions exists to become a trusted personal operating system for individual life execution.

The 2.0 end-state is a retrieval-backed, path-compiling, energy-aware, explainable, correctable life intelligence runtime. It should understand a person's goals, constraints, knowledge sources, capacity, contradictions, and corrections well enough to shape believable paths through real life.

Ambitions is not a generic to-do app, a corporate task manager, a gamified habit toy, a hardware-first moonshot, or a chat-first AI wrapper.

## Ambitions 2.0 Product Promise

Ambitions should eventually be able to say:

Give me your goal, your real life context, your actual constraints, and your current starting point.
I will tell you what kind of problem this is.
I will tell you what I know, what I am assuming, and what I need to confirm.
I will retrieve current relevant context when the world outside your head matters.
I will compile a believable path.
I will adapt the next move to your actual time, history, and energy fit.
I will keep the path fresh as conditions change.
I will help you move without turning your life into admin.

## Ambitions 2.0 Product Thesis

Ambitions 2.0 should help a person:

1. Turn generalized life goals into structured, believable paths.
2. Ground recommendations in retrievable knowledge with provenance, freshness, and trust signals.
3. Ask clarifying questions when the goal, domain, constraint, or evidence is ambiguous.
4. Compile paths that include milestones, dependencies, resources, risks, and alternative routes.
5. Match plans to energy, capacity, focus fit, and recovery state without pretending to measure fake biometrics.
6. Detect contradictions between user intent, real behavior, known requirements, and system assumptions.
7. Let the user correct and teach the system, then make those corrections durable.
8. Explain why a recommendation exists, what evidence supports it, and what remains uncertain.
9. Integrate the intelligence runtime into product surfaces only after the contracts are stable.

## Core Platform Layers

### Life Graph

The structured model of the user's life:

- ambitions, goals, milestones, tasks, time blocks, rituals
- domains, roles, obligations, relationships, responsibilities
- path branches, dependencies, prerequisites, deadlines, application windows
- support, delegation, household, and care context

### Memory

The durable record of what has happened and what the system has learned:

- goal history and plan changes
- drift, recovery, and execution patterns
- user corrections and preference changes
- energy-fit and focus-fit patterns
- repeated blockers, assumptions, and contradictions

### Knowledge Truth

The retrieval and evidence layer:

- world-knowledge retrieval
- provider boundaries
- source provenance
- freshness and update windows
- trust and quality scoring
- uncertainty labels
- source auditability

Retrieval must improve truth. It must not hide uncertainty behind confident prose.

### Goal Understanding

The interpretation layer:

- generalized goal classification
- domain inference
- constraint extraction
- ambiguity detection
- clarification question generation
- user-answer incorporation

### Path Compilation

The system that turns a goal into a path:

- staged milestones
- prerequisites and dependencies
- resource requirements
- timing windows
- alternative branches
- fallback paths
- domain-specific constraints
- acceptance and readiness criteria

### Resource Graph

The model of useful external and internal resources:

- source entities
- requirements, credentials, courses, guides, organizations, applications, references
- source ranking and trust
- freshness checks
- dependency links to path stages

### Energy and Capacity

The operating system for realistic personal effort:

- capacity budgets
- energy and focus fit
- low-energy/admin/deep-work/creative/social effort shapes
- sustainable pacing
- recovery state
- learned fit from behavior and explicit feedback

Energy should be modeled as fit and capacity, not fake biometrics.

### Contradiction and Correction

The loop that keeps the system honest:

- contradiction detection across goals, behavior, plans, requirements, and retrieved knowledge
- user correction capture
- durable teaching signals
- conflict resolution between old assumptions and new truth
- correction-aware ranking and explanation

The user must be able to correct the system.

### Explainability and Trust

The audit layer:

- why this recommendation exists
- which sources or memories support it
- what is inferred versus known
- freshness and confidence labels
- user-visible correction controls
- privacy and local-first posture

### Runtime Integration

The reusable intelligence boundary:

- service-level contracts for retrieval, understanding, path compilation, energy, correction, and explanation
- runtime-safe snapshots
- local-first degradation
- product-shell adapters
- surface-safe action and audit payloads

## Ambitions 2.0 Phases

### Phase A — Knowledge and Truth Architecture

Build provider, provenance, freshness, trust, and retrieval boundaries before any retrieval-backed recommendation reaches product UX.

Exit criteria:

- knowledge providers are abstracted
- source provenance is captured
- freshness and trust metadata are part of every retrieved claim
- uncertainty can be represented without product-shell improvisation

### Phase B — Goal Understanding and Clarification

Build generalized goal understanding and the clarification engine before compiling paths.

Exit criteria:

- goals can be interpreted across domains
- ambiguities become structured clarification needs
- user answers can update goal understanding deterministically

### Phase C — Path Compiler and Domain Intelligence

Build the path compiler and domain-pack framework before path UX.

Exit criteria:

- a goal can compile into staged path candidates
- domain packs can contribute requirements without owning the whole planner
- compiler output includes assumptions, readiness, dependencies, and fallback branches

### Phase D — Resource Graph and Freshness

Build resource graph, source ranking, update checks, and freshness propagation.

Exit criteria:

- resources can be attached to path stages
- stale evidence can be detected and downgraded
- source ranking is explainable

### Phase E — Energy and Capacity Operating System

Build energy, capacity, fit, pacing, and learning contracts.

Exit criteria:

- path and task recommendations can account for realistic effort fit
- energy signals are explicit, user-correctable, and non-biometric
- ranking can prefer sustainable execution over fantasy planning

### Phase F — Contradiction, Correction, and Teaching Loop

Build contradiction detection, correction capture, and durable teaching before opaque AI behavior spreads.

Exit criteria:

- the system can detect conflicts between plans, behavior, requirements, and user corrections
- corrections update future interpretation and ranking
- teaching history is visible enough to audit

### Phase G — Explainability, Trust Controls, and Runtime Integration

Build source audit, why-this explanations, trust controls, and runtime contracts.

Exit criteria:

- recommendations can explain source, memory, inference, freshness, and uncertainty
- trust controls exist before broad runtime propagation
- intelligence services integrate behind stable runtime contracts

### Phase H — Ambitions 2.0 Product Shell

Integrate the 2.0 intelligence into user-facing product surfaces after the underlying contracts exist.

Exit criteria:

- product surfaces consume stable intelligence outputs
- path, resource, energy, correction, and explanation UX do not invent business logic
- shell behavior remains correctable and auditable

## Ambitions 2.0 Principles

1. Truth before novelty.
2. Retrieval must improve truth, not hide uncertainty.
3. Provenance, freshness, and trust are product requirements, not backend details.
4. Clarify before compiling when the goal is ambiguous.
5. Path UX must trail path compiler contracts.
6. Energy is fit and capacity, not fake biometric certainty.
7. The user must be able to correct the system.
8. Explanations should distinguish known facts, retrieved claims, inference, and assumptions.
9. Hardware and voice follow trust, not the reverse.
10. Runtime propagation follows trust controls, not the reverse.
11. Prefer deterministic boundaries over opaque AI islands.
12. Preserve local-first degradation and user data control.

## Non-Goals

Do not let Ambitions 2.0 become:

- a black-box AI shell
- a source-less recommendation engine
- a generic chat assistant
- a brittle path template library
- a fake-health or fake-biometrics product
- a noisy productivity coach
- a hardware-first or voice-first program before trust exists
- a parallel runtime that bypasses the native Ambitions architecture

## Immediate Ambitions 2.0 Implementation Order

1. Canon reset.
2. Knowledge / provider / provenance / freshness boundary.
3. Understanding and clarification.
4. Path compiler foundation.
5. Domain intelligence packs.
6. Resource graph and freshness.
7. Energy and capacity operating system.
8. Contradiction and correction loop.
9. Explainability and trust controls.
10. Runtime integration.
11. Product shell integration.

## Success Definition

Ambitions 2.0 succeeds when a user can give Ambitions a meaningful life goal and receive a believable, sourced, correctable path that respects reality: requirements, timing, resources, capacity, energy fit, contradictions, and changing life context.

Ambitions becomes a true operating system when it can:

- understand goals beyond narrow task planning
- retrieve and rank trustworthy knowledge
- compile paths with dependencies and alternatives
- adapt to energy and capacity
- explain itself
- accept correction
- propagate intelligence safely across runtime and product surfaces

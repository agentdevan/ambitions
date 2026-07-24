# Ambitions Capability Model

## Purpose

The Capability Model defines the product layer between Ambitions' mission and its detailed requirements.

A capability describes a durable promise to the person using Ambitions. It is not defined by whether current code, a current screen, or a current architecture can fulfill it.

## Primary definition

A capability is:

> A durable, user-facing product promise describing something meaningful Ambitions can enable, understand, generate, protect, simulate, transform, coordinate, or help a person accomplish.

A valid capability remains intelligible when its current UI, algorithm, persistence mechanism, model, or architecture is replaced.

## Capability tests

A candidate is probably a capability when all of the following are true:

1. **Person-facing value:** It produces a meaningful outcome for the person rather than only serving an internal implementation.
2. **Durability:** The promise should survive changes in implementation or presentation.
3. **Distinct meaning:** It expresses a coherent promise that can be distinguished from neighboring promises.
4. **Ownable behavior:** It can eventually have bounded product ownership, requirements, verification, and evidence.
5. **Non-triviality:** It is larger than a single control, field, animation, or incidental action.
6. **Product legitimacy:** It is compatible with the Constitution, local-first law, user control, privacy, accessibility, and native Apple quality.

Failure of one test does not automatically discard the candidate. Ambiguous candidates remain preserved for reconciliation.

## What is not a capability

### Surface

Examples: Today, Goals, Time, You.

A surface owns and expresses capabilities but is not itself a capability.

### Global facility

Examples: Capture, Search, Motion, Trust inspection.

A global facility may contain one or more capabilities. Its existence alone is not the user-facing promise.

### Domain object

Examples: Goal, Goal Path, Step, Attachment, Life Branch.

Objects carry identity and state. Capabilities act through or upon them.

### Runtime or subsystem

Examples: Private Life Runtime, scheduling engine, persistence, local learning.

Systems enable capabilities. They are not automatically capabilities.

### Requirement or invariant

Requirements constrain capability behavior. A single requirement is normally too narrow to be a capability.

### Interaction or visual treatment

Examples: a swipe, button, sheet, Liquid Glass, matched transition, floating dock.

An interaction can be required expression, but the durable promise must be stated independently.

### Implementation mechanism

Examples: SQLite, SwiftData, Core Spotlight, CloudKit, an LLM, embeddings, a reducer, or a file-provider API.

Mechanisms may be mandated by separate platform or architecture law, but do not define the capability's user promise.

### Project, campaign, or implementation task

Planning containers and delivery work are not product capabilities.

## Composition law

Capabilities may relate without being collapsed:

- **depends_on** — one capability requires another to function safely or meaningfully.
- **composes_with** — capabilities combine into a larger experience but remain independently valuable.
- **specializes** — one capability is a narrower form of another.
- **projects_into** — a capability appears within a surface or journey without being owned by that presentation.
- **conflicts_with** — two candidate promises cannot both remain valid without an owner decision.
- **supersedes** — an approved capability explicitly replaces an earlier one while preserving history.

Similarity of wording is not sufficient evidence for merging.

## Independent lifecycle dimensions

Capability state must not be represented by one overloaded status.

### Authority status

- `owner_seed` — directly supplied by the owner, preserved but not yet canonized.
- `repository_candidate` — discovered from repository evidence.
- `proposed` — reconciled proposal awaiting owner decision.
- `canonized` — accepted into normative capability authority.
- `deferred` — intentionally retained but not currently advanced.
- `rejected` — explicitly declined with rationale.
- `retired` — formerly canonical and explicitly superseded or withdrawn.

### Specification maturity

- `unframed` — terminology exists without a stable product promise.
- `framed` — promise, user outcome, and boundaries are stated.
- `architected` — ownership and system boundaries are defined.
- `specified` — normative behavior, states, edge cases, privacy, and accessibility are defined.
- `implementation_ready` — acceptance criteria, proof obligations, and dependencies are complete.

### Implementation status

- `not_assessed`
- `not_started`
- `partial`
- `implemented`
- `superseded_implementation`

### Verification status

- `not_assessed`
- `unverified`
- `behavior_verified`
- `experience_verified`
- `release_verified`

These dimensions are independent. Code can be implemented while the candidate remains non-canonical. A canonical capability can remain unimplemented. Tests cannot promote authority.

## Required canonical capability fields

A future canonical entry must contain:

- Stable `CAP-*` identifier
- Canonical name
- Primary taxonomy category
- Product promise
- User outcome
- Why it belongs in Ambitions
- Example experience
- Explicit non-goals
- Owning product domain
- Supporting systems and objects
- Required personal context
- Privacy/data classification implications
- Accessibility implications
- Authority and maturity states
- Source provenance
- Requirement links
- Surface and journey projections
- Test and proof links where they exist
- Known gaps and owner decisions

## Evidence rules

1. Preserve the exact source terminology alongside normalized names.
2. Record source path and location whenever available.
3. Distinguish normative, accepted reference, historical, implementation, test, and owner-stated evidence.
4. Do not treat repetition as authority.
5. Do not treat code existence as product approval.
6. Do not treat historical supersession as deletion; preserve lineage.
7. Do not silently remove a candidate because it is difficult, expensive, incomplete, or currently unsupported.
8. Mark inferred capabilities explicitly and state the evidence used for the inference.
9. When sources conflict, preserve both and route the conflict to reconciliation.

## Naming law

Canonical names should:

- Describe the durable product promise rather than the current mechanism.
- Use language understandable to product, design, engineering, QA, privacy, and accessibility reviewers.
- Avoid generic category labels such as "AI assistance" when the actual promise is narrower.
- Avoid embedding implementation brands unless native integration with that brand is itself the durable promise.
- Preserve meaningful Ambitions terminology where it carries product law.

## Merging law

Candidates may be merged only when:

- Their user outcomes are materially the same.
- Their boundaries and non-goals do not conflict.
- The merged promise loses no meaningful owner intent.
- Source provenance remains traceable to the merged identity.

Candidates must remain separate when they differ by user outcome, authority, privacy consequence, lifecycle, or proof obligation—even when one depends on the other.

## Retirement law

A canonical capability may be retired only through an explicit owner decision containing:

- Capability ID and name
- Reason for retirement
- Replacement or superseding capability, if any
- Migration and traceability disposition
- Treatment of requirements, surfaces, tests, and implementation
- Effective canon revision

Absence from a generated file, codebase, roadmap, or surface does not retire a capability.

## Product Genome position

The Capability Atlas occupies the stable bridge in this chain:

```text
Vision
  -> Constitution and product principles
  -> Capabilities
  -> Behaviors and requirements
  -> Architecture and objects
  -> Runtime systems
  -> Surfaces and interactions
  -> Tests and evidence
  -> Release state
```

The Product Genome is incomplete when either direction of this chain is not traceable.

# Ambitions Capability Taxonomy

Status: **non-normative Phase C proposal**

This taxonomy organizes intended Ambitions capabilities by durable product meaning. It does not mirror the current root information architecture, implementation modules, or visual system. Assignment to a domain does not canonize a candidate or imply that it is implemented.

## Governing model

Every qualified candidate receives exactly one primary domain. A candidate may reference no more than three secondary domains when those relationships express dependency, projection, or cross-domain consequence rather than duplicate ownership.

A domain must remain meaningful if Ambitions changes its screens, algorithms, storage, or internal architecture. Today, Goals, Time, You, Capture, Search, objects, runtime services, Apple APIs, and design treatments may express or support capabilities, but none automatically becomes a capability domain.

## Domain map

| Domain | Product meaning | Boundary |
|---|---|---|
| `DOM-CONTEXT` | Personal Context, Learning, and Transfer | Learns from or transfers what is understood about the person; does not own the plans or simulations that consume that understanding. |
| `DOM-PATH` | Goals, Paths, and Progression | Owns pursuits and coherent progression; not present execution, exact chronology, or generic storage. |
| `DOM-EXECUTION` | Present Execution and Adaptation | Owns what is actionable now and in-progress adaptation; not full path or schedule ownership. |
| `DOM-TIME` | Time, Capacity, and Reflow | Owns temporal placement, capacity, sequence, and reflow; not goal meaning or hypothetical alternatives. |
| `DOM-SIMULATION` | Simulation and Decision Support | Owns reversible counterfactual exploration and trade-offs; accepted paths transfer to other domains. |
| `DOM-SEARCH` | Search, Command, and Inspection | Owns global discovery, asking, inspection, and invocation; never the returned object's source of truth. |
| `DOM-KNOWLEDGE` | Knowledge, Files, and Attachments | Owns durable information custody and relationships; not external presentation or goal progression. |
| `DOM-SHARING` | Sharing and External Expression | Owns deliberate preparation of content to leave the private Ambitions context. |
| `DOM-IDENTITY` | Identity, Privacy, and Trust | Owns consent, sensitive-data boundaries, explanation, and the person's relationship with the system. |
| `DOM-APPEARANCE` | Appearance and Personal Expression | Owns meaningful person-authored visual expression within native and accessible boundaries. |
| `DOM-RESILIENCE` | Resilience, Recovery, and Continuity | Owns trustworthy behavior under offline, stale, interrupted, conflicted, or recovering conditions. |
| `DOM-CAPTURE` | Capture and Interpretation | Owns fast expression, provisional interpretation, review, and accepted placement. |
| `DOM-CLOSURE` | Reflection, Proof, and Closure | Owns person-facing outcome evidence, reflection, receipts, history, and completed consequence. |
| `DOM-APPLE` | Apple Ecosystem and Automation | Owns native Apple-system reach only when that reach is part of the durable user promise. |

## Domain definitions

### `DOM-CONTEXT` — Personal Context, Learning, and Transfer

**Purpose:** Understand the person over time and use learned patterns, preferences, skills, constraints, and outcomes to improve future support.

**Owns:** personal-context interpretation, local learning, and cross-domain transfer of learned strategies or skills.

**Does not own:** goal-path construction, scenario comparison, privacy settings, or generic model-training infrastructure.

**Anti-overlap law:** This domain owns what Ambitions learns from or transfers about the person. The resulting goal path, simulation, search behavior, or execution behavior remains owned by its primary product domain.

### `DOM-PATH` — Goals, Paths, and Progression

**Purpose:** Help a person form meaningful pursuits, understand the path toward them, and preserve coherent progression across changing circumstances.

**Owns:** goal formation, goal-path generation and revision, dependencies, progression, and canonical path projection.

**Does not own:** present-execution selection, exact scheduling, generic file custody, or counterfactual simulation.

**Anti-overlap law:** The domain owns the pursuit and its path. Execution, time, simulation, and knowledge may support or project that path without acquiring path ownership.

### `DOM-EXECUTION` — Present Execution and Adaptation

**Purpose:** Help a person understand what is executable now, act with appropriate context, and adapt present work without collapsing into a task list.

**Owns:** present-reality orientation, executable-now context, in-progress adaptation, and return-to-work support.

**Does not own:** the full goal path, exact chronology, system-wide recovery mechanics, or retrieval.

**Anti-overlap law:** Use this domain when the durable promise is about acting now. Path, chronology, and degraded-state guarantees remain separate.

### `DOM-TIME` — Time, Capacity, and Reflow

**Purpose:** Help a person place, understand, and revise commitments against real chronology, capacity, dependencies, and disruption.

**Owns:** schedule placement, capacity-aware temporal planning, dependency-aware reflow, and chronological consequence.

**Does not own:** goal meaning, present-execution prioritization, life-path simulation, or import implementation.

**Anti-overlap law:** This domain owns temporal placement and repair. A goal path may depend on Time without transferring path ownership.

### `DOM-SIMULATION` — Simulation and Decision Support

**Purpose:** Let a person explore plausible alternatives, trade-offs, consequences, and uncertainty before committing their real life graph.

**Owns:** counterfactual simulation, scenario comparison, trade-off exploration, and uncertainty-aware decision support.

**Does not own:** committed goal paths, live schedule mutation, recommendation feeds, or unsupported certainty.

**Anti-overlap law:** Alternatives remain hypothetical and reversible here. Accepted decisions transfer to Goals, Time, Execution, or another applicable domain.

### `DOM-SEARCH` — Search, Command, and Inspection

**Purpose:** Let a person privately find, understand, inspect, ask about, and act on Ambitions objects and relationships from a global native command surface.

**Owns:** global retrieval, semantic and exact search, search-to-command action, result inspection, and search-grounded asking.

**Does not own:** capture, canonical object creation, generic chat, or the source-of-truth semantics of returned objects.

**Anti-overlap law:** Search owns discovery and invocation. It never becomes the canonical owner of the object, mutation, or consequence it exposes.

### `DOM-KNOWLEDGE` — Knowledge, Files, and Attachments

**Purpose:** Keep supporting information, files, references, notes, and provenance durably attached to the life objects they inform.

**Owns:** object-attached files, attachment lifecycle, source relationships, and searchable local knowledge.

**Does not own:** goal progression, share presentation, cloud-drive replacement, or public-source research.

**Anti-overlap law:** Use this domain when durable knowledge custody and relationship are primary. Use Sharing when external presentation or transfer is primary.

### `DOM-SHARING` — Sharing and External Expression

**Purpose:** Help a person deliberately transform and share selected Ambitions content while preserving meaning, privacy, provenance, and audience control.

**Owns:** share composition, audience-appropriate transformation, redaction review, and external formats.

**Does not own:** canonical local mutation, general file storage, private-app appearance, or automatic publication.

**Anti-overlap law:** Sharing owns preparation for external expression. Source objects retain their original domain ownership.

### `DOM-IDENTITY` — Identity, Privacy, and Trust

**Purpose:** Give the person legible control over who Ambitions understands them to be, what data exists, how it is used, and why the system acted.

**Owns:** identity and system relationship, privacy boundaries, trust inspection, consent, sensitive-data control, and provenance visibility.

**Does not own:** appearance authoring, search ranking, learning algorithms, or generic settings.

**Anti-overlap law:** Other capabilities may depend on privacy and trust, but they cannot absorb this domain's control and explanation obligations.

### `DOM-APPEARANCE` — Appearance and Personal Expression

**Purpose:** Let a person meaningfully shape Ambitions' visual expression within native, accessible, coherent product boundaries.

**Owns:** first-class appearance authoring, personal visual expression, accessible transformations, preview, and safe application.

**Does not own:** the core visual-system law, shared-document styling, generic theme toggles alone, or information architecture.

**Anti-overlap law:** Person-authored expression belongs here. Design implementation and visual authority remain supporting law, not capability identity.

### `DOM-RESILIENCE` — Resilience, Recovery, and Continuity

**Purpose:** Keep Ambitions understandable and useful through offline operation, stale or partial information, interruption, conflict, failure, and restoration.

**Owns:** offline continuity, failure-safe preservation, recovery, restoration, staleness disclosure, replay, and repair.

**Does not own:** ordinary successful workflows, generic diagnostics UI, feature business rules, or synchronization merely as infrastructure.

**Anti-overlap law:** The degraded-state guarantee is primary here; the capability being protected remains a secondary domain.

### `DOM-CAPTURE` — Capture and Interpretation

**Purpose:** Let a person express something quickly, preserve it provisionally, inspect interpretation, and place it without premature commitment.

**Owns:** global expression capture, provisional interpretation, review, and capture-to-object placement.

**Does not own:** retrieval, content publishing, final path generation, or microphone technology as an end in itself.

**Anti-overlap law:** Capture owns intake until the person accepts placement. Canonical ownership then transfers to the receiving object and domain.

### `DOM-CLOSURE` — Reflection, Proof, and Closure

**Purpose:** Help a person understand what changed, preserve meaningful evidence, reflect on outcomes, and close work without losing history.

**Owns:** completion proof, outcome reflection, person-facing receipts, history, and learned consequence.

**Does not own:** repository audit evidence, analytics dashboards, path creation, or search inspection.

**Anti-overlap law:** Use this domain for completed consequence and reflection, not ongoing execution or governance proof.

### `DOM-APPLE` — Apple Ecosystem and Automation

**Purpose:** Extend Ambitions coherently through native Apple platforms, system surfaces, and user-authorized automation without weakening local-first control.

**Owns:** App Intents and Shortcuts exposure, Spotlight participation, widgets and native surfaces, and experienced cross-device continuity.

**Does not own:** framework choices, generic platform compliance, capabilities merely because they use an Apple API, or unbounded autonomous action.

**Anti-overlap law:** Native ecosystem reach is primary only when it is itself part of the user promise. Otherwise Apple technology remains implementation support.

## Qualified candidate placement

| Candidate | Primary domain | Secondary relationships |
|---|---|---|
| Skill Transference | Personal Context, Learning, and Transfer | Goals, Paths, and Progression; Simulation and Decision Support |
| Contextual Generative Goal Pathing | Goals, Paths, and Progression | Personal Context; Time and Reflow; Simulation |
| Alternate Career Path Simulation | Simulation and Decision Support | Personal Context; Goals and Paths; Time and Capacity |
| Step Placement Reflow | Time, Capacity, and Reflow | Goals and Paths; Present Execution |
| Ambitions Native Search and Command | Search, Command, and Inspection | Identity, Privacy, and Trust; Apple Ecosystem and Automation |
| First-Class Appearance Studio | Appearance and Personal Expression | Identity, Privacy, and Trust |
| First-Class Content Share Studio | Sharing and External Expression | Identity, Privacy, and Trust; Knowledge, Files, and Attachments |
| Goal-Attached File Storage | Knowledge, Files, and Attachments | Goals and Paths; Search and Retrieval |
| Search Find Act Inspect | Search, Command, and Inspection | Identity, Privacy, and Trust |
| Search Find Ask Act Inspect | Search, Command, and Inspection | Personal Context; Identity, Privacy, and Trust |
| Canonical Goal Path Projection Across Surfaces | Goals, Paths, and Progression | Present Execution; Time and Reflow; Search and Inspection |
| Offline Present-Execution Continuity | Resilience, Recovery, and Continuity | Present Execution; Identity, Privacy, and Trust |
| Offline Search Continuity and Repair | Resilience, Recovery, and Continuity | Search, Command, and Inspection; Identity, Privacy, and Trust |

## Current validation state

- Qualified candidates expected: **13**
- Primary assignments: **13**
- Unassigned qualified candidates: **0**
- Duplicate primary assignments: **0**
- Unknown domain references: **0**
- Candidates exceeding three secondary domains: **0**

These values are proposal assertions until the deterministic taxonomy validator is installed and executed in CI.

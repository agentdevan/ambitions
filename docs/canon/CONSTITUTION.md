+++
spec_id = "CONSTITUTION"
title = "Ambitions Constitution"
kind = "constitution"
status = "normative"
owner_domain = "product-and-engineering"
canon_revision = 1
owns_concepts = [
  "accessibility.semantic-equivalence",
  "account.boundary",
  "authority.mission",
  "authority.moat",
  "authority.origin",
  "authority.product-definition",
  "control.force-nothing",
  "control.material-confirmation",
  "control.undo-recovery",
  "data.loss-stop-ship",
  "global.search.private-command-layer",
  "global.trust-ownership",
  "ia.nonroot-ownership",
  "ia.plain-language",
  "ia.root-labels",
  "ia.root-state-invariance",
  "ia.root-surfaces",
  "language.root-labels",
  "mission.anti-metrics",
  "mission.capabilities",
  "mission.capability-meaning",
  "mission.category",
  "mission.core-loop",
  "mission.foundation-runtime",
  "mission.function",
  "mission.hard-red",
  "mission.integration",
  "mission.launch-bar",
  "mission.moat",
  "mission.moat-continuity",
  "mission.naming-stack",
  "mission.non-commodity",
  "mission.origin-outcome",
  "mission.origin-problem",
  "mission.origin-structure",
  "mission.reflow",
  "mission.runtime-relation",
  "mission.success",
  "mission.user",
  "object.canonical-graph",
  "object.future-step-identity",
  "object.goal-lifecycle",
  "object.lifecycle-deletion",
  "object.proof-requirement",
  "object.reminder-completion",
  "object.saved-for-later",
  "object.taxonomy",
  "platform.calendar-replacement",
  "platform.native-iphone",
  "privacy.cloudkit-continuity",
  "privacy.local-authority",
  "privacy.no-account-core",
  "privacy.r2-public-only",
  "privacy.visibility",
  "proof.evidence",
  "proof.figma-authority",
  "runtime.durable-success",
  "runtime.mutation-invariant",
  "runtime.mutation-sequence",
  "runtime.no-direct-write",
  "runtime.source-owner",
  "shell.stage",
  "surface.today-primary-identity",
  "surface.time-external-visibility",
  "surface.you-depth",
]
inherits = []
depends_on = []
source_owners = []
+++

# Ambitions Constitution

This Constitution is the compact, stable product and engineering law of
Ambitions. It preserves the mission, product category, information architecture,
object boundaries, local-first privacy model, user-control rules, runtime
invariants, and native iPhone quality bar. Detailed behavior lives in the owning
specifications and standards listed by `MANIFEST.toml`.

The Constitution describes intended product behavior. Live source, builds,
tests, generated project state, and runtime inspection establish whether that
behavior is implemented correctly. Documentation is neither an authorization
system nor a substitute for executable evidence.

## How to read this Constitution

The controlled modality is part of each law. `MUST` and `MUST NOT` express invariants or hard boundaries. `MAY` permits behavior only inside the stated scope. The prose following a metadata block explains the law and its product consequence. Examples clarify intent but do not narrow an otherwise broader rule. When two laws apply, they are composed unless their scopes truly conflict. Privacy, user control, accessibility, and data integrity are floors: a detailed specification may be stricter, but it cannot waive them by omission.

“Canonical” means there is one accountable owner for intended meaning or mutable state. It does not require one source file, one storage table, one view, or one visual representation. Read projections may be numerous; mutation ownership may not. “Local” means the core private decision and data path does not depend on an Ambitions-hosted service, an external model, or a network round trip. Optional system-owned continuity or external side effects remain governed by explicit boundaries and do not redefine the local owner.

“Proof” has context. User Proof is evidence the user chooses to associate with progress. A Receipt or History entry is system-produced evidence of a mutation. Engineering evidence includes builds, tests, runtime inspection, accessibility checks, security/privacy checks, performance measurements, migrations, and rendered UI. These categories may reference one another, but they do not merge. A photo attached to a Goal does not establish software correctness, and a passing test does not establish that the user accomplished a Goal.

The Constitution also separates stable product boundaries from mutable implementation inventories. The specification atlas defines detailed contracts; source and tests may evolve while preserving those contracts.

# Article 1 — Product definition and interpretation

This article establishes the product reading order. It prevents a routing guide,
implementation artifact, visual board, tracker object, generated report, or
historical document from becoming product law merely because it is newer or
convenient. The Constitution, owning specifications, and engineering standards
form the active product canon and may be edited through ordinary repository
changes.

## LAW-AUTHORITY-PRODUCT-DEFINITION-001 — Product-definition authority

- **Concept:** `authority.product-definition`
- **Modality:** `MUST`
- **Scope:** Interpretation of intended Ambitions product, IA, object, runtime, privacy, platform, and proof law
- **Status:** `normative`
- **Verification:** `CANON-AUDIT-AUTHORITY-001`
- **Supersedes:** none

The Constitution MUST own only stable product and engineering invariants.
Owning specifications and standards refine those invariants without weakening
them. Current source, tests, runtime behavior, and generated project state
determine what works; they do not silently redefine intended product behavior.
Design references and Figma frames refine visual direction only within the
product boundaries defined here.

## AUTHORITY-MISSION-001 — Supreme mission interpretation

- **Concept:** `authority.mission`
- **Modality:** `MUST`
- **Scope:** Every Ambitions product, design, engineering, and QA interpretation
- **Status:** `normative`
- **Verification:** `CANON-AUDIT-MISSION-001`
- **Supersedes:** none

Every Ambitions decision MUST be interpreted through the supreme mission: Ambitions is a private Personal Life OS for contextual life orchestration. A narrower surface, feature, or technical objective may not weaken the integrated movement from intent through context, path, time fit, adaptation, action, proof, and learning. When detailed requirements appear to conflict, the interpretation that preserves private, inspectable, user-controlled orchestration wins unless this Constitution is explicitly changed.

## AUTHORITY-ORIGIN-001 — Origin doctrine boundary

- **Concept:** `authority.origin`
- **Modality:** `MUST`
- **Scope:** Product framing, prioritization, onboarding, language, and experience rationale
- **Status:** `normative`
- **Verification:** `CANON-AUDIT-ORIGIN-001`
- **Supersedes:** none

The sanitized origin doctrine MUST explain why Ambitions exists and whom it serves without exposing private founder details or overriding product law. It preserves the problem of high-agency people having more ambition than operating structure. Origin material may guide priorities, scenarios, and copy, but it MUST NOT expose private personal history. When origin rhetoric conflicts with mission, privacy, root IA, or user control, the stricter constitutional law governs.

## AUTHORITY-MOAT-001 — Moat authority boundary

- **Concept:** `authority.moat`
- **Modality:** `MUST`
- **Scope:** Strategic differentiation, runtime continuity, recommendations, recovery, and anti-commodity review
- **Status:** `normative`
- **Verification:** `CANON-AUDIT-MOAT-001`
- **Supersedes:** none

The Private Life Runtime is the strategic and technical moat only insofar as it serves the mission locally, inspectably, and under user control. Moat doctrine may define continuity, accountability, proof, and recovery obligations, but it MUST NOT override root IA, privacy firewalls, confirmation rules, or data-integrity boundaries. A named runtime, graph, kernel, or source file is not the moat. The moat exists when local history improves fit and continuity through real behavior.

# Article 2 — Product category, mission, and promise

Ambitions is one integrated Personal Life OS, not a bundle of productivity modules. The mission laws preserve the purpose of the product while leaving detailed Today, Goals, Time, You, Capture, and journey behavior to the Atlas. These laws describe the intended product and cannot, by themselves, establish that any capability is implemented, reliable, accessible, private in practice, or ready to release.

## MISSION-CATEGORY-001 — Product category

- **Concept:** `mission.category`
- **Modality:** `MUST`
- **Scope:** Product identity, strategy, design, implementation direction, and public positioning
- **Status:** `normative`
- **Verification:** `CANON-AUDIT-CATEGORY-001`
- **Supersedes:** none

Ambitions MUST be a premium, native iPhone-first, local-first Personal Life OS for contextual life orchestration. It turns meaningful life intent into adaptive, scheduled, recoverable progress while keeping private intelligence inspectable and user-controlled. “Personal Life OS” describes the integrated product category, not an excuse to expose operating-system metaphors, architecture vocabulary, or a dashboard of internals. A task, calendar, reminder, goal, note, habit, or assistant capability is valid only as part of this coherent product.

## MISSION-FUNCTION-001 — Primary function

- **Concept:** `mission.function`
- **Modality:** `MUST`
- **Scope:** The primary outcome Ambitions provides to an individual user
- **Status:** `normative`
- **Verification:** `SCENARIO-ORCHESTRATION-END-TO-END-001`
- **Supersedes:** none

Ambitions MUST convert messy life intent into contextual goal paths, scheduled next actions, adaptive schedule change, recovery choices, proof-backed progress, and user learning. The product must connect what matters with what reality can hold and what can be started next. Screens that separately store tasks, events, goals, or notes do not satisfy this function unless the integrated loop connects them through one canonical local model and humane user control.

## MISSION-NAMING-001 — Strategic naming stack

- **Concept:** `mission.naming-stack`
- **Modality:** `MUST`
- **Scope:** Canon, strategy, positioning, and internal product interpretation
- **Status:** `normative`
- **Verification:** `CANON-AUDIT-NAMING-001`
- **Supersedes:** none

The stable naming stack MUST remain coherent: the product category is Personal Life OS; the strategic thesis is Private Life Orchestration; the primary function is contextual life orchestration; the core capability is generative goal pathing with schedule reflow; and the technical moat is the Private Life Runtime. These terms clarify different layers and MUST NOT be collapsed into competing product identities. Primary UI uses plain object and action language rather than presenting this strategic stack as user-facing architecture.

## MISSION-INTEGRATION-001 — Integrated function

- **Concept:** `mission.integration`
- **Modality:** `MUST`
- **Scope:** Cross-capability product behavior
- **Status:** `normative`
- **Verification:** `SCENARIO-ORCHESTRATION-END-TO-END-001`
- **Supersedes:** none

Ambitions MUST preserve one continuous function: capture intent, understand enough context, route to the correct canonical object, form or refine a path, fit action into time, respond when reality changes, preserve closure and proof, and carry learning forward. No capability may become an isolated mini-app with its own truth, state, or motivation model. The product succeeds through continuity among direction, capacity, action, closure, proof, recovery, and future adaptation—not through the mere presence of feature screens.

## MISSION-LAUNCH-BAR-001 — Integrated launch bar

- **Concept:** `mission.launch-bar`
- **Modality:** `MUST`
- **Scope:** Product-completeness claims about Ambitions' core value
- **Status:** `normative`
- **Verification:** `SCENARIO-ORCHESTRATION-END-TO-END-001`, `PROOF-RELEASE-CLAIM-001`
- **Supersedes:** none

The launch bar MUST be an operating orchestration loop, not a collection of visible destinations or source-present models. Ambitions must safely accept intent, preserve it, establish a useful path, fit an actionable next step into time reality, recover from change, and retain proof and learning. If a required part is absent, untested, or fixture-only, the product is incomplete. Canon may require the bar without pretending current implementation has reached it.

## MISSION-CAPABILITIES-001 — Capability layers serve orchestration

- **Concept:** `mission.capabilities`
- **Modality:** `MUST`
- **Scope:** Tasks, habits, rituals, calendars, reminders, goals, learning, capacity, and assistant-like behavior
- **Status:** `normative`
- **Verification:** `CANON-AUDIT-CAPABILITY-INTEGRATION-001`
- **Supersedes:** none

Ambitions MAY provide mature task execution, recurring intent, scheduling, reminders, goal planning, capacity support, follow-up, and local learning. Each capability MUST serve the Personal Life OS rather than establish a separate product center. Capability breadth is not permission for duplicate objects, duplicate mutation authorities, disconnected navigation, or category drift. A best-in-class foundation and a deep runtime are complementary: foundation behavior prevents daily failure while runtime continuity creates durable direction.

## MISSION-CAPABILITY-MEANING-001 — Capability semantics

- **Concept:** `mission.capability-meaning`
- **Modality:** `MUST`
- **Scope:** Constitutional interpretation of common planning capabilities
- **Status:** `normative`
- **Verification:** `CANON-AUDIT-CAPABILITY-SEMANTICS-001`
- **Supersedes:** none

Capability meanings MUST stay distinct and composable: a Step is an execution unit; recurring intent expresses a habit or ritual; calendar data expresses time reality; a Reminder is a return point; a Goal carries direction and path; energy and capacity constrain fit; learning adjusts future behavior; schedule change reconciles reality; and Proof establishes trustworthy continuity. These meanings may be refined in object specifications, but no implementation may overload one type merely to avoid modeling a real boundary.

## MISSION-RUNTIME-RELATION-001 — Runtime serves the product

- **Concept:** `mission.runtime-relation`
- **Modality:** `MUST`
- **Scope:** Relationship between deep local intelligence and user-facing experience
- **Status:** `normative`
- **Verification:** `SCENARIO-RUNTIME-INSPECTION-001`
- **Supersedes:** none

The Private Life Runtime MUST serve practical object behavior rather than become a destination, diagnostic spectacle, or intelligence dashboard. The user should experience better fit, clearer consequences, preserved progress, and more humane recovery. Deeper reasoning must be inspectable when it matters, but internal graphs, ledgers, kernels, projections, and confidence machinery MUST NOT substitute for understandable user language. Depth belongs underneath plain, native UI.

## MISSION-REFLOW-001 — Schedule adaptation is core

- **Concept:** `mission.reflow`
- **Modality:** `MUST`
- **Scope:** Changes in intent, capacity, commitments, completion, proof, and recovery
- **Status:** `normative`
- **Verification:** `SCENARIO-SCHEDULE-CHANGE-001`
- **Supersedes:** none

Schedule adaptation MUST be a core capability. When reality changes, Ambitions must evaluate protected and fixed boundaries, movable work, capacity, deadlines, dependencies, recovery, and user rules. It may suggest movement, resizing, deferral, or a lighter path, but material near-term consequences require the control laws in Article 4. “Reflow” may remain an internal term; primary copy should describe what will change in plain language.

## MISSION-HARD-RED-001 — Mission drift hard red

- **Concept:** `mission.hard-red`
- **Modality:** `MUST NOT`
- **Scope:** Product center, architecture, positioning, and user-pressure mechanisms
- **Status:** `normative`
- **Verification:** `CANON-AUDIT-MISSION-HARD-RED-001`
- **Supersedes:** none

Ambitions MUST NOT become a task list with decorative goals, a calendar clone, a habit tracker driven by streak pressure, a chatbot-centered planner, a dashboard of life metrics, a generic notes inbox, a social performance surface, or a cloud-backed private-life profiler. It MUST NOT require an account or network for core value, expose opaque recommendations without correction, or treat shame and fake urgency as motivation. Any such center is constitutional drift, not a harmless presentation choice.

## MISSION-ORIGIN-PROBLEM-001 — Core origin problem

- **Concept:** `mission.origin-problem`
- **Modality:** `MUST`
- **Scope:** The enduring user problem Ambitions is designed to solve
- **Status:** `normative`
- **Verification:** `CANON-AUDIT-ORIGIN-PROBLEM-001`
- **Supersedes:** none

Ambitions MUST serve the problem that intelligence and ambition do not automatically create operating structure. A capable person can imagine a meaningful future yet lack a durable sequence, time fit, memory, resources, proof, and recovery system. The product therefore protects direction and follow-through without treating the user as low-agency, deficient, or in need of coercion. It builds operating structure around existing agency.

## MISSION-ORIGIN-OUTCOME-001 — Origin-to-product outcome

- **Concept:** `mission.origin-outcome`
- **Modality:** `MUST`
- **Scope:** User outcomes produced by the integrated product
- **Status:** `normative`
- **Verification:** `SCENARIO-ORIGIN-GOLDEN-001`
- **Supersedes:** none

The product MUST turn meaningful intent into an understandable path, a reality-fit schedule, concrete Steps, timely reminders, inspectable Proof, and a review rhythm that protects adjustment and learning. Those capabilities must help the user build Life Capital: durable knowledge, relationships, health, resources, skills, confidence, and other compounding capacity that improves future choice. Review must connect present evidence to future foresight so the user can see likely consequences, revise direction before drift becomes failure, and understand how current action belongs to a meaningful future. These are stable user outcomes, not a promise that every named feature is currently implemented. The outcome is not maximal throughput. It is durable direction, realistic action, preserved progress, greater future agency, and less dependence on working memory for every commitment and ambition.

## MISSION-FOUNDATION-RUNTIME-001 — Foundation and runtime relationship

- **Concept:** `mission.foundation-runtime`
- **Modality:** `MUST`
- **Scope:** Planning foundation and Private Life Runtime capability
- **Status:** `normative`
- **Verification:** `SCENARIO-FOUNDATION-TO-RUNTIME-001`
- **Supersedes:** none

Ambitions MUST be excellent at reminders, recurring Steps, calendar-grade planning, quick Capture, simple goals, search, notifications, completion, and missed-work recovery while also providing path generation, capacity fit, proof continuity, learning, and adaptation. The foundation is not a disposable MVP layer, and the runtime is not permission to neglect ordinary reliability. Thin use must remain useful; deep use must remain genuinely deep.

## MISSION-ORIGIN-STRUCTURE-001 — Structure, not moral judgment

- **Concept:** `mission.origin-structure`
- **Modality:** `MUST`
- **Scope:** Explanations, recovery, learning, notifications, and product tone
- **Status:** `normative`
- **Verification:** `COPY-NON-SHAMING-001`
- **Supersedes:** none

Ambitions MUST treat the origin problem as missing or mismatched operating structure, not a character flaw or lack of motivation. Recommendations and recovery language should describe observed fit, timing, capacity, or consequence. The product MUST NOT diagnose laziness, anxiety, avoidance, discipline failure, burnout, or commitment from behavioral signals. It may state that a time window has not been holding a Step and offer alternatives the user controls.

## MISSION-SUCCESS-001 — Product success

- **Concept:** `mission.success`
- **Modality:** `MUST`
- **Scope:** Evaluation of long-term product value
- **Status:** `normative`
- **Verification:** `SCENARIO-ORIGIN-GOLDEN-001`
- **Supersedes:** none

Ambitions succeeds when the user can see a meaningful future, understand the path, start what fits, recover when life changes, and retain evidence that progress still counts. Success is not measured constitutionally by task count, schedule density, engagement, streak, model usage, or account conversion. Product metrics may support operations, but they cannot replace the human outcome or pressure the user into behavior that conflicts with reality.

Success evaluation MUST test future intelligence, product, and runtime outcomes against the canonical orchestration scenarios.

## MISSION-USER-001 — Primary user

- **Concept:** `mission.user`
- **Modality:** `MUST`
- **Scope:** Product design and prioritization for the intended user
- **Status:** `normative`
- **Verification:** `SCENARIO-ORIGIN-GOLDEN-001`
- **Supersedes:** none

Ambitions MUST serve high-agency people with more ambition than operating structure: people carrying simultaneous obligations, goals, ideas, constraints, resources, and future possibilities who need a reliable way to connect them. The product should respect intelligence and choice, reduce memory burden, and make unfamiliar paths learnable without condescension. It must support one-Step goals and lifelong direction without declaring either form less meaningful.

## MISSION-MOAT-001 — Private Life Runtime moat

- **Concept:** `mission.moat`
- **Modality:** `MUST`
- **Scope:** Long-term strategic differentiation
- **Status:** `normative`
- **Verification:** `SCENARIO-PRIVATE-LIFE-RUNTIME-DIFFERENTIATION-001`
- **Supersedes:** none

The moat MUST be a local, inspectable, user-controlled continuity that turns intent into reality-fit action and preserves what changed over time. Different local schedules, capacity, protected boundaries, proof, corrections, and recovery state should produce meaningfully different, explainable paths. The moat is not a branded architecture noun, cloud model, hidden profile, or collection of source-present contracts. It requires demonstrated continuity among context, recommendation, action, receipt, replay, and learning.

## MISSION-MOAT-CONTINUITY-001 — Continuity scope

- **Concept:** `mission.moat-continuity`
- **Modality:** `MUST`
- **Scope:** Closure, proof, recovery, recommendations, and corrections over time
- **Status:** `normative`
- **Verification:** `SCENARIO-CONTINUITY-001`
- **Supersedes:** none

Local continuity MUST preserve honest closure state, user-approved Proof, receipts, recovery history, recommendation rationale, and user corrections. Relaunch and replay should not erase the reason a path exists or cause duplicate completion. The user must be able to inspect and, where relevant, correct, reset, archive, or delete learning influences. Continuity that cannot be understood or controlled is not the Ambitions moat.

## MISSION-NON-COMMODITY-001 — Anti-commodity center

- **Concept:** `mission.non-commodity`
- **Modality:** `MUST NOT`
- **Scope:** Product center and primary information architecture
- **Status:** `normative`
- **Verification:** `CANON-AUDIT-NON-COMMODITY-001`
- **Supersedes:** none

Ambitions MUST NOT center generic task management, calendar optimization, notes, habit scoring, chat, social sharing, or productivity reporting. It may match or exceed the ordinary utility of those categories, but its center remains contextual life orchestration: direction connected to path, path connected to time, time connected to action, and action connected to proof and adaptation. Commodity patterns may be implementation tools; they may not become the product idea.

## MISSION-ANTI-METRICS-001 — Anti-metric discipline

- **Concept:** `mission.anti-metrics`
- **Modality:** `MUST NOT`
- **Scope:** Product optimization, user-facing feedback, and recommendation incentives
- **Status:** `normative`
- **Verification:** `CANON-AUDIT-ANTI-METRICS-001`
- **Supersedes:** none

Ambitions MUST NOT optimize the user experience around task throughput without proof, calendar density without capacity fit, generic productivity or life scores, streak pressure, cloud-model engagement, chatbot volume, hidden recommendation acceptance, or account conversion that weakens offline core value. Operational metrics may measure software health and product learning, but user-facing behavior must preserve autonomy, context, humane recovery, and the right to choose a different path.

## MISSION-ORCHESTRATION-LOOP-001 — Complete orchestration loop

- **Concept:** `mission.core-loop`
- **Modality:** `MUST`
- **Scope:** Product mission and every end-to-end orchestration behavior
- **Status:** `normative`
- **Verification:** `SCENARIO-ORCHESTRATION-END-TO-END-001`
- **Supersedes:** `CLAIM-LFT-0070`, `CLAIM-MOM-0005`, `CLAIM-MOM-0053`

Ambitions MUST orchestrate Intent through Context, Path, Placement / Time Fit, Reflow / Recovery, Action, Closure / Proof, and Learning; a shorthand MUST NOT remove or reorder required behavior.

This approved composition allows concise language in UI, plans, or diagrams while preserving the full semantic chain. “Placement” and “Time Fit,” “Reflow” and “Recovery,” and “Closure” and “Proof” express paired responsibilities rather than optional substitutions. Any downstream specification may add detail, but none may omit a stage whose absence would break continuity or user control.

# Article 3 — Root IA and global-system law

The root IA is intentionally small. This article defines ownership, not detailed screen anatomy. Surface specifications may describe states and interactions, but they cannot add a persistent destination, turn global behavior into content, or expose internal branded concepts as primary labels. The shell must remain native and object-led while global actions stay available without duplicating ownership.

## CONST-IA-ROOT-001 — Canonical root law

- **Concept:** `ia.root-surfaces`
- **Modality:** `MUST`
- **Scope:** Persistent root navigation and product routing
- **Status:** `normative`
- **Verification:** `CANON-AUDIT-ROOT-IA-001`
- **Supersedes:** none

Ambitions MUST have exactly four persistent root surfaces: Today, Goals, Time, and You. No fifth persistent destination may be added through a tab, dock item, swipe page, hidden route mode, or compatibility alias. Detailed features and system states belong beneath these roots, in contextual overlays, or in global systems with a single owner. A surface name is product law; an internal type or historical route is not.

## LAW-IA-ROOT-001 — Four-surface invariance

- **Concept:** `ia.root-state-invariance`
- **Modality:** `MUST`
- **Scope:** App shell, root routes, tests, visual authority, and product language
- **Status:** `normative`
- **Verification:** `SCENARIO-ROOT-NAVIGATION-001`
- **Supersedes:** none

Every supported app state MUST preserve Today / Goals / Time / You as the complete root set. Onboarding, permissions, Capture, Search, inspection, full-screen editors, and deep links may temporarily cover or bypass root presentation, but they do not become additional roots. Root controls may adapt for accessibility and education without changing the underlying four destinations. Any test, design, or implementation that requires Motion, Capture, Plan, Profile, Captures, Pulse, or another persistent root is stale or constitutionally invalid.

## LAW-IA-NONROOT-001 — Global non-root ownership

- **Concept:** `ia.nonroot-ownership`
- **Modality:** `MUST`
- **Scope:** Capture, Search, Motion, trust inspection, and cross-surface behavior
- **Status:** `normative`
- **Verification:** `CANON-AUDIT-NONROOT-001`
- **Supersedes:** none

Capture MUST remain the global composer and durable intake boundary, not a tab, inbox, or permanent destination. Motion MUST remain cross-surface behavior that communicates continuity, consequence, recovery, and closure, not a content feed or analytics page. Search MUST remain a global local-first Find / Ask / Act / Inspect system. Contextual trust inspection may be entered from affected objects and You, but it does not become persistent global chrome.

## LAW-SEARCH-PRIVATE-COMMAND-LAYER-001 — Private understanding and command layer

- **Concept:** `global.search.private-command-layer`
- **Modality:** `MUST`
- **Scope:** Global Search identity, local intelligence, action authority, creation routing, inspection, and private-data boundary
- **Status:** `normative`
- **Verification:** `SCENARIO-SEARCH-PRIVATE-COMMAND-LAYER-001`
- **Supersedes:** none

Global Search MUST remain one unified, local-first Find / Ask / Act / Inspect surface and MUST remain fully useful without Ask. Find remains deterministic and offline; optional Ask synthesis remains on device and grounded in privacy-authorized data and approved references; Act proposes rather than silently mutating; Inspect keeps source, privacy, proof, history, and receipt evidence contextual; creation belongs to Capture. Search MUST NOT become a generic AI destination, a hosted-intelligence or cloud-profiling path, or a parallel composer. Search MUST NOT transfer the private life graph. Detailed owning specifications define the exact grounding, evidence, confirmation, persistence, accessibility, degraded-state, and performance contracts without weakening this boundary.

## LAW-IA-PLAIN-LANGUAGE-001 — Plain user mental model

- **Concept:** `ia.plain-language`
- **Modality:** `MUST`
- **Scope:** Root surfaces, primary actions, empty states, notifications, and basic flows
- **Status:** `normative`
- **Verification:** `COPY-PRIMARY-LANGUAGE-001`
- **Supersedes:** none

The user MUST encounter familiar life objects and plain actions rather than architecture taxonomy. Runtime, projection, ledger, kernel, engine, lens, policy, receipt pipeline, and similar internal vocabulary may appear in implementation or deep technical evidence but MUST NOT carry primary UI. When a strategic concept needs product expression, the owning specification must translate it into understandable object state, consequence, and choice.

## LAW-LANGUAGE-ROOT-LABELS-001 — Locked root labels

- **Concept:** `language.root-labels`
- **Modality:** `MUST`
- **Scope:** User-visible naming of persistent roots
- **Status:** `normative`
- **Verification:** `COPY-ROOT-LABELS-001`
- **Supersedes:** none

The only persistent user-facing root labels MUST be Today, Goals, Time, and You. Branded or metaphorical anatomy may inform design and internal implementation, but it cannot replace these labels. Accessibility labels must identify each control unambiguously even when the visual root treatment is icon-only. Localized labels may adapt language while preserving the same four concepts and route ownership.

## LAW-IA-TRUST-001 — Contextual trust ownership

- **Concept:** `global.trust-ownership`
- **Modality:** `MUST`
- **Scope:** Proof, Source, Privacy, History, Receipts, and recommendation rationale
- **Status:** `normative`
- **Verification:** `SCENARIO-TRUST-INSPECTION-001`
- **Supersedes:** none

Trust MUST remain inspectable and contextual. Proof, Source, Privacy, History, and Receipts attach to the object or consequence they explain, with broader controls and archives reachable through You or Search. Trust information must not crowd the first viewport, become a global activity feed, or substitute for the product object. Material changes must still expose enough trust information for informed confirmation and later review.

## LAW-SHELL-STAGE-001 — One native Stage

- **Concept:** `shell.stage`
- **Modality:** `MUST`
- **Scope:** Root composition, drilldown, overlays, and global-system presentation
- **Status:** `normative`
- **Verification:** `SCENARIO-SHELL-OWNERSHIP-001`
- **Supersedes:** none

Ambitions MUST present one native object Stage with adaptive root and drilldown composition. The shell is a product layer, not a bordered wrapper around disconnected screens. Each visible shell concept has one owner, global actions appear once, safe areas and focus remain coherent, and drilldowns use predictable native return behavior. The user sees life objects and consequences, not the architecture used to render them.

## IA-PLAIN-BRANDED-NAMING-001 — Plain root and object naming

- **Concept:** `ia.root-labels`
- **Modality:** `MUST`
- **Scope:** Root navigation, canonical object language, accessibility labels, and internal branded anatomy
- **Status:** `normative`
- **Verification:** `COPY-ROOT-LABELS-001`, `A11Y-ROOT-NAVIGATION-001`
- **Supersedes:** `CLAIM-LFT-0028`, `CLAIM-MOM-0041`, `CLAIM-MOM-0055`, `CLAIM-NAV-034`

Root navigation and canonical objects MUST use plain comprehensible user language; icon-only visual treatment MUST retain accessible labels, and internal branded anatomy MUST NOT silently become product copy.

This approved composition separates visual treatment from semantic naming. It permits restrained branded design internally while requiring every root and primary object to remain understandable without prior knowledge of Ambitions lore. Education, long-press disclosure, and accessibility presentation may reveal visible labels without creating a different IA.

## SURFACE-TODAY-IDENTITY-001 — Today boundary

- **Concept:** `surface.today-primary-identity`
- **Modality:** `MUST`
- **Scope:** Constitutional identity of Today, without detailed surface anatomy
- **Status:** `normative`
- **Verification:** `SCENARIO-TODAY-PRIMARY-OBJECT-001`
- **Supersedes:** `CLAIM-IA-SHELL-SURFACES-0007`, `CLAIM-IA-SHELL-SURFACES-0043`, `CLAIM-IA-SHELL-SURFACES-0052`, `CLAIM-IA-SHELL-SURFACES-0053`, `CLAIM-IA-SHELL-SURFACES-0065`, `CLAIM-LFT-0003`, `CLAIM-LFT-0044`, `CLAIM-MOM-0042`

Today MUST remain an object-led reality surface around now; Start here MUST remain its dominant decision object, and the rolling temporal rail MUST NOT become the surface identity or a backlog.

The detailed Today specification owns eligibility, layout, interaction, and degraded states. Constitutionally, Today is neither a full calendar nor an inventory of everything unfinished. Supporting temporal context exists to improve the decision, not to replace it.

## SURFACE-YOU-DEPTH-001 — You boundary

- **Concept:** `surface.you-depth`
- **Modality:** `MUST`
- **Scope:** Constitutional identity and root depth of You
- **Status:** `normative`
- **Verification:** `SCENARIO-YOU-PRIMARY-IDENTITY-001`
- **Supersedes:** `CLAIM-IA-SHELL-SURFACES-0056`, `CLAIM-IA-SHELL-SURFACES-0063`

You MUST remain a low-scroll, searchable command and trust center; broad statistics MUST NOT dominate the root and MAY appear only as private, inspectable, non-shaming detail.

The owning surface specification may organize account, privacy, automation, learning, data, and diagnostics, but it must preserve a calm primary hierarchy. Statistics support understanding and correction; they do not become a scorecard or social profile.

# Article 4 — User control, confirmation, undo, and recovery

Ambitions can be adaptive only if the user remains the final authority. This article governs material consequences regardless of which surface or system initiates them. It distinguishes suggestions from commitments, lightweight undo from durable rollback, completion from closure, and observed behavior from moral judgment. Detailed journeys may strengthen these rules but cannot weaken them.

## CONTROL-FORCE-NOTHING-001 — User remains final authority

- **Concept:** `control.force-nothing`
- **Modality:** `MUST`
- **Scope:** Goals, Steps, deadlines, priorities, schedule changes, automation, deletion, learning, notifications, and sensitive inferences
- **Status:** `normative`
- **Verification:** `SCENARIO-USER-CONTROL-001`
- **Supersedes:** none

Ambitions MUST preserve meaningful user choice. It may suggest, warn, simulate, protect, schedule within granted authority, and make consequences clear, but it must not force a goal, Step, deadline, priority, pause, deletion, behavioral interpretation, notification style, or automation level. The user can reject a recommendation, accept a visible conflict, choose a different tradeoff, or withdraw delegated authority. Automation is a revocable permission, not ownership of the user’s life.

## CONTROL-MATERIAL-CONFIRMATION-001 — Material consequence confirmation

- **Concept:** `control.material-confirmation`
- **Modality:** `MUST`
- **Scope:** Committed time, due dates, recurrence, protected boundaries, required work, notifications, external writes, deletion, and irreversible data scope
- **Status:** `normative`
- **Verification:** `SCENARIO-MATERIAL-CONFIRMATION-001`
- **Supersedes:** none

Every material change MUST be previewed and confirmed unless the user has explicitly authorized that exact class of change under a clear, revocable rule. The preview must identify affected objects, important tradeoffs, protected or fixed boundaries, external effects, and the available undo or rollback path. Minor suggestions may be applied within approved limits, but uncertainty about whether a consequence is material is resolved in favor of user awareness.

## CONTROL-UNDO-RECOVERY-001 — Undo, rollback, and humane recovery

- **Concept:** `control.undo-recovery`
- **Modality:** `MUST`
- **Scope:** Accepted mutations, missed work, schedule change, deletion, import, conversion, and failure
- **Status:** `normative`
- **Verification:** `SCENARIO-UNDO-RECOVERY-001`
- **Supersedes:** none

Meaningful accepted changes MUST provide a safe reversal or recovery model appropriate to their consequence. Recent lightweight changes may offer short-window undo; durable, destructive, grouped, or external changes require explicit rollback, restore, or reconciliation behavior. Recovery must preserve the last honest state, original input, relevant proof, and the user’s thread of progress. Language must remain truthful and non-shaming, using concrete states such as Still counts, Move it, Blocked, Waiting, Not needed, Review, or Undo where appropriate.

## OBJECT-GOAL-LIFECYCLE-001 — User-controlled Goal lifecycle

- **Concept:** `object.goal-lifecycle`
- **Modality:** `MUST`
- **Scope:** Goal lifecycle, advisory state, closure, archive, and resumption
- **Status:** `normative`
- **Verification:** `SCENARIO-GOAL-LIFECYCLE-001`
- **Supersedes:** `CLAIM-OBJ-002`, `CLAIM-OBJ-038`

Goal lifecycle MUST be user-controlled and distinct from advisory or constraint state; the product MUST use Ended rather than Abandoned and MUST preserve resume, archive, history, and rollback semantics.

Advisory states such as waiting, blocked, recovering, or needing attention may inform the user without silently changing lifecycle. Completion, ending, pausing, archiving, and deletion remain distinct decisions with explicit consequences.

## OBJECT-LIFECYCLE-DELETION-001 — Lifecycle, conversion, and deletion distinction

- **Concept:** `object.lifecycle-deletion`
- **Modality:** `MUST`
- **Scope:** Every canonical object that supports completion, closure, archive, Trash, conversion, recurrence, restore, or permanent deletion
- **Status:** `normative`
- **Verification:** `SCENARIO-OBJECT-DELETION-001`, `SCENARIO-OBJECT-CONVERSION-001`
- **Supersedes:** `CLAIM-LFT-0197`, `CLAIM-OBJ-029`

Completion, closure, archive, Trash, and permanent deletion MUST remain distinct; every supported conversion or deletion MUST preserve or explicitly retire identity lineage, relationships, history, receipts, recurrence scope, and rollback behavior.

The user must understand whether work is done, a loop is closed, an object no longer influences planning, an item is recoverable, or data will be irreversibly removed. A conversion may change role or type only through previewed field and consequence handling.

## OBJECT-PROOF-REQUIREMENT-001 — Proof choice and advance notice

- **Concept:** `object.proof-requirement`
- **Modality:** `MUST`
- **Scope:** User-supplied Proof, completion rules, closure rules, and automatic mutation receipts
- **Status:** `normative`
- **Verification:** `SCENARIO-PROOF-REQUIREMENT-001`
- **Supersedes:** `CLAIM-LFT-0087`, `CLAIM-OBJ-009`, `CLAIM-OBJ-034`, `CLAIM-OBJ-055`, `CLAIM-STB-0500`, `CLAIM-STB-0578`

User-supplied Proof MAY be optional, suggested, or explicitly required before work begins; required Proof MUST NOT appear as a surprise at completion, and system mutation receipts MUST remain a separate automatic obligation.

Proof remains user-approved evidence on the honor system. A requirement may support path integrity without turning Ambitions into a proof-grading or compliance product. Automatic receipts attest to system behavior, not the truth or quality of the user’s evidence.

Historical Proof MUST remain linked to its original context and applicability state; later path or requirement changes MUST describe the new relationship positively without declaring prior user evidence invalid.

# Article 5 — Canonical object-boundary law

The object ecology must be stable enough for identity, history, replay, privacy, import, and projection to remain coherent. Detailed object definitions belong in the Atlas. Constitutionally, the same real-world object cannot become independent copies across surfaces, and a role, state, or visual projection cannot silently acquire a new canonical identity.

## OBJECT-CANONICAL-GRAPH-001 — One canonical local identity graph

- **Concept:** `object.canonical-graph`
- **Modality:** `MUST`
- **Scope:** Canonical objects, surfaces, Search, widgets, App Intents, receipts, and history
- **Status:** `normative`
- **Verification:** `SCENARIO-CANONICAL-IDENTITY-001`
- **Supersedes:** `CLAIM-LFT-0195`, `CLAIM-OBJ-024`

Ambitions MUST maintain one canonical local identity graph; surfaces and search MUST be derived projections or lenses and MUST NOT become independent object stores or mutation authorities.

Every projection must retain enough stable identity and lineage to route actions back to the canonical owner. Read optimization, external presentation, and accessibility alternatives may reshape information without duplicating truth. If a projection cannot identify the canonical object it represents, it cannot offer mutation.

## OBJECT-FUTURE-STEP-IDENTITY-001 — Future Step identity must be singular

- **Concept:** `object.future-step-identity`
- **Modality:** `MUST`
- **Scope:** Future Step canon and any implementation that schedules future path movement
- **Status:** `normative`
- **Verification:** `SCENARIO-FUTURE-STEP-IDENTITY-001`
- **Supersedes:** `CLAIM-OBJ-058`, `CLAIM-STB-0551`

Future Step MUST be specified as exactly one canonical Step role, placement state, path-node subtype, or distinct object before implementation; it MUST NOT create duplicate identity or lineage.

Until the owning object specifications establish that exact boundary, implementation must not invent competing records to satisfy Goals and Time independently. Whatever model is approved must preserve one history, one mutation owner, path relationship, placement consequence, and migration law.

## OBJECT-TAXONOMY-001 — Canonical taxonomy boundary

- **Concept:** `object.taxonomy`
- **Modality:** `MUST`
- **Scope:** All user-meaningful object families and proposed additions to the object model
- **Status:** `normative`
- **Verification:** `CANON-AUDIT-OBJECT-TAXONOMY-001`
- **Supersedes:** `CLAIM-LFT-0193`, `CLAIM-MOM-0010`

The Atlas MUST define exactly one canonical identity boundary for every user object and MUST NOT promote a role, state, projection, or implementation type into a separate object without lifecycle and migration law.

New object types require user meaning, identity, relationships, lifecycle, valid and invalid transitions, deletion and restore behavior, privacy classification, import/export behavior, projections, accessibility, and migration consequences. Naming a struct or visual node is insufficient.

## TIME-EXTERNAL-VISIBILITY-001 — External visibility and capacity distinction

- **Concept:** `surface.time-external-visibility`
- **Modality:** `MUST`
- **Scope:** External-only calendar items before user-approved import or link
- **Status:** `normative`
- **Verification:** `SCENARIO-EXTERNAL-CAPACITY-001`
- **Supersedes:** `CLAIM-LFT-0146`, `CLAIM-STB-0140`

External-only calendar items MUST NOT appear as Ambitions Events before user-approved import or link, but Time MUST preserve an explicit privacy-filtered capacity/review model so hidden commitments cannot silently cause overbooking.

Visibility as a native object and influence on planning capacity are separate decisions. The detailed import journey must give the user inspectable choices and must not leak sensitive external content merely to reserve unavailable time.

## OBJECT-REMINDER-COMPLETION-001 — Reminder acknowledgement is not work completion

- **Concept:** `object.reminder-completion`
- **Modality:** `MUST NOT`
- **Scope:** Reminder lifecycle, notification actions, linked Steps, and recurrence
- **Status:** `normative`
- **Verification:** `SCENARIO-REMINDER-COMPLETION-001`
- **Supersedes:** `CLAIM-OBJ-020`, `CLAIM-OBJ-060`

A Reminder MUST NOT independently complete user work unless canonical law defines its relationship to a Step; notification acknowledgement, linked-Step completion, Reminder state, and recurrence scope MUST remain distinct transitions.

Dismissal, snooze, trigger delivery, acknowledgement, and completion carry different meaning. A convenient notification action cannot fabricate progress, erase a recurring obligation, or bypass the canonical owner of linked work.

## OBJECT-SAVED-FOR-LATER-001 — Durable unresolved input

- **Concept:** `object.saved-for-later`
- **Modality:** `MUST`
- **Scope:** Input intentionally saved without complete typing, placement, or promotion
- **Status:** `normative`
- **Verification:** `SCENARIO-SAVED-FOR-LATER-001`
- **Supersedes:** `CLAIM-LFT-0041`, `CLAIM-LFT-0181`

Saved for Later MUST be a durable, locally recoverable unresolved-input state with explicit reachability and promotion; it MUST NOT become a root Inbox, Today clutter, notes feed, or generic backlog.

Original input must survive interruption and routing uncertainty. Search or contextual review may expose the unresolved state, but only explicit promotion, scheduling, or an earned suggestion may move it into active execution. Durability does not imply a new destination.

# Article 6 — Private Life Runtime and mutation invariants

The runtime may be deep, but its mutation law must be boring, deterministic, and inspectable. This article governs meaningful private-state changes regardless of their entry point. Detailed transaction, journal, storage, projection, side-effect, and repair contracts live in system specifications and standards. Constitutional law names the invariant and canonical owner boundary without claiming current app-wide compliance.

## CONST-RUNTIME-MUTATION-001 — Mutation invariant

- **Concept:** `runtime.mutation-invariant`
- **Modality:** `MUST`
- **Scope:** Every meaningful private life state change
- **Status:** `normative`
- **Verification:** `SCENARIO-RUNTIME-MUTATION-001`
- **Supersedes:** none

Every meaningful state change MUST preserve the semantic sequence Command → Event → Projection → Receipt → Replay. Validation, authorization, rollback preparation, canonical object persistence, history lineage, and side-effect reconciliation refine that sequence and may not be omitted. Parsers, planners, schedulers, Search actions, App Intents, widgets, Share intake, imports, automation, and repair tools all remain subject to the same law.

## LAW-RUNTIME-DURABLE-SUCCESS-001 — Truthful durable success

- **Concept:** `runtime.durable-success`
- **Modality:** `MUST`
- **Scope:** Any action represented to the user as accepted or successful
- **Status:** `normative`
- **Verification:** `SCENARIO-DURABLE-SUCCESS-001`
- **Supersedes:** none

Ambitions MUST NOT report a meaningful mutation as successful until the authoritative local commit is durable enough for replay and the user-visible result accurately represents it. External side effects may remain pending after local acceptance, but their pending, succeeded, failed, or reconciled state must be durable and inspectable. A visual animation, optimistic string, callback, or fixture result cannot substitute for canonical commit evidence.

## LAW-RUNTIME-NO-DIRECT-WRITE-001 — No direct mutation bypass

- **Concept:** `runtime.no-direct-write`
- **Modality:** `MUST NOT`
- **Scope:** Production private-data mutation and adapter behavior
- **Status:** `normative`
- **Verification:** `AUDIT-RUNTIME-DIRECT-WRITE-001`
- **Supersedes:** none

No production surface, feature service, repository convenience, extension, import adapter, external bridge, or repair path MAY directly mutate canonical private state outside the sanctioned runtime sequence. Storage technology is a substrate, not mutation authority. Adapters translate and reconcile; they do not decide policy or independently commit canonical meaning. Any temporary migration shim must be bounded, contain no new policy, and have a named removal target.

## RUNTIME-MUTATION-SEQUENCE-001 — Complete safe mutation sequence

- **Concept:** `runtime.mutation-sequence`
- **Modality:** `MUST`
- **Scope:** Every meaningful state change and every meaningful write
- **Status:** `normative`
- **Verification:** `SCENARIO-RUNTIME-MUTATION-001`, `AUDIT-RUNTIME-DIRECT-WRITE-001`
- **Supersedes:** `CLAIM-LFT-0198`, `CLAIM-RPPS-0002`, `CLAIM-RPPS-0027`, `CLAIM-RPPS-0069`, `CLAIM-STB-0235`

Every meaningful mutation MUST validate and authorize a Command, prepare rollback, durably commit canonical Event and object state, materialize Projections, issue truthful Receipt and History lineage, and produce a replayable result; no adapter or direct write MAY bypass the sequence.

The sequence is semantic rather than permission to create duplicate authorities for each noun. Implementations may atomically coordinate stages, but they must prove ordering, idempotency, failure behavior, and the distinction between local acceptance and external effect results.

## RUNTIME-SOURCE-OWNER-001 — Canonical runtime owner

- **Concept:** `runtime.source-owner`
- **Modality:** `MUST`
- **Scope:** New canonical private-data mutation and storage authority
- **Status:** `normative`
- **Verification:** `AUDIT-RUNTIME-SOURCE-OWNER-001`
- **Supersedes:** `CLAIM-RPPS-0010`, `CLAIM-RPPS-0070`

Canonical private-data mutation and storage authority MUST live under Core/LocalRuntimeOS; Core/Persistence MUST NOT gain new authority and MAY remain only as bounded migration scaffolding with a removal target.

This approved path is a stable owner boundary, not a mutable source inventory or proof that migration is complete. Existing compatibility code may continue only within explicit debt and must not acquire new policy, mutation, projection, receipt, replay, privacy, sync, or repair ownership.

# Article 7 — Local-first, privacy, sync, account, and egress law

Private life context is exceptionally sensitive. Local-first is therefore both a product capability and an authority boundary. This article distinguishes optional identity, private user-owned continuity, public reference infrastructure, and external effects. No network feature may become a disguised private-life backend, and no privacy behavior may exceed what current implementation and tests actually protect.

## LAW-LOCAL-AUTHORITY-001 — Local private-data authority

- **Concept:** `privacy.local-authority`
- **Modality:** `MUST`
- **Scope:** Goals, Life Areas, captures, Steps, Events, Reminders, schedules, proof, receipts, recovery, corrections, and learned behavior
- **Status:** `normative`
- **Verification:** `SCENARIO-OFFLINE-LOCAL-AUTHORITY-001`
- **Supersedes:** none

Core private life data and decision authority MUST remain local by default. The device must be able to accept intent, mutate canonical state, project current behavior, inspect history, and replay without a hosted Ambitions private-data service. Optional continuity or external integration may transport approved data only under its own explicit law; it cannot become the authoritative decision maker for the private life graph.

## LAW-OFFLINE-NO-ACCOUNT-001 — Complete no-account core

- **Concept:** `privacy.no-account-core`
- **Modality:** `MUST`
- **Scope:** Core Today, Goals, Time, You, Capture, Search, closure, proof, and history value
- **Status:** `normative`
- **Verification:** `SCENARIO-OFFLINE-NO-ACCOUNT-001`
- **Supersedes:** none

Ambitions MUST remain fully useful for core value without account sign-in and without network access. Permission denial, unavailable public references, sign-out, or service outage must degrade optional features rather than block local planning and execution. “Offline core” is a required product behavior; current implementation and tests must demonstrate it.

## LAW-ACCOUNT-BOUNDARY-001 — Optional Ambitions Account

- **Concept:** `account.boundary`
- **Modality:** `MUST NOT`
- **Scope:** Ambitions identity, entitlement, support, recovery, and optional network features
- **Status:** `normative`
- **Verification:** `PRIVACY-ACCOUNT-BOUNDARY-001`
- **Supersedes:** none

An Ambitions Account MAY support optional identity, entitlements, subscription, support, account recovery, public-reference access, and future explicitly approved network features. It MUST NOT own, store, synchronize, profile, or infer from the private life graph. Account deletion and local-data deletion remain distinct. Sign-out retains local data unless the user explicitly chooses a separate destructive action with consequence review.

## LAW-R2-PUBLIC-ONLY-001 — Public-reference firewall

- **Concept:** `privacy.r2-public-only`
- **Modality:** `MUST NOT`
- **Scope:** R2, Source Atlas, reference freshness, pack delivery, and related requests
- **Status:** `normative`
- **Verification:** `PRIVACY-R2-EGRESS-001`
- **Supersedes:** none

R2 and Source Atlas MAY store or deliver approved public, reference, provenance, freshness, and non-sensitive access state. They MUST NOT receive, store, infer from, personalize from, or transmit goals, captures, calendar context, schedule assumptions, life areas, Proof, Receipts, closure history, behavior patterns, inferred priorities, private user context, or the private life graph. Public reference is not private intelligence.

## PRIVACY-CLOUDKIT-CONTINUITY-001 — Disabled-until-approved continuity

- **Concept:** `privacy.cloudkit-continuity`
- **Modality:** `MUST`
- **Scope:** Private-graph continuity, CloudKit, Ambitions Account, R2, and offline use
- **Status:** `normative`
- **Verification:** `TEST-CLOUDKIT-CONTINUITY-SAFETY-001`, `SCENARIO-OFFLINE-NO-ACCOUNT-001`
- **Supersedes:** `CLAIM-LFT-0038`, `CLAIM-LFT-0093`, `CLAIM-MOM-0043`, `CLAIM-RPPS-0001`, `CLAIM-RPPS-0014`, `CLAIM-RPPS-0017`, `CLAIM-RPPS-0018`, `CLAIM-RPPS-0050`, `CLAIM-RPPS-0051`, `CLAIM-RPPS-0052`, `CLAIM-RPPS-0053`, `CLAIM-RPPS-0054`, `CLAIM-RPPS-0055`, `CLAIM-RPPS-0056`, `CLAIM-RPPS-0058`, `CLAIM-RPPS-0065`, `CLAIM-RPPS-0067`, `CLAIM-RPPS-0068`

Ambitions MUST remain fully usable locally without an account or network; Ambitions Account and R2 MUST NOT store the private graph, and user-owned CloudKit continuity MUST remain disabled until its explicit privacy, conflict, recovery, migration, and proof requirements are approved and satisfied.

Before continuity is enabled, implementation and executable tests must define and verify data classification, explicit user consent, local source-of-truth authority, encryption and account boundaries, deterministic conflict and merge semantics, tombstones and deletion propagation, restore behavior, sign-out behavior, offline divergence, old-client compatibility, development and production environment separation, schema migration and rollback, privacy and security behavior, failure recovery, and rollback for every enabled path. Product aspiration or existing scaffolding is insufficient.

## PRIVACY-VISIBILITY-001 — Contextual and discoverable privacy

- **Concept:** `privacy.visibility`
- **Modality:** `MUST`
- **Scope:** Global privacy controls and contextual permission, egress, legal, and destructive-data boundaries
- **Status:** `normative`
- **Verification:** `SCENARIO-PRIVACY-INSPECTION-001`
- **Supersedes:** `CLAIM-LFT-0039`, `CLAIM-STB-0179`

You MUST own discoverable global privacy controls, status, and repair; privacy explanation MUST appear contextually at permission, egress, legal, and destructive-data boundaries and MUST NOT become ambient sensitive status or root noise.

The user must be able to understand and change relevant choices without being continuously exposed to private labels or alarming chrome. Contextual explanation should state what is used, what remains available without it, and how to reverse the decision.

# Article 8 — Native iPhone, accessibility, and platform law

Ambitions is a flagship native iPhone product. Native does not mean visual imitation; it means using Apple platform behavior, semantics, accessibility, lifecycle, and interaction ownership unless a custom approach is demonstrably necessary. Platform integration remains a projection or external effect of canonical local state and cannot bypass privacy or mutation law.

## PLATFORM-NATIVE-IPHONE-001 — Native-first implementation

- **Concept:** `platform.native-iphone`
- **Modality:** `MUST`
- **Scope:** iPhone UI, navigation, controls, presentation, motion, haptics, permissions, and Apple ecosystem integration
- **Status:** `normative`
- **Verification:** `STANDARD-NATIVE-IOS-001`
- **Supersedes:** none

Ambitions MUST be implemented as a premium native iPhone-first product. SwiftUI and system-owned navigation, controls, materials, accessibility, and presentation are the default. Custom Stage, UIKit, rendering, or gesture infrastructure must prove a product-law need that native APIs cannot satisfy and must include semantic, reduced-motion, and failure-safe alternatives. Web-app chrome, fake controls, detached panels, and decorative technical theater are constitutionally unacceptable.

## ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001 — Accessibility is equivalent product access

- **Concept:** `accessibility.semantic-equivalence`
- **Modality:** `MUST`
- **Scope:** Every visual, spatial, gestural, temporal, animated, and haptic product behavior
- **Status:** `normative`
- **Verification:** `STANDARD-ACCESSIBILITY-001`
- **Supersedes:** none

Accessibility MUST be a product acceptance requirement from design through proof. Every spatial or visual system needs equivalent semantics, ordered navigation, state, rationale, and actions; drag and resize need accessible alternatives; motion needs Reduce Motion behavior; color needs non-color encoding; and focus must restore predictably. Dynamic Type, VoiceOver, contrast, Reduce Transparency, hit targets, and supported input alternatives are required behavior, not a later compliance pass.

## PLATFORM-CALENDAR-REPLACEMENT-001 — Replacement target and safety boundary

- **Concept:** `platform.calendar-replacement`
- **Modality:** `MUST`
- **Scope:** Ordinary personal calendar planning and claims that Ambitions replaces external calendar tools
- **Status:** `normative`
- **Verification:** `PROOF-CALENDAR-GRADE-001`
- **Supersedes:** `CLAIM-LFT-0031`, `CLAIM-STB-0135`, `CLAIM-STB-0471`

Time MUST target first-class replacement of ordinary personal calendar planning,
but external fallback MUST remain available until calendar-grade behavior,
accessibility, privacy, migration, and performance requirements work in the
supported scope. The owning Time, import, scheduling, platform, and validation
specifications define those requirements.

# Article 9 — Implementation evidence and data safety

Canon states what the product should do. Builds, tests, runtime inspection,
rendered UI, security/privacy checks, migrations, and performance measurements
show whether a change actually does it. This distinction is an engineering
rule, not an authorization or approval process.

## CONST-PROOF-EVIDENCE-001 — Executable evidence establishes behavior

- **Concept:** `proof.evidence`
- **Modality:** `MUST`
- **Scope:** Implementation, runtime, interaction, visual, accessibility, privacy, data integrity, and release behavior
- **Status:** `normative`
- **Verification:** Applicable build, test, runtime, visual, security, privacy, migration, and performance checks
- **Supersedes:** none

Documentation, plans, issue comments, source names, and test names MUST NOT be
treated as evidence that behavior works. A concrete implementation assertion
must be supported by the applicable current build, test, runtime, rendered UI,
security/privacy, migration, data-integrity, accessibility, or performance
result. This law creates no task-start, attestation, reviewer, or wording gate.

## PROOF-FIGMA-AUTHORITY-001 — Figma authority is scoped

- **Concept:** `proof.figma-authority`
- **Modality:** `MUST`
- **Scope:** Figma direction, final visual packages, successor nodes, screenshots, and implementation proof
- **Status:** `normative`
- **Verification:** `PROOF-FIGMA-AUTHORITY-001`
- **Supersedes:** `CLAIM-NAV-127`, `CLAIM-NAV-128`

Figma visual references MUST distinguish a selected direction, a final design
package, and the rendered application. Node `250:104` MUST NOT be treated as the
current target when successor package node `257:93` applies. A design target
guides implementation; rendered behavior and accessibility still require their
applicable engineering checks.

## LAW-DATA-LOSS-STOP-SHIP-001 — Data-loss risk blocks the affected claim

- **Concept:** `data.loss-stop-ship`
- **Modality:** `MUST`
- **Scope:** Persistence, migration, restore, sync, repair, deletion, and any release claim affected by credible data-loss risk
- **Status:** `normative`
- **Verification:** `PROOF-DATA-INTEGRITY-001`
- **Supersedes:** none

Any reproducible path that can silently discard accepted, unsynced, unexported,
or unrestorable canonical user data MUST block the affected release until it is
repaired and covered by executable failure, rollback, migration, and recovery
checks. A successful happy-path build is not sufficient data-safety evidence.

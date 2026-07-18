# Ambitions Canon and Specification System Design

**Status:** Approved design  
**Design selected:** Design A — Markdown-first Specification Atlas with a compiled knowledge graph  
**Owner:** Devan Warner  
**Approval date:** 2026-07-11  
**Target repository:** `agentdevan/ambitions`  
**Primary migration corpus:** Linear document `B1A-D01R — Ambitions Product / IA / Object Model Full Design Spec v3 — Canonical` (`96b93346-271d-46fc-beab-43ff7e286b5d`)  
**Design authority of this document:** Architecture and migration design only. It does not change active product canon, implementation status, Linear status, Figma authority, or release claims.

**Train 5 trust-topology amendment:** `TRAIN5-TRUST-TOPOLOGY-AMENDMENT-2026-07-17`, recorded at `docs/superpowers/amendments/2026-07-17-train-5-trust-topology-amendment.json`, governs Tasks 24–29 where it is more specific than the original Train 5 allocation. The amendment changes sequencing and proof ownership only; it does not change active authority, routing, CI, retained skills, cutover state, or any product/release claim.

**Owner direct-integration override:** `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z` supersedes every protected-branch, required-CI/check, CI-installation, ruleset-inspection, live-boundary activation/no-drift receipt, and post-merge protected-receipt prerequisite for Tasks 24–29. Those controls remain an unimplemented future target and MUST NOT be claimed from this train. Tasks 24–29 may integrate directly only after exact SHA-bound local authorization and verification, one exact high-risk review, an owner-approved break-glass record bound to this decision, and current rollback evidence. Gate B must state `live_enforcement_proven = false` and `post_merge_receipt_required = false`; Task 26 cuts authority and routing without installing protected CI; Gate C still requires exact destructive manifests/dry-runs, rollback, independent review, privacy/security/proof-honesty review, and owner-approved Search frames; Task 29 is limited to compact permanent negatives, one canary, and one regression closeout with no GitHub protection inspection. Final claims explicitly exclude protected enforcement. One reviewable commit per numbered task remains mandatory. Any contradictory Task 24–29 wording below is superseded by this paragraph and the bound amendment record.

Task 24 additionally owns exactly two non-directional canon evidence inputs: `docs/canon/specifications/global/search.md` and `docs/canon/specifications/journeys/search-find-ask-act-inspect.md`. Their content-identity change owns all fourteen `docs/canon/generated/` manifest projections, `docs/canon/generated/codex-consumption-benchmark.md`, plus freshness-only rebinding of `docs/canon/migration/UX_BLUEPRINT.md`, `VISUAL_AUTHORITY_REBASELINE.md`, `ux-blueprint-requirement-dispositions.json`, `ux-blueprint.json`, `visual-authority-r1-node-snapshot.json`, `visual-authority-rebaseline.json`, `docs/canon/registries/command-gate-approval-receipts.json`, and `command-gate-dependencies.json`; Task 24 also owns this five-document topology amendment bundle. After inputs freeze, perform those deterministic rebindings and regenerate the fifteen generated projections exactly once, then require `build --check` Green. Task 25 may not change those inputs or freshness outputs while they remain frozen. Tasks 24–29 use existing task type `release`, budget class `complex`, and exact ceiling `30,000`; `governance` remains unknown and fails `PACK_TASK_TYPE_UNKNOWN`.

---

## 1. Executive decision

Ambitions will replace its distributed truth network with one governed repo authority package:

```text
Compact Constitution
        ↓
Canonical modular Specification Atlas
        ↓
Deterministic canon compiler and traceability graph
        ↓
Task-specific Codex context packs
        ↓
Source / tests / proof
```

The system will be Markdown-first for human and Codex readability, schema-constrained for deterministic validation, and compiled into machine-readable indexes, coverage reports, traceability maps, impact reports, external authority manifests, and bounded Codex task packs.

The Linear v3 canon is the primary migration corpus because it is the latest owner-directed product, IA, and object-model authority and already consolidates Decisions 1–201. It is not the final monolithic file. Its accepted claims will be decomposed into stable constitutional laws and modular specifications, reconciled against other repo, Linear, Figma, source, test, and proof evidence, then superseded.

The migration is fail-closed and destructive only after proof. Existing truth remains active during a shadow migration. Authority cutover occurs only after the new system proves semantic coverage, conflict resolution, traceability, Codex consumption quality, and rollback safety. Superseded authority is then deleted rather than retained in an active archive.

---

## 2. Problem statement

Ambitions has two related problems.

### 2.1 Truth sprawl

Product, design, architecture, engineering, validation, process, and release law are distributed across:

- `docs/truth/**`,
- `docs/constitution/**`,
- `AGENTS.md`,
- root and docs READMEs,
- retained skills and scripts,
- Linear initiatives, projects, issues, documents, comments, and status text,
- Figma files, authority frames, annotations, and handoff boards,
- source comments and tests that encode behavior not fully specified elsewhere.

Several artifacts claim authority, restate the same law, define overlapping precedence, or mix intended product behavior with current implementation state. Reading order and conflict tables reduce some risk but do not create one write authority.

### 2.2 Application specification gaps

Even a strong product canon can leave implementation-critical questions undefined:

- failure and rollback behavior,
- object lifecycle edge cases,
- recurrence exceptions,
- offline and degraded states,
- sync conflict semantics,
- deletion, Trash, restore, and recovery,
- accessibility equivalents for spatial interaction,
- source ownership,
- required tests and proof,
- visual authority and SwiftUI plausibility,
- performance and energy budgets,
- import and external-adapter behavior.

A descriptive wiki page can appear complete while omitting one or more of these requirements. Codex then infers behavior, copies stale implementation, or produces internally plausible but unauthorized solutions.

The target system must solve both problems: one authority model and measurable specification completeness.

---

## 3. Goals

The design must:

1. Establish one repo-owned normative authority package.
2. Preserve human-readable product reasoning and premium iOS design intent.
3. Give every normative requirement a stable, addressable identifier.
4. Give every normalized concept exactly one canonical owner.
5. Separate intended law from current implementation and proof state.
6. Turn the application into a modular, comprehensive specification atlas.
7. Detect missing specifications deterministically.
8. Detect likely conceptual conflicts across repo, Linear, Figma, source, and tests.
9. Present material conflicts to the owner with a reasoned recommendation.
10. Compile bounded, task-specific Codex context packs.
11. Map requirements to source owners, tests, scenarios, visual authority, proof, and current claim state.
12. Support safe, impact-aware future canon amendments.
13. Preserve local-first, privacy, accessibility, native-platform, and proof invariants.
14. Replace the current constitutional control plane after shadow validation.
15. Delete superseded files and downstream duplicate authority after cutover.
16. Prevent authority sprawl from returning through CI and repository policy.
17. Convert ChatGPT intent into a fail-closed, current-task authorization that binds the exact checkout, intake, dependencies, and diff.
18. Preserve protected-branch required CI as a future target while Tasks 24–29 use owner-approved exact SHA-bound local authorization and explicitly do not claim protected enforcement.

---

## 4. Non-goals

This design does not:

- implement or change Ambitions product behavior;
- claim current source matches the v3 canon;
- make any feature Ready For Codex;
- establish Runtime, Interaction, Visual, Accessibility, Privacy, Device, TestFlight, App Store, or Release Green;
- replace Git as the historical record;
- create a cloud-hosted knowledge service;
- make Linear or Figma a canonical write authority;
- require an LLM, network connection, Linear, or Figma for local audit or CI;
- preserve every historical sentence or artifact;
- create an active archive directory for superseded truth;
- use a database as the human-editable source of truth;
- bulk rewrite production Swift during the canon-system build.

---

## 5. Design principles

### 5.1 One write authority, multiple generated views

A single source of truth means one governed write authority and one concept-ownership model. It does not require one physical file.

### 5.2 Law over lore

Normative requirements must be precise, scoped, addressable, and testable. Rationale supports law but cannot become a second source of law.

### 5.3 Product intent and implementation reality are separate

Canon defines what Ambitions must be. Source, tests, logs, screenshots, device evidence, and approval define what Ambitions currently proves.

### 5.4 Human-readable source, machine-readable structure

Markdown is the primary authoring medium. Structured front matter, stable IDs, controlled fields, and deterministic parsing make it enforceable.

### 5.5 One owner per concept

Multiple specifications may inherit or reference a concept. Only one normative artifact may define it.

### 5.6 Compile context instead of asking Codex to browse everything

Codex receives the smallest complete context pack for the task. Full-corpus reading is reserved for canon and audit work.

### 5.7 Deterministic CI, model-assisted product reasoning

The compiler and CI never depend on model judgment. Codex assists with semantic extraction, conflict analysis, and recommendations during migrations and amendments.

### 5.8 Parallelize inspection, serialize authority changes

Independent agents may inspect different domains. One canonical writer integrates approved decisions.

### 5.9 Delete after proven supersession

Git history is the rollback and historical record. Superseded active authority is removed after migration proof.

### 5.10 Fail closed

Unresolved P0 law, missing source ownership, missing UI authority, missing mutation safety, or missing validation blocks Codex readiness for affected work.

### 5.11 Intent is not authorization

ChatGPT expresses intent but cannot authorize implementation. Machine-readable PR intake is untrusted intent only. Project Instructions and skills are not authority. Intake may request scope, files, validation, proof, and claim ceiling, but it cannot carry authoritative owner approval, authorized-file decisions, proof claims, validation results, break-glass permission, or merge permission. A tracked change is authorized only when trusted policy computes authorization from the trusted base branch canon, schemas, task policy/registry, source ownership, trusted state snapshots, and platform-authenticated event/approval provenance, then validates the exact final diff. Any missing, mismatched, revoked, or stale trusted input invalidates authorization.

### 5.12 Protected enforcement is a future target outside Tasks 24–29

The long-term target is protected-branch required CI that independently regenerates authorization from trusted base-owned or externally pinned policy. Owner decision `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z` explicitly excludes that installation and proof from Tasks 24–29. For this train, exact SHA-bound local authorization/finalization, verification, one exact high-risk review, rollback, and the bound owner break-glass record form the integration boundary. This exception creates no claim that protected enforcement exists.

---

## 6. Alternatives considered

### 6.1 Design A — Markdown-first Atlas with compiled graph

Humans and Codex edit schema-constrained Markdown. A deterministic compiler produces machine indexes and task packs.

**Decision:** Selected.

**Why:** Best balance of reviewability, Git ergonomics, product nuance, Codex readability, machine validation, and recoverability.

### 6.2 Design B — Structured-data-first canon

YAML or JSON is the primary source, with generated Markdown.

**Rejected as primary source:** Excellent for registries but weak for nuanced product reasoning, review, and long-form behavior contracts.

### 6.3 Design C — Canonical graph database

A SQLite or graph database owns truth, with generated documents.

**Rejected as primary source:** Poor diffs, opaque merge conflicts, tooling dependency, and reduced manual recoverability. An ignored generated SQLite cache remains permissible.

---

## 7. Target authority model

### 7.1 Normative authority

The only normative root after cutover is:

```text
docs/canon/
```

`docs/canon/MANIFEST.toml` declares every active normative file. A file is not authoritative merely because it contains words such as `truth`, `canon`, `authority`, `constitution`, `doctrine`, `standard`, or `design`.

### 7.2 Authority classes

| Class | Owns | Does not own |
|---|---|---|
| Constitution | Stable product and engineering invariants | Detailed screen behavior, mutable implementation status |
| Specification | Detailed application behavior and object contracts | Current proof or release status |
| Standard | Cross-cutting quality and engineering obligations | Product-specific object ownership unless delegated |
| Decision docket | Temporary unresolved proposal and impact analysis | Active law before approval |
| Generated projection | Indexes, task packs, reports, maps | Hand-edited authority |
| Source and tests | Current implementation reality | Intended product law |
| Linear | Execution, status, risk, acceptance, proof links | Product law |
| Figma | Approved visual authority and evidence | Product IA, runtime, privacy, or release law |
| ChatGPT handoff and PR intake | Untrusted intent only and requested scope | Owner approval, authorized scope, proof, validation result, merge permission, or canon |
| Project Instructions and skills | Non-authoritative routing and procedural adaptation | Product law, task authorization, or merge permission |

### 7.3 Precedence

After cutover:

```text
Owner-approved current user instruction
→ docs/canon/CONSTITUTION.md
→ owning canonical specification or standard
→ approved amendment integrated into canon
→ generated task pack for the current canon revision
→ implementation issue acceptance packet
→ source, tests, and current proof for implementation claims
```

Source may reveal that implementation differs from canon; it does not silently amend canon.

This precedence establishes meaning, not implementation permission. Current task authorization regenerated from the exact checkout and intake gates tracked changes but has no normative rank and cannot override any item above.

---

## 8. Repository structure

```text
docs/canon/
├── MANIFEST.toml
├── CONSTITUTION.md
├── specifications/
│   ├── app/
│   │   ├── shell.md
│   │   ├── navigation.md
│   │   ├── launch-and-setup.md
│   │   ├── permissions.md
│   │   ├── degraded-states.md
│   │   └── deep-linking.md
│   ├── surfaces/
│   │   ├── today.md
│   │   ├── goals.md
│   │   ├── time.md
│   │   └── you.md
│   ├── global/
│   │   ├── capture.md
│   │   ├── search.md
│   │   ├── trust-inspection.md
│   │   └── motion.md
│   ├── objects/
│   │   ├── life-area.md
│   │   ├── goal.md
│   │   ├── goal-path.md
│   │   ├── step.md
│   │   ├── event.md
│   │   ├── reminder.md
│   │   ├── note.md
│   │   ├── saved-for-later-draft.md
│   │   ├── proof.md
│   │   ├── attachment.md
│   │   ├── closure.md
│   │   ├── schedule-placement.md
│   │   ├── notification-rule.md
│   │   ├── receipt.md
│   │   ├── history-event.md
│   │   ├── source-reference.md
│   │   ├── recovery-segment.md
│   │   └── import-diff-record.md
│   ├── journeys/
│   │   ├── capture-to-placement.md
│   │   ├── goal-creation-and-activation.md
│   │   ├── start-and-complete-step.md
│   │   ├── closure-and-proof.md
│   │   ├── schedule-reflow.md
│   │   ├── missed-work-recovery.md
│   │   ├── external-calendar-import.md
│   │   ├── search-find-act-inspect.md
│   │   └── backup-restore-reset.md
│   └── systems/
│       ├── private-life-runtime.md
│       ├── persistence-and-replay.md
│       ├── local-learning.md
│       ├── scheduling-and-capacity.md
│       ├── privacy-and-data-classification.md
│       ├── sync-and-continuity.md
│       ├── notifications.md
│       ├── apple-ecosystem.md
│       ├── source-atlas.md
│       ├── diagnostics.md
│       └── import-export-repair.md
├── standards/
│   ├── native-ios-engineering.md
│   ├── swiftui-and-design-system.md
│   ├── accessibility.md
│   ├── copy-and-state-language.md
│   ├── performance-and-energy.md
│   ├── security-and-privacy.md
│   ├── testing-and-fixtures.md
│   └── validation-and-release.md
├── decisions/
│   ├── open/
│   └── SUPERSESSION_LEDGER.toml
├── references/
│   ├── chatgpt-project-instructions.md
│   ├── skill-dependencies.json
│   └── validation-command-manifest.json
├── schemas/
│   ├── manifest.schema.json
│   ├── specification.schema.json
│   ├── requirement.schema.json
│   ├── authority-reference.schema.json
│   ├── task-pack.schema.json
│   ├── trusted-event.schema.json
│   ├── approval-attestation.schema.json
│   ├── validation-attestation.schema.json
│   ├── ruleset-evidence.schema.json
│   ├── task-intake.schema.json
│   └── task-authorization.schema.json
└── generated/
    ├── CODEX_START_HERE.md
    ├── CHATGPT_CODEX_HANDOFF.md
    ├── AUTHORIZATION_GATE_TRANSITION.md
    ├── github-authorization-boundary.json
    ├── INDEX.md
    ├── canon-index.json
    ├── concept-ownership.json
    ├── requirement-graph.json
    ├── specification-coverage.md
    ├── unresolved-conflicts.md
    ├── law-source-map.json
    ├── law-test-map.json
    ├── law-proof-map.json
    ├── visual-authority-manifest.json
    ├── external-reference-impact.md
    └── supersession-manifest.json
```

Generated task packs and caches remain ignored:

```text
.codex/canon-packs/
.codex/task-authorization/
.codex/task-finalization/
.codex/canon-cache.sqlite
.codex/canon-migration/
```

`AUTHORIZATION_GATE_TRANSITION.md` and `github-authorization-boundary.json` are generated evidence projections listed by the manifest and reproduced by `build --check`; neither is normative authority. The transition document is deterministic transition/rollback evidence. The GitHub boundary projection validates and renders separately acquired live evidence; it cannot query or manufacture live state.

---

## 9. Compact Constitution design

The Constitution owns only stable laws.

Recommended articles:

1. Authority, interpretation, and amendment.
2. Product category, mission, and promise.
3. Root IA and global-system law.
4. User control, confirmation, undo, and recovery.
5. Canonical object-boundary law.
6. Private Life Runtime and mutation invariants.
7. Local-first, privacy, sync, account, and egress law.
8. Native iPhone, accessibility, and platform law.
9. Proof, evidence, status, and release-claim law.
10. Canon evolution, ownership, and destructive supersession.

Target properties:

- 40–80 stable laws.
- Approximately 8,000–15,000 words.
- Readable end-to-end by a senior contributor.
- No mutable source-path inventory.
- No current test or issue status.
- No copied Figma board description.
- No repeated surface behavior.
- No implementation-completeness claim.
- No separate engineering constitution that can become a parallel root.

Detailed Today, Time, Goal, Capture, sync, and journey behavior belongs in the Atlas.

---

## 10. Canonical document format

### 10.1 Front matter

TOML front matter is selected because Python 3 can parse it with the standard library and it remains readable in Markdown.

```markdown
+++
spec_id = "SURFACE-TODAY"
title = "Today"
kind = "surface"
status = "normative"
owner_domain = "product"
canon_revision = 1

owns_concepts = [
  "surface.today.primary-identity",
  "surface.today.temporal-scope",
  "surface.today.execution-eligibility",
  "surface.today.resting-states"
]

inherits = [
  "MISSION-001",
  "IA-ROOT-001",
  "USER-CONTROL-001",
  "OFFLINE-CORE-001"
]

depends_on = [
  "OBJECT-STEP",
  "OBJECT-EVENT",
  "OBJECT-REMINDER",
  "JOURNEY-RECOVERY"
]
+++
```

### 10.2 Requirement block

Every normative requirement uses a stable heading and controlled metadata:

```markdown
## TODAY-IDENTITY-001 — Primary identity

- **Concept:** `surface.today.primary-identity`
- **Modality:** `MUST`
- **Scope:** Today root at rest
- **Status:** Normative
- **Verification:** `SCENARIO-TODAY-001`, `SCENARIO-TODAY-004`
- **Supersedes:** `DECISION-044`, `VSP-TODAY-LEGACY-003`

Today presents the user’s actionable reality around now.

The rolling prior-24-hour and next-24-hour rail is temporal anatomy
supporting that identity. It does not make Today a timeline, backlog,
calendar clone, or project-inventory surface.
```

### 10.3 Allowed modalities

```text
MUST
MUST NOT
SHOULD
SHOULD NOT
MAY
INFORMATIONAL
```

P0 and hard-red behavior must use `MUST` or `MUST NOT`.

### 10.4 Stable ID law

- IDs are globally unique.
- IDs are never reused.
- Clarifications may retain an ID only when semantics do not change.
- Semantic changes supersede the old ID and create a new ID.
- Structural file moves retain IDs and concept ownership.
- Removed IDs remain only in the supersession ledger.
- Section numbers and decision numbers are provenance, not durable references.

---

## 11. Concept ownership

Every normalized concept has exactly one owner.

Examples:

```text
surface.today.primary-identity
surface.time.external-event-visibility
object.step.lifecycle
object.event.capacity-behavior
journey.capture.proposal-flow
system.sync.conflict-resolution
standard.accessibility.spatial-equivalence
standard.proof.visual-green
```

Rules:

1. A concept key appears in exactly one `owns_concepts` list.
2. Other files may inherit or reference the concept.
3. A reference cannot weaken or redefine the owning requirement.
4. Scope-specific exceptions live with the owning concept or use an explicitly linked exception requirement.
5. The compiler rejects ambiguous or duplicate ownership.
6. Model similarity may suggest likely duplicates, but the deterministic registry decides exact ownership.

This is the primary anti-sprawl mechanism.

---

## 12. Specification completeness profiles

The compiler validates required coverage by specification kind.

### 12.1 Surface profile

A surface cannot be `Spec Ready` without:

- purpose and user question;
- entry and exit paths;
- route and presentation behavior;
- objects displayed;
- resting states;
- loading and transitional states;
- empty and degraded states;
- commands and user actions;
- durable mutation effects;
- failure and rollback behavior;
- offline behavior;
- privacy and data classification;
- accessibility and reading order;
- Dynamic Type behavior;
- Reduce Motion and Reduce Transparency;
- copy and state language;
- visual authority;
- source ownership;
- test scenarios;
- proof obligations;
- performance expectations.

### 12.2 Object profile

An object cannot be `Spec Ready` without:

- stable identity;
- user meaning;
- relationships;
- lifecycle;
- valid transitions;
- invalid transitions;
- commands;
- recurrence and scheduling behavior where applicable;
- deletion, Trash, restore, and archive behavior;
- history and receipts;
- privacy and sync classification;
- import/export behavior;
- projection surfaces;
- accessibility representation;
- source and test ownership.

### 12.3 Journey profile

A journey cannot be `Spec Ready` without:

- trigger and starting state;
- preconditions;
- happy path;
- branches;
- cancellation;
- interruption and resume;
- commit boundary;
- failure path;
- recovery;
- undo or rollback;
- receipts and proof;
- accessibility;
- offline behavior;
- scenario tests.

### 12.4 System profile

A system cannot be `Spec Ready` without:

- responsibility and non-responsibility;
- inputs and outputs;
- authority boundary;
- data classification;
- state model;
- failure and recovery;
- local-first and network boundary;
- deterministic behavior requirements;
- observability;
- source ownership;
- tests and proof;
- performance and resource constraints.

### 12.5 Explicit not-applicable rule

A required cell may be `not_applicable` only with a rationale and owner. Empty fields, `TBD`, and implied behavior fail audit.

---

## 13. Gap model

The compiler reports distinct gap classes.

### 13.1 Canon-to-code gap

Canon requires behavior with no current source or test mapping.

### 13.2 Code-to-canon gap

Source implements meaningful product behavior without accepted specification. Disposition must be:

- add to canon,
- classify as implementation detail, or
- remove as unauthorized behavior.

### 13.3 Figma-to-canon gap

An approved frame introduces a control, route, object, state, or behavior not defined in canon.

### 13.4 Linear-to-canon gap

Active work references stale, missing, or superseded law.

### 13.5 Internal specification gap

Examples:

- happy path exists but failure path is missing;
- object exists but deletion semantics are absent;
- command exists but receipt or rollback is unspecified;
- standard text state exists but accessibility stress state is missing;
- sync exists but conflict behavior is undefined;
- visual authority exists but source ownership is absent.

### 13.6 Severity

```text
P0_BLOCKER
P1_REQUIRED
P2_IMPROVEMENT
INFORMATIONAL
```

A P0 gap blocks affected `Spec Ready` and Ready For Codex promotion.

---

## 14. Compiler architecture

### 14.1 Package structure

```text
tools/ambitions_canon/
├── __init__.py
├── cli.py
├── model.py
├── parser.py
├── manifest.py
├── registry.py
├── graph.py
├── audit.py
├── build.py
├── query.py
├── coverage.py
├── impact.py
├── task_pack.py
├── migration.py
├── conflicts.py
├── external_authority.py
├── authorization.py
├── skill_conformance.py
├── purge.py
└── render.py

scripts/
└── ambitions-canon.py

tests/canon/
├── test_parser.py
├── test_manifest.py
├── test_registry.py
├── test_graph.py
├── test_audit.py
├── test_coverage.py
├── test_impact.py
├── test_task_pack.py
├── test_authorization.py
├── test_skill_conformance.py
├── test_conflicts.py
└── test_purge.py
```

The thin script delegates to the typed package.

### 14.2 Core commands

```bash
python3 scripts/ambitions-canon.py audit
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
python3 scripts/ambitions-canon.py query --id TODAY-IDENTITY-001
python3 scripts/ambitions-canon.py query --concept surface.today.primary-identity
python3 scripts/ambitions-canon.py coverage
python3 scripts/ambitions-canon.py traceability --check
python3 scripts/ambitions-canon.py impact --base origin/main
python3 scripts/ambitions-canon.py pack --scope surface.today
python3 scripts/ambitions-canon.py pack --issue-json .codex/intake/AMB-1842.json
python3 scripts/ambitions-canon.py task start --intake-json .codex/intake/AMB-1842.json
python3 scripts/ambitions-canon.py task finalize --authorization .codex/task-authorization/AMB-1842.json
python3 scripts/ambitions-canon.py skill-conformance --check
python3 scripts/ambitions-canon.py conflicts report
python3 scripts/ambitions-canon.py amend scaffold --concept surface.today.primary-identity
python3 scripts/ambitions-canon.py authority-sprawl --check
python3 scripts/ambitions-canon.py purge plan
python3 scripts/ambitions-canon.py purge verify
```

### 14.3 Deterministic outputs

The build must be reproducible from tracked source:

- sorted output;
- stable serialization;
- explicit schema versions;
- source canon SHA;
- compiler version;
- no timestamps in content-addressed outputs unless isolated in non-diff metadata;
- no network or model calls;
- atomic file replacement;
- `build --check` verifies a clean generated state.

### 14.4 Generated cache

An ignored SQLite cache may support fast local queries. It must be disposable and reproducible. It cannot contain unique authority.

---

## 15. Deterministic audit and model-assisted reasoning

### 15.1 Deterministic audit detects

- missing required files;
- malformed front matter;
- duplicate IDs;
- duplicate concept ownership;
- unknown dependencies;
- cycles;
- invalid modalities;
- contradictory exact requirements;
- missing completeness-profile fields;
- missing required verification;
- stale generated output;
- superseded IDs still referenced;
- missing source/test/proof/Figma mappings;
- forbidden authority outside `docs/canon/`;
- Linear or Figma manifests referencing unknown requirements.

### 15.2 Codex-assisted semantic analysis detects candidates

- different wording expressing the same concept;
- competing primary identities;
- general law versus exception;
- product target versus implementation status;
- visual interpretation versus product law;
- later correction versus earlier decision;
- object-boundary conflict;
- lifecycle conflict;
- privacy or sync boundary conflict;
- behavior encoded only in source or tests;
- accepted concepts missing from the proposed Atlas.

Model output is advisory. Material decisions require owner approval or an already explicit owner decision.

---

## 16. Conflict docket

Every material conflict uses one temporary docket:

```text
Conflict ID
Concept key
Why the conflict is conceptual

Claim A
Source
Date and authority
Intended user consequence

Claim B
Source
Date and authority
Intended user consequence

Compatibility analysis
Can both remain under explicit scopes?

Recommendation
Keep A / Keep B / Compose / Reject both

Proposed canonical requirement
Product impact
Architecture impact
Privacy impact
Accessibility impact
Figma impact
Linear impact
Source and test impact

Superseded artifacts
Owner decision
```

Codex must recommend a winner or a stronger composed law. It must not merely list differences.

Resolved docket files are deleted after integration. The compact supersession ledger records:

- conflict ID;
- old IDs;
- resulting ID;
- decision date;
- owner;
- commit;
- superseded artifacts.

---

## 17. Primary migration corpus

The Linear v3 document is the primary migration corpus.

### 17.1 Why it is primary

It is the newest owner-directed canonical product, IA, and object-model specification, covers Decisions 1–201, and already contains:

- product identity and moat;
- root IA;
- shell and route behavior;
- Today, Goals, Time, and You boundaries;
- Capture and Search;
- contextual Trust;
- system and Apple ecosystem layers;
- canonical object taxonomy;
- object-boundary matrices;
- lifecycle semantics;
- local-first, CloudKit, account, R2, and Source Atlas boundaries;
- mutation law;
- accessibility and quality acceptance;
- downstream Feature boundaries.

### 17.2 Why it is not final

It remains too broad for default Codex context, mixes constitutional and detailed specification material, names related authorities, and cannot deterministically expose all missing implementation contracts.

### 17.3 Import law

Before migration:

1. Export the complete document losslessly.
2. Verify title, entity ID, update time, owner, and revision.
3. Preserve raw export in ignored migration state and a checksum in tracked migration evidence.
4. Decompose it into atomic claims.
5. Map every claim to a target law, specification, standard, provenance-only record, conflict docket, or rejection.
6. Do not delete or archive the Linear source until coverage and owner review are complete.

### 17.4 Preliminary conflicts requiring dockets

At minimum:

- Today primary identity versus temporal rail;
- long orchestration loop versus shortened v3 loop;
- mutation sequence and the role of validation/history;
- explicit CloudKit private-graph continuity versus earlier prohibition language;
- first-class calendar replacement target versus staged implementation and proof status.

These must be resolved conceptually, not through string precedence.

---

## 18. Codex consumption

### 18.1 Thin front door

`AGENTS.md` becomes a compact routing contract after cutover. It does not repeat the Constitution.

A read-only nontrivial task may begin with a pack. Every task that may create a tracked change begins with deterministic authorization:

```bash
python3 scripts/ambitions-canon.py task start \
  --intake-json .codex/intake/AMB-1842.json
```

`task start` validates the intake, computes the current bindings, runs skill conformance, generates the bounded pack, and writes an ignored local authorization envelope. Before commit or review, the task must finalize:

```bash
python3 scripts/ambitions-canon.py task finalize \
  --authorization .codex/task-authorization/AMB-1842.json
```

`task finalize` revalidates every binding and authorizes only the exact final diff and changed-file set. Pack-only commands remain available for read-only planning and inspection but never authorize source edits or merge.

### 18.2 Task-pack contents

```text
Canon revision and source SHA
Authorization schema and compiler version
Task-intake digest
Starting Git SHA and pre-existing diff digest
Requested scope and requested changed-file set
Trusted event and approval provenance
Task type and scope
Applicable constitutional laws
Applicable specifications
Object lifecycles
Relevant journeys
Cross-cutting standards
Current source owners
Current implementation posture
Known risks and issues
Visual authority
Required tests
Required validation
Required proof
Computed authorized changed-file set
Required CI-owned validation attestations
Skill dependencies and dependency digests
Forbidden changes
Open conflicts
Claim ceiling
Rollback requirements
```

### 18.3 Context targets

| Pack type | Target |
|---|---:|
| Root routing digest | 1,000–2,000 tokens |
| Mechanical task | 4,000–8,000 tokens |
| Normal feature leaf | 8,000–16,000 tokens |
| Complex runtime or SwiftUI task | 16,000–30,000 tokens |
| Release-proof task pack | Complex; exact estimated-token ceiling of 30,000 tokens |
| Constitutional audit | Explicit full-corpus workflow |

The release-proof classification is the only budget amendment. `PACK_BUDGETS` remains exactly `mechanical=8_000`, `normal=16_000`, `complex=30_000`, and `constitutional-audit=None`. The task-type map remains exactly `mechanical→mechanical`, `docs→normal`, `release→complex`, `swiftui→complex`, `runtime→complex`, `privacy→complex`, and `constitutional-audit→constitutional-audit`. `governance` remains unknown and fails with `PACK_TASK_TYPE_UNKNOWN`; the speculative `governance: normal` mapping is not approved and MUST NOT survive into Task 24 or any later integrated state.

### 18.4 Resume guard

After interruption, compaction, or resume, Codex regenerates the pack from base-trusted revisioned snapshots and, where required, platform-authenticated attestations for:

- current canon revision;
- current Git SHA and diff;
- current issue data;
- current source ownership;
- current known issues and proof state;
- current conflict state;
- current skill dependency registry and retained-skill state.

A stale pack never authorizes source edits. Resume requires a new `task start`; finalization must bind the current canon revision, trusted Git event/local-mode state and exact diff, request intake, trusted issue/source-ownership/known-issues/proof/conflict snapshots, current skill dependency state, and any required authenticated approval. Intake cannot declare any of those trusted states current.

### 18.5 Readiness stops

Codex stops before implementation when:

- required conflict is unresolved;
- an issue references a superseded requirement;
- behavior lacks an owning specification;
- a mutation lacks durable commit, receipt, replay, or rollback rules;
- UI work lacks required visual authority;
- source ownership is unresolved;
- required validation is unspecified;
- a P0 specification gap affects scope.

### 18.6 Task intake and authorization contracts

`task-intake.schema.json` defines the machine-readable handoff boundary as untrusted intent only. Required request fields use `requested_*` names: stable task/intake ID, `requested_task_type`, `requested_scope`, `requested_requirement_ids`, issue reference, `requested_changed_files`, `requested_validation`, `requested_proof`, `requested_rollback`, `requested_claim_ceiling`, and requested skill adapters. ChatGPT, a contributor, or PR prose may prepare this intake. Intake MUST NOT contain or imply authoritative owner approval, computed file authorization, validation results, proof claims, break-glass permission, or merge permission.

`task-authorization.schema.json` defines the deterministic computed result and distinguishes every requested field from trusted output such as `computed_authorized_files`, computed required checks, computed proof obligations, and computed maximum claim ceiling. `task start` derives those outputs only from trusted base branch canon, schemas, task policy/registry, source ownership, base-trusted state snapshots, and trusted platform records. It binds the intake digest, canon/source/policy/schema revisions, ownership and skill-registry digests, trusted snapshot digests, and `trusted_event_provenance`. Contributor fields cannot override computed results.

When policy requires owner-gated or break-glass approval, authorization consumes a separate platform-authenticated approval attestation. The attestation binds repository identity, PR/task/intake ID, base SHA, head SHA, intake digest, approval policy and revision, authenticated owner principal, exact approved scope, one-time-use state, expiry, and revocation state. The protected platform record—not PR prose, intake JSON, or ChatGPT identity—is approval provenance. Missing, expired, revoked, reused, scope-mismatched, or unavailable trusted approval/state projection fails closed.

`task finalize` recomputes all trusted bindings and records the exact final diff digest and sorted computed changed-file set. It rejects a changed request, changed trusted state, missing or stale platform event/approval provenance, missing CI-owned validation attestations, or a diff outside `computed_authorized_files`. Envelopes and finalization receipts are ignored, deterministic, sorted, UTF-8, newline-terminated, atomic, timestamp-free, and contain no unique authority.

### 18.7 Skill dependency conformance

The canonical `references/skill-dependencies.json` registry maps each retained procedural skill to stable canonical requirement IDs, declared dependency paths, dependency digests, schema/compiler compatibility, and its allowed adapter purpose. Retained skills carry this metadata but do not copy law. `skill-conformance --check` runs offline and deterministically; it rejects missing, undeclared, stale, circular, or authority-bearing skill dependencies. Project Instructions and skills are not authority and cannot widen an intake, waive a gate, or substitute for current canon.

The exact ChatGPT Project Instructions are stored as governed reference material in `references/chatgpt-project-instructions.md`. Their byte-for-byte SHA-256 is recorded and verified in generated `CHATGPT_CODEX_HANDOFF.md`; changing those bytes requires the governed amendment path and regeneration. The generated handoff explains the intent-to-intake-to-authorization flow without becoming a second authority root.

### 18.8 Independent CI regeneration and bypass law

The merge-authorizing check receives machine-readable PR intake as untrusted intent and receives trusted event bindings from the GitHub control plane: immutable repository ID and name, PR number, base ref and SHA, head SHA, and merge base. None may come from intake. Authorization fails on repository mismatch, missing Git objects, base movement, force-push/head replacement, or a merge base inconsistent with the trusted event.

Exact authorization computes `merge_base_sha = git merge-base(trusted_base_sha, trusted_head_sha)`, verifies it matches trusted event provenance, then compares the tree at `merge_base_sha` with the tree at `trusted_head_sha`. `trusted_base_sha` remains independently bound for base-drift detection; any base, head, or merge-base change invalidates authorization and requires regeneration. The synthetic GitHub merge commit is a separate compatibility result and is never the authority delta.

The canonical base-to-head tree delta is normalized path-by-path from Git tree entries, independent of Git command version, configuration, rename threshold, or copy heuristic. The rule is absolute: do not infer rename or copy. A move is deterministic delete/add; a copy is an add. There are no paired old and new paths: each raw path has one old/new entry tuple. Each changed record binds base64url-encoded raw path bytes plus an optional non-authoritative UTF-8 display, status derived only from entry presence/equality, old and new modes, old and new object type, old and new object IDs, and blob sizes where applicable. Blobs are opaque blob object IDs/sizes; no textual or binary heuristic affects authority. Symlinks and submodule gitlinks are distinguished by Git mode, and mode-only changes remain explicit records.

Records sort lexicographically by unsigned raw path bytes; a record with the same raw path has exactly one old/new tuple. The tree-delta digest is SHA-256 over UTF-8 canonical JSON with sorted object keys, records in that raw-byte order, no insignificant whitespace, and one terminal newline. Local worktree `task start`/`task finalize` mode binds local HEAD plus starting/final working-tree entries and is advisory for contributor discipline. CI PR-range mode binds the trusted immutable base/head/merge-base trees and alone may support merge authorization; the modes share entry normalization and hashing but cannot substitute for one another.

### 18.9 Trusted verifier boundary

The merge-authorizing validator, schemas, task policy, and workflow logic execute from the trusted base branch or an externally pinned immutable digest. The trust-boundary workflow uses base-owned `pull_request_target` or an equivalent mechanism with least privilege, read-only contents, no secrets, and no execution or import of PR-controlled code. PR checkout is data only. Untrusted PR test jobs may execute PR code but cannot emit the merge-authorizing check.

Required-check identity binds workflow path/ref/digest and expected GitHub check-run/integration identity, including app identity, not only a mutable display name. Any mismatch fails closed.

### 18.10 Offline freshness and trusted state

For offline authorization, `current` means an exact base-trusted, revisioned repository snapshot or a platform-authenticated attestation bound to the trusted event. Current issue, ownership, known-issue, proof, conflict, skill, Linear, Figma, and approval state must be materialized through a separate trusted sync/approval step with revision and digest before authorization. CI performs no network, model, or cloud lookup. It never treats intake digest or contributor assertions as external freshness. Missing projection or any snapshot revision/digest change invalidates authorization. The compiler may prove consistency of provided bytes; it cannot claim live external freshness.

### 18.11 CI-owned validation and proof attestations

Intake may request expected validation but cannot prove it. Trusted authorization derives required validation from a base-owned or immutably pinned command manifest and validation workflow. Every consumed result binds validation workflow path/ref/digest, command-manifest digest, exact command/check ID, repository, base/head/merge base, task authorization, integration identity, exit status, artifact digest, skipped/not-run reason, and proof/claim ceiling. The trusted workflow emits the machine-readable CI-owned validation attestation only for that exact tuple. Finalize consumes only matching Green required attestations and rejects missing, stale, contributor-authored, mismatched-head, wrong-digest/integration, skipped-required, or non-Green evidence.

PR-controlled workflows cannot satisfy required validation even when GitHub reports them Green. PR code may be the test subject only inside a least-privilege, no-secrets trusted validation job; it cannot supply or edit the workflow, validation policy, or commands that approve it. Untrusted PR jobs remain advisory and cannot be re-attested into authority.

Workflow order is: trusted start and requirements derivation → required validation → CI-owned attestations → exact-diff finalize → skill conformance/build/audits as applicable. Local validation is advisory and cannot authorize merge.

### 18.12 Tasks 24–29 direct-integration transition and break-glass

The two-stage protected gate-change protocol remains an unimplemented future target. Tasks 24–29 do not install protected CI, switch or inspect a ruleset, require a post-merge receipt, or claim live enforcement. They integrate directly under owner decision `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z` only after exact SHA-bound local authorization/finalization, verification, one exact high-risk review, and current rollback evidence.

Train 5 preserves one program train but has three integration boundaries. Task 24 is a shadow-only verifier-foundation commit and reviewed foundation PR. It owns the reusable Gate B verifier, `task_pack.py` budget/freshness contract and its exact schema/permanent tests, closed registry, benchmark harness and exact fixtures, fixed benchmark policy, and closed legacy-audit invariant-parity policy needed by Task 25. It may also bind the validation command manifest and modify `task-authorization-policy.json` only if Gate B requires a byte change. Exact Task 24 files, fixture paths, folded permanent repair-test owners, `TASK_24_IMPLEMENTATION_REPORT.md`, and ignored `.superpowers/sdd/progress.md` are listed in the Train 5A plan; broad fixture staging is forbidden. Task 24 remains non-authoritative and MUST NOT change `authority_state`, `AGENTS.md` routing, retained skills, replacement CI, protected ruleset state, or cutover state. Its reviewed bytes must merge before Task 25 begins. Reuse bounded patches from the frozen speculative Task 24 and Task 25 candidates; do not repair, test, or merge those branches in place.

Task 25 is proof/generated-output-only. It MUST execute the already-integrated Task 24 verifier bytes and MUST NOT introduce or modify verifier, schema, policy, registry, CLI, fixture, or test behavior. Its tracked files are limited to `docs/canon/generated/cutover-readiness.md`, `docs/canon/migration/purge-plan.toml`, deterministic generated outputs changed by frozen inputs, and `docs/canon/migration/TASK_25_IMPLEMENTATION_REPORT.md`; `.superpowers/sdd/progress.md` remains ignored. Gate B must be Green and approved before Task 26 changes authority, routing, or retained skills. That decision covers Task 26 authority/routing cutover only, requires `live_enforcement_proven = false` and `post_merge_receipt_required = false`, and keeps destructive and purge approvals false, Gate C Red, and purge-scope approval deferred. Task 26 installs no protected CI. One reviewable commit per numbered task remains mandatory.

Task 25 derives the exact required visual screen, state, journey, object, accessibility-variant, and visual-requirement set from the merged canon, UX, and visual ledgers; derives review dimensions from fixed merged policy; requires `figma-design-export` evidence bound to Figma file key, node ID, frame version, artifact bytes/digest, and the merged visual ledger; and remains Red for every `gap_blocked_state_ids` entry. It runs the base-owned old audit and requires a closed one-to-one legacy-audit invariant-parity registry with no missing, duplicate, unknown, or weaker mapping. It requires and parses all five replacement commands: audit, build check, P0 coverage, traceability, and authority sprawl. It binds real rollback evidence, uses bounded reads and explicit timeouts, and never upgrades design-authority evidence into simulator, runtime, device, accessibility, or release proof.

The exact Tasks 25–26 range integrates directly after exact local authorization/finalization, one exact high-risk review, rollback, and the owner decision are current. Task 26 changes canon authority and repo routing only. No workflow installation, GitHub protection inspection, live-boundary activation, or post-merge receipt is required or produced, and protected enforcement remains unproven.

Tasks 27–29 continue as Train 5B from integrated Task 26 main in a separate reviewed commit range. Task 27 removes approved bypass paths in bounded reviewed batches. Task 28 is unchanged. Task 29 retains compact permanent negatives including the Task 24 topology repairs, runs exactly one end-to-end canary and one qualifying regression, and performs no GitHub protection inspection or no-drift receipt work. It records owner break-glass decision `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z`, exact reviewed SHA, rollback, `live_enforcement_proven = false`, and the explicit protected-enforcement exclusion.

Every Task 24, Task 25, and Task 29 Python proof command is pinned to `python3.12`. Each task's durable evidence records the exact interpreter version and executable identity with the commands, exit codes, and results.

Tasks 24–29 require current task authorization/finalization, exact SHA verification, one exact high-risk review, and rollback before direct integration. Owner decision `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z` is the scoped break-glass record and authorizes no reusable or routine bypass. Reuse, ordinary routing outside Tasks 24–29, scope drift, missing review, or missing rollback fails closed. Gate B and Gate C cannot waive retained authorization, Critical/Important repair, security/privacy/proof honesty, owner-approved Search frames, or exact destructive manifests/dry-runs; protected CI is outside their current scope.

---

## 19. Traceability and implementation reality

The system maintains:

```text
Requirement
→ canonical source owner
→ current implementation path
→ focused test
→ scenario
→ visual authority where applicable
→ proof artifact
→ current claim status
```

Current implementation state is generated from live evidence:

- source tree;
- project configuration;
- tests;
- validation logs;
- evidence manifests;
- known issues.

It is not manually maintained as product truth.

A missing mapping does not prove missing implementation. It creates an explicit traceability gap that must be inspected.

---

## 20. Linear projection

Linear owns execution, not canon.

Every Project, Parent Feature, and Codex leaf uses:

```text
Canon revision:
Applicable constitutional laws:
Applicable specifications:
Requirements implemented:
Requirements preserved:
Source owners:
Acceptance scenarios:
Validation:
Proof:
Known gaps:
Rollback:
```

Linear may own:

- status;
- priority;
- dependencies;
- risk;
- assignee;
- acceptance state;
- proof links;
- implementation gaps;
- owner review.

Linear may not restate as independent truth:

- mission;
- root IA;
- object definitions;
- lifecycle;
- privacy law;
- runtime invariants;
- surface behavior;
- engineering standards.

Canon amendments generate an impact report. Codex proposes tracker repairs; it does not silently bulk rewrite Linear.

---

## 21. Figma projection

Figma owns approved visual authority and evidence.

Every authority frame must reference:

```text
Visual authority ID
Canon revision
Applicable requirement IDs
Frame version
Owner approval
SwiftUI plausibility classification
Accessibility variants
Implementation status
```

Figma may own:

- geometry;
- visual hierarchy;
- component composition;
- adaptive layout;
- material and motion demonstrations;
- accessibility variants;
- visual proof;
- owner-approved visual decisions within product law.

Figma may not independently own:

- root IA;
- object taxonomy;
- runtime behavior;
- privacy boundaries;
- source ownership;
- implementation or release status.

A canon change marks affected Figma references stale until reviewed.

---

## 22. Amendment workflow

A temporary amendment contains:

```text
Problem
Affected concept keys
Current requirements
Proposed requirements
Rationale
Alternatives
Superseded requirements
Specification impact
Source and test impact
Figma impact
Linear impact
Privacy, accessibility, and performance impact
Migration
Rollback
Owner approval
```

### 22.1 Amendment classes

**Clarification:** Semantics unchanged; ID retained.

**Semantic amendment:** User-visible behavior, ownership, constraints, or acceptance changes; old ID superseded, new ID created.

**Structural refactor:** File layout changes; IDs and concept ownership retained.

**Removal:** ID retired and never reused; all references resolved before merge.

### 22.2 Impact gate

Before merge, the compiler reports:

- affected specifications;
- source owners;
- tests and scenarios;
- proof obligations;
- Figma authority;
- Linear work;
- generated packs;
- new specification gaps.

The amendment cannot merge while unresolved P0 dependents remain.

---

## 23. Migration phases

### Phase 0 — Freeze and baseline

- Freeze new truth, canon, constitution, doctrine, and authority documents.
- Freeze new Figma `AUTHORITY` frames except explicit repair.
- Record baseline commit and rollback tag.
- Export the complete v3 document.
- Inventory repo, Linear, and Figma authority.
- Record inbound references and current generated checks.
- Do not change active authority.

### Phase 1 — Compiler foundation

- Add schemas and manifest.
- Add parser and typed models.
- Add deterministic audit.
- Add malformed-canon fixtures.
- Establish generated-output determinism.
- Keep current constitutional audit active.

### Phase 2 — Shadow Atlas

- Create target structure.
- Import the v3 corpus first.
- Assign provisional IDs and concept keys.
- Produce coverage and provenance reports.
- Do not switch authority.

### Phase 3 — Full claim ingestion

- Extract claims from repo truth and constitution files.
- Extract Linear documents, descriptions, comments, and owner decisions.
- Extract Figma authority semantics.
- Inspect material behavior encoded only in source and tests.
- Build the normalized claim graph.

### Phase 4 — Conceptual reconciliation

- Generate conflict dockets.
- Run parallel read-only domain reviews.
- Run one synthesis pass.
- Bring material decisions to the owner.
- Integrate approved outcomes.

### Phase 5 — Canon and Atlas synthesis

- Write the compact Constitution.
- Complete surface, object, journey, system, and standard files.
- Remove internal duplication.
- Validate concept ownership.
- Run independent semantic-loss review.

### Phase 6 — Specification completion

- Run completeness profiles.
- Identify P0 and P1 gaps.
- Resolve or explicitly block gaps.
- Prevent `Spec Ready` where required contracts are absent.

### Phase 7 — Traceability and Codex packs

- Map requirements to source, tests, scenarios, Figma, proof, and issues.
- Generate bounded task packs.
- Benchmark representative product, SwiftUI, runtime, privacy, accessibility, and release tasks.

### Phase 8 — Dual-run gate

Both systems coexist temporarily.

Before this phase, Task 24's independently reviewed shadow verifier foundation is merged without changing active authority, routing, retained skills, replacement CI, or cutover state. Task 25 executes only those merged verifier bytes and contributes proof/generated output, not verifier behavior.

Required proof:

- every active old authority has a disposition;
- no accepted unique concept is lost;
- every active requirement has one owner;
- generated output is reproducible;
- external references resolve;
- representative Codex tasks receive correct packs;
- ChatGPT handoff produces schema-valid intake but cannot self-authorize;
- intake is untrusted request-only data and cannot supply owner approval, authorized scope, proof, validation result, break-glass, or merge permission;
- trusted GitHub repository/PR/base/head/merge-base bindings and required platform approval attestations are provenance-complete;
- canonical tree-entry deltas cover raw-path bytes, delete/add move normalization, copy-as-add, opaque blobs, symlinks, mode changes, submodule gitlinks, deletions, merge commits, synthetic merge compatibility, base movement, and force-push/head replacement;
- missing or stale intake and stale envelopes fail closed;
- resume regenerates authorization from current state;
- final diff and changed files are exact and declared;
- skill dependency freshness is proven;
- all eight representative task scenarios pass `task start` and `task finalize`;
- local packs, envelopes, and receipts cannot self-authorize; exact local authorization/finalization is independently checked against the reviewed SHA;
- the owner decision, exact tree delta, one exact high-risk review, and rollback bind the same frozen candidate;
- the exact visual coverage set and fixed review dimensions are derived from merged ledgers/policy, not caller assertions;
- every accepted visual artifact uses `figma-design-export` evidence bound to its Figma and artifact identity, and no gap-blocked state remains;
- the base-owned old audit runs and a closed legacy-audit invariant-parity registry maps every old invariant exactly once to equivalent-or-stronger coverage;
- all five replacement commands are parsed as Green: audit, build check, P0 coverage, traceability, and authority sprawl;
- rollback is proven by a bound rollback receipt or equivalent executable restore evidence, not a prose token;
- verifier reads are bounded and verifier-controlled subprocesses have explicit timeouts.

This proof is Gate B. Gate B remains hard Red until every item is Green, current, and independently reviewed. Task 26 cannot start while Gate B is Red.

Any owner approval recorded by Task 25 is explicitly `owner_gate_b_task_26_authority_routing_cutover_approval`: it covers Task 26 authority/routing cutover only under `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z`. It records `live_enforcement_proven = false`, `post_merge_receipt_required = false`, destructive approval and purge approval as false, purge-scope approval as deferred to Gate C, and Gate C as Red.

### Phase 9 — Authority/routing cutover by direct integration

One controlled cutover boundary from merged Task 24 plus reviewed Task 25 proof:

- switch `AGENTS.md` to generated routing;
- require `task start` and `task finalize` for every tracked change;
- reduce retained skills to non-authoritative procedural adapters with canonical dependency metadata;
- generate `CHATGPT_CODEX_HANDOFF.md` and verify the governed ChatGPT Project Instructions SHA-256;
- make `docs/canon/` the only normative path;
- record cutover commit and canon revision;
- mark old authorities superseded for the cutover boundary only.
- integrate each numbered task as one exact reviewed commit after SHA-bound local authorization/finalization, one exact high-risk review, rollback, and owner decision `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z`;
- install or inspect no protected CI, required check, branch rule, or ruleset;
- record `live_enforcement_proven = false` and `post_merge_receipt_required = false`;
- keep Gate C Red until rollback, privacy/security/proof-honesty review, owner-approved Search frames, and exact destructive manifests/dry-runs are Green.

### Phase 10 — Destructive purge

After Train 5A direct integration and Gate C approval for the retained destructive controls:

- delete old truth files;
- delete separate engineering constitution and article shards;
- delete old hand-maintained registries;
- delete stale skills, old handoff documents, compatibility routers, and every authorization bypass path named by the purge manifest;
- archive or delete superseded Linear canon documents after extraction;
- remove copied canon prose from active Linear objects;
- consolidate and delete superseded Figma authority;
- rewrite all inbound references;
- retain no active archive directory.

### Phase 11 — Anti-regression and closeout

- retain a compact deterministic set of permanent authorization, proof-honesty, destructive-manifest/dry-run, rollback, privacy/security, Search-frame, amendment, and deleted-authority negatives;
- run the eight representative scenarios inside exactly one qualifying regression;
- run exactly one end-to-end ChatGPT-to-Codex canary;
- perform no GitHub protection, ruleset, required-check, activation, or no-drift inspection;
- record owner break-glass decision `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z`, exact reviewed SHA, and rollback;
- record `live_enforcement_proven = false` and explicitly exclude protected enforcement from final claims;
- record the Python 3.12 interpreter version and executable identity in the durable Task 29 closeout evidence;
- publish evidence-bounded closeout;
- do not claim implementation or release Green from governance completion.

---

## 24. Replacement of the current constitutional audit

The existing `scripts/ambitions-constitution-audit.py` remains unchanged during shadow migration.

It is not extended into the new compiler because it hardcodes the current topology, including:

- required constitution files;
- separate parent and engineering constitutions;
- Articles 25–43;
- fixed opportunity counts;
- split law registries;
- current source/test-map topology.

At cutover, its useful invariants migrate to:

```bash
python3 scripts/ambitions-canon.py audit
python3 scripts/ambitions-canon.py build --check
python3 scripts/ambitions-canon.py coverage --fail-on-p0-gap
python3 scripts/ambitions-canon.py traceability --check
python3 scripts/ambitions-canon.py authority-sprawl --check
```

Task 24 creates a closed `legacy-audit-invariant-parity.json` registry that maps every base-owned old-audit invariant exactly once to an equivalent-or-stronger replacement invariant. Missing, duplicate, unknown, or weaker mappings fail closed. Task 25 runs the base-owned old audit, parses all five replacement commands, and records parity proof using the already-merged Task 24 verifier. The old audit is deleted only after this proof is Green and independently reviewed.

---

## 25. Destructive supersession safety

An artifact is eligible for deletion only when:

1. every atomic claim has a disposition;
2. every accepted unique concept has a canonical destination;
3. all conflicts are resolved;
4. all inbound references are identified;
5. replacement IDs are verified;
6. Linear and Figma references are reconciled;
7. canon build and coverage checks pass;
8. an independent reviewer signs off;
9. a rollback commit or tag exists.

The purge system produces a manifest:

```toml
[[artifact]]
path = "docs/truth/PRODUCT_EXPERIENCE_CANON.md"
action = "delete"
replacement_ids = ["EXPERIENCE-001", "USER-CONTROL-001", "LEARNING-004"]
unique_content_extracted = true
incoming_links_rewritten = true
owner_approved = true
rollback_ref = "<commit>"
```

`purge verify` fails if any deleted artifact still has active inbound references or unresolved claims.

Git history is the historical record. No new in-repo graveyard is created.

---

## 26. Anti-regression controls

The future CI target, and the Task 29 local regression for its retained subset, fail when:

- normative authority appears outside `docs/canon/`;
- a new prohibited authority filename is added without allowlist;
- a concept has multiple owners;
- an ID is duplicated or reused;
- generated output is stale;
- a superseded ID is referenced;
- a required completeness profile is incomplete;
- a launch-critical requirement lacks required traceability;
- a Figma or Linear manifest references an unknown ID;
- a task pack cannot be built for a declared implementation scope;
- a mutable source path is promoted to permanent product law;
- an amendment bypasses impact review;
- a deleted authority remains referenced;
- task intake is missing, stale, malformed, or inconsistent with the checkout;
- intake asserts approval, authorized scope, validation/proof result, break-glass, or merge permission;
- trusted repository/PR/base/head/merge-base event bindings are missing or inconsistent;
- the canonical tree delta omits a raw-path delete/add, opaque blob, symlink, gitlink, deletion, or mode-only change;
- a stale task pack or local authorization artifact is presented as merge proof;
- the final diff contains an undeclared file or lacks current finalization;
- a retained skill has stale or undeclared canonical dependencies;
- the exact local authorization/finalization does not bind the reviewed SHA;
- owner decision `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z`, one exact high-risk review, or rollback is absent or scope-mismatched;
- destructive manifests/dry-runs, privacy/security/proof-honesty review, or owner-approved Search-frame evidence is absent or stale;
- a Task 24–29 artifact claims `live_enforcement_proven = true`, requires a post-merge receipt, or claims protected enforcement/no drift.

Authority-word scanning is a candidate detector, not the sole enforcement mechanism. Legitimate source comments and historical Git messages must not cause false authority.

---

## 27. Security and privacy

- The compiler runs locally and offline.
- The tracked canon contains no real private life graph or user data.
- Linear and Figma exports used during migration must be stored in ignored local state unless a redacted evidence artifact is explicitly approved.
- Generated task packs must exclude credentials and private external content.
- External authority manifests store stable IDs and links, not copied confidential payloads.
- Model-assisted reconciliation may use connected sources during controlled review, but CI never requires model or cloud access.
- R2 and Source Atlas boundaries remain public/reference-only.
- User-owned CloudKit continuity, if retained by owner decision, remains distinct from Ambitions Account and Ambitions-hosted storage.
- Purge manifests must not expose secrets or private attachment URLs.

---

## 28. Reliability and error handling

### 28.1 Parser errors

Malformed normative files fail with:

- path;
- line;
- rule;
- expected form;
- stable error code.

No partial generated output is committed.

### 28.2 Atomic generation

Generated files are built into a temporary directory, validated, and atomically swapped only after all checks pass.

### 28.3 External connector failures

Linear or Figma unavailability does not break local canon audit. It marks external reconciliation stale and blocks only affected external-authority claims or cutover gates.

Authorization may consume only a base-trusted revisioned snapshot produced by a separate trusted sync. Connector unavailability or snapshot drift blocks authorization for dependent work; intake cannot convert cached or asserted external state into current proof.

### 28.4 Missing model review

Semantic review absence cannot be presented as conflict-free proof. Deterministic checks still run, and unresolved semantic review remains an explicit gate.

### 28.5 Stale migration source

If the v3 Linear document changes after export, its checksum mismatch invalidates the import baseline and requires re-extraction before cutover.

### 28.6 Interrupted purge

Purge executes in bounded commits or atomic batches with a manifest. Every batch has a rollback reference and verification before the next batch.

---

## 29. Testing strategy

### 29.1 Unit tests

Cover:

- front matter parsing;
- requirement extraction;
- modality validation;
- stable IDs;
- concept ownership;
- dependency graph;
- cycle detection;
- supersession;
- completeness profiles;
- traceability;
- task-pack selection;
- impact analysis;
- purge eligibility;
- deterministic rendering.

### 29.2 Negative fixtures

Include:

- duplicate ID;
- duplicate concept owner;
- unknown inheritance;
- cyclic dependency;
- semantic-removal reference;
- incomplete surface;
- missing rollback;
- unknown Figma requirement;
- stale generated SHA;
- authority file outside allowlist;
- mutable implementation claim in Constitution;
- missing or stale task intake;
- stale task pack and stale authorization envelope;
- undeclared changed file or changed exact diff;
- missing finalization receipt;
- stale or authority-bearing retained skill;
- contributor-controlled artifact offered as self-authorizing proof;
- bypassed amendment and deleted authority reference;
- intake-carried approval, authorized-file, proof, validation-result, break-glass, or merge claims;
- repository mismatch, base movement, force-push/head replacement, missing Git object, or inconsistent merge base;
- clean head versus synthetic merge checkout and merge-commit cases;
- delete/add move normalization, copy-as-add, opaque blob, raw-path bytes, symlink, mode-only, submodule gitlink, and deletion deltas;
- exact authorized/finalized SHA mismatch or missing exact high-risk review;
- missing/mismatched/reused owner direct-integration decision or rollback;
- stale trusted snapshot, overbroad destructive manifest, dry-run mismatch, or protected-enforcement overclaim;
- caller-supplied visual completeness, omitted required screen/state/journey/object/accessibility variant/visual requirement, non-fixed review dimension, or nonempty gap-blocked state;
- visual evidence that is not a digest-bound `figma-design-export`, or that attempts to upgrade a Figma design claim into simulator/runtime/device/accessibility proof;
- missing, duplicate, unknown, or weaker legacy-audit invariant mapping, or a missing/non-Green replacement command result;
- unbounded evidence pre-read, verifier-controlled subprocess without a timeout, or prose-only rollback assertion without bound rollback evidence.

### 29.3 Golden tests

Generate expected:

- `canon-index.json`;
- concept ownership;
- requirement graph;
- coverage report;
- task packs;
- impact reports;
- purge manifests.

Golden output must remain deterministic.

### 29.4 Integration tests

Exercise:

- parse → graph → audit → build;
- amendment → impact → supersession;
- issue intake → task pack;
- ChatGPT handoff → task intake → task start → exact-diff task finalize;
- resume → authorization regeneration → stale local artifact rejection;
- exact local base/head tree delta → computed authorization → exact-diff finalize;
- owner decision + exact reviewed SHA + rollback → direct-integration record;
- old authority inventory → migration dispositions;
- cutover reference rewrite;
- purge verification.

Task 29 retains only the compact direct-integration, proof-honesty, destructive-safety, privacy/security, Search-frame, amendment, and deleted-authority subset as permanent fast deterministic negatives. It runs exactly one canary and one qualifying regression and performs no GitHub protection inspection.

### 29.5 Semantic-loss review

A separate Codex review compares the raw migration corpus with proposed canon and reports:

- accepted unique claims not represented;
- rejected claims still present;
- weakened constraints;
- lost exceptions;
- accidental status promotion;
- duplicated ownership.

Semantic review is evidence, not deterministic CI.

### 29.6 Codex consumption benchmark

Representative tasks must include:

- Today SwiftUI change;
- Time recurrence behavior;
- Capture proposal flow;
- LocalRuntimeOS mutation;
- CloudKit continuity;
- Source Atlas boundary;
- accessibility repair;
- release-proof claim.

All eight representative tasks must run through both `task start` and `task finalize` using bounded deterministic fixtures/unit tests. Exactly one heavyweight end-to-end canary proves ChatGPT intent becomes bounded intake rather than authority. Do not duplicate the eight scenarios as heavyweight repository integrations when the deterministic harness proves the same invariants.

For each task, compare the old read path and new pack on:

- relevant-law recall;
- contradictory guidance;
- context size;
- unauthorized assumptions;
- source-owner accuracy;
- validation completeness;
- proof and claim discipline.

---

## 30. Execution style recommendation

Implementation should use stacked, independently reviewable trains.

Recommended sequence:

1. schemas and parser;
2. compiler audit and generated index;
3. corpus inventory and lossless v3 import;
4. claim graph and conflict docket tooling;
5. Constitution synthesis;
6. surface and global specifications;
7. object specifications;
8. journey and system specifications;
9. standards and traceability;
10. Codex task-pack integration;
11. Linear and Figma projection repair;
12. cutover;
13. purge;
14. post-purge audit.

Agent posture:

```text
One lead coordinator
        ↓
Parallel read-only reviewers
        ↓
One canonical writer
        ↓
Independent reviewer
        ↓
Deterministic verification
        ↓
Owner decision where required
```

Parallel work is appropriate for inventory, extraction, domain analysis, gap detection, and red-team review.

Parallel work is forbidden for final concept ownership, owner-conflict decisions, simultaneous edits to the same normative file, cutover, and destructive purge.

Compiler implementation uses test-driven development, typed Python, standard-library-first dependencies, small commits, independent review, and verification before completion.

Gate C is the post-Train-5A direct-integration, pre-destruction owner gate. It remains hard Red until exact SHA-bound authorization/finalization, one exact high-risk review, rollback, privacy/security/proof-honesty review, owner-approved Search frames, exact destructive manifests, and exact dry-runs are current and Green. It then gates destructive Tasks 27–28 and destructive/migration-state-removal portions of Task 29. Delegation cannot waive any retained Red, Critical, Important, authorization, security/privacy/proof-honesty, rollback, Search-frame, or destructive-cleanup requirement. Protected CI, required checks, ruleset inspection, and post-merge/live-boundary receipts are excluded for Tasks 24–29 and must not be claimed.

A detailed task-by-task implementation plan will define branch or main posture, exact files, tests, commands, commit boundaries, review checkpoints, and model assignments after this design is reviewed.

---

## 31. Rollback strategy

### Before cutover

Delete the shadow `docs/canon/` work and compiler commits or revert the stacked train. Existing authority remains unchanged.

### At cutover

Use a named baseline tag and cutover commit. Revert the cutover to restore old authority and routing. Tasks 24–29 do not install protected CI.

### During purge

Each deletion batch records:

- base commit;
- affected artifacts;
- replacement IDs;
- rewritten references;
- verification output;
- rollback commit.

Do not combine the entire purge with unrelated source changes.

### After purge

Git history and the baseline tag preserve previous content. Reintroduction requires a deliberate revert or amendment, not an active archive.

---

## 32. Acceptance criteria

This design is implemented only when:

1. `docs/canon/` is the sole normative authority package.
2. `MANIFEST.toml` lists every active normative artifact.
3. Every canonical concept has exactly one owner.
4. Every normative requirement has a stable ID.
5. Every accepted Decision 1–201 has a disposition.
6. Every old active authority artifact has a migration disposition.
7. All material conflicts have owner decisions.
8. Every launch-critical surface, object, journey, and system satisfies its profile or has an explicit blocker.
9. Codex can generate deterministic, bounded task packs.
10. Task packs include law, specifications, source owners, tests, visual authority, proof, risk, and claim ceiling.
11. Current implementation state is generated from evidence rather than hand-maintained as canon.
12. Linear contains references and execution state rather than copied product law.
13. Figma contains governed visual authority rather than independent product doctrine.
14. Future amendments generate deterministic impact reports.
15. Superseded repo, Linear, and Figma authority is deleted.
16. CI prevents authority sprawl from returning.
17. Representative Codex benchmarks show improved adherence without unsupported claims.
18. Governance completion does not overclaim product implementation or release readiness.
19. Every tracked change requires current `task start` and exact-diff `task finalize` authorization.
20. Tasks 24–29 bind exact SHA local authorization/finalization, one exact high-risk review, owner decision `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z`, and rollback; protected enforcement remains excluded and unproven.
21. Project Instructions and skills remain non-authoritative, skill dependencies are current, and the ChatGPT Project Instructions SHA-256 is verified.
22. Gate B and Gate C are Green for retained controls with exact review; the owner override removes only protected-enforcement prerequisites and waives no retained authorization, security/privacy/proof-honesty, rollback, Search-frame, or destructive requirement.
23. Intake remains untrusted request-only data; computed authorization and owner/break-glass provenance bind the exact local SHA and the recorded owner decision.
24. Exact PR authorization binds immutable repository/PR/base/head/merge-base state and a complete canonical tree delta.
25. Final evidence records the owner break-glass decision, exact reviewed SHA, rollback, `live_enforcement_proven = false`, `post_merge_receipt_required = false`, and an explicit statement that protected CI was neither installed nor proven.

---

## 33. Proof and claim boundary

This document proves only that the target architecture and migration design were owner-approved and recorded.

It does not prove:

- the full v3 corpus was exported;
- claims were extracted;
- conflicts were resolved;
- the Constitution or Atlas exists;
- the compiler exists or passes;
- Linear or Figma is reconciled;
- old authority is safe to delete;
- source matches canon;
- any product, visual, accessibility, runtime, privacy, device, or release claim is Green;
- the authorization controls, protected-branch ruleset, or end-to-end canary are implemented merely because this design specifies them.
- protected enforcement or no-drift closeout exists; Tasks 24–29 explicitly do not produce that proof.

Those claims require the implementation plan, executed work, current validation, evidence, owner decisions, and independent review.

---

## 34. Design approval record

**Selected design:** Design A — Markdown-first Specification Atlas with a compiled knowledge graph.

**Approved target:** Compact Constitution + canonical Specification Atlas + compiler architecture.

**Migration posture:** Treat the Linear v3 document as the primary migration corpus, not the final monolithic authority.

**Execution posture approved at design level:** Shadow migration, deterministic compiler, model-assisted semantic reconciliation, task-specific Codex packs, owner conflict dockets, stacked reviewable trains, and destructive supersession after proof.

**Owner approval:** Devan Warner, 2026-07-11.

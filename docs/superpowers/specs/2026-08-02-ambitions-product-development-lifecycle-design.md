# Ambitions Product Development Lifecycle Skill Design

**Date:** 2026-08-02  
**Status:** Pending owner review  
**Repository baseline inspected:** `a758c727ea62ae0d7bc1ef634b8a59e5366970ae`  
**Target repository:** `agentdevan/ambitions`

## 1. Decision summary

Ambitions will standardize material product development around this lifecycle:

```text
Idea
  → Research document
  → Review and revision until PASS
  → Scope document
  → Review and revision until PASS
  → Design document
  → Review and revision until PASS
  → Groom for implementation
  → Implement
  → Test
  → Merge
```

The repository will implement this as one project-local Codex skill named
`ambitions-product-development-lifecycle`, supported by three versioned document
templates, four reference contracts, two deterministic Python utilities, unit
fixtures, and pressure-scenario validation.

The lifecycle is a quality and reasoning system. It is not task authorization,
owner attestation, merge permission, or a process-only repository gate. Canon
remains the durable product authority. Source, tests, runtime evidence, and the
existing Code Quality workflow remain the implementation and merge controls.

## 2. Repository alignment

The design extends current Ambitions conventions:

- `AGENTS.md` routes work through relevant canon, source, and tests while
  rejecting process-only authorization ceremony.
- `docs/canon/README.md` defines canon as durable product and engineering truth.
- `.agents/skills/ambitions-native-visual-foundry/SKILL.md` establishes
  project-local skills under `.agents/skills/`.
- `docs/qa/evidence/2026-07-23-vc14-native-foundry-bootstrap/skill-validation.md`
  establishes before-and-after pressure testing for repository skills.

The resulting authority flow is:

1. Research records evidence, uncertainty, alternatives, and recommendation.
2. Scope records the bounded product commitment.
3. Design resolves how the commitment becomes a native, testable system.
4. Passed scope and design identify required canon changes.
5. Accepted durable behavior is incorporated into owning canon sources.
6. Canon, source, tests, and runtime evidence control implementation thereafter.
7. Lifecycle documents remain provenance and do not override newer canon.

## 3. Goals

The system must:

1. Produce consistently structured research, scope, and design documents.
2. Prevent material ideas from becoming code before evidence, commitment, and
   design decisions are resolved.
3. Separate research from scope and scope from implementation design.
4. Make formal review outcomes binary and actionable.
5. Preserve traceability from findings through requirements, design, and proof.
6. Detect downstream documents bound to obsolete upstream meaning.
7. Keep the skill concise through progressive loading of templates and rubrics.
8. Embed native Apple behavior, local-first architecture, privacy,
   accessibility, data integrity, interruption, recovery, and performance in
   the applicable phase rather than deferring them to final testing.
9. Give implementation grooming enough resolved detail to prevent invention
   during coding.
10. Avoid lifecycle overhead when existing authority already resolves the work.

## 4. Non-goals

The system will not:

- create a competing source of product truth beside canon;
- require all three documents for typo fixes, routine maintenance, mechanical
  refactors, or contained defects whose expected behavior is already canonical;
- replace issue tracking, implementation plans, pull requests, code review, or
  test evidence;
- use document status as merge authorization;
- allow a passed document with blockers, contradictory decisions, or unresolved
  behavior that would force implementation invention;
- silently alter approved upstream decisions from a downstream phase;
- treat Figma, screenshots, fixtures, or previews as proof of runtime behavior;
- duplicate existing implementation, debugging, testing, security,
  accessibility, or native-visual skill instructions;
- migrate historical documents solely to make them match the new format.

## 5. Applicability

### 5.1 Complete lifecycle required

Use research, scope, and design for material changes to one or more of:

- product behavior or user outcome;
- canonical objects, identity, ownership, lifecycle, or consequence semantics;
- information architecture, navigation, primary journeys, or presentation;
- architecture, persistence, migration, concurrency, replay, recovery, or sync;
- private-data boundaries or off-device egress;
- accessibility semantics or equivalent interaction;
- performance budgets or operational behavior;
- a new system, surface, major capability, or externally observable contract;
- multiple domains requiring explicit reconciliation.

### 5.2 Reduced entry point

Work may begin at scope or design when current canon and source already establish
all earlier answers. The new document must cite the exact authority and explain
why new research or scope is unnecessary.

Examples:

- implementing an already-normative requirement with no unresolved product
  choice;
- designing a bounded viewport whose behavior and acceptance conditions are
  fully specified;
- repairing an architecture seam whose ownership and invariants are canonical.

The reduced entry point is explicit metadata. The validator does not fabricate
missing documents.

### 5.3 Complete lifecycle normally unnecessary

The full chain is normally unnecessary for:

- spelling, comment, or non-semantic copy corrections;
- mechanical refactors with no contract change;
- bounded dependency and tooling maintenance;
- tests added for existing behavior;
- contained defects where canon, source, and tests establish the expected result.

If investigation exposes a product choice rather than a defect, work re-enters
the earliest unresolved lifecycle phase.

## 6. Repository architecture

```text
.agents/skills/ambitions-product-development-lifecycle/
├── SKILL.md
├── assets/
│   ├── research-document-template.md
│   ├── scope-document-template.md
│   └── design-document-template.md
├── references/
│   ├── lifecycle-contract.md
│   ├── research-review-rubric.md
│   ├── scope-review-rubric.md
│   └── design-review-rubric.md
└── scripts/
    ├── new_document.py
    └── validate_document.py

docs/product-development/
└── <initiative-slug>/
    ├── research.md
    ├── scope.md
    └── design.md
```

Templates are copied assets. Lifecycle and review rules are references loaded
only when relevant. Scripts enforce mechanical rules that should not depend on
agent judgment.

## 7. Skill contract

### 7.1 Frontmatter

```yaml
---
name: ambitions-product-development-lifecycle
description: Use when an Ambitions idea, feature, product behavior, architecture change, or UX change requires research, scope definition, implementation design, or readiness review before implementation.
---
```

The description states triggering conditions only, so agents must read the
complete skill rather than treating frontmatter as a workflow shortcut.

### 7.2 Responsibilities

The skill must:

1. Inspect current repository state, relevant canon, source, tests, evidence,
   and existing initiative documents.
2. Select the correct lifecycle entry point.
3. Resolve a stable initiative ID and slug.
4. Instantiate the exact phase template through `new_document.py`.
5. Preserve required headings and identifier conventions.
6. Distinguish sourced fact, observed repository fact, user intent, inference,
   recommendation, assumption, and unresolved unknown.
7. Load the phase-specific review rubric.
8. Return exactly `PASS` or `NEEDS REVISION` for a formal phase review.
9. Reference each blocker to an affected section or stable ID.
10. Prevent phase advancement while blockers remain.
11. Reopen the earliest upstream phase responsible for a downstream defect.
12. Run validation before claiming a document passed.
13. Reconcile downstream status after an accepted upstream semantic revision.
14. Hand a passed design to implementation grooming rather than embedding a full
    task plan in the design document.
15. Preserve the distinction between document quality and code readiness.

### 7.3 Formal review output

Formal reviews use these headings in this order:

```text
Verdict: PASS | NEEDS REVISION

Blocking findings
Non-blocking improvements
Traceability gaps
Stale or conflicting inputs
Required revisions
Next permitted lifecycle phase
```

There is no conditional pass. A blocker produces `NEEDS REVISION`.
Non-blocking improvements may remain after `PASS` only when omission creates no
ambiguity, untested obligation, data risk, accessibility failure, or
implementation invention.

## 8. Initiative document model

### 8.1 Stable directory and files

Each initiative uses one stable directory:

```text
docs/product-development/<initiative-slug>/
```

The directory and phase filenames do not change during revisions. Git preserves
history; routine `-r01`, `-r02`, and similar document copies are prohibited.

### 8.2 Stable identifiers

Initiative IDs use the creation month and remain unchanged if work continues in
later months:

```text
PD-YYYY-MM-<UPPERCASE-SLUG>
```

Document IDs append the phase:

```text
PD-2026-08-ADAPTIVE-START-HERE-RESEARCH
PD-2026-08-ADAPTIVE-START-HERE-SCOPE
PD-2026-08-ADAPTIVE-START-HERE-DESIGN
```

Content IDs are stable within the initiative:

- findings: `FIND-001`;
- risks: `RISK-001`;
- requirements: `REQ-001`;
- acceptance criteria: `AC-001`;
- design decisions: `DESIGN-001`;
- planned verification: `VERIFY-001`;
- open decisions: `OPEN-001`.

Removed IDs are retired and never reassigned to a different concept.

### 8.3 Shared TOML frontmatter

```toml
+++
initiative_id = "PD-2026-08-ADAPTIVE-START-HERE"
document_id = "PD-2026-08-ADAPTIVE-START-HERE-RESEARCH"
document_type = "research"
status = "draft"
revision = 1
created_at = "2026-08-02"
updated_at = "2026-08-02"

entry_point = "research"
input_documents = []
input_revisions = []
input_hashes = []

review_verdict = "unreviewed"
blocking_findings = 0
canon_targets = []
supersedes = []
+++
```

Allowed statuses:

- `draft`;
- `in-review`;
- `needs-revision`;
- `passed`;
- `stale`;
- `superseded`.

Allowed verdicts:

- `unreviewed`;
- `needs-revision`;
- `pass`.

`status = "passed"` requires `review_verdict = "pass"`, zero blocking findings,
a successful validation result, and current upstream inputs.

### 8.4 Upstream binding and semantic staleness

Scope binds to the exact passed research revision and semantic hash. Design
binds to the exact passed scope revision and semantic hash. A reduced entry point
binds to exact canon or approved design authority.

A material research change makes dependent scope and design effectively stale.
A material scope change makes dependent design effectively stale. Material
changes include findings, recommendations, requirements, acceptance criteria,
boundaries, dependencies, risks, design decisions, or verification obligations.
Formatting-only and spelling-only changes do not propagate staleness when the
normalized semantic hash remains unchanged.

Staleness handling must be safe and explicit:

1. `validate_document.py` is read-only by default.
2. When an upstream semantic hash changes, validation reports the dependent
   document's effective status as stale and exits nonzero.
3. CI never silently edits initiative files.
4. After the upstream revision is intentionally accepted, the skill explicitly
   changes affected downstream frontmatter to `status = "stale"` in a separate,
   reviewable edit.
5. A stale document remains historical evidence but cannot advance the phase.
6. Revalidation clears the effective stale error only after the downstream
   document is reconciled, rebound to the new input, reviewed, and passed again.

## 9. Research document contract

The research document answers:

> What is true, what remains uncertain, what constraints exist, and which
> direction is best supported by evidence?

It does not commit detailed implementation scope.

### 9.1 Required sections

1. Executive finding
2. Idea and problem statement
3. Research questions
4. Hypotheses requiring validation
5. Current Ambitions state
   - Relevant canon
   - Live implementation
   - Existing tests and evidence
   - Known gaps or contradictions
6. User and product evidence
7. Apple platform and ecosystem research
8. Technical feasibility
9. Privacy and local-first implications
10. Accessibility implications
11. Alternatives considered
12. Tradeoff analysis
13. Findings
14. Recommended direction
15. Rejected directions
16. Remaining unknowns
17. Risk register
18. Source ledger
19. Handoff to scope
20. Review history

A non-applicable section remains present and states why it is not material.

### 9.2 Evidence classification

Material statements must be classifiable as:

- externally sourced fact;
- observed current-repository fact;
- user-provided product intent;
- inference;
- recommendation;
- assumption;
- unresolved unknown.

External claims require sources. Repository claims cite paths, symbols, tests,
commands, or evidence artifacts. Inferences name their supporting evidence.

### 9.3 Research pass criteria

Research passes only when:

- material claims are sourced or explicitly classified;
- current repo and canon reality were inspected;
- research questions are answered or carried forward as explicit unknowns;
- meaningful alternatives were compared;
- recommendation follows from findings;
- rejected directions include reasons;
- privacy, local-first behavior, accessibility, Apple behavior, failure, and
  recovery are considered where relevant;
- contradictions are reconciled or escalated;
- detailed implementation scope is not prematurely locked;
- no unknown prevents a bounded scope decision;
- the source ledger is sufficient to reproduce material analysis.

## 10. Scope document contract

The scope document answers:

> What exact product outcome are we committing to, and what are we explicitly
> not building?

It consumes passed research or cites exact authority for a reduced entry point.
It defines observable obligations without unnecessarily choosing implementation
mechanics.

### 10.1 Required sections

1. Scope decision
2. Research input and revision
3. Problem being solved
4. Desired user outcome
5. Target users and scenarios
6. In scope
7. Out of scope
8. Product requirements
9. Required states and behaviors
10. Acceptance criteria
11. Product invariants
12. Native Apple constraints
13. Privacy and data boundaries
14. Accessibility requirements
15. Offline, interruption, and recovery expectations
16. Performance expectations
17. Dependencies
18. Risks and mitigations
19. Measurement and success evidence
20. Release boundary
21. Canon impact
22. Design brief
23. Open decisions
24. Review history

### 10.2 Requirement rules

Each `REQ-*` must:

- describe one observable obligation;
- identify its owner domain or intended canon owner;
- avoid combining independent requirements;
- be testable or inspectable;
- reference supporting findings or established authority;
- map to one or more `AC-*` entries.

Each `AC-*` defines inspectable evidence. Subjective closure such as “looks
good,” “works correctly,” or “feels native” is insufficient without measurable
or observable conditions.

### 10.3 Scope pass criteria

Scope passes only when:

- outcome and release boundary are bounded;
- in-scope and out-of-scope behavior are unambiguous;
- requirements are supported by research or authority;
- every requirement maps to acceptance criteria;
- every acceptance criterion is verifiable;
- privacy, local-first, accessibility, offline, interruption, failure,
  recovery, migration, and performance obligations are explicit where relevant;
- dependencies and risks are identified;
- open decisions do not require invention during design or implementation;
- canon targets and owner domains are named;
- scope is one coherent design and implementation program or is decomposed
  before passing.

## 11. Design document contract

The design document answers:

> How will the passed scope become a coherent, native, testable Ambitions
> implementation?

It combines product interaction, state, architecture, privacy, accessibility,
data integrity, and verification. It is neither a visual-only document nor a
code-level task plan.

### 11.1 Required sections

1. Design decision summary
2. Scope input and revision
3. Design principles
4. Protected product characteristics
5. User journey
6. Information architecture
7. Canonical object ownership
8. State model
9. Command and consequence model
10. Screen and presentation behavior
11. Navigation, focus, dismissal, and restoration
12. SwiftUI composition
13. Domain and service boundaries
14. Persistence and migration behavior
15. Concurrency, replay, and atomicity implications
16. Offline behavior
17. Privacy and security
18. Accessibility
19. Motion and Reduce Motion
20. Reduce Transparency, contrast, and legibility
21. Error, interruption, recovery, rollback, and Undo
22. Performance considerations
23. Diagnostics and telemetry boundaries
24. Testing strategy
25. Visual and runtime proof plan
26. File and module impact
27. Legacy deletion or supersession
28. Implementation seams
29. Requirement-to-design traceability
30. Implementation grooming handoff
31. Open questions
32. Review history

### 11.2 Design decision rules

Each `DESIGN-*` must:

- resolve one material product or technical decision;
- reference the `REQ-*` and `AC-*` entries it satisfies;
- identify the owning layer or module;
- state rejected alternatives when the decision is non-obvious;
- define failure and recovery behavior when applicable;
- identify intended verification evidence.

Diagrams, native frames, prototypes, and pseudocode may support the contract but
never replace it.

### 11.3 Traceability matrix

The design contains a complete matrix:

| Research finding or authority | Scope requirement | Acceptance criterion | Design decision | Planned verification |
|---|---|---|---|---|
| `FIND-003` | `REQ-004` | `AC-007` | `DESIGN-011` | `VERIFY-009` |

Every requirement and acceptance criterion appears. Orphan requirements,
unverified acceptance criteria, and design decisions with no scope basis block
passage.

### 11.4 Design pass criteria

Design passes only when:

- every passed scope requirement is covered;
- every acceptance criterion has planned verification;
- object, state, command, data, source, and module ownership are explicit;
- native presentation, navigation, dismissal, focus, restoration, keyboard, and
  safe-area behavior are resolved where applicable;
- loading, empty, populated, degraded, error, interrupted, recovery, completed,
  archived, and destructive states are addressed where applicable;
- local-first, privacy, accessibility, migration, concurrency, replay,
  rollback, and data-integrity behavior are resolved where relevant;
- preview or fixture evidence is not represented as runtime proof;
- implementation seams are narrow and independently testable;
- file impact and intended legacy deletion are identified;
- no placeholder, contradiction, or unresolved product behavior remains;
- implementation can be groomed without inventing behavior.

## 12. Review and revision behavior

### 12.1 Independent review

Formal review attempts to falsify completeness, consistency, traceability,
feasibility, privacy, accessibility, and verification claims. It is not merely a
prose edit.

### 12.2 Revision rules

A semantic revision must:

- preserve stable IDs for unchanged concepts;
- increment `revision`;
- update `updated_at`;
- record verdict and resolved blockers in Review history;
- avoid silently changing upstream decisions;
- reopen the responsible upstream phase when necessary;
- recalculate the semantic hash;
- reconcile dependent status;
- pass validation before a new pass claim.

### 12.3 Phase reversal

The lifecycle is reversible:

```text
Research review may reopen research.
Scope work or review may reopen research.
Design work or review may reopen scope or research.
Implementation grooming may reopen design, scope, or research.
Implementation or testing may expose an earlier defect.
```

Correct the earliest defective phase first, then reconcile downstream work.

## 13. Deterministic tooling

Utilities use the Python 3.12 standard library unless the repository establishes
a different supported baseline during implementation.

### 13.1 `new_document.py`

Example:

```sh
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/new_document.py \
  --initiative "Adaptive Start Here" \
  --phase research
```

Required behavior:

- normalize and validate slug and IDs;
- create the initiative directory when absent;
- copy the exact phase template;
- populate dates, entry point, and upstream references;
- calculate upstream semantic hashes;
- refuse overwrite;
- refuse scope when required research is missing, stale, or not passed;
- refuse design when required scope is missing, stale, or not passed;
- allow reduced entry only with a valid authority path and rationale;
- print the created path and next required action;
- make no unrelated edits.

### 13.2 `validate_document.py`

Examples:

```sh
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/validate_document.py \
  docs/product-development/adaptive-start-here/research.md

python3 .agents/skills/ambitions-product-development-lifecycle/scripts/validate_document.py \
  --initiative docs/product-development/adaptive-start-here

python3 .agents/skills/ambitions-product-development-lifecycle/scripts/validate_document.py \
  --all --format json
```

Required validation:

- parse TOML frontmatter;
- validate document and initiative IDs;
- require mandatory heading set and order;
- enforce valid status and verdict combinations;
- reject duplicate active content IDs;
- allow intentional gaps for retired IDs but reject malformed or reassigned IDs;
- validate upstream paths, revisions, hashes, and pass state;
- detect effective staleness without mutating files;
- require source-ledger support for material findings;
- require requirement-to-finding or authority linkage;
- require requirement-to-acceptance linkage;
- require complete design traceability;
- reject placeholders, fill-in markers, and empty required sections in passed
  documents;
- reject passed status with blockers or open decisions that require invention;
- report file, section, identifier, and remediation;
- exit nonzero on failure;
- provide stable JSON diagnostics for CI and future tools.

### 13.3 Semantic hash

The semantic hash excludes non-semantic fields such as `updated_at`,
formatting-only whitespace, and append-only review-history metadata. It includes
findings, recommendations, requirements, acceptance criteria, boundaries,
risks, decisions, traceability, and other semantic body content.

The normalization algorithm must be documented and unit-tested. A raw file hash
is insufficient because harmless formatting changes would invalidate every
downstream phase.

## 14. Code Quality integration

After the standalone system is validated, an affected-path lane may be added to
the existing Code Quality workflow for:

```text
.agents/skills/ambitions-product-development-lifecycle/**
docs/product-development/**
```

The lane validates document consistency and skill fixtures. It does not create a
new branch-protection check, authorize merging, or decide strategic approval.
CI validation is read-only.

## 15. Canon handoff

Passed scope and design documents include `canon_targets`. During grooming or
implementation:

1. Resolve each target against current generated canon routing.
2. Amend the owning normative source when durable product truth changes.
3. Add or update requirement and verification IDs under current canon rules.
4. Run `python3 scripts/ambitions-canon.py check`.
5. Retain lifecycle documents as provenance.

Current canon wins over an older lifecycle document unless a new lifecycle
explicitly proposes changing canon.

## 16. Implementation grooming handoff

A passed design provides bounded planning inputs rather than a task list:

- passed paths, revisions, and hashes;
- required canon amendments;
- implementation seams and dependency order;
- affected modules and expected file classes;
- required tests and proof lanes;
- migration and compatibility obligations;
- legacy deletion obligations;
- risks and stop conditions;
- requirement, acceptance, design, and verification IDs.

If these cannot be converted into executable work without invention, grooming
reopens the responsible lifecycle phase.

## 17. Skill testing strategy

The skill is developed using documentation TDD: run fresh agents without the
skill, record failures, add the minimum instruction or contract needed, rerun the
same scenarios, and refine only for observed loopholes.

### 17.1 Pressure scenarios

At minimum:

1. Immediate SwiftUI implementation requested from a vague idea.
2. Incomplete research encouraged to produce plausible scope.
3. One unresolved privacy blocker presented as a candidate conditional pass.
4. Passed research changes after scope and design pass.
5. Preview screenshot presented as runtime proof.
6. A spelling correction presented as requiring the full lifecycle.
7. Historical passed design conflicts with current canon.
8. Design omits ownership and concurrency behavior.
9. Acceptance criteria lack planned verification.
10. Document pass status is treated as a merge authorization receipt.

### 17.2 Expected post-skill behavior

Fresh agents must:

- choose the correct entry point;
- resist premature implementation;
- distinguish evidence, inference, and assumption;
- issue binary verdicts;
- detect and explicitly reconcile stale dependencies;
- treat canon as current durable authority;
- reject preview-only runtime claims;
- avoid over-applying the lifecycle;
- surface ownership, privacy, accessibility, recovery, and verification gaps;
- keep document quality separate from merge authorization.

### 17.3 Script tests

Unit tests cover:

- ID and slug generation;
- template instantiation and overwrite refusal;
- upstream pass requirements and reduced-entry authority;
- frontmatter and heading validation;
- status and verdict combinations;
- stable identifier uniqueness;
- semantic hashing and effective stale detection;
- source-ledger enforcement;
- requirement and acceptance coverage;
- design traceability;
- placeholder and empty-section rejection;
- JSON diagnostics and nonzero exit behavior;
- path traversal rejection;
- proof that validation does not mutate files.

Tests use temporary directories and fixtures only.

## 18. Delivery boundary and adoption sequence

This design is intentionally bounded so one implementation plan can complete the
skill system without also delivering an unrelated Ambitions product feature.

### 18.1 Initial implementation — in scope

1. Create the skill, templates, rubrics, lifecycle contract, scripts, and tests.
2. Run and commit baseline and post-skill pressure-scenario evidence.
3. Validate a synthetic or fixture initiative through research, scope, design,
   review, semantic staleness, and grooming handoff.
4. Add concise repository routing for material initiatives.
5. Leave historical documents unchanged.

### 18.2 Follow-up adoption — not required for initial completion

1. Use the lifecycle for the first real bounded Ambitions initiative.
2. Evaluate whether template or rubric refinement is needed.
3. Add the affected-path Code Quality lane only after standalone behavior is
   stable.
4. Measure whether the lifecycle reduces invention, revision churn, and proof
   gaps without adding disproportionate process cost.

A real feature implementation and merge are evidence of adoption, not blockers
to completing the lifecycle skill itself.

## 19. Failure handling

- **Missing upstream document:** stop and name the required phase or reduced-entry
  authority.
- **Invalid frontmatter:** identify the field and accepted values; do not rewrite
  silently during validation.
- **Stale dependency:** report effective stale status and the changed input;
  apply explicit frontmatter updates only through a separate edit.
- **Conflicting authority:** resolve the conflict in the earliest owning phase or
  canon source.
- **Unreachable source:** classify the claim as unverified.
- **Oversized initiative:** decompose during research or scope before pass.
- **Validator defect:** fail safely, preserve documents, and repair with tests.
- **Skill ambiguity:** reproduce it with a pressure scenario before editing the
  skill.

## 20. Security and privacy

Templates must prevent credentials, production secrets, unnecessary personal
records, or private-life graph content from being copied into artifacts.
Research uses public sources, repository evidence, or redacted user context
unless a protected internal source is explicitly required.

The skill never directs private Ambitions data to external research services.
Scripts use no network access, execute no embedded document content, restrict
operations to approved repository roots, and reject path traversal.

## 21. Accessibility and quality posture

Accessibility is resolved across phases: research identifies constraints, scope
defines obligations, design resolves semantic and interaction behavior, and
implementation/testing produces proof. Applicable concerns include VoiceOver,
Switch Control, Dynamic Type, focus, Reduce Motion, Reduce Transparency,
contrast, interruption, errors, and recovery.

The same early-to-late treatment applies to privacy, local-first behavior,
persistence, migration, concurrency, replay, recovery, performance, and native
Apple conventions.

## 22. Initial implementation acceptance criteria

The first implementation is complete when:

1. The complete skill directory and specified files exist.
2. `SKILL.md` is concise and delegates templates and rubrics.
3. All templates contain required frontmatter and sections.
4. Both utilities implement the safe interfaces in this design.
5. Unit tests cover all mechanical invariants and pass.
6. Baseline and post-skill pressure evidence is committed.
7. Fresh post-skill agents satisfy every required behavior scenario.
8. A fixture initiative completes all three document phases and grooming handoff.
9. Upstream semantic changes are detected without silent mutation and correctly
   invalidate downstream pass state.
10. The validator rejects incomplete traceability, placeholders, blockers, and
    invalid status combinations.
11. Repository guidance distinguishes material initiatives from trivial work.
12. Applicable canon changes for the lifecycle system itself are reconciled and
    `python3 scripts/ambitions-canon.py check` remains green.
13. No process-only merge gate or authorization receipt is introduced.

## 23. Resolved design choices

- One lifecycle skill, not three independent skills.
- Templates as assets; contracts and rubrics as references.
- Initiative documents under `docs/product-development/<initiative>/`.
- One file per phase with Git history for revisions.
- Binary `PASS` or `NEEDS REVISION` verdicts.
- Semantic upstream hashes and explicit stale-state reconciliation.
- Read-only validation and CI; no silent file mutation.
- Lifecycle documents as pre-canon provenance.
- Deterministic scripts for mechanical rules.
- Before-and-after pressure testing before adoption.
- Initial implementation bounded to the lifecycle system and fixture proof.
- Real feature adoption and optional CI integration deferred to follow-up.

## 24. Open questions

None block implementation planning. Implementation may refine command spelling,
internal parser decomposition, fixture organization, and exact test locations
while preserving every behavior and acceptance criterion in this design.

## 25. Self-review result

- **Placeholder scan:** No unresolved fill-in content exists.
- **Internal consistency:** Read-only validation, explicit stale reconciliation,
  canon authority, and binary review states agree across sections.
- **Scope check:** Initial implementation is bounded to one skill system and
  fixture proof; real feature adoption and CI integration are follow-up work.
- **Ambiguity check:** Lifecycle entry, pass requirements, reduced entry,
  staleness behavior, authority precedence, and completion criteria are explicit.

## 26. Owner review gate

This written specification requires owner review before implementation planning.
Requested revisions must be applied here and the self-review repeated. After
owner approval, create the detailed implementation plan using the repository's
implementation-planning workflow.

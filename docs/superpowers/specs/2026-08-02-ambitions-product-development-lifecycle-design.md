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
`ambitions-product-development-lifecycle`, supported by three canonical document
templates, four reference contracts, two deterministic Python utilities, and
pressure-scenario validation.

The lifecycle is a quality and reasoning system. It is not a task authorization,
owner attestation, merge permission, or process-only repository gate. Existing
repository law remains controlling: canon defines durable product truth, normal
repository work remains governed by relevant source, tests, and Code Quality,
and implementation may merge only after its actual code and evidence pass the
applicable engineering checks.

## 2. Context and current repository alignment

The design follows existing Ambitions conventions rather than creating a
parallel operating model.

- `AGENTS.md` routes contributors through generated canon, owning
  specifications, source, and tests, while explicitly rejecting process-only
  authorization ceremony.
- `docs/canon/README.md` establishes canon as the durable product and engineering
  truth and provides the deterministic compiler and reading order.
- `.agents/skills/ambitions-native-visual-foundry/SKILL.md` proves that
  project-local skills under `.agents/skills/` are an accepted repository
  mechanism.
- `docs/qa/evidence/2026-07-23-vc14-native-foundry-bootstrap/skill-validation.md`
  establishes a precedent for testing skill behavior with fresh agents before
  and after skill installation.

This lifecycle must cooperate with those systems:

1. Product-development documents capture discovery, decisions, and provenance.
2. Passed documents declare the canon changes required by the initiative.
3. Durable accepted behavior is written into the appropriate canon source.
4. Canon, source, tests, and runtime evidence control implementation and release.
5. Historical research, scope, and design documents remain provenance; they do
   not become a competing normative specification network.

## 3. Goals

The system must:

1. Produce consistently structured research, scope, and design documents.
2. Prevent Codex from skipping directly from an idea into implementation for a
   material product or architecture change.
3. Separate evidence gathering from commitment and separate commitment from
   implementation design.
4. Make review outcomes binary and actionable.
5. Preserve traceability from research findings through requirements, design
   decisions, implementation, and verification.
6. Detect when an approved downstream document depends on an outdated upstream
   revision.
7. Keep the skill concise by loading only the template and review rubric relevant
   to the active phase.
8. Support Ambitions as a native, local-first, privacy-preserving iPhone product,
   with accessibility, recovery, data integrity, and Apple-platform behavior
   treated as first-class concerns.
9. Give implementation grooming a sufficiently complete design so that Codex
   does not invent unresolved product behavior while coding.
10. Apply only where the expected quality benefit exceeds the process cost.

## 4. Non-goals

The system will not:

- create a new source of durable product truth beside canon;
- require a research, scope, and design packet for typo fixes, mechanical
  maintenance, contained bug fixes with already-canonical expected behavior, or
  routine dependency updates;
- replace issue tracking, implementation plans, pull requests, code review, or
  test evidence;
- use document status as merge authorization;
- permit a passed document with unresolved placeholders or blocking findings;
- silently change an approved upstream decision while revising a downstream
  document;
- force visual mockups when the initiative has no material visual dimension;
- treat screenshots, Figma, fixtures, or preview state as proof of runtime
  capability;
- duplicate the instructions of existing implementation, debugging, testing,
  accessibility, security, or native visual skills.

## 5. Applicability

### 5.1 Required lifecycle

Use the complete lifecycle for any change that materially affects one or more of:

- product behavior or user outcomes;
- canonical objects, ownership, identity, lifecycle, or consequence semantics;
- information architecture, navigation, primary journeys, or presentation;
- architecture, persistence, migration, concurrency, replay, recovery, or sync;
- private-data boundaries or off-device egress;
- accessibility semantics or equivalent interaction;
- performance budgets or operational behavior;
- a new system, surface, major capability, or externally observable contract;
- multiple domains whose interaction requires explicit reconciliation.

### 5.2 Reduced lifecycle

A contained change may begin at scope or design only when the earlier answers are
already established by current canon and source. The document must cite the
specific upstream authority and explain why new research is unnecessary.

Examples include:

- implementing an already-normative requirement with no unresolved product
  choice;
- redesigning a bounded viewport where the product behavior is fully specified;
- repairing an architecture seam whose correct ownership and invariants are
  already canonical.

The validator records the approved entry point. It does not fabricate missing
upstream documents.

### 5.3 Lifecycle not required

The complete lifecycle is normally unnecessary for:

- spelling, copy, or comment corrections that do not change meaning;
- mechanical refactors with no contract change;
- dependency or tooling maintenance with bounded expected behavior;
- test-only additions for existing behavior;
- contained defects where current canon, source, and tests already establish the
  expected result.

If investigation reveals a product decision rather than a defect, the work must
re-enter the appropriate lifecycle phase.

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

The templates are assets because they are copied into initiative directories.
The contracts and rubrics are references because agents read them when making or
reviewing documents. The scripts enforce mechanical invariants that should not
be left to prose judgment.

## 7. Skill contract

### 7.1 Frontmatter

```yaml
---
name: ambitions-product-development-lifecycle
description: Use when an Ambitions idea, feature, product behavior, architecture change, or UX change requires research, scope definition, implementation design, or readiness review before implementation.
---
```

The description states only the triggering conditions. It does not summarize the
workflow, because agents must load the complete skill rather than treating its
description as sufficient instructions.

### 7.2 Skill responsibilities

The skill must:

1. Inspect current repository state, relevant canon, source, tests, and existing
   initiative documents before drafting.
2. Classify the correct lifecycle entry point.
3. Resolve the initiative ID and stable slug.
4. Use `new_document.py` to instantiate the exact phase template.
5. Preserve required headings and stable identifier conventions.
6. Distinguish source-backed fact, observed repository fact, inference,
   recommendation, assumption, and unresolved unknown.
7. Load the review rubric for the active phase.
8. Return exactly `PASS` or `NEEDS REVISION` for formal phase reviews.
9. Make blocking findings concrete and reference the affected section or ID.
10. Refuse phase advancement while blocking findings remain.
11. Reopen an upstream phase when a downstream review discovers an upstream
    error or missing decision.
12. Run the validator before claiming a document is passed.
13. Mark downstream documents stale after a material upstream revision.
14. End a passed design phase by handing off to implementation grooming rather
    than embedding a full task plan inside the design document.
15. Preserve the distinction between document approval and code readiness.

### 7.3 Required output for formal reviews

Every formal phase review must use these headings in this order:

```text
Verdict: PASS | NEEDS REVISION

Blocking findings
Non-blocking improvements
Traceability gaps
Stale or conflicting inputs
Required revisions
Next permitted lifecycle phase
```

There is no conditional pass. A document with a blocker receives
`NEEDS REVISION`. Non-blocking improvements may remain after `PASS` only when
omitting them does not create ambiguity, untested behavior, data risk,
accessibility failure, or implementation invention.

## 8. Initiative document model

### 8.1 Stable initiative directory

Each initiative uses one stable directory:

```text
docs/product-development/<initiative-slug>/
```

The directory is not renamed when a document is revised. Git history preserves
past revisions. Separate `-r01`, `-r02`, and similar document copies are not
created for normal revision cycles.

### 8.2 Stable identifiers

An initiative receives an ID in this form:

```text
PD-YYYY-MM-<UPPERCASE-SLUG>
```

Example:

```text
PD-2026-08-ADAPTIVE-START-HERE
```

Document IDs append the phase:

```text
PD-2026-08-ADAPTIVE-START-HERE-RESEARCH
PD-2026-08-ADAPTIVE-START-HERE-SCOPE
PD-2026-08-ADAPTIVE-START-HERE-DESIGN
```

Content identifiers are local to the initiative but stable across revisions:

- research findings: `FIND-001`;
- risks: `RISK-001`;
- product requirements: `REQ-001`;
- acceptance criteria: `AC-001`;
- design decisions: `DESIGN-001`;
- planned verification: `VERIFY-001`;
- open decisions: `OPEN-001`.

Removed identifiers are retired, not reassigned to different concepts.

### 8.3 Shared frontmatter

All three documents begin with TOML frontmatter:

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

Allowed document statuses are:

- `draft`;
- `in-review`;
- `needs-revision`;
- `passed`;
- `stale`;
- `superseded`.

Allowed review verdicts are:

- `unreviewed`;
- `needs-revision`;
- `pass`.

`status = "passed"` requires `review_verdict = "pass"`, zero blocking findings,
a successful validator run, and no stale upstream input.

### 8.4 Upstream binding

Scope binds to the exact passed research revision and content hash. Design binds
to the exact passed scope revision and hash. A reduced lifecycle binds to the
specific canon or design authority that justifies skipping an earlier document.

A material change to passed research makes dependent scope and design stale. A
material change to passed scope makes dependent design stale. Stale documents
may be read as history but cannot authorize phase advancement.

A material change is one that affects a finding, recommendation, requirement,
acceptance criterion, boundary, dependency, risk posture, design decision, or
verification obligation. Formatting-only and spelling-only edits do not require
staleness propagation when the normalized semantic hash remains unchanged.

## 9. Research document contract

The research document answers:

> What is true, what remains uncertain, what constraints exist, and which
> direction is best supported by evidence?

It does not commit implementation scope.

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

Sections remain present even when not applicable; they explicitly state why the
area is not material rather than disappearing.

### 9.2 Evidence classification

Every material statement must be classifiable as one of:

- externally sourced fact;
- observed current-repository fact;
- user-provided product intent;
- inference;
- recommendation;
- assumption;
- unresolved unknown.

External claims require sources. Repository claims cite paths, symbols, tests,
commands, or evidence artifacts. Inference must name the evidence it depends on.

### 9.3 Research pass criteria

Research passes only when:

- all material claims are sourced or explicitly classified;
- current repo and canon reality were inspected;
- research questions are answered or carried forward as explicit unknowns;
- meaningful alternatives were compared;
- the recommended direction follows from the findings;
- rejected directions include reasons;
- privacy, local-first behavior, accessibility, Apple-platform behavior,
  failure, and recovery are considered where relevant;
- known contradictions are reconciled or escalated;
- the document does not prematurely lock detailed implementation scope;
- no unresolved unknown prevents a bounded scope decision;
- the source ledger is complete enough to reproduce the analysis.

## 10. Scope document contract

The scope document answers:

> What exact product outcome are we committing to, and what are we explicitly
> not building?

It consumes passed research or cites existing authority for a reduced entry
point. It defines observable product obligations without unnecessarily choosing
implementation mechanics.

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
- reference at least one supporting `FIND-*` or established authority;
- map to one or more `AC-*` entries.

Each `AC-*` must define the evidence required to determine success. It must not
use subjective closure language such as “looks good,” “works correctly,” or
“feels native” without measurable or inspectable conditions.

### 10.3 Scope pass criteria

Scope passes only when:

- the outcome and release boundary are bounded;
- in-scope and out-of-scope behavior are unambiguous;
- every requirement is supported by research or existing authority;
- every requirement maps to acceptance criteria;
- every acceptance criterion is verifiable;
- privacy, local-first, accessibility, offline, interruption, failure, recovery,
  migration, and performance obligations are explicit where relevant;
- dependencies and product risks are identified;
- open decisions do not require Codex to invent behavior during design or
  implementation;
- required canon changes and affected owner domains are named;
- the scope is small enough to become one coherent design and implementation
  program or is explicitly decomposed before passing.

## 11. Design document contract

The design document answers:

> How will the passed scope become a coherent, native, testable Ambitions
> implementation?

The design combines product interaction, state, architecture, privacy,
accessibility, data integrity, and verification. It is not merely a visual
mockup document or a code-level task list.

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
- state alternatives rejected when the choice is non-obvious;
- name failure and recovery behavior when the decision can fail;
- identify the intended verification evidence.

Design may include diagrams, screen references, native frames, prototypes, or
pseudocode when useful. Those artifacts support the written contract; they do
not replace it.

### 11.3 Traceability matrix

The design includes a complete matrix with at least these columns:

| Research finding or authority | Scope requirement | Acceptance criterion | Design decision | Planned verification |
|---|---|---|---|---|
| `FIND-003` | `REQ-004` | `AC-007` | `DESIGN-011` | `VERIFY-009` |

Every requirement and acceptance criterion must appear in the matrix. A design
cannot pass with orphan requirements, unverified acceptance criteria, or design
decisions that have no scope basis.

### 11.4 Design pass criteria

Design passes only when:

- every passed scope requirement is covered;
- every acceptance criterion has planned verification;
- object, state, command, data, source, and module ownership are explicit;
- native presentation, navigation, dismissal, focus, restoration, and keyboard
  behavior are resolved where applicable;
- loading, empty, populated, degraded, error, interrupted, recovery, completed,
  archived, and destructive states are addressed where applicable;
- local-first, privacy, accessibility, migration, concurrency, replay, rollback,
  and data-integrity behavior are resolved where relevant;
- preview or fixture evidence is not misrepresented as runtime proof;
- implementation seams are narrow and independently testable;
- file impact and intended legacy deletion are identified;
- no `TODO`, `TBD`, contradictory decision, or unresolved product behavior
  remains;
- a Codex implementation agent can groom the work without inventing behavior.

## 12. Review and revision behavior

### 12.1 Review independence

A formal review evaluates the document against the phase contract and the
current upstream authority. It does not merely proofread prose. The reviewer
must attempt to falsify completeness, consistency, traceability, feasibility,
privacy, accessibility, and verification claims.

### 12.2 Revision rules

When revising:

- preserve stable IDs for unchanged concepts;
- increment `revision` for semantic changes;
- update `updated_at`;
- record the review verdict and resolved blockers in Review history;
- do not silently alter upstream decisions;
- explicitly reopen the upstream phase when a downstream blocker originates
  there;
- rerun validation after every semantic revision;
- recalculate semantic hashes and propagate staleness.

### 12.3 Phase reversal

The lifecycle is intentionally reversible:

```text
Research review may reopen research.
Scope work or review may reopen research.
Design work or review may reopen scope or research.
Implementation grooming may reopen design, scope, or research.
Implementation or testing may expose a design, scope, or research defect.
```

The earliest defective phase is corrected first. Downstream work is then
reconciled against the new passed revision.

## 13. Deterministic tooling

Both utilities use Python 3.12 standard library only unless the current
repository establishes a different supported baseline at implementation time.

### 13.1 `new_document.py`

Proposed interface:

```sh
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/new_document.py \
  --initiative "Adaptive Start Here" \
  --phase research

python3 .agents/skills/ambitions-product-development-lifecycle/scripts/new_document.py \
  --initiative-id PD-2026-08-ADAPTIVE-START-HERE \
  --phase scope
```

Required behavior:

- normalize and validate the initiative slug;
- generate stable initiative and document IDs;
- create the initiative directory when absent;
- copy the exact template for the requested phase;
- populate dates, phase, entry point, and upstream references;
- calculate and store upstream hashes;
- refuse to overwrite an existing document;
- refuse scope creation when required research is absent, stale, or not passed;
- refuse design creation when required scope is absent, stale, or not passed;
- support an explicit reduced lifecycle only when a valid authority path and
  rationale are supplied;
- print the created path and next required action;
- make no unrelated repository edits.

### 13.2 `validate_document.py`

Proposed interfaces:

```sh
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/validate_document.py \
  docs/product-development/adaptive-start-here/research.md

python3 .agents/skills/ambitions-product-development-lifecycle/scripts/validate_document.py \
  --initiative docs/product-development/adaptive-start-here

python3 .agents/skills/ambitions-product-development-lifecycle/scripts/validate_document.py \
  --all
```

Required validation:

- parse and validate TOML frontmatter;
- require correct document and initiative IDs;
- require the exact mandatory heading set and order;
- reject unknown status or verdict values;
- enforce valid status and verdict combinations;
- reject duplicate active content IDs;
- detect missing identifier sequences only when they indicate malformed or
  reassigned IDs; retired IDs may create intentional gaps;
- validate upstream paths, revisions, hashes, and passed status;
- detect stale downstream documents;
- require research source ledger entries for material findings;
- require requirement-to-finding or authority linkage;
- require requirement-to-acceptance linkage;
- require complete design traceability;
- reject placeholders such as `TODO`, `TBD`, `FIXME`, fill-in markers, and empty
  required sections in passed documents;
- reject `status = "passed"` with blocking findings or open questions that would
  require implementation invention;
- report errors with file, section, identifier, and remediation;
- exit nonzero on failure;
- provide a stable machine-readable JSON mode for CI and future tooling.

### 13.3 Semantic hash

The implementation must define a normalized semantic hash that excludes fields
whose change does not alter meaning, such as `updated_at`, formatting-only
whitespace, and review-history append-only metadata. It includes findings,
requirements, acceptance criteria, boundaries, risks, decisions, traceability,
and other semantic body content.

The exact normalization algorithm must be documented and unit-tested. A raw
file hash alone is insufficient because harmless formatting edits would
otherwise invalidate every downstream phase.

## 14. Code Quality integration

A lightweight validation lane may be added to the existing Code Quality workflow
when any of these paths change:

```text
.agents/skills/ambitions-product-development-lifecycle/**
docs/product-development/**
```

The lane runs the validator against affected initiative documents and the skill
fixture corpus. It must not add a process-only branch protection check beyond
the existing Code Quality workflow.

The workflow validates document consistency; it does not determine whether a
pull request is authorized to merge or whether an initiative is strategically
approved.

## 15. Canon handoff

Passed scope and design documents include `canon_targets` naming the owning
canon files or owner domains expected to change. During grooming or
implementation:

1. Review the canon targets against current generated routing.
2. Amend the owning normative source when the initiative changes durable product
   truth.
3. Add or update requirement IDs and verification links according to current
   canon conventions.
4. Run `python3 scripts/ambitions-canon.py check`.
5. Keep the product-development documents as provenance.

After the durable truth is incorporated, canon controls future work. A conflict
between an old initiative document and current canon is resolved in favor of
current canon unless a new lifecycle explicitly proposes changing it.

## 16. Implementation grooming handoff

A passed design does not contain a complete implementation plan. Its grooming
handoff provides the bounded inputs needed to create one:

- passed document paths, revisions, and hashes;
- canon amendments required before or with implementation;
- implementation seams and dependency ordering;
- affected modules and expected file classes;
- required tests and proof lanes;
- migration or compatibility requirements;
- legacy deletion obligations;
- known risks and stop conditions;
- requirement, acceptance, decision, and verification IDs.

The implementation-planning workflow converts those inputs into executable
work items. Grooming must return to an earlier lifecycle phase when the design
cannot be decomposed without inventing behavior.

## 17. Testing strategy for the skill

The skill itself is developed using documentation TDD: observe baseline agent
behavior without the skill, install the minimum skill and assets, rerun the same
pressure scenarios, then refine only for observed gaps.

### 17.1 Baseline pressure scenarios

At minimum, test fresh agents against these cases:

1. **Implementation pressure** — The user demands immediate SwiftUI coding from
   a vague feature idea and says documentation can be written later.
2. **Research-to-scope leakage** — The research evidence is incomplete, but the
   agent is encouraged to invent a bounded scope from plausible assumptions.
3. **Conditional-pass pressure** — A scope document has one material unresolved
   privacy question and many otherwise strong sections.
4. **Stale-upstream pressure** — Passed research changes after scope and design
   have already passed.
5. **Visual-proof inflation** — A preview screenshot exists, but runtime state,
   persistence, navigation, and recovery are unverified.
6. **Over-application pressure** — A spelling correction is presented, and the
   agent is asked to create the full three-document lifecycle.
7. **Canon conflict** — A historical passed design conflicts with current canon.
8. **Architecture invention** — The scope passes, but the design omits object
   ownership and concurrency behavior.
9. **Traceability omission** — A polished design covers the user journey but
   leaves two acceptance criteria without planned verification.
10. **Process bureaucracy** — An agent tries to turn document pass status into a
    required merge authorization receipt.

### 17.2 Expected post-skill behavior

The validated skill must cause fresh agents to:

- choose the correct lifecycle entry point;
- resist implementation before required upstream pass;
- distinguish evidence, inference, and assumption;
- return binary review verdicts;
- mark downstream documents stale;
- treat canon as current durable authority;
- reject preview-only runtime claims;
- avoid full lifecycle overhead for trivial work;
- surface ownership, privacy, accessibility, recovery, and verification gaps;
- preserve document pass as a quality state rather than merge authorization.

### 17.3 Script tests

Add unit tests for:

- ID and slug generation;
- template instantiation;
- overwrite refusal;
- upstream pass requirements;
- reduced-entry authority validation;
- frontmatter parsing;
- heading validation;
- status transitions;
- stable identifier uniqueness;
- semantic hashing;
- stale propagation;
- source-ledger enforcement;
- requirement and acceptance coverage;
- design traceability completeness;
- placeholder rejection;
- JSON diagnostic output;
- expected nonzero exit behavior.

Use temporary directories and fixture documents. Tests must not mutate real
initiative documents.

## 18. Rollout

### Phase 1 — Skill and contract implementation

Create the skill, assets, references, scripts, and test fixtures. Do not migrate
historical documents.

### Phase 2 — Pressure validation

Run documented before-and-after agent scenarios. Record exact baseline failures,
post-skill behavior, remaining loopholes, and any refinements.

### Phase 3 — Pilot initiative

Use one new, bounded Ambitions initiative to exercise all three document phases,
review loops, staleness handling, grooming handoff, canon update, implementation,
testing, and merge.

### Phase 4 — Code Quality integration

Add affected-path validation after the pilot demonstrates stable templates and
script behavior. Keep the check inside the existing Code Quality workflow.

### Phase 5 — Adopt as default

Update concise contributor routing so material initiatives load the lifecycle
skill. Do not rewrite historical evidence or force old projects into the new
shape unless they are actively reopened.

## 19. Failure handling

- **Missing upstream document:** stop phase creation and name the required prior
  phase or explicit reduced-entry authority.
- **Invalid frontmatter:** report the exact field and accepted values; do not
  rewrite silently during validation.
- **Stale dependency:** mark the dependent document stale and identify the first
  changed upstream revision.
- **Conflicting authority:** stop and resolve the conflict in the earliest owning
  document or canon source.
- **Unreachable source:** classify the claim as unverified; do not cite an
  inaccessible source as established evidence.
- **Oversized initiative:** decompose during research or scope before allowing
  scope or design to pass.
- **Validator defect:** preserve the document, fail safely, and repair the
  validator with tests before trusting its result.
- **Skill ambiguity:** add a pressure scenario reproducing the failure before
  changing the skill.

## 20. Security and privacy

The templates must prevent private user data, credentials, production secrets,
or unnecessary personal records from being copied into research or design
artifacts. Research uses public sources, repository evidence, or redacted
user-provided context unless the initiative specifically requires a protected
internal source.

The skill must not instruct agents to send Ambitions private-life graph content
to external research services. Any proposed external processing is an explicit
scope and design decision subject to current privacy canon.

Scripts operate only on repository files, use no network access, execute no
content embedded in documents, and treat paths as untrusted input. They reject
path traversal outside approved skill and product-development roots.

## 21. Accessibility and product-quality posture

The lifecycle embeds accessibility rather than adding it at final testing.
Research identifies accessibility constraints and user impact. Scope defines
requirements and acceptance criteria. Design resolves semantic structure,
focus, Dynamic Type, VoiceOver, Switch Control, Reduce Motion, Reduce
Transparency, contrast, interruption, error, and recovery behavior as relevant.
Implementation and testing then produce evidence against those obligations.

The same early-to-late treatment applies to privacy, local-first behavior,
persistence, migration, concurrency, replay, recovery, performance, and native
Apple conventions.

## 22. Acceptance criteria for implementing this design

The lifecycle system is complete when:

1. The repository contains the named skill directory and all specified files.
2. `SKILL.md` remains concise and delegates detailed templates and rubrics to
   assets and references.
3. All three templates contain their required sections and shared frontmatter.
4. The two utilities implement the described safe interfaces.
5. Unit tests cover the mechanical invariants.
6. Baseline and post-skill pressure-scenario evidence is committed.
7. Post-skill agents pass all required behavior scenarios without creating
   process-only merge authorization.
8. A pilot initiative successfully proceeds through research, scope, design,
   grooming, implementation, testing, and merge.
9. Upstream semantic changes correctly mark downstream documents stale.
10. The validator rejects incomplete traceability and placeholders in passed
    documents.
11. Required canon changes are incorporated into owning normative sources and
    the canon compiler remains green.
12. Code Quality integration, when added, runs only for affected paths and stays
    within the existing workflow.
13. Repository guidance clearly distinguishes material initiatives from trivial
    work that does not require the full lifecycle.

## 23. Resolved design choices

- Use one lifecycle skill rather than three independent skills.
- Store templates as skill assets and review rubrics as references.
- Store initiative documents under `docs/product-development/<initiative>/`.
- Use one file per phase with Git history for revisions.
- Use binary `PASS` or `NEEDS REVISION` review outcomes.
- Use semantic upstream hashes and automatic stale detection.
- Keep product-development documents pre-canon and provenance-oriented.
- Do not add process-only merge gates.
- Use deterministic scripts for structure, status, traceability, and staleness.
- Test the skill with before-and-after pressure scenarios before adoption.

## 24. Open questions

None block implementation planning. Implementation may refine command-line
spelling, internal parser decomposition, fixture organization, and exact test
file locations while preserving every behavioral contract and acceptance
criterion in this design.

## 25. Owner review gate

This written specification requires owner review before implementation planning.
Requested revisions must be applied here and the specification rechecked for
placeholders, contradictions, ambiguity, and excessive scope. After owner
approval, create the detailed implementation plan using the repository's
implementation-planning workflow.

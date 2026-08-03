# Ambitions Product Development Lifecycle Skill Design

**Date:** 2026-08-02  
**Status:** Revision 2 — producer review complete; consumer review pending  
**Repository baseline inspected:** `a758c727ea62ae0d7bc1ef634b8a59e5366970ae`  
**Target repository:** `agentdevan/ambitions`

## 1. Decision summary

Ambitions will use this development lifecycle for material product work:

```text
Idea
  → ChatGPT authors Research
  → Content review and revision until PASS
  → Codex consumption review and revision until PASS
  → ChatGPT authors Scope
  → Content review and revision until PASS
  → Codex consumption review and revision until PASS
  → ChatGPT authors Design
  → Content review and revision until PASS
  → Codex consumption review and revision until PASS
  → Codex grooms for implementation
  → Implement
  → Test
  → Merge
```

The system will be implemented as one portable, versioned skill package that both
ChatGPT and Codex use in different role modes. The repository copy is canonical.
Codex discovers it from `.agents/skills`; ChatGPT must use an installed copy of
the same package or explicitly load the canonical package before authoring.
Repo-local Codex discovery must never be assumed to make the skill available in
ChatGPT web or mobile.

The package contains three versioned document templates, producer and consumer
contracts, phase review rubrics, one deterministic lifecycle CLI, test fixtures,
and cross-product pressure validation.

The lifecycle is a product-quality and handoff system. It is not task
authorization, owner attestation, merge permission, or a process-only branch
gate. Current canon, source, tests, runtime evidence, and Code Quality remain the
implementation authority.

## 2. Core operating premise

ChatGPT creates the research, scope, and design documents. Codex must be able to
consume each committed document without reconstructing the prior conversation,
repeating the research, guessing missing product behavior, or loading the entire
document when a bounded summary and linked sections are sufficient.

A chat response is not a lifecycle document. A document becomes eligible for
Codex consumption only after it is persisted at its canonical repository path,
bound to a repository baseline, content-reviewed, and structurally valid.

Codex consumption is an actual phase gate, not a hypothetical rubric. For each
document, Codex verifies that the artifact is current, internally coherent,
properly bounded, traceable, and usable by the next phase. Codex does not replace
product judgment; it tests whether the documented judgment can be acted on
without invention.

## 3. Authority model

The three documents have different authority classes:

| Document | Authority class | May establish | Must not establish |
|---|---|---|---|
| Research | `evidence` | Findings, uncertainty, alternatives, recommendation, constraints | Committed scope or implementation architecture |
| Scope | `product-commitment` | User outcome, boundaries, requirements, acceptance criteria, release boundary | Unnecessary code structure or unresearched behavior |
| Design | `implementation-design` | Resolved interaction, state, architecture, data, recovery, accessibility, and proof design | Authority that conflicts with current canon or source reality |

All three remain pre-canon provenance. When durable product truth changes, the
owning canon source must be amended. Current canon wins over an older lifecycle
document unless a new lifecycle explicitly proposes changing that canon.

Codex must not implement from Research or Scope alone unless the initiative has
an explicitly validated reduced entry point whose current authority already
resolves Design.

## 4. Applicability

### 4.1 Complete lifecycle required

Use all three documents for material changes to one or more of:

- user outcome or externally observable product behavior;
- canonical object identity, ownership, lifecycle, projection, or consequence;
- information architecture, navigation, primary journey, or presentation;
- architecture, persistence, migration, concurrency, replay, atomicity,
  recovery, sync, or repair;
- private-data boundaries or off-device egress;
- accessibility semantics or equivalent interaction;
- performance budgets or operational behavior;
- a new system, surface, major capability, or contract;
- multiple domains requiring explicit reconciliation.

### 4.2 Reduced entry point

Work may begin at Scope or Design only when current canon and live source already
resolve every skipped-phase question. The document must cite exact authority,
its repository revision, and a rationale. Codex consumption review must verify
that the cited authority actually covers the skipped phase.

### 4.3 Lifecycle normally unnecessary

The complete chain is normally unnecessary for spelling corrections,
non-semantic comments, mechanical refactors with no contract change, bounded
tooling maintenance, tests for established behavior, and contained defects whose
expected result is already canonical. If investigation exposes a product choice,
the work re-enters the earliest unresolved phase.

## 5. Repository and package architecture

```text
.agents/skills/ambitions-product-development-lifecycle/
├── SKILL.md
├── agents/
│   └── openai.yaml
├── assets/
│   └── templates/
│       └── v1/
│           ├── research.md
│           ├── scope.md
│           └── design.md
├── references/
│   ├── lifecycle-contract.md
│   ├── producer-contract.md
│   ├── consumer-contract.md
│   ├── research-review-rubric.md
│   ├── scope-review-rubric.md
│   └── design-review-rubric.md
├── scripts/
│   └── ambitions_product_docs.py
└── tests/
    ├── fixtures/
    └── test_ambitions_product_docs.py

docs/product-development/
└── <initiative-slug>/
    ├── research.md
    ├── scope.md
    ├── design.md
    └── evidence/               # optional referenced annexes
```

There is one canonical package and one canonical template copy. ChatGPT
distribution must be generated from or installed from this package; manually
maintained duplicate templates are prohibited.

## 6. Skill discovery and deployment

The skill package follows the open skill format and is usable by both products,
but discovery differs by surface.

### 6.1 Codex

Codex discovers the canonical repository package at:

```text
$REPO_ROOT/.agents/skills/ambitions-product-development-lifecycle/
```

Root `AGENTS.md` receives one concise routing statement for material product
work. The skill description must front-load the trigger and boundary:

```yaml
---
name: ambitions-product-development-lifecycle
description: Use when creating, reviewing, or consuming an Ambitions research, scope, or design document for a material product, UX, or architecture change; do not use for routine work whose behavior is already canonical.
---
```

### 6.2 ChatGPT

The repository-local path alone does not guarantee availability in ChatGPT.
Initial delivery must provide and verify one supported ChatGPT invocation path:

1. install the same standalone skill package in a supported ChatGPT desktop
   surface; or
2. package the same skill as a private plugin for the owner's ChatGPT Work/web/
   mobile workflow; or
3. explicitly load the canonical `SKILL.md`, active template, and producer
   contract from the repository before authoring.

Option 3 is an operational fallback, not permission to copy or fork templates.
The skill version and template version written into the document must match the
canonical repository package.

`agents/openai.yaml` supplies a clear display name, short description, and
default authoring prompt. Implicit invocation remains enabled only after trigger
and over-application tests pass.

## 7. Role modes

One package exposes three tightly bounded role modes.

### 7.1 Producer mode — ChatGPT

Producer mode must:

1. load the canonical template and producer contract;
2. inspect current canon, source, tests, evidence, and existing initiative files;
3. record the exact repository baseline used;
4. use current external research where the question is time-sensitive;
5. write a self-contained artifact that does not depend on chat history;
6. preserve IDs, headings, authority boundaries, and traceability;
7. persist the document at the canonical repository path;
8. run or emulate structural validation when tools permit;
9. perform the content-integrity review lane;
10. stop at `needs-revision` when evidence, decisions, or access are insufficient.

Producer mode does not declare Codex consumption readiness.

### 7.2 Review mode — ChatGPT or a fresh reviewer

Content review attempts to falsify factual support, completeness, product logic,
boundaries, alternatives, privacy, accessibility, and internal consistency. It
binds its verdict to the exact document revision and contract hash.

A semantic edit invalidates the content-review verdict. A fresh context or fresh
agent is preferred. Self-review is allowed only when the review pass is explicit,
separate from drafting, and uses the same rubric and hash binding.

### 7.3 Consumer mode — Codex

Consumer mode must:

1. load root instructions, the lifecycle skill, and consumer contract;
2. validate document structure and current review binding;
3. compare the recorded repository baseline with current `HEAD`;
4. inspect changes to cited canon, source, tests, and owner domains;
5. verify authority class and upstream bindings;
6. read the handoff summary before loading linked detail sections;
7. test whether the next phase can proceed without invention;
8. return `PASS` or `NEEDS REVISION` with exact IDs and sections;
9. bind the consumer verdict to the current revision and contract hash;
10. set `status = "passed"` only when both review lanes pass the same hash.

Consumer review is not merge authorization and does not approve product strategy
beyond determining that the accepted strategy is coherent and actionable.

## 8. Canonical persistence and handoff

The canonical handoff is the committed repository file, not a pasted message,
attachment, local temporary file, or uncommitted draft.

A document is handoff-ready only when:

- it exists at `docs/product-development/<initiative>/<phase>.md`;
- its identity, schema, template, revision, and authority class are valid;
- its repository baseline is recorded;
- its content review passes the current revision and contract hash;
- its upstream bindings are current;
- structural validation passes.

Codex may consume an unpassed document only to perform consumer review. It must
not use it for implementation or downstream phase advancement.

## 9. Shared document contract

### 9.1 Required TOML frontmatter

```toml
+++
schema_version = 1
template_version = "research-v1"
skill_version = "1.0.0"

initiative_id = "PD-2026-08-ADAPTIVE-START-HERE"
document_id = "PD-2026-08-ADAPTIVE-START-HERE-RESEARCH"
document_type = "research"
authority_class = "evidence"
entry_point = "research"

status = "draft"
revision = 1
created_at = "2026-08-02"
updated_at = "2026-08-02"
repository_baseline_commit = "0123456789abcdef0123456789abcdef01234567"
external_research_as_of = "2026-08-02"
contract_hash = ""

content_review_verdict = "unreviewed"
content_review_revision = 0
content_review_hash = ""
consumer_review_verdict = "unreviewed"
consumer_review_revision = 0
consumer_review_hash = ""
blocking_findings = 0

canon_targets = []
supersedes = []

[[inputs]]
document_id = ""
path = ""
revision = 0
contract_hash = ""
authority_commit = ""
+++
```

Research omits empty `[[inputs]]`. Scope binds to passed Research. Design binds
to passed Scope. A reduced entry uses `[[inputs]]` entries for the exact canon or
approved design authority it relies on.

Parallel arrays for paths, revisions, and hashes are prohibited.

### 9.2 Status values

Allowed statuses:

- `draft`;
- `content-reviewed`;
- `needs-revision`;
- `passed`;
- `stale`;
- `superseded`.

`passed` requires:

- both verdicts equal `pass`;
- both review revisions equal the current revision;
- both review hashes equal the current contract hash;
- zero blocking findings;
- valid current inputs;
- successful structural and consumption validation.

### 9.3 Versioning

`schema_version` controls machine interpretation. `template_version` controls the
required headings and section contract. `skill_version` records the package used
by the author.

A new template version must not silently invalidate or reinterpret a previously
passed document. Validators retain support for active historical versions or
require an explicit migration. Migrations are reviewable, never automatic, and
invalidate prior review bindings when authority-bearing text changes.

## 10. Contract hash and revision binding

The system uses a deterministic **contract hash**, not a claimed semantic hash.
The tool does not attempt to decide whether two different sentences mean the
same thing.

The contract hash includes authority-bearing frontmatter and body sections. It
excludes the hash field itself, review metadata, timestamps, and append-only
review history. Normalization handles line endings, trailing whitespace, and
pure formatting rules documented by the tool.

Any textual change inside an authority-bearing section changes the contract
hash, including a spelling correction. This conservative invalidation is
intentional. The system may avoid revision churn only for changes confined to
explicitly excluded metadata or review-history fields.

Every semantic or authority-bearing edit increments `revision`, clears both
review verdicts and hashes, and may stale downstream documents. A verdict that
does not match the current revision and contract hash is invalid even if the
frontmatter still says `pass`.

## 11. Agent handoff summary

Every document begins with `## Agent handoff summary` immediately after
frontmatter. It is the first semantic section and has a hard maximum of 1,200
words.

It contains:

- one-sentence decision or finding;
- authority class and permitted use;
- repository baseline and research-as-of date;
- required upstream inputs;
- top decisions or findings by stable ID;
- protected constraints and explicit exclusions;
- unresolved blockers, which must be `None` for passage;
- exact next action;
- section-reading map for deeper context.

The summary is not a substitute for validation or the full contract. It is a
context-efficient routing layer for Codex.

Primary documents should remain concise. When evidence, comparisons, or visual
material would dominate the core contract, move it to referenced files under
`evidence/`. The primary document must still contain enough analysis and
conclusions to remain usable if Codex cannot access an external website.

## 12. Dual review gate

Each phase has two independent verdict lanes bound to the same revision and
contract hash.

### 12.1 Content-integrity review

This lane asks whether the document is factually supported, internally coherent,
appropriately bounded, and product-complete for its phase.

### 12.2 Codex-consumption review

This lane asks whether the next phase can consume the document without hidden
chat context, stale repository assumptions, missing authority, ambiguous IDs,
unbounded reading, or product invention.

For Research, the consumer question is whether Scope can be authored without
repeating research or guessing constraints. For Scope, it is whether Design can
resolve implementation behavior without inventing product requirements. For
Design, it is whether Codex can groom and implement without inventing behavior
or violating current canon and source.

### 12.3 Formal review output

```text
Verdict: PASS | NEEDS REVISION
Review lane: CONTENT | CONSUMER
Reviewed revision: <integer>
Reviewed contract hash: <sha256>

Blocking findings
Non-blocking improvements
Traceability gaps
Stale or conflicting inputs
Required revisions
Next permitted lifecycle phase
```

There is no conditional pass. Any authority-bearing revision invalidates both
lanes and reruns both reviews.

## 13. Research document contract

Research answers:

> What is true, what remains uncertain, what constraints exist, and which
> direction is best supported by evidence?

Required sections:

1. Agent handoff summary
2. Idea and problem statement
3. Research questions
4. Current Ambitions baseline
5. User and product evidence
6. Apple platform and ecosystem evidence
7. Technical feasibility
8. Privacy and local-first implications
9. Accessibility implications
10. Alternatives and tradeoffs
11. Findings
12. Recommended direction
13. Rejected directions
14. Remaining unknowns
15. Risk register
16. Source ledger
17. Handoff to Scope
18. Review history

Every material finding has a stable `FIND-*` ID and cites `SRC-*` or exact
repository evidence. Each source-ledger entry includes title, publisher or repo
path, URL when applicable, access date, temporal sensitivity, supported claim
IDs, and a concise evidence summary. Codex must not need network access merely to
understand why an accepted finding exists.

Research passes only when no unresolved unknown prevents a bounded scope choice,
meaningful alternatives were compared, current repo and canon were inspected,
time-sensitive claims are current, and recommendation follows from evidence.
Research must not preselect detailed implementation architecture.

## 14. Scope document contract

Scope answers:

> What exact product outcome are we committing to, and what are we explicitly
> not building?

Required sections:

1. Agent handoff summary
2. Research input and authority
3. Problem and desired user outcome
4. Target users and scenarios
5. In scope
6. Out of scope
7. Product requirements
8. Required states and behaviors
9. Acceptance criteria
10. Product invariants
11. Native Apple constraints
12. Privacy and data boundaries
13. Accessibility requirements
14. Offline, interruption, failure, and recovery expectations
15. Performance expectations
16. Dependencies and risks
17. Measurement and success evidence
18. Release boundary
19. Canon impact
20. Design brief
21. Open decisions
22. Review history

Each `REQ-*` is one observable obligation, cites supporting findings or current
authority, names its intended owner domain, and maps to one or more `AC-*`
entries. Each `AC-*` defines inspectable evidence and avoids subjective closure
without observable conditions.

Scope passes only when its outcome, boundaries, states, risks, dependencies,
canon targets, and release boundary are explicit, every requirement is
verifiable, and no open decision forces Design or implementation to invent
product behavior.

## 15. Design document contract

Design answers:

> How will the passed scope become a coherent, native, testable Ambitions
> implementation?

Required sections:

1. Agent handoff summary
2. Scope input and authority
3. Design principles and protected characteristics
4. User journey and information architecture
5. Canonical object ownership
6. State model
7. Command and consequence model
8. Screen and presentation behavior
9. Navigation, focus, dismissal, restoration, keyboard, and safe areas
10. SwiftUI composition
11. Domain and service boundaries
12. Persistence, migration, concurrency, replay, and atomicity
13. Offline behavior
14. Privacy and security
15. Accessibility
16. Motion, Reduce Motion, Reduce Transparency, contrast, and legibility
17. Error, interruption, recovery, rollback, and Undo
18. Performance and diagnostics boundaries
19. Testing strategy
20. Visual and runtime proof plan
21. File and module impact
22. Legacy deletion or supersession
23. Implementation seams and dependency order
24. Requirement-to-design traceability
25. Implementation grooming handoff
26. Open questions
27. Review history

Each `DESIGN-*` resolves one material decision, maps to `REQ-*`, `AC-*`, and
`VERIFY-*`, names its owner layer or module, records non-obvious rejected
alternatives, and defines failure and recovery where applicable.

The traceability matrix includes every requirement and acceptance criterion.
Design passes only when current canon and source do not contradict it, all
applicable states and platform behaviors are resolved, preview evidence is not
inflated into runtime proof, implementation seams are bounded, and Codex can
groom the work without product invention.

## 16. Codex consumption protocol

Codex reads in this order:

1. active `AGENTS.md` instruction chain;
2. lifecycle `SKILL.md` and consumer contract;
3. target document frontmatter and Agent handoff summary;
4. upstream handoff summaries and linked IDs;
5. current owning canon;
6. current source, tests, and changed paths relevant to cited authority;
7. full document sections only as needed to resolve the task.

Before accepting a document, Codex runs the lifecycle CLI in `consume` mode. It
must stop and return `NEEDS REVISION` when:

- the document is not at the canonical path;
- schema or template version is unsupported;
- review binding does not match current revision and hash;
- recorded repository baseline is absent or relevant authority changed;
- upstream inputs are stale, missing, or not passed;
- cited source evidence is unavailable and the document is not self-contained;
- authority class is exceeded;
- required IDs are orphaned or contradictory;
- the next phase requires inference not authorized by the document;
- current canon or source conflicts with the document.

A baseline commit difference alone does not automatically fail. Codex inspects
whether changed files affect cited canon, source owners, tests, dependencies, or
assumptions. Unrelated repository changes are reported but do not stale the
document.

## 17. Deterministic lifecycle CLI

Use one Python standard-library CLI to avoid duplicated parsers and inconsistent
state transitions:

```text
ambitions_product_docs.py new
ambitions_product_docs.py check
ambitions_product_docs.py hash
ambitions_product_docs.py review
ambitions_product_docs.py reconcile
ambitions_product_docs.py consume
```

Required behavior:

- instantiate the exact active template without overwrite;
- support producer-created files when shell execution was unavailable;
- parse and validate TOML frontmatter;
- validate schema, template, skill, IDs, headings, and authority class;
- compute the documented contract hash;
- validate review bindings and status combinations;
- validate structured `[[inputs]]` records;
- detect relevant repository-baseline drift;
- require finding-to-source, requirement-to-finding, requirement-to-acceptance,
  and design-to-verification traceability;
- reject placeholders and empty required sections in reviewable documents;
- record review verdicts only against the current revision and hash;
- explicitly mark or rebind stale documents through reviewable commands;
- never silently mutate files during `check` or CI;
- restrict writes to approved repository roots and reject path traversal;
- provide stable JSON output and nonzero failure exits.

The CLI may update metadata only through explicit write subcommands. Every write
prints the path, fields changed, previous value, new value, and next required
action.

## 18. Template evolution

Templates are immutable within a version. Improvements create `v2`, not an
in-place reinterpretation of `v1` documents.

A version change requires:

- migration rationale;
- compatibility decision for passed historical documents;
- validator coverage for each supported version;
- explicit migration command if migration is needed;
- review invalidation when authority-bearing content changes;
- a cross-product test proving ChatGPT and Codex load the same version.

## 19. Testing strategy

The skill is developed with documentation TDD: run pressure scenarios without
the skill, record failures, install the minimum contract, rerun the same cases,
and refine only for observed gaps.

Required scenario groups:

### 19.1 Producer scenarios

- ChatGPT lacks live repo access but attempts to pass Research.
- ChatGPT writes a polished chat response but does not persist the document.
- ChatGPT uses a stale template or skill version.
- ChatGPT invents evidence or silently fills an unknown.
- ChatGPT over-applies the lifecycle to a trivial correction.
- ChatGPT edits a passed revision without invalidating review bindings.

### 19.2 Consumer scenarios

- Codex receives only Design and hidden chat context is missing.
- Current canon changed after the recorded baseline.
- Research links external sources but omits evidence summaries.
- Scope has testable requirements but ambiguous out-of-scope behavior.
- Design is visually complete but omits data ownership or recovery.
- A preview screenshot is presented as runtime proof.
- A consumer attempts to implement from Research or Scope alone.

### 19.3 Cross-product fixture

A fixture initiative must be authored through the ChatGPT producer path and
consumed through the Codex path. The test proves:

- identical skill and template versions;
- canonical repository persistence;
- both review lanes bound to one revision and hash;
- bounded summary-first reading;
- stale detection after a relevant upstream or canon change;
- successful Research → Scope → Design → grooming handoff;
- no dependence on the original ChatGPT conversation.

### 19.4 CLI tests

Unit tests cover template creation, version support, IDs, TOML parsing, contract
hashing, review binding, status rules, input records, traceability, baseline
comparison, stale reconciliation, path safety, read-only checks, JSON output, and
nonzero failure behavior.

## 20. Delivery boundary

### 20.1 Initial implementation — required

1. Create the portable skill package, role contracts, versioned templates,
   lifecycle CLI, fixtures, and tests.
2. Add `agents/openai.yaml` and concise root `AGENTS.md` routing.
3. Establish and verify the owner's ChatGPT invocation path for the same package.
4. Run baseline and post-skill producer, consumer, and cross-product scenarios.
5. Complete one fixture initiative through all three phases and grooming handoff.
6. Leave historical initiative documents unchanged.

### 20.2 Follow-up adoption

1. Use the lifecycle for the first real bounded Ambitions initiative.
2. Refine only from observed producer or consumer failures.
3. Add affected-path Code Quality validation after standalone behavior is stable.
4. Measure revision churn, implementation invention, context usage, and proof
   gaps.

A real feature implementation is adoption evidence, not a blocker to completing
the lifecycle system.

## 21. Security, privacy, and offline posture

Templates must not copy credentials, production secrets, unnecessary personal
records, or private-life graph content into repository artifacts. Research uses
public sources, repository evidence, or appropriately redacted internal context.

The lifecycle CLI uses no network access, executes no document content, and
performs writes only inside approved roots. External research is summarized in
the document so Codex can consume accepted findings without network access.

## 22. Initial implementation acceptance criteria

The lifecycle system is complete when:

1. The canonical package and every specified file exist.
2. ChatGPT and Codex demonstrably load the same skill and template versions.
3. ChatGPT can create each canonical document without relying on hidden chat
   context or a local shell.
4. Codex can consume each document using summary-first routing and current repo
   verification.
5. Both review lanes bind to the same current revision and contract hash.
6. The CLI enforces structure, authority, traceability, versions, review binding,
   stale inputs, and safe writes.
7. Relevant repository or canon changes invalidate consumption; unrelated changes
   do not.
8. Research source evidence is reproducible and self-contained enough for Codex.
9. Scope cannot pass with product ambiguity that Design would need to invent.
10. Design cannot pass with implementation ambiguity, ownership gaps, or proof
    inflation.
11. A cross-product fixture completes Research, Scope, Design, and grooming.
12. Pressure tests correct observed baseline failures.
13. Current canon remains green after any required lifecycle-system amendment.
14. No process-only merge gate, owner receipt, or authorization ceremony is
    introduced.

## 23. Resolved design choices

- One canonical portable skill package serves both ChatGPT and Codex.
- Product-specific role modes are Producer, Content Review, and Consumer.
- Every phase requires both content and actual Codex-consumption review.
- The repository file, not chat history, is the canonical handoff.
- Each document declares a distinct authority class.
- Templates and schemas are versioned and immutable within a version.
- Review verdicts bind to exact revision and contract hash.
- A deterministic contract hash replaces unverifiable semantic-equivalence
  claims.
- Every document begins with a bounded Agent handoff summary.
- Codex uses summary-first, linked-section consumption.
- External evidence is summarized so accepted research survives offline use.
- One lifecycle CLI owns deterministic parsing and state transitions.
- ChatGPT deployment is explicitly verified rather than inferred from Codex
  repo-local discovery.

## 24. Open questions

None block the second review pass. Implementation planning may choose the exact
private ChatGPT distribution mechanism after checking the owner's supported
surface, but the final system must verify that ChatGPT uses the canonical package
and version rather than a copied prompt or divergent template.

## 25. Review gate

This revision has completed the producer-side ruthless review. It requires a
second, independent Codex-consumer review. If that pass finds no blocker after
revision, the specification is approved and may proceed directly to detailed
implementation planning.
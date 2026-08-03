# Ambitions Product Development Lifecycle Skill Design

**Date:** 2026-08-02  
**Status:** Revision 5 — final verification candidate  
**Repository baseline inspected:** `581fc28d8830e702e00ac76a9f15f11f57c05b80`  
**Target repository:** `agentdevan/ambitions`

## 1. Decision summary

Ambitions will use this lifecycle for material product work:

```text
Idea
  → ChatGPT authors Research
  → Seal exact revision
  → Content review and revision until PASS
  → Codex consumption review and revision until PASS
  → ChatGPT authors Scope
  → Seal exact revision
  → Content review and revision until PASS
  → Codex consumption review and revision until PASS
  → ChatGPT authors Design
  → Seal exact revision
  → Content review and revision until PASS
  → Codex consumption review and revision until PASS
  → Canon reconciliation and Codex implementation grooming
  → Implement
  → Test
  → Merge
```

The system is one portable, versioned skill package used by ChatGPT and Codex in
different role modes. The repository package is canonical. Codex discovers it
from `.agents/skills`; ChatGPT must use an installed or explicitly loaded copy
whose package and template hashes match the repository source.

The package contains three immutable versioned templates, producer and consumer
contracts, phase rubrics, one deterministic lifecycle CLI, fixtures, and
cross-product validation.

This is a product-quality and cross-agent handoff system. It is not task
authorization, owner attestation, merge permission, or a process-only branch
gate. Current canon, source, tests, runtime evidence, and Code Quality remain the
implementation authority.

## 2. Core operating premise

ChatGPT creates the Research, Scope, and Design documents. Codex must consume
each committed document without reconstructing chat history, repeating accepted
research, guessing missing behavior, or loading unbounded context.

A chat response is not a lifecycle document. A document becomes eligible for
review only after it is persisted at its canonical repository path and sealed to
an exact revision, contract hash, repository baseline, skill package, template,
and derived freshness set. A sealed document becomes eligible for downstream use
only after both review lanes pass that same revision and hash.

Codex consumption is an actual review lane. It verifies that the artifact is
current, bounded, traceable, self-contained, and usable by the next phase. Codex
does not replace product judgment; it determines whether the documented judgment
can be acted on without invention.

## 3. Authority model

| Document | Authority class | May establish | Must not establish |
|---|---|---|---|
| Research | `evidence` | Findings, uncertainty, alternatives, recommendation, constraints | Committed scope or implementation architecture |
| Scope | `product-commitment` | User outcome, boundaries, requirements, acceptance criteria, release boundary | Unnecessary code structure or unresearched behavior |
| Design | `implementation-design` | Resolved interaction, state, architecture, data, recovery, accessibility, and proof design | Undeclared authority that conflicts with current canon |

All three documents are pre-canon provenance. Current canon wins over an older
lifecycle document unless the current initiative explicitly declares a canon
delta. An explicit canon delta is a proposal, not active law, until the owning
canon source is amended and the canon compiler passes.

Codex must not implement from Research or Scope alone unless a validated reduced
entry point proves that current authority already resolves Design.

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

Work may begin at Scope or Design only when current canon and live source resolve
every skipped-phase question. The document cites exact authority, repository
commit, and rationale. Codex consumption review verifies that the authority
actually covers the skipped phase.

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
├── package-manifest.json
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
    └── evidence/               # optional, locally referenced annexes
```

There is one canonical package and one canonical template copy. ChatGPT
distribution is generated from or installed from this package. Manually
maintained duplicate templates are prohibited.

## 6. Skill identity, discovery, and deployment

### 6.1 Deterministic package identity

`package-manifest.json` identifies the operational package. It contains:

```json
{
  "manifest_schema": 1,
  "skill_version": "1.0.0",
  "files": [
    {"path": "SKILL.md", "sha256": "<lowercase-hex>"},
    {"path": "agents/openai.yaml", "sha256": "<lowercase-hex>"},
    {"path": "assets/templates/v1/research.md", "sha256": "<lowercase-hex>"}
  ]
}
```

The complete `files` array includes every operational file under `SKILL.md`,
`agents/`, `assets/`, `references/`, and `scripts/`. It excludes tests and the
manifest itself to avoid a hash cycle. Paths are repository-relative to the
skill root, sorted lexicographically, unique, and use `/` separators. Each file
hash is SHA-256 over its exact bytes.

The manifest is serialized as UTF-8 canonical JSON with sorted keys, compact
separators, and a terminal LF. `skill_package_hash` is lowercase SHA-256 over
those canonical manifest bytes, prefixed with `sha256:`. `template_hash` is the
prefixed exact-byte SHA-256 recorded for the selected template in the manifest.

The CLI regenerates and verifies the manifest. A missing, extra, renamed, or
content-changed operational file fails package verification until the manifest
and skill version are intentionally updated.

### 6.2 Codex discovery

Codex discovers the repository package at:

```text
$REPO_ROOT/.agents/skills/ambitions-product-development-lifecycle/
```

Root `AGENTS.md` receives one concise routing statement. The skill description
front-loads the trigger and boundary:

```yaml
---
name: ambitions-product-development-lifecycle
description: Use when creating, reviewing, or consuming an Ambitions research, scope, or design document for a material product, UX, or architecture change; do not use for routine work whose behavior is already canonical.
---
```

### 6.3 ChatGPT deployment

Repo-local Codex discovery does not guarantee ChatGPT availability. Initial
delivery must verify one supported path for the owner's actual ChatGPT surface:

1. the same standalone skill in a supported desktop surface;
2. the same skill packaged as a private plugin for ChatGPT Work/web/mobile; or
3. explicit loading of canonical `SKILL.md`, manifest, template, and producer
   contract from the repository as a documented fallback.

The document records both `skill_package_hash` and `template_hash`; matching
version strings alone are insufficient. `agents/openai.yaml` provides display
metadata and a default authoring prompt. Implicit invocation remains enabled only
after trigger and over-application tests pass.

## 7. Role modes

### 7.1 Producer mode — ChatGPT

Producer mode must:

1. load the canonical manifest, template, and producer contract;
2. inspect current canon, source, tests, evidence, and initiative files;
3. record the exact repository baseline and structured owner-path inputs;
4. use current external research when claims are time-sensitive;
5. write a self-contained artifact independent of chat history;
6. preserve IDs, authority boundaries, and traceability;
7. persist the file at the canonical path;
8. perform a non-authoritative preflight when deterministic tooling is
   unavailable;
9. obtain an authoritative seal before requesting a review verdict;
10. complete the content-integrity review lane;
11. stop at `needs-revision` when evidence, access, or decisions are insufficient.

Producer mode never declares Codex consumption readiness. A preflight is not a
substitute for the lifecycle CLI.

### 7.2 Content review mode — ChatGPT or a fresh reviewer

Content review attempts to falsify factual support, product logic, alternatives,
boundaries, privacy, accessibility, and internal consistency. It is performed
only after the current revision is sealed and binds to the exact revision and
contract hash.

A fresh context or agent is preferred. Self-review is permitted only as a
separate explicit pass using the same rubric. Any authority-bearing edit
invalidates the seal and both verdicts.

### 7.3 Consumer mode — Codex

Consumer mode must:

1. load active instructions, the lifecycle skill, and consumer contract;
2. verify package identity and recompute the sealed contract hash;
3. compare the baseline commit with current `HEAD` using the derived freshness
   set and semantic inspection of relevant changes;
4. verify template, authority class, evidence, and upstream bindings;
5. read the handoff summary before linked detail sections;
6. test whether the next phase can proceed without invention;
7. return `PASS` or `NEEDS REVISION` with exact IDs and sections;
8. record the consumer review only through an explicit lifecycle CLI write;
9. set `passed` only when both lanes pass the same revision and hash.

Consumer review is not merge authorization and does not replace product
approval. It tests actionability and current-repository coherence.

## 8. Canonical persistence and handoff

The canonical handoff is the committed repository file, not pasted text,
attachment, temporary file, or uncommitted draft.

A document is handoff-ready only when:

- it exists at `docs/product-development/<initiative>/<phase>.md`;
- identity, versions, package hashes, revision, and authority class are valid;
- repository baseline and structured owner paths are recorded;
- the current revision is sealed and its stored hash recomputes exactly;
- the content review passes that revision and contract hash;
- upstream bindings and evidence-file hashes are current;
- authoritative structural validation passes.

Codex may consume an unpassed document only to review it. It must not use it for
implementation or downstream phase advancement.

## 9. Shared document contract

### 9.1 Required TOML frontmatter

```toml
+++
schema_version = 1
template_version = "research-v1"
template_hash = "sha256:<hash>"
skill_version = "1.0.0"
skill_package_hash = "sha256:<hash>"

authoring_surface = "chatgpt"
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
content_blocking_findings = 0
consumer_review_verdict = "unreviewed"
consumer_review_revision = 0
consumer_review_hash = ""
consumer_blocking_findings = 0

canon_targets = []
canon_delta_ids = []
source_owner_paths = []
test_owner_paths = []
dependency_paths = []
additional_freshness_paths = []
freshness_paths = []
supersedes = []

[[inputs]]
kind = "lifecycle-document"
authority_id = "PD-2026-08-ADAPTIVE-START-HERE-RESEARCH"
path = "docs/product-development/adaptive-start-here/research.md"
revision = 1
contract_hash = "sha256:<hash>"
commit = "0123456789abcdef0123456789abcdef01234567"

[[evidence_files]]
path = "docs/product-development/adaptive-start-here/evidence/comparison.md"
sha256 = "<hash>"
role = "supports FIND-003 and FIND-004"
+++
```

Research omits empty `[[inputs]]`. Parallel arrays for paths, revisions, and
hashes are prohibited. `freshness_paths` is CLI-managed and must be empty in a
new unsealed template.

### 9.2 Typed input schemas

The validator enforces these exact input records:

| `kind` | Required fields | Permitted use |
|---|---|---|
| `lifecycle-document` | `authority_id`, `path`, `revision`, `contract_hash`, `commit` | Scope-to-Research and Design-to-Scope binding |
| `canon` | `authority_id`, `path`, `commit` | Reduced entry from current normative authority |
| `approved-design` | `authority_id`, `path`, `revision`, `contract_hash`, `commit` | Reduced Design entry from a separately approved design authority |
| `repository-evidence` | `authority_id`, `path`, `commit` | Exact source, test, or evidence authority needed to justify reduced entry |

Unknown kinds fail validation. Fields not listed for the selected kind fail
validation unless added by a future schema version. Every path must be repository
relative and remain inside the repository root.

### 9.3 Derived freshness set

Authors declare exact `canon_targets`, `source_owner_paths`, `test_owner_paths`,
`dependency_paths`, and optional `additional_freshness_paths`. `seal` derives
`freshness_paths` as the sorted, deduplicated union of:

- all declared owner and dependency path arrays;
- every `inputs[].path`;
- every `evidence_files[].path`;
- current generated canon routing when `canon_targets` is non-empty;
- the skill package manifest and active template path.

Authors may expand freshness through `additional_freshness_paths` but cannot
remove a derived path. The validator rejects a manually altered or incomplete
`freshness_paths` array.

The phase rubrics also require reviewers to verify that declared owners cover all
repository evidence and all canon/source/test areas on which material findings,
requirements, decisions, or proof obligations depend. Deterministic derivation
prevents omission of declared authority; review prevents omission of undeclared
but materially relied-on authority.

### 9.4 Status values and transitions

Allowed statuses:

- `draft`;
- `sealed`;
- `content-reviewed`;
- `needs-revision`;
- `passed`;
- `stale`;
- `superseded`.

The state machine is deterministic:

| Current state | Command/result | Next state | Required side effects |
|---|---|---|---|
| absent | `new` | `draft` | Create exact template with revision `1`; no hash or verdicts |
| `draft` or `needs-revision` | `seal` succeeds | `sealed` | Derive freshness, compute/store hash, clear both review lanes |
| `sealed` | content review `PASS` | `content-reviewed` | Record content verdict and append review history |
| `sealed` | content review `NEEDS REVISION` | `needs-revision` | Record blockers and append review history |
| `content-reviewed` | consumer review `PASS` | `passed` | Record consumer verdict and append review history |
| `content-reviewed` | consumer review `NEEDS REVISION` | `needs-revision` | Record blockers and append review history |
| `passed` | relevant upstream or evidence drift | effective `stale` | Read-only checks fail; explicit `reconcile --mark-stale` persists `stale` |
| `stale` | `reconcile --reopen` | `draft` | Increment revision, update inputs/baseline, clear seal and both reviews |
| any non-superseded state | `supersede` | `superseded` | Record replacement document and reason |

Authority-bearing edits are permitted only in `draft` or `needs-revision`.
A `stale` document must first run `reconcile --reopen`. Editing a sealed,
content-reviewed, passed, stale, or superseded body directly is invalid. The
validator detects a mismatched stored hash and fails even when status was not
changed.

`passed` requires both verdicts and blocker counts to pass the same current
revision and contract hash, valid current inputs and evidence hashes, and
successful structural and consumer validation.

### 9.5 Versioning

`schema_version` controls machine interpretation. `template_version` controls
headings and section contracts. `skill_version` identifies the package release.
The package and template hashes prove exact content identity.

Templates are immutable within a version. A new version does not silently
reinterpret passed historical documents. Validators retain explicit support or
require a reviewable migration that invalidates affected review bindings.

## 10. Exact contract-hash algorithm

The system uses a deterministic **contract hash**. It does not infer semantic
equivalence.

### 10.1 Included frontmatter

The canonical frontmatter projection includes:

- schema, template, and skill versions and hashes;
- authoring surface;
- initiative and document identity;
- document type, authority class, and entry point;
- repository baseline and external research date;
- canon targets, canon delta IDs, owner/dependency arrays, derived freshness,
  and supersession IDs;
- canonicalized `inputs` and `evidence_files` records.

### 10.2 Excluded frontmatter

The projection excludes:

- `status`, `revision`, `created_at`, and `updated_at`;
- `contract_hash`;
- all review verdict, review hash, and blocker-count fields.

Reviews bind separately to both revision and contract hash.

### 10.3 Body normalization

The CLI:

1. removes the `Review history` heading and all descendant content;
2. converts line endings to LF;
3. removes trailing whitespace on each line;
4. removes leading and trailing blank lines;
5. preserves all other text, heading order, code, tables, and internal spacing.

### 10.4 Canonical serialization

The included frontmatter is serialized as UTF-8 canonical JSON with keys sorted,
compact separators, arrays preserved except set-like path arrays sorted and
deduplicated, and structured records sorted by `kind`, `path`, and
`authority_id`. The hash input is:

```text
<canonical-frontmatter-json>\n---BODY---\n<normalized-body>
```

The contract hash is lowercase SHA-256 prefixed with `sha256:`.

Any textual change in an included body section changes the hash, including a
spelling correction. This conservative invalidation is intentional. Every
authority-bearing edit increments `revision`, clears the seal and both review
lanes, and may stale downstream documents.

## 11. Agent handoff summary

Every document begins with `## Agent handoff summary` immediately after
frontmatter. It is the first included body section and has a hard maximum of
1,200 words.

It contains:

- one-sentence finding or decision;
- authority class and permitted use;
- repository baseline and research-as-of date;
- required upstream inputs;
- top findings or decisions by stable ID;
- protected constraints and explicit exclusions;
- declared canon deltas;
- unresolved blockers, which must be `None` for passage;
- exact next action;
- section-reading map for deeper context.

The summary routes Codex; it does not replace the full contract. Large evidence,
comparisons, or visuals move to hashed files under `evidence/`. The primary
document remains self-contained enough to understand accepted conclusions
without external network access.

## 12. Dual review gate and durable review record

Each phase has two verdict lanes bound to the same sealed revision and hash.

### 12.1 Content-integrity review

Determines whether the document is factually supported, internally coherent,
appropriately bounded, and complete for its authority class.

### 12.2 Codex-consumption review

Determines whether the next phase can proceed without hidden conversation state,
stale repository assumptions, missing authority, unbounded reading, or product
invention.

For Research, Codex tests whether Scope can be authored without redoing research.
For Scope, it tests whether Design can be authored without inventing product
requirements. For Design, it tests whether canon reconciliation and
implementation grooming can proceed without inventing behavior.

### 12.3 Formal review output

```text
Verdict: PASS | NEEDS REVISION
Review lane: CONTENT | CONSUMER
Review ID: REV-CONTENT-001
Reviewed revision: <integer>
Reviewed contract hash: sha256:<hash>

Blocking findings
Non-blocking improvements
Traceability gaps
Stale or conflicting inputs
Required revisions
Next permitted lifecycle phase
```

The lifecycle CLI `review` command requires a sealed document, verifies the
submitted revision and hash, atomically updates lane-specific frontmatter, and
appends the complete review entry under `Review history`. Review-history entries
are append-only, have stable IDs, record reviewer surface and date, and are
excluded from the contract hash. A revision invalidates both lanes; there is no
conditional pass.

## 13. Freshness and repository-drift contract

Consumer review compares `repository_baseline_commit..HEAD` against the derived
`freshness_paths`:

1. no changed freshness path: report unrelated drift and continue;
2. changed freshness path: perform semantic inspection and return pass only when
   the change cannot affect a finding, requirement, decision, dependency, or
   proof obligation;
3. missing baseline or unreachable commit: `NEEDS REVISION`;
4. changed package or template hash: use the document's declared supported
   version; do not reinterpret it under the new package.

Path intersection is a conservative filter, not the final semantic judgment.
Each time-sensitive external source records an access date and recheck trigger in
the Source ledger. Expired or triggered evidence blocks consumption until
refreshed or explicitly shown to remain valid.

## 14. Research document contract

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

Every material finding has `FIND-*` and cites `SRC-*` or exact repository
evidence. Source entries include title, publisher or path, URL when applicable,
access date, temporal sensitivity, recheck trigger, supported IDs, and concise
evidence summary. Evidence annexes are hashed in frontmatter.

Research passes only when no unknown prevents a bounded scope choice, meaningful
alternatives were compared, current repo and canon were inspected, time-sensitive
evidence is current, and recommendation follows from evidence. It must not lock
detailed implementation architecture.

## 15. Scope document contract

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
19. Canon impact and proposed canon deltas
20. Design brief
21. Open decisions
22. Review history

Each `REQ-*` is one observable obligation, cites findings or authority, names its
intended owner domain, and maps to `AC-*`. Each `AC-*` defines inspectable
evidence.

A proposed canon change receives `CANON-DELTA-*` and records the current authority,
proposed replacement or amendment, rationale, affected requirements, and
migration or compatibility implications.

Scope passes only when outcome, boundaries, states, risks, dependencies, canon
targets, canon deltas, and release boundary are explicit, requirements are
verifiable, and no open decision forces Design or implementation invention.

## 16. Design document contract

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
22. Current-source delta and legacy deletion
23. Canon reconciliation plan
24. Implementation seams and dependency order
25. Requirement-to-design traceability
26. Implementation grooming handoff
27. Open questions
28. Review history

Each `DESIGN-*` resolves one material decision, maps to `REQ-*`, `AC-*`, and
`VERIFY-*`, names an owner layer, records non-obvious rejected alternatives, and
defines failure and recovery where applicable.

Design may intentionally differ from current source and may propose canon
changes. It passes only when those deltas are explicit, scoped, feasible, and
traceable. Undeclared conflict with canon or source is a blocker. Preview evidence
must not be represented as runtime proof, implementation seams must be bounded,
and Codex must be able to groom without product invention.

## 17. Codex consumption protocol

Codex reads in this order:

1. active `AGENTS.md` instruction chain;
2. lifecycle `SKILL.md` and consumer contract;
3. target frontmatter and Agent handoff summary;
4. upstream summaries and linked IDs;
5. current owning canon and declared canon deltas;
6. current source, tests, and derived-freshness diffs;
7. full sections only as needed.

Before acceptance, Codex runs `check` and `consume`. It returns
`NEEDS REVISION` when:

- canonical path, identity, versions, manifest, or package hashes are invalid;
- seal, contract hash, or review binding is stale;
- baseline or owner/freshness data is missing;
- relevant repo changes are unreconciled;
- inputs or evidence hashes are stale;
- external evidence is expired or non-self-contained;
- authority class is exceeded;
- IDs or traceability are incomplete;
- the next phase requires unauthorized inference;
- canon or source conflict is undeclared;
- declared deltas omit consequences, migration, or proof obligations.

A baseline commit difference alone does not fail. Unrelated drift is reported and
ignored after path and semantic inspection.

## 18. Deterministic lifecycle CLI

Use one Python standard-library CLI:

```text
ambitions_product_docs.py package
ambitions_product_docs.py new
ambitions_product_docs.py check
ambitions_product_docs.py hash
ambitions_product_docs.py seal
ambitions_product_docs.py review
ambitions_product_docs.py reconcile
ambitions_product_docs.py consume
ambitions_product_docs.py supersede
```

`check`, `hash`, and `consume` are read-only. `package`, `new`, `seal`, `review`,
`reconcile`, and `supersede` are explicit write commands. `package --check` is
read-only; `package --write` regenerates the manifest.

### 18.1 `seal` contract

`seal` is the only command that may establish or replace `contract_hash` and
`freshness_paths`. It:

1. requires a writable state;
2. verifies package and template identity;
3. validates schema, headings, typed inputs, evidence hashes, declared owners,
   dependencies, and additional freshness paths;
4. derives and writes the exact freshness set;
5. requires revision to have increased after a previously sealed contract was
   reopened;
6. computes and writes the exact contract hash;
7. clears both review lanes and blocker counts;
8. changes status to `sealed`;
9. appends a non-review seal event to Review history;
10. prints the sealed revision, hash, freshness set, and next review lane.

### 18.2 General CLI behavior

The CLI must:

- instantiate exact templates without overwrite;
- support producer-created drafts when shell execution was unavailable;
- parse TOML and validate all schema variants;
- generate and verify the package manifest and template hashes;
- implement the exact contract-hash algorithm;
- validate seals, review records, and status combinations;
- validate typed inputs and evidence-file hashes;
- derive freshness and compare baseline diffs against it;
- require finding-to-source, requirement-to-finding, requirement-to-acceptance,
  design-to-verification, and canon-delta traceability;
- reject placeholders and empty required sections before sealing;
- append seal and review records atomically;
- explicitly mark or reopen stale documents;
- never mutate during CI or read-only commands;
- restrict writes to approved roots and reject path traversal;
- emit stable JSON diagnostics and nonzero failure exits.

Every write prints path, changed fields, previous and new values, and next action.

## 19. Canon reconciliation

After Design passes and before implementation grooming is final:

1. resolve each `canon_target` and `CANON-DELTA-*` against current generated
   routing;
2. classify the delta as amendment, addition, supersession, or no canon change;
3. update the owning canon source before or atomically with implementation;
4. update requirement and verification links under current canon conventions;
5. run `python3 scripts/ambitions-canon.py check`;
6. re-run Design consumption after relevant canon changes;
7. reopen Design only if reconciliation changes an authority-bearing decision.

A passed Design authorizes planning for declared deltas; it does not make those
deltas normative before canon reconciliation.

## 20. Template evolution

Templates are immutable within a version. Improvements create a new version.
Version changes require migration rationale, compatibility policy, validator
coverage, explicit migration commands where needed, review invalidation for
contract changes, and a cross-product proof that ChatGPT and Codex use identical
package and template hashes.

## 21. Testing strategy

Develop the skill with documentation TDD: record baseline failures, add minimum
contracts, rerun identical scenarios, and refine only for observed gaps.

### 21.1 Producer scenarios

- no live repo access but Research is marked passed;
- polished chat output is not persisted;
- stale package or template is used;
- evidence or unknowns are invented;
- trivial work triggers the full lifecycle;
- a passed body changes without reopening and resealing;
- a preflight is mistaken for authoritative validation.

### 21.2 Consumer scenarios

- Design arrives without chat history;
- relevant and unrelated repo changes occur after baseline;
- an author omits a materially relied-on owner path;
- source links lack evidence summaries;
- evidence annex content changes without hash update;
- Scope has ambiguous exclusions;
- Design omits ownership or recovery;
- current source differs intentionally but the delta is undeclared;
- a canon delta is declared without migration or proof consequences;
- preview evidence is inflated;
- implementation starts from Research or Scope alone.

### 21.3 Cross-product fixture

A fixture initiative is authored through ChatGPT and consumed through Codex. It
proves identical package/template hashes, canonical persistence, authoritative
sealing, derived freshness, durable review records, summary-first reading,
relevant-drift detection, evidence-hash checking, Research → Scope → Design →
canon reconciliation → grooming, and independence from the original chat.

### 21.4 CLI tests

Tests cover package manifest generation, templates, versions, package hashes,
IDs, TOML, canonical hashing, sealing, freshness derivation, incomplete
freshness rejection, illegal post-seal edits, review history, state transitions,
typed inputs, evidence hashes, relevant drift, canon deltas, traceability, stale
reconciliation, path safety, read-only behavior, JSON output, and failure exits.

## 22. Delivery boundary

### 22.1 Initial implementation — required

1. Create the portable package, manifest, role contracts, immutable templates,
   CLI, fixtures, and tests.
2. Add `agents/openai.yaml` and concise root routing.
3. Verify the owner's actual ChatGPT invocation path against canonical package
   and template hashes.
4. Run baseline and post-skill producer, consumer, and cross-product scenarios.
5. Complete one fixture through all document phases, canon reconciliation
   simulation, and grooming handoff.
6. Leave historical documents unchanged.

### 22.2 Follow-up adoption

Use the first real bounded initiative, refine only from observed failures, add
Code Quality validation after stability, and measure revision churn,
implementation invention, context use, and proof gaps.

A real feature implementation is adoption evidence, not a blocker to completing
the lifecycle system.

## 23. Security, privacy, and offline posture

Templates must not copy credentials, production secrets, unnecessary personal
records, or private-life graph content into repository artifacts. Research uses
public sources, repository evidence, or appropriately redacted internal context.

The lifecycle CLI uses no network access, executes no document content, and
writes only inside approved roots. Accepted external evidence is summarized so
Codex can consume it offline.

## 24. Initial implementation acceptance criteria

The system is complete when:

1. The canonical package, manifest, and every specified file exist.
2. ChatGPT and Codex load identical package and template hashes.
3. ChatGPT can create canonical drafts without hidden chat context or a local
   shell; authoritative sealing and review binding still occur before pass.
4. Codex consumes each document using summary-first routing and current-repo
   verification.
5. Both review lanes bind to one sealed revision and contract hash and have
   durable append-only review records.
6. Package identity, the exact document-hash algorithm, and the seal transition
   are implemented and tested.
7. Typed inputs, evidence hashes, owner declarations, derived freshness, and
   relevant drift are enforced.
8. Relevant changes invalidate consumption; unrelated changes do not.
9. Research is reproducible and self-contained enough for offline Codex use.
10. Scope cannot pass with product ambiguity Design would need to invent.
11. Design cannot pass with undeclared source/canon differences, ownership gaps,
    or proof inflation.
12. Declared canon deltas include authority, consequences, migration, and proof.
13. A cross-product fixture completes all phases and grooming handoff.
14. Pressure tests correct observed baseline failures.
15. Canon reconciliation remains green.
16. No process-only merge gate or authorization ceremony is introduced.

## 25. Resolved design choices

- One canonical portable package serves both products.
- Producer, Content Review, and Consumer are distinct role modes.
- Each phase requires actual Codex consumption review.
- Repository files, not chat history, are canonical handoffs.
- Documents declare distinct authority classes.
- A canonical package manifest and exact hashes prevent cross-product drift.
- An explicit seal establishes the reviewable revision, freshness set, and hash.
- Review verdicts bind to exact sealed revision and deterministic contract hash.
- Review records are durable and append-only.
- Typed inputs eliminate parallel-array ambiguity.
- A complete state machine prevents implicit lifecycle transitions.
- Freshness is derived from structured owners and cannot be weakened manually.
- Evidence annexes are content-hashed.
- Declared canon/source deltas are permitted; undeclared conflicts block.
- Every document starts with a bounded Agent handoff summary.
- Codex reads summaries and linked sections before full documents.
- One lifecycle CLI owns deterministic identity, validation, and transitions.

## 26. Open questions

None block final verification or implementation planning. The implementation plan
may select the supported ChatGPT installation mechanism after checking the
owner's available surface, but it must deliver and verify one mechanism before
the lifecycle system is complete.

## 27. Review gate

Revision 5 incorporates both ruthless review passes and all final mechanical
repairs. Approval requires verification that package identity, sealing,
typed-input schemas, derived freshness, state transitions, review binding,
authority deltas, and the cross-product handoff are internally consistent and
directly implementable.
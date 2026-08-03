+++
schema_version = 1
template_version = "scope-v1"
template_hash = "sha256:94840a4ce88a5be28f9ba2154a5aa025d1f3923618389fd2648bfeb4ce41bb6e"
skill_version = "1.0.0"
skill_package_hash = "sha256:b810179fdc59fb037091b03502b226d996d9ea128cde7118d60eee46e7e178cf"

authoring_surface = "chatgpt"
initiative_id = "PD-2026-08-LIFECYCLE-FIXTURE"
document_id = "PD-2026-08-LIFECYCLE-FIXTURE-SCOPE"
document_type = "scope"
authority_class = "product-commitment"
entry_point = "scope"

status = "sealed"
revision = 1
created_at = "2026-08-03"
updated_at = "2026-08-03"
repository_baseline_commit = "5d224acfd5f4ad7063be14ae4b3f0a030a195ccd"
external_research_as_of = "2026-08-03"
contract_hash = "sha256:c36b663f358c3b23170b2a455274d70c2035afa79eb0f860c6cf628b27afef58"

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
source_owner_paths = [".agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/package_identity.py", ".agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/repository.py", ".agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py", ".agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py"]
test_owner_paths = [".agents/skills/ambitions-product-development-lifecycle/tests/test_ambitions_product_docs.py"]
dependency_paths = ["AGENTS.md", ".agents/skills/ambitions-product-development-lifecycle/SKILL.md", ".agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/scope.md", ".agents/skills/ambitions-product-development-lifecycle/package-manifest.json", ".agents/skills/ambitions-product-development-lifecycle/references/lifecycle-contract.md", ".agents/skills/ambitions-product-development-lifecycle/references/producer-contract.md", ".agents/skills/ambitions-product-development-lifecycle/references/scope-review-rubric.md", "docs/canon/CONSTITUTION.md", "docs/canon/generated/CODEX_START_HERE.md", "docs/product-development/lifecycle-fixture/evidence/comparison.md"]
additional_freshness_paths = []
freshness_paths = [".agents/skills/ambitions-product-development-lifecycle/SKILL.md", ".agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/scope.md", ".agents/skills/ambitions-product-development-lifecycle/package-manifest.json", ".agents/skills/ambitions-product-development-lifecycle/references/lifecycle-contract.md", ".agents/skills/ambitions-product-development-lifecycle/references/producer-contract.md", ".agents/skills/ambitions-product-development-lifecycle/references/scope-review-rubric.md", ".agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/package_identity.py", ".agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/repository.py", ".agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py", ".agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py", ".agents/skills/ambitions-product-development-lifecycle/tests/test_ambitions_product_docs.py", "AGENTS.md", "docs/canon/CONSTITUTION.md", "docs/canon/generated/CODEX_START_HERE.md", "docs/product-development/lifecycle-fixture/evidence/comparison.md", "docs/product-development/lifecycle-fixture/research.md"]
supersedes = []

[[inputs]]
kind = "lifecycle-document"
authority_id = "PD-2026-08-LIFECYCLE-FIXTURE-RESEARCH"
path = "docs/product-development/lifecycle-fixture/research.md"
revision = 3
contract_hash = "sha256:850dea049c234d05bc54493ee5c6adde18c15f438a27d1c1cfba7bbc953042c1"
commit = "5d224acfd5f4ad7063be14ae4b3f0a030a195ccd"

[[evidence_files]]
path = "docs/product-development/lifecycle-fixture/evidence/comparison.md"
sha256 = "d7d291725a25ad4ad14f7e8804cb5dfc88c480268203a635d2f87ac8a4590010"
role = "Repository-only comparison evidence for relevant-versus-unrelated drift and fixture boundaries"
+++

## Agent handoff summary

`Lifecycle Fixture` is a synthetic, documentation-only lifecycle initiative. This Scope commits only the observable repository-documentation obligations needed for a later Design document to continue the fixture from the exact passed Research handoff. It does not propose or authorize an Ambitions feature, user-facing behavior, canon change, implementation, merge, deployment, or release.

The sole lifecycle authority is `PD-2026-08-LIFECYCLE-FIXTURE-RESEARCH`, revision 3, contract hash `sha256:850dea049c234d05bc54493ee5c6adde18c15f438a27d1c1cfba7bbc953042c1`, committed at `5d224acfd5f4ad7063be14ae4b3f0a030a195ccd`. Requirements below convert Research findings into inspectable obligations for the fixture document chain: exact upstream binding, self-contained traceability, complete owner paths, explicit exclusions, deterministic acceptance criteria, revision-bound lifecycle state, and separation of relevant repository drift from unrelated changes.

The intended reader is a later lifecycle producer or reviewer working only from committed repository files. That reader must be able to determine what the fixture promises, what it excludes, which repository paths own its mechanics, how each requirement is accepted, and which questions are deliberately closed. The current revision's lifecycle status, seal and contract binding, freshness, and review state are determined only by frontmatter and recorded lifecycle events. No body statement independently establishes those facts or any canon activation, implementation readiness, merge readiness, or release readiness.

## Research input and authority

Upstream lifecycle input: `PD-2026-08-LIFECYCLE-FIXTURE-RESEARCH`, revision 3, `sha256:850dea049c234d05bc54493ee5c6adde18c15f438a27d1c1cfba7bbc953042c1`, commit `5d224acfd5f4ad7063be14ae4b3f0a030a195ccd`.

This Scope consumes `FIND-001` through `FIND-009`, the Research source ledger, risk register, owner paths, evidence binding, and its synthetic non-product boundary. The Research remains evidence authority; this Scope may commit only the fixture's documentation obligations. It may not reinterpret repository mechanics into Ambitions product behavior or select implementation architecture.

The exact upstream binding is immutable for this revision. Historical Research revisions, their seals, contract hashes, or review records are context only and cannot substitute for revision 3 at the named commit. No originating chat, prior lifecycle conversation, hidden expected answer, lifecycle design specification, implementation plan, SDD ledger, baseline scoring, or local checkout is an input to this Scope.

## Problem and desired user outcome

The repository has executable lifecycle mechanics and a passed synthetic Research document, but the committed human-readable chain needs a Scope that states exactly what a documentation-only fixture must guarantee before Design can proceed without inventing behavior.

The desired outcome is that a repository reader can inspect one committed Scope file and unambiguously determine:

- the exact passed Research revision being consumed;
- the synthetic, non-product, non-canon, non-implementation boundary;
- the complete observable obligations and acceptance evidence;
- the repository owner paths that control package identity, lifecycle transitions, validation, drift classification, and acceptance coverage;
- the distinction between relevant and unrelated repository drift;
- the absence of unresolved product or implementation decisions.

This outcome concerns lifecycle-document portability and traceability only. It creates no Ambitions user outcome and makes no claim that the application has changed.

## Target users and scenarios

Primary users are repository maintainers, lifecycle producers, Content reviewers, and Consumer reviewers evaluating the portable lifecycle package from committed files.

The supported scenarios are:

1. A later Design producer starts from this committed Scope and the exact recorded Research binding without access to any prior chat.
2. A reviewer traces every `REQ-*` obligation to Research findings or repository authority and to one or more `AC-*` conditions.
3. A consumer identifies which changed repository paths are relevant because they are declared owners, dependencies, inputs, evidence, package identity, or template identity.
4. A consumer sees unrelated changed paths reported separately rather than treated as automatic blockers.
5. A reader verifies that the fixture neither changes product canon nor asserts implementation, merge, or release authority.

No scenario includes an Ambitions end user, runtime interaction, product telemetry, Apple-platform integration, or shipping decision.

## In scope

- One canonical Scope document at `docs/product-development/lifecycle-fixture/scope.md`.
- Exact binding to the passed Research revision and commit recorded in frontmatter.
- Requirements for self-contained repository-only handoff, stable IDs, owner paths, evidence references, acceptance criteria, lifecycle-state boundaries, and drift classification.
- Preservation of the active skill package and `scope-v1` template identities.
- Explicit owner coverage for package identity, repository reads, transitions, validation, and installed acceptance tests.
- Documentation-level acceptance evidence that a later reviewer can inspect in committed canon, source, tests, Research, and comparison evidence.
- A Design brief limited to documenting how a later Design phase should map the committed requirements to implementation-design descriptions of the fixture mechanics without changing those mechanics.

## Out of scope

- Any Ambitions feature, user need, user workflow, product behavior, UI, copy, navigation, data model, persistence behavior, network behavior, account behavior, or Apple-platform behavior.
- Any edit to current canon, generated canon, source code, tests, package files, evidence files, Research, or other lifecycle documents.
- Any new lifecycle command, schema, template, status, transition, validation rule, test behavior, or package capability.
- Any implementation architecture, code change, migration, entitlement, deployment, release plan, rollout, telemetry, or operational process.
- Any assertion that the fixture is sealed, reviewed, passed, consumed, CLI-validated, merge-ready, release-ready, or active canon.
- Any use of historical Research revision authority in place of the exact revision 3 binding.
- Any reliance on originating chat, previous lifecycle conversation, hidden expected output, local checkout, or uncommitted evidence.

## Product requirements

| Requirement ID | Observable obligation | Owner domain | Finding or authority IDs | Acceptance IDs |
|---|---|---|---|---|
| REQ-001 | The Scope must identify itself as a synthetic documentation-only fixture and must state that it creates no Ambitions feature, canon, implementation, merge, or release authority. | Lifecycle documentation boundary | FIND-003, FIND-007, FIND-009 | AC-001, AC-010 |
| REQ-002 | The Scope must bind exactly one upstream lifecycle input: `PD-2026-08-LIFECYCLE-FIXTURE-RESEARCH`, revision 3, contract hash `sha256:850dea049c234d05bc54493ee5c6adde18c15f438a27d1c1cfba7bbc953042c1`, commit `5d224acfd5f4ad7063be14ae4b3f0a030a195ccd`. | Lifecycle input binding | FIND-004, FIND-008, FIND-009, PD-2026-08-LIFECYCLE-FIXTURE-RESEARCH | AC-002 |
| REQ-003 | The Scope must remain self-contained: its conclusion, constraints, IDs, inputs, owner paths, exclusions, acceptance evidence, risks, and next permitted authoring concern must be understandable without chat history. | Producer handoff | FIND-003, FIND-009 | AC-003 |
| REQ-004 | Every material repository dependency must be declared through source owner, test owner, dependency, input, evidence, package, or template paths so relevant drift cannot be silently classified as unrelated. | Freshness and ownership | FIND-002, FIND-004, FIND-005, FIND-006 | AC-004, AC-005 |
| REQ-005 | The Scope must require relevant repository drift to receive explicit semantic assessment before a later Consumer PASS, while unrelated changed paths remain separately reported and are not automatic blockers. | Drift classification | FIND-004, FIND-005, FIND-006 | AC-006, AC-007 |
| REQ-006 | Lifecycle state must be revision-bound: current status, seal, review, and contract-hash authority must be taken from frontmatter and recorded lifecycle events, never inferred from historical records or stale narrative prose. | Lifecycle state integrity | FIND-008, FIND-009 | AC-008 |
| REQ-007 | Requirement and acceptance IDs must provide complete traceability from Research findings or repository authority to observable obligations and inspectable evidence. | Traceability | FIND-002, FIND-003, FIND-005, FIND-006 | AC-009 |
| REQ-008 | Canon impact must remain explicitly empty, and the document must state that no proposed canon delta exists for this fixture. | Canon boundary | FIND-007 | AC-010 |
| REQ-009 | The Scope must not leave any open decision that would require Design to invent product behavior, fixture semantics, owner coverage, acceptance evidence, or authority. | Design readiness | FIND-003, FIND-009 | AC-011 |
| REQ-010 | The committed document must preserve `authoring_surface = "chatgpt"`, active package version `1.0.0`, package hash `sha256:b810179fdc59fb037091b03502b226d996d9ea128cde7118d60eee46e7e178cf`, template version `scope-v1`, and template hash `sha256:94840a4ce88a5be28f9ba2154a5aa025d1f3923618389fd2648bfeb4ce41bb6e`. | Package and template identity | FIND-002 | AC-012 |

## Required states and behaviors

Lifecycle state for any revision is represented by that revision's frontmatter and recorded lifecycle events. Narrative obligations in this section are transition-independent and do not establish the current revision's status, seal, contract hash, freshness, or review state.

Required behavior for later lifecycle handling:

- A later phase must consume the exact adjacent passed input recorded for that phase; it must not substitute another revision, path, contract hash, or commit.
- Historical lifecycle records must remain visible as history but cannot bind the current revision.
- Authority-bearing content changes after a `needs-revision` or stale result require reopening as a new draft revision.
- Package and template identities must remain exact and historically verifiable at the relevant baseline.
- Relevant drift is any baseline-to-HEAD change under the authoritative freshness union of canon targets, source owners, test owners, dependencies, additional freshness paths, inputs, evidence, package manifest, and selected template.
- Relevant drift requires an explicit impact assessment before Consumer PASS. Unrelated drift is reported separately and does not itself establish semantic incompatibility.
- A lifecycle PASS, if later recorded, remains a quality verdict only and cannot authorize edits, canon activation, merge, deployment, or release.

No runtime state machine, product state, UI state, persistence state, or Apple-platform state is created by this Scope.

## Acceptance criteria

| Acceptance ID | Verifiable condition | Required evidence |
|---|---|---|
| AC-001 | The handoff summary, problem statement, scope boundaries, release boundary, and invariants consistently identify the initiative as synthetic and documentation-only and deny product, canon, implementation, merge, and release authority. | Inspection of this committed Scope plus `AGENTS.md`, the active `SKILL.md`, and `docs/canon/CONSTITUTION.md`. |
| AC-002 | Frontmatter contains one `lifecycle-document` input whose authority ID, canonical path, revision, contract hash, and commit exactly equal the passed Research binding. | This Scope frontmatter and `docs/product-development/lifecycle-fixture/research.md` at commit `5d224acfd5f4ad7063be14ae4b3f0a030a195ccd`. |
| AC-003 | A reader can identify the outcome, boundaries, requirements, acceptance criteria, owner paths, risks, and next phase concern without any chat history. | Complete inspection of this single committed file using the producer contract and Scope review rubric. |
| AC-004 | `source_owner_paths` includes package identity, repository, transition, and validation implementations; `test_owner_paths` includes the installed lifecycle acceptance test. | Scope frontmatter and the named repository files at the baseline commit. |
| AC-005 | `dependency_paths`, the input binding, evidence record, package manifest, and selected template collectively cover all non-weakenable freshness dependencies stated by this Scope. | Scope frontmatter compared with `derive_freshness_paths` in `validation.py` and the active package manifest. |
| AC-006 | The Scope states that changed paths in the authoritative freshness union are relevant and require explicit semantic assessment before Consumer PASS. | REQ-005, Required states and behaviors, `validation.py`, and the installed acceptance test. |
| AC-007 | The Scope states that unrelated changed paths are separately reported and are not automatic blockers. | REQ-005, Required states and behaviors, Research `FIND-006`, comparison evidence, and the installed acceptance test. |
| AC-008 | The Scope assigns current lifecycle authority only to frontmatter and recorded events and prohibits reuse of prior revision seals, reviews, or contract hashes. | REQ-006, Product invariants, Research revision history, `transitions.py`, and `lifecycle-contract.md`. |
| AC-009 | Every `REQ-*` row cites at least one Research `FIND-*` or the declared upstream input authority ID and at least one `AC-*`; each `AC-*` names inspectable repository evidence. | Product requirements and Acceptance criteria tables in this file. |
| AC-010 | `canon_targets` and `canon_delta_ids` are empty, and the Canon impact section declares no proposed delta. | Scope frontmatter and Canon impact and proposed canon deltas section. |
| AC-011 | Open decisions contains no unresolved choice and explicitly states that Design must not invent behavior or authority. | Open decisions and Design brief sections. |
| AC-012 | Frontmatter exactly preserves the requested authoring surface, skill version, package hash, template version, and template hash. | Scope frontmatter and `package-manifest.json` at the repository baseline. |

## Product invariants

- The fixture remains synthetic, repository-only, and documentation-only.
- No statement in this Scope creates or changes Ambitions product law or runtime behavior.
- Research remains evidence; Scope commits only fixture obligations; Design, if later produced, may describe implementation design but cannot authorize implementation.
- Exact revision, contract-hash, canonical-path, and commit equality is required for lifecycle input binding.
- Current lifecycle state is determined only by frontmatter and recorded lifecycle events.
- Historical seals, reviews, and reopen events remain revision-bound history.
- Declared owner and dependency paths must not be weakened to make relevant drift appear unrelated.
- Unrelated drift must not be promoted into a blocker without applicable evidence.
- A lifecycle quality verdict cannot authorize repository edits, merge, deployment, canon activation, or release.
- No originating chat or prior lifecycle conversation is required to understand or consume this Scope.

## Native Apple constraints

None apply. This Scope does not define an iPhone surface, SwiftUI behavior, App Intent, entitlement, system framework use, device capability, background execution, notification, widget, accessibility API, or App Store behavior.

A later real product initiative must perform its own current Apple-platform research. This fixture cannot be cited as evidence that any Apple constraint is satisfied or inapplicable outside this documentation-only initiative.

## Privacy and data boundaries

The fixture uses repository documentation, synthetic identifiers, hashes, paths, commits, and lifecycle metadata only. It does not access, transform, store, transmit, or infer Ambitions user data.

GitHub is an authoring and version-control surface for this repository artifact; it is not part of Ambitions product runtime. This Scope creates no account boundary, network dependency, CloudKit behavior, telemetry, analytics, model call, or private-data flow.

Current constitutional privacy and user-control requirements remain unchanged. No privacy implementation or compliance claim is made.

## Accessibility requirements

No user-facing product accessibility requirement is introduced because no UI or interaction is in scope.

The document itself must remain navigable as structured Markdown with descriptive headings, readable prose, stable identifiers, and tables whose columns state their purpose. This repository-document readability requirement does not establish VoiceOver, Dynamic Type, contrast, motion, focus, keyboard, switch-control, or cognitive-accessibility compliance in the Ambitions application.

## Offline, interruption, failure, and recovery expectations

No Ambitions runtime offline, interruption, failure, or recovery behavior is changed.

For the lifecycle fixture, failure handling is documentary:

- missing or mismatched upstream bindings block legitimate downstream authoring;
- insufficient evidence, access, owner coverage, or decisions require `needs-revision` rather than invention;
- relevant drift requires explicit assessment before Consumer PASS;
- stale or rejected authority-bearing content must reopen as a new draft revision before correction;
- historical records remain preserved for auditability.

This section states obligations only; authoritative lifecycle records determine whether any check, transition, or review has occurred for a revision.

## Performance expectations

No application performance behavior or target is introduced.

Repository-document inspection must remain bounded to the declared canonical file, exact upstream document, active package/template identities, current canon boundary documents, named owner source, and installed acceptance test. No latency, memory, energy, launch, rendering, storage, or network target is claimed.

## Dependencies and risks

Dependencies are the exact upstream Research binding, active package manifest and selected Scope template, producer and lifecycle contracts, Scope review rubric, canon boundary documents, lifecycle owner source, installed acceptance test, and committed comparison evidence declared in frontmatter.

Material risks and treatments:

- **RISK-001 — Product confusion:** readers may mistake fixture commitments for product requirements. Mitigation: keep canon targets empty and repeat the synthetic boundary in summary, requirements, invariants, and release boundary.
- **RISK-002 — Input substitution:** a historical or later Research revision may be substituted for the exact passed input. Mitigation: require exact path, revision, contract hash, and commit equality.
- **RISK-003 — Incomplete owner coverage:** omitted paths may make relevant drift appear unrelated. Mitigation: declare package identity, repository, transitions, validation, test, input, evidence, contract, rubric, canon boundary, manifest, and template paths.
- **RISK-004 — Unrelated drift overreach:** unrelated repository changes may be treated as automatic blockers. Mitigation: preserve separate unrelated-path reporting and require evidence of impact before blocking.
- **RISK-005 — Lifecycle-state drift:** narrative claims may become stale after a transition. Mitigation: keep present lifecycle authority in frontmatter and recorded events; describe transition behavior generically in prose.
- **RISK-006 — Authority escalation:** a committed, reviewed, or passed fixture may be interpreted as permission to implement, merge, activate canon, or release. Mitigation: state repeatedly that the lifecycle is a quality workflow without those authorities.
- **RISK-007 — Hidden-context dependence:** Design may rely on previous conversations or expected answers. Mitigation: complete all requirements, acceptance evidence, owner paths, exclusions, and decisions in this file.

## Measurement and success evidence

Success is demonstrated by repository inspection, not product telemetry.

The Scope's committed bytes provide the inspectable basis for evaluating:

- exact upstream binding;
- stable requirement and acceptance IDs;
- complete requirement-to-evidence traceability;
- complete owner and dependency paths for material claims;
- explicit relevant-versus-unrelated drift obligations;
- empty canon impact;
- closed decisions;
- explicit non-product and non-authorization boundaries.

Lifecycle seal, freshness, review, and consumption outcomes, when recorded, are bound separately to their exact revision and contract hash. No CLI execution or automated validation result is claimed by this document.

## Release boundary

There is no Ambitions product release in this initiative.

The only deliverable described by this Scope is a documentation artifact that may be considered by later lifecycle phases. The artifact does not authorize Design, implementation, source changes, canon edits, tests, merge, deployment, distribution, or release. Any later transition requires its own explicit repository record and remains subject to the lifecycle's non-authorization boundary.

## Canon impact and proposed canon deltas

| Canon delta ID | Current authority | Proposed change | Rationale | Requirement IDs | Migration or compatibility impact | Proof obligation |
|---|---|---|---|---|---|---|

No canon delta is proposed. `canon_targets = []` and `canon_delta_ids = []` are intentional because the fixture does not change intended Ambitions product or engineering law. Current canon is read only to preserve the authority boundary.

## Design brief

A later Design document may describe how the existing lifecycle package mechanics represent this fixture's committed obligations. It must bind exactly to the passed revision of this Scope available at that time and must not invent new behavior.

Design must map each `REQ-*` and `AC-*` to existing repository seams covering:

- canonical document identity and adjacent-phase input binding;
- package and template identity verification;
- typed metadata and evidence records;
- revision-bound sealing, review, reopen, and historical state;
- freshness-path derivation and baseline-to-HEAD drift classification;
- explicit assessment of relevant drift and separate reporting of unrelated paths;
- installed acceptance-test evidence for the Research → Scope → Design chain.

Design must preserve the empty canon impact, documentation-only release boundary, complete owner paths, and lack of implementation authority. It may not propose code changes, schema changes, new commands, new tests, new product behavior, or a rollout.

## Open decisions

None.

All behavior needed by Design is resolved in this Scope: the exact upstream binding, fixture boundary, requirements, acceptance criteria, owner paths, drift semantics, lifecycle-state rules, canon impact, and release boundary are fixed. A later Design producer must stop rather than invent any missing product behavior, implementation change, authority, or acceptance evidence.

## Review history

- 2026-08-03: Revision 1 authored and committed from the exact passed Research revision 3 binding at commit `5d224acfd5f4ad7063be14ae4b3f0a030a195ccd`.
- No originating chat or previous lifecycle conversation was used.
- No lifecycle CLI execution or validation is claimed by this authoring record.
### Seal event

- Sealed at: `2026-08-03T16:13:54Z`
- Revision: `1`
- Contract hash: `sha256:c36b663f358c3b23170b2a455274d70c2035afa79eb0f860c6cf628b27afef58`
- Freshness paths:
- .agents/skills/ambitions-product-development-lifecycle/SKILL.md
- .agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/scope.md
- .agents/skills/ambitions-product-development-lifecycle/package-manifest.json
- .agents/skills/ambitions-product-development-lifecycle/references/lifecycle-contract.md
- .agents/skills/ambitions-product-development-lifecycle/references/producer-contract.md
- .agents/skills/ambitions-product-development-lifecycle/references/scope-review-rubric.md
- .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/package_identity.py
- .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/repository.py
- .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py
- .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py
- .agents/skills/ambitions-product-development-lifecycle/tests/test_ambitions_product_docs.py
- AGENTS.md
- docs/canon/CONSTITUTION.md
- docs/canon/generated/CODEX_START_HERE.md
- docs/product-development/lifecycle-fixture/evidence/comparison.md
- docs/product-development/lifecycle-fixture/research.md

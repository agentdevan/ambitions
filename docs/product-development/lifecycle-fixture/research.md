+++
schema_version = 1
template_version = "research-v1"
template_hash = "sha256:ea95f88f1bcfc75898f5cb32e7a7151a8c094b9791439f7fa4a0cf1466afb39a"
skill_version = "1.0.0"
skill_package_hash = "sha256:b810179fdc59fb037091b03502b226d996d9ea128cde7118d60eee46e7e178cf"

authoring_surface = "chatgpt"
initiative_id = "PD-2026-08-LIFECYCLE-FIXTURE"
document_id = "PD-2026-08-LIFECYCLE-FIXTURE-RESEARCH"
document_type = "research"
authority_class = "evidence"
entry_point = "research"

status = "draft"
revision = 1
created_at = "2026-08-03"
updated_at = "2026-08-03"
repository_baseline_commit = "fc8eca8d7b913a3d6cef82e33bfd3c7f419c0021"
external_research_as_of = "2026-08-03"
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
source_owner_paths = [".agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/package_identity.py", ".agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/repository.py", ".agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py", ".agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py"]
test_owner_paths = [".agents/skills/ambitions-product-development-lifecycle/tests/test_ambitions_product_docs.py"]
dependency_paths = ["AGENTS.md", ".agents/skills/ambitions-product-development-lifecycle/SKILL.md", ".agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/research.md", ".agents/skills/ambitions-product-development-lifecycle/package-manifest.json", ".agents/skills/ambitions-product-development-lifecycle/references/producer-contract.md", ".agents/skills/ambitions-product-development-lifecycle/references/research-review-rubric.md", ".agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/constants.py", ".agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/models.py", ".agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/toml_codec.py", "docs/canon/CONSTITUTION.md", "docs/canon/generated/CODEX_START_HERE.md"]
additional_freshness_paths = []
freshness_paths = []
supersedes = []

[[evidence_files]]
path = "docs/product-development/lifecycle-fixture/evidence/comparison.md"
sha256 = "d7d291725a25ad4ad14f7e8804cb5dfc88c480268203a635d2f87ac8a4590010"
role = "Repository-only comparison evidence for relevant-versus-unrelated drift and fixture boundaries"
+++

## Agent handoff summary

`Lifecycle Fixture` is a synthetic, repository-only lifecycle initiative. It exists solely to demonstrate that the installed portable skill can carry a self-contained committed document chain from Research through later Scope and Design, with committed evidence and explicit relevant-versus-unrelated repository-drift handling. It does not propose or authorize an Ambitions product feature, product behavior, canon change, implementation, merge, or release.

This Research revision is a draft authored on the ChatGPT surface. Its repository baseline is `fc8eca8d7b913a3d6cef82e33bfd3c7f419c0021`, the commit that introduced the hashed comparison evidence. That evidence commit was created directly from the supplied remote branch HEAD `2199f8de3b19dddf16cb42d995f77a581ddee03d` after GitHub reported the two refs identical. The active package and selected template identities are bound in frontmatter.

The principal finding is that the installed package already defines the required mechanics: immutable phase templates, exact package and template identity, committed evidence hashes, adjacent-phase input binding, exact canonical paths, and a drift split in which changes under sealed freshness paths are relevant while other changed paths are reported as unrelated. The installed acceptance test exercises a synthetic Research → Scope → Design chain and both drift classes. This document does not claim that the current draft has been sealed, validated by the CLI, reviewed, passed, or consumed.

The next lifecycle action is not authorized by this draft. After a separate seal and the required reviews, a fixture-only Scope could consume the stable `FIND-*` records below without inventing product behavior.

## Idea and problem statement

The repository contains a portable product-development lifecycle skill and an installed acceptance test, but repository-level proof should also exist as a canonical, human-readable initiative chain. The fixture must show that Research can be committed with exact package identity, exact template identity, repository evidence, stable findings, owner paths, and a baseline suitable for later drift assessment.

The problem is bounded to documentation and lifecycle mechanics. A valid result must not use a real feature as test material, amend current canon, imply unresolved Ambitions behavior, or treat a lifecycle document as implementation or merge authority.

## Research questions

1. Can Research be authored as a self-contained canonical file using only committed repository evidence and no originating-chat history?
2. Does the active package bind the exact skill package, template, canonical path, repository baseline, evidence digest, owner paths, and phase authority class needed for a portable handoff?
3. Does the installed implementation distinguish relevant repository drift from unrelated drift in a deterministic way?
4. Does repository test evidence exercise a committed Research → Scope → Design chain with adjacent-phase bindings?
5. What boundaries prevent this fixture from becoming product canon, product behavior, implementation architecture, or approval?
6. What remains unknown until sealing, content review, consumer review, and downstream authoring occur?

## Current Ambitions baseline

The root contributor guide routes material unresolved product, UX, or architecture initiatives to the installed lifecycle skill. It assigns canonical Research, Scope, and Design authoring to ChatGPT and downstream consumer review to Codex, while stating that the workflow is a quality mechanism rather than edit or merge authorization.

The active skill requires one role at a time. Producer work inspects current canon, source, tests, evidence, and initiative files; creates a self-contained canonical document; commits the draft; and preserves the phase authority boundary. Research has `authority_class = "evidence"` and cannot commit product behavior or implementation architecture.

The package manifest declares skill version `1.0.0`, schema version 1 support, and the `research-v1`, `scope-v1`, and `design-v1` template family. The active package hash is `sha256:b810179fdc59fb037091b03502b226d996d9ea128cde7118d60eee46e7e178cf`; the selected Research template hash is `sha256:ea95f88f1bcfc75898f5cb32e7a7151a8c094b9791439f7fa4a0cf1466afb39a`.

The canon start guide and Constitution separate intended product law from implementation evidence and authorization. They require current canon to be read with live source and tests, and they state that documentation does not establish current implementation correctness or grant repository authority. Because this initiative is documentation-only and introduces no product behavior, `canon_targets` and `canon_delta_ids` are empty.

The pre-authoring branch comparison established that `codex/product-development-lifecycle` was identical to `2199f8de3b19dddf16cb42d995f77a581ddee03d`. The committed evidence baseline is the immediate child commit `fc8eca8d7b913a3d6cef82e33bfd3c7f419c0021`.

## User and product evidence

This fixture has no user-research claim and no real-product hypothesis. No interviews, analytics, usability studies, support data, market data, or product telemetry were inspected or inferred.

Repository evidence supports a narrower conclusion: the lifecycle package can represent a synthetic initiative with stable IDs, a source ledger, hashed evidence, declared owner paths, downstream input bindings, and repository-drift classification. The installed acceptance test is executable evidence about the package contract, not evidence that any Ambitions user need or product feature exists.

Evidence classification for this Research is:

- **Current canon:** `docs/canon/generated/CODEX_START_HERE.md` and `docs/canon/CONSTITUTION.md`, used only to preserve the product-law and authority boundary.
- **Repository evidence:** contributor instructions, active package identity, Research template, producer contract, review rubric, lifecycle source, installed acceptance test, and the committed comparison file.
- **External evidence:** none.

## Apple platform and ecosystem evidence

No Apple platform behavior is proposed or evaluated. The fixture adds no UI, App Intent, persistence behavior, networking, CloudKit behavior, device capability, entitlement, background task, accessibility API use, or App Store surface.

No external Apple documentation was required for the repository-only question. This absence must not be generalized to a real product initiative. Any future Scope or Design that introduced Apple platform behavior would need current, directly applicable Apple evidence and could not inherit an “applicable” conclusion from this fixture.

## Technical feasibility

The repository implementation supports the fixture mechanics:

- document creation normalizes `Lifecycle Fixture` to `docs/product-development/lifecycle-fixture/<phase>.md` and identity `PD-2026-08-LIFECYCLE-FIXTURE`;
- package identity is derived from the canonical manifest bytes and the selected template record;
- frontmatter parsing accepts only the version-one typed fields, input bindings, and evidence records;
- Research begins without upstream lifecycle inputs;
- evidence records bind a repository-relative path, raw SHA-256 digest, and role;
- draft documents must keep `contract_hash` and `freshness_paths` empty;
- sealing, which is outside this task, derives freshness paths and computes a contract hash;
- downstream Scope and Design creation requires an exact committed passed adjacent upstream document unless a separately validated reduced-entry authority is used;
- consumption compares baseline-to-HEAD changed paths and separates relevant paths from unrelated paths.

The installed acceptance test creates a synthetic evidence file before Research, completes and commits each phase, binds Scope to the passed Research commit and Design to the passed Scope commit, and exercises both drift classes.

This task used GitHub repository reads and direct GitHub writes only. No local checkout was inspected. No lifecycle CLI execution or CLI validation is claimed.

## Privacy and local-first implications

The fixture contains repository documentation and synthetic identifiers only. It does not read, store, transform, transmit, or infer Ambitions user data. It does not alter the app's local-first runtime, private-data boundaries, account model, persistence, replay, migration, or network behavior.

GitHub is the repository authoring surface for this fixture, not part of Ambitions product runtime. The existence of a GitHub commit therefore does not support any claim about product data handling, offline behavior, or privacy implementation.

The constitutional privacy and user-control floors remain unchanged. A later real-product initiative could not cite this fixture as privacy evidence.

## Accessibility implications

No user-facing interface or interaction is added, so there is no product accessibility behavior to approve or test. The documentation uses descriptive headings, plain text, and tables so a repository reader can navigate the evidence.

This document does not establish VoiceOver, Dynamic Type, contrast, motion, keyboard, focus, switch control, cognitive accessibility, or other runtime accessibility compliance. Those obligations remain applicable only when a real product scope affects them.

## Alternatives and tradeoffs

| Alternative | Benefit | Cost or failure mode | Disposition |
|---|---|---|---|
| Do not create a canonical fixture | No new files | Leaves the portable workflow demonstrated only in source and tests, not in a committed human-readable lifecycle chain | Rejected |
| Create only `research.md` without committed evidence | Fewer commits | Evidence would not exist at the Research baseline, weakening evidence binding and repository validation | Rejected |
| Use an actual Ambitions feature as fixture content | More product-like prose | Risks inventing behavior, changing canon expectations, or implying implementation authority | Rejected |
| Copy expected answers from prior chats or hidden fixture material | Faster authoring | Violates repository-only provenance and makes the handoff non-portable | Rejected |
| Create committed comparison evidence first, then a draft canonical Research document | Preserves evidence-at-baseline, stable IDs, exact package identity, and a clean authority boundary | Requires two sequential commits and later independent lifecycle transitions | Recommended |

## Findings

| Finding ID | Classification | Finding | Source IDs | Scope implication |
|---|---|---|---|---|
| FIND-001 | Fact | The supplied branch and remote HEAD were identical before authoring, and the committed evidence baseline is the direct child commit containing only `comparison.md`. | SRC-001, SRC-012 | A later fixture Scope can bind the exact passed Research commit while retaining an auditable pre-authoring baseline. |
| FIND-002 | Fact | The active manifest supports schema version 1 and the Research, Scope, and Design version-one templates with exact package and template hashes. | SRC-002, SRC-004, SRC-010 | Scope must preserve the bound package and template identities rather than restating an unversioned process. |
| FIND-003 | Fact | Producer instructions require current repository inspection, a self-contained canonical path, committed evidence and owner paths, explicit unknowns, and phase authority separation. | SRC-001, SRC-003, SRC-005, SRC-006 | Scope may rely on this document only after required lifecycle transitions; it must not use chat history as missing authority. |
| FIND-004 | Fact | The lifecycle implementation derives freshness from declared owners, dependencies, inputs, evidence, package manifest, and template, then classifies baseline-to-HEAD changes as relevant by exact-or-descendant path match and all other changes as unrelated. | SRC-007, SRC-008, SRC-012 | Scope and Design must declare complete owner and dependency paths so later drift is classified against an explicit set. |
| FIND-005 | Fact | Relevant drift creates a semantic-review blocker, while unrelated drift is reported separately and does not by itself create that blocker. | SRC-008, SRC-011, SRC-012 | Later consumer review must assess every relevant changed path and must not elevate unrelated changes into implicit blockers. |
| FIND-006 | Fact | The installed acceptance test constructs a committed Research → Scope → Design chain, binds adjacent passed revisions and commits, and exercises both unrelated and relevant drift cases. | SRC-011, SRC-012 | A fixture-only Scope can define proof obligations around the existing acceptance contract without inventing product behavior. |
| FIND-007 | Fact | Current canon separates product law from source/test evidence and does not grant edit, implementation, merge, or release authority. | SRC-001, SRC-013, SRC-014 | `canon_targets` stays empty; downstream fixture documents must preserve the non-product, non-authorization boundary. |
| FIND-008 | Bounded conclusion | Repository evidence is sufficient to recommend a later fixture-only Scope direction, but insufficient to claim this draft is sealed, valid, reviewed, passed, consumed, implementation-ready, merge-ready, or release-ready. | SRC-003, SRC-005, SRC-006, SRC-008 | The next permitted work remains conditional on separate lifecycle transitions and reviews. |
| FIND-009 | Explicit unknown | Future repository drift, future review findings, and the exact Scope and Design contract hashes do not yet exist. | SRC-006, SRC-008, SRC-012 | Downstream work must record actual committed inputs and actual drift instead of pre-filling expected outcomes. |

## Recommended direction

After this exact Research revision is separately sealed and receives the required reviews, create a fixture-only Scope that turns the findings into observable documentation obligations, not Ambitions product behavior. The Scope should require:

- exact binding to the passed Research revision, contract hash, and commit;
- preservation of the two canonical paths already created and the canonical downstream paths;
- no canon target, product requirement, UI behavior, runtime behavior, or implementation authorization;
- explicit acceptance evidence for package/template identity, evidence hashing, adjacent-phase input binding, and relevant-versus-unrelated drift handling;
- an out-of-scope boundary covering real features, canon changes, implementation, review verdict fabrication, merge, and release;
- unresolved future drift and review findings to remain explicit.

This recommendation is evidence-level only. It does not create Scope authority or permit implementation.

## Rejected directions

- Treating the installed acceptance test as proof of a real Ambitions feature.
- Adding or modifying product canon for the fixture.
- Using the lifecycle design specification, lifecycle implementation plan, an SDD workspace or ledger, prior lifecycle conversations, baseline scoring, or expected-answer material.
- Sealing this Research document during the authoring task.
- Recording a content or consumer review verdict.
- Claiming CLI validation, Codex review, consumer readiness, implementation approval, merge approval, or release approval.
- Authoring Scope or Design before the required Research transition and review conditions are satisfied.

## Remaining unknowns

1. Whether this committed Research draft will pass the lifecycle CLI's structural and repository validation when run from a compatible checkout.
2. The contract hash and freshness set that a future seal would compute for this exact revision.
3. The findings, improvements, or revisions that a future content review may identify.
4. Whether a future consumer review will pass and permit Scope.
5. The exact future Scope and Design revisions, contract hashes, input commits, and review records.
6. Which repository paths, if any, will drift after sealing and how each relevant path will be assessed.
7. Whether later active package or template changes will require reconciliation before consumption.

## Risk register

| Risk ID | Risk | Likelihood | Impact | Mitigation or evidence needed |
|---|---|---|---|---|
| RISK-001 | Fixture prose is mistaken for a real product proposal. | Medium | High | Keep `canon_targets` empty; repeat the synthetic and non-product boundary in every downstream phase. |
| RISK-002 | A downstream document invents missing review or authority state. | Medium | High | Bind only actual committed passed upstream metadata; leave unknowns explicit. |
| RISK-003 | Relevant owner paths are omitted, causing meaningful drift to appear unrelated. | Medium | High | Carry complete source, test, dependency, input, evidence, package, and template paths into the sealed freshness union. |
| RISK-004 | Unrelated repository changes are treated as automatic lifecycle blockers. | Low | Medium | Preserve the implementation's separate `unrelated_paths` reporting and require blockers only for applicable validation or relevant drift. |
| RISK-005 | Package or template identity changes after the baseline. | Medium | Medium | Reconcile against the active package and historical baseline before consumption. |
| RISK-006 | The two-commit evidence-first sequence is misread as a single atomic commit. | Low | Low | Record the evidence commit as the Research baseline and report the final Research commit separately. |
| RISK-007 | Documentation quality is conflated with CLI, review, merge, or release approval. | Medium | High | Make no such claim; perform each transition or review only through its separate explicit workflow. |

## Source ledger

| Source ID | Title or repository path | Publisher | URL | Accessed | Temporal sensitivity | Recheck trigger | Supports | Evidence summary |
|---|---|---|---|---|---|---|---|---|
| SRC-001 | `AGENTS.md` | Ambitions repository |  | 2026-08-03 | Medium | Recheck when root contributor instructions change | FIND-001, FIND-003, FIND-007 | Routes unresolved material initiatives to the lifecycle skill and separates workflow quality from edit or merge authority. |
| SRC-002 | `.agents/skills/ambitions-product-development-lifecycle/package-manifest.json` | Ambitions repository |  | 2026-08-03 | High | Recheck when manifest bytes or package hash change | FIND-002 | Declares skill version, supported document contracts, and operational file digests. |
| SRC-003 | `.agents/skills/ambitions-product-development-lifecycle/SKILL.md` | Ambitions repository |  | 2026-08-03 | High | Recheck when the active skill changes | FIND-003, FIND-008 | Defines Producer, Content review, Consumer, lifecycle phase, and authority boundaries. |
| SRC-004 | `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/research.md` | Ambitions repository |  | 2026-08-03 | High | Recheck when the selected template hash changes | FIND-002 | Provides the immutable Research metadata and section profile. |
| SRC-005 | `.agents/skills/ambitions-product-development-lifecycle/references/producer-contract.md` | Ambitions repository |  | 2026-08-03 | High | Recheck when producer obligations change | FIND-003, FIND-008 | Requires repository inspection, committed inputs, self-contained authoring, and authority separation. |
| SRC-006 | `.agents/skills/ambitions-product-development-lifecycle/references/research-review-rubric.md` | Ambitions repository |  | 2026-08-03 | High | Recheck when Research review criteria change | FIND-003, FIND-008, FIND-009 | Defines support, uncertainty, owner-path, drift, and review-output expectations without supplying a verdict. |
| SRC-007 | `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py` | Ambitions repository |  | 2026-08-03 | High | Recheck when creation, sealing, or input-binding transitions change | FIND-004 | Defines canonical identity, baseline capture, package/template binding, Research entry, and adjacent-phase inputs. |
| SRC-008 | `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py` | Ambitions repository |  | 2026-08-03 | High | Recheck when validation or drift classification changes | FIND-004, FIND-005, FIND-008, FIND-009 | Derives freshness paths, validates evidence, compares baseline to HEAD, and separates relevant from unrelated paths. |
| SRC-009 | `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/toml_codec.py` | Ambitions repository |  | 2026-08-03 | Medium | Recheck when frontmatter schema or serialization changes | FIND-002, FIND-003 | Constrains frontmatter to typed scalar, array, input, and evidence fields. |
| SRC-010 | `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/package_identity.py` | Ambitions repository |  | 2026-08-03 | High | Recheck when package-hash or historical-package verification changes | FIND-002 | Defines canonical manifest hashing and historical package/template verification. |
| SRC-011 | `.agents/skills/ambitions-product-development-lifecycle/tests/test_ambitions_product_docs.py` | Ambitions repository |  | 2026-08-03 | High | Recheck when installed acceptance coverage changes | FIND-005, FIND-006 | Exercises the synthetic chain, adjacent input bindings, unrelated drift, relevant drift, and semantic-review blocking. |
| SRC-012 | `docs/product-development/lifecycle-fixture/evidence/comparison.md` | Ambitions repository |  | 2026-08-03 | High | Recheck when baseline, owner paths, drift implementation, test, package, or template changes | FIND-001, FIND-004, FIND-005, FIND-006, FIND-009 | Committed repository-only comparison evidence bound by SHA-256 in this Research draft. |
| SRC-013 | `docs/canon/generated/CODEX_START_HERE.md` | Ambitions canon |  | 2026-08-03 | Medium | Recheck when generated canon navigation changes | FIND-007 | Requires current canon to be read with source and tests and denies authorization semantics. |
| SRC-014 | `docs/canon/CONSTITUTION.md` | Ambitions canon |  | 2026-08-03 | Medium | Recheck when constitutional authority or product-law boundaries change | FIND-007 | Separates intended product law, implementation evidence, proof categories, and repository authorization. |

## Handoff to Scope

No Scope document is authorized or created by this draft.

After an exact committed seal and the required reviews, a Scope producer should consume:

- `FIND-001` through `FIND-009`;
- repository baseline `fc8eca8d7b913a3d6cef82e33bfd3c7f419c0021`;
- the active package and Research template identities in frontmatter;
- hashed evidence `docs/product-development/lifecycle-fixture/evidence/comparison.md`;
- the complete declared source, test, and dependency paths;
- the non-product, non-canon, non-implementation boundary;
- the explicit unknowns and risks.

The smallest legitimate Scope question is: what observable documentation and traceability obligations must a synthetic lifecycle chain satisfy to prove evidence binding, adjacent-phase handoff, and relevant-versus-unrelated drift behavior without changing Ambitions product behavior?

Scope must not answer any real product question, activate canon, select implementation architecture, or treat this Research recommendation as approval.

## Review history

- 2026-08-03: Revision 1 authored as an unsealed, unreviewed ChatGPT draft from committed repository evidence. No lifecycle review verdict was issued.

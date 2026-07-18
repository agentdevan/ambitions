# Ambitions Canon and Specification System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Ambitions’ distributed truth network with a compact Constitution, a canonical modular Specification Atlas, and a deterministic compiler that gives Codex bounded context, exposes specification gaps, reconciles conceptual conflicts, traces law to source/tests/proof, and safely destroys superseded authority after owner-approved cutover.

**Architecture:** Build a Python 3.12 standard-library compiler beside the current authority and run it in shadow mode until the new canon proves coverage, determinism, traceability, conflict resolution, Codex-consumption quality, and rollback safety. Treat the Linear v3 canon as the primary migration corpus, decompose it and all other authority into atomic claims, serialize final normative writing through one canonical writer, then cut over authority and routing before bounded repo, Linear, and Figma purge trains. Protected CI remains a separately unimplemented target outside Tasks 24–29.

**Tech Stack:** Python 3.12 standard library (`dataclasses`, `enum`, `tomllib`, `json`, `hashlib`, `sqlite3`, `argparse`, `pathlib`, `tempfile`, `unittest`), Markdown with TOML front matter, TOML/JSON registries, Git, GitHub Actions, Linear and Figma connectors for controlled external reconciliation.

**Train 5 trust-topology amendment:** `TRAIN5-TRUST-TOPOLOGY-AMENDMENT-2026-07-17`, recorded at `docs/superpowers/amendments/2026-07-17-train-5-trust-topology-amendment.json`, governs Tasks 24–29 where it is more specific than the original allocation.

**Owner direct-integration override:** `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z` supersedes every protected-branch, required-CI/check, CI-installation, ruleset-inspection, live-boundary activation/no-drift receipt, and post-merge protected-receipt prerequisite for Tasks 24–29. Those controls remain an unimplemented future target and MUST NOT be claimed from this train. Tasks 24–29 may integrate directly only after exact SHA-bound local authorization and verification, one exact high-risk review, an owner-approved break-glass record bound to this decision, and current rollback evidence. Gate B must state `live_enforcement_proven = false` and `post_merge_receipt_required = false`; Task 26 cuts authority and routing without installing protected CI; Gate C still requires exact destructive manifests/dry-runs, rollback, independent review, privacy/security/proof-honesty review, and owner-approved Search frames; Task 29 is limited to compact permanent negatives, one canary, and one regression closeout with no GitHub protection inspection. Final claims explicitly exclude protected enforcement. One reviewable commit per numbered task remains mandatory. Any contradictory Task 24–29 wording below is superseded by this paragraph and the bound amendment record.

Task 24 additionally owns exactly two non-directional canon evidence inputs: `docs/canon/specifications/global/search.md` and `docs/canon/specifications/journeys/search-find-ask-act-inspect.md`. Their content-identity change owns all fourteen `docs/canon/generated/` manifest projections, `docs/canon/generated/codex-consumption-benchmark.md`, plus freshness-only rebinding of `docs/canon/migration/UX_BLUEPRINT.md`, `VISUAL_AUTHORITY_REBASELINE.md`, `ux-blueprint-requirement-dispositions.json`, `ux-blueprint.json`, `visual-authority-r1-node-snapshot.json`, `visual-authority-rebaseline.json`, `docs/canon/registries/command-gate-approval-receipts.json`, and `command-gate-dependencies.json`; Task 24 also owns this five-document topology amendment bundle. After inputs freeze, perform those deterministic rebindings and regenerate the fifteen generated projections exactly once, then require `build --check` Green. Task 25 may not change those inputs or freshness outputs while they remain frozen. Tasks 24–29 use existing task type `release`, budget class `complex`, and exact ceiling `30,000`; `governance` remains unknown and fails `PACK_TASK_TYPE_UNKNOWN`.

## Global Constraints

- Implement the approved design at `docs/superpowers/specs/2026-07-11-ambitions-canon-specification-system-design.md`.
- Primary migration corpus: Linear document `96b93346-271d-46fc-beab-43ff7e286b5d`, title `B1A-D01R — Ambitions Product / IA / Object Model Full Design Spec v3 — Canonical`.
- The current `docs/truth/**`, `docs/constitution/**`, `AGENTS.md`, and `scripts/ambitions-constitution-audit.py` remain active authority until the cutover task completes.
- Do not delete, demote, or rewrite active authority during shadow migration except for the explicit authority-freeze guard and non-normative routing notes named by this plan.
- Do not change production Swift, persistence schemas, runtime behavior, UI, copy, entitlements, privacy manifests, account behavior, R2 behavior, or release state in this program.
- The compiler and CI must run offline with no model, network, Linear, Figma, or cloud dependency.
- Use Python 3.12. The CLI must exit `2` with `PYTHON_VERSION_UNSUPPORTED` on Python below 3.11; CI uses Python 3.12.
- Use only the Python standard library unless a later owner-approved amendment changes this constraint.
- Normative source is Markdown with TOML front matter. JSON/TOML files may own schemas, manifests, mappings, ledgers, and generated projections but not free-standing product doctrine.
- Generated output is deterministic: sorted keys and records, UTF-8, newline-terminated files, explicit schema/compiler versions, no volatile timestamps, no network/model calls, and atomic replacement.
- `docs/canon/` is shadow and non-authoritative until `MANIFEST.toml` changes from `authority_state = "shadow"` to `authority_state = "active"` in the cutover task.
- Every normative requirement has one stable ID; IDs are never reused.
- Every normalized concept has exactly one owner.
- P0 or hard-red requirements use `MUST` or `MUST NOT`.
- Current implementation and proof state must be generated from source/evidence and must not be embedded as permanent product law.
- Linear owns execution and evidence links, not canon. Figma owns visual authority and evidence, not product IA, runtime, privacy, source ownership, or release status.
- Material semantic conflicts require owner decision. Codex recommends a winner or stronger composition; it never silently decides.
- Parallelize read-only inventory, extraction, gap detection, and red-team review. Serialize concept ownership, normative writing, cutover, and deletion.
- No implementation task runs in parallel with another implementation task. Each task receives an independent spec-and-quality review before the next task begins.
- Use test-driven development for compiler behavior: write a failing test, verify the expected failure, implement the minimum, rerun focused and regression tests, then commit.
- Use one reviewable commit per numbered task that changes tracked files. Run `git diff --check` before every commit.
- Do not claim implementation, Runtime, Interaction, Visual, Accessibility, Privacy, Device, TestFlight, App Store, or Release Green from canon-governance work.
- Raw Linear/Figma exports and task packs remain under ignored `.codex/` state. Tracked migration evidence contains stable IDs, redacted metadata, checksums, and dispositions only.
- Git history and named rollback tags are the historical record. Do not create a retained archive/graveyard of superseded truth.
- Cutover and every destructive external action require a fresh owner-approved manifest and independent review.
- The approved design authorizes isolated worktrees, feature branches, and stacked reviewable trains for this program despite the normal repo main-only default.
- ChatGPT intent cannot authorize implementation. Machine-readable PR intake is untrusted intent only; Project Instructions, skills, PR prose, task packs, local authorization envelopes, and finalization receipts are non-authoritative. Intake may request but cannot approve files, prove validation, assert proof, grant break-glass, or permit merge.
- Every tracked change requires current deterministic `task start` authorization and exact-diff `task finalize` authorization computed from trusted base canon/policy/ownership, base-trusted revisioned snapshots, trusted event bindings, and any required platform-authenticated approval. Any stale or missing trusted input invalidates authorization.
- For Tasks 24–29, exact SHA-bound local authorization and verification are the enforcement record under owner decision `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z`; protected CI is neither installed nor required and remains unproven.
- The owner decision is the scoped break-glass record for Tasks 24–29. It requires one exact high-risk review and current rollback evidence and creates no reusable or routine bypass.
- Exact PR authorization uses the canonical base-to-head tree delta bound to trusted repository/PR/base/head/merge-base state, never intake or the synthetic merge checkout.
- The two-stage protected gate-change protocol remains a future target; it is not installed, inspected, or claimed by Tasks 24–29.
- Gate B and Gate C remain hard Red gates for their retained scope. Delegation cannot waive exact SHA-bound authorization, Critical/Important repair, security/privacy/proof honesty, rollback, owner-approved Search frames, or exact destructive manifests and dry-runs. Protected CI and ruleset proof are explicitly outside these gates for Tasks 24–29.
- Release-proof task packs are complex with an exact estimated-token ceiling of 30,000. Every other budget class and mapping remains unchanged; the speculative `governance: normal` mapping is prohibited.
- Do not run expensive full regressions on speculative, intermediate, known-blocked, or structurally unmergeable candidates. Task 29 closeout is limited to compact permanent negatives, exactly one canary, and one qualifying regression after the final candidate freezes.
- Every Task 24, Task 25, and Task 29 Python proof command uses `python3.12`; durable task evidence records the exact interpreter version and executable identity.

## Program Execution Model

Use five stacked trains. Each train is independently reviewable and must be Green for its exact scope before the next train starts.

| Train | Branch | Base | Tasks | Purpose |
|---|---|---|---|---|
| 1 | `codex/canon-01-foundation` | `main` | 0–8 | Freeze, parser, manifest, audit, deterministic build, coverage, task packs |
| 2 | `codex/canon-02-reconciliation` | Train 1 head | 9–12 | Corpus catalog, claims, conflict dockets, owner decision gate |
| 3 | `codex/canon-03-atlas` | Train 2 head | 13–19 | Constitution, app/surface/object/journey/system/standard specifications |
| 4 | `codex/canon-04-consumption` | Train 3 head | 20–23 | Traceability, Codex packs/benchmarks, Linear and Figma reconciliation |
| 5 | `codex/canon-05-cutover` | merged Train 4 head | 24–29 | Merged shadow verifier foundation, proof-only Gate B, cutover, bounded purge, external destruction, closeout |

Train 5 remains one program train but uses three integration boundaries: the shadow-only Task 24 verifier-foundation merge, the Tasks 25–26 Train 5A cutover merge, and the Tasks 27–29 Train 5B closeout merge. The exact boundary is defined below.

Within each train, use **Subagent-Driven Development**:

1. Lead coordinator extracts one task brief.
2. Fresh implementer executes only that task and writes a report.
3. Independent task reviewer returns both spec-compliance and code-quality verdicts.
4. Critical and Important findings are repaired and re-reviewed.
5. The coordinator records the reviewed commit range in `.superpowers/sdd/progress.md`.
6. At train end, a most-capable reviewer performs a whole-train review.
7. Open a draft stacked PR with exact validation and claim ceiling.

Model assignment:

- Mechanical one- or two-file implementation with complete code shape: Terra Medium.
- Parser, graph, build, task-pack, and integration implementation: Sol High.
- Corpus semantic extraction and domain review: Sol High, parallel read-only.
- Conflict synthesis, Constitution writing, semantic-loss review, and final branch review: Sol Max.
- Ultra may coordinate independent read-only domain audits; Ultra must not write normative files or perform purge.

## Target File Map

### Compiler and CLI

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
├── traceability.py
├── benchmark.py
├── authorization.py
├── skill_conformance.py
├── purge.py
└── render.py

scripts/
├── ambitions-canon.py
└── ambitions-authority-freeze-check.py
```

### Tests

```text
tests/canon/
├── fixtures/
├── golden/
├── test_model.py
├── test_parser.py
├── test_manifest.py
├── test_registry.py
├── test_graph.py
├── test_audit.py
├── test_build.py
├── test_coverage.py
├── test_query.py
├── test_task_pack.py
├── test_impact.py
├── test_migration.py
├── test_conflicts.py
├── test_external_authority.py
├── test_traceability.py
├── test_claims.py
├── test_benchmark.py
├── test_authorization.py
├── test_skill_conformance.py
├── test_purge.py
└── test_integration.py

scripts/tests/
└── test_ambitions_authority_freeze_check.py
```

### Canon source and projections

Use the exact tree defined in the approved design, plus these non-normative support directories:

```text
docs/canon/
├── MANIFEST.toml
├── CONSTITUTION.md
├── specifications/**
├── standards/**
├── decisions/
│   ├── open/
│   └── SUPERSESSION_LEDGER.toml
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
├── references/
│   ├── linear.toml
│   ├── figma.toml
│   ├── proof-sources.toml
│   ├── chatgpt-project-instructions.md
│   ├── skill-dependencies.json
│   └── validation-command-manifest.json
├── migration/
│   ├── authority-freeze-baseline.json
│   ├── source-catalog.json
│   ├── claim-dispositions.json
│   ├── linear-reconciliation.json
│   └── figma-reconciliation.json
└── generated/
    ├── AUTHORIZATION_GATE_TRANSITION.md
    ├── github-authorization-boundary.json
    └── **
```

`references/**` contains stable external identifiers, governed handoff reference bytes, skill dependency metadata, and reconciliation state only. It is not normative doctrine and cannot authorize implementation.

The manifest and deterministic build own both named generated evidence projections. `AUTHORIZATION_GATE_TRANSITION.md` records deterministic transition/rollback evidence. `github-authorization-boundary.json` is a validated projection of separately acquired live GitHub evidence. Neither is normative authority, and neither can manufacture live state.

---

## Plan Set

This master plan delegates executable task detail to eleven bounded plan files across five review trains:

1. [`2026-07-11-ambitions-canon-train-1a-foundation.md`](2026-07-11-ambitions-canon-train-1a-foundation.md) — Tasks 0–2.
2. [`2026-07-11-ambitions-canon-train-1b-foundation.md`](2026-07-11-ambitions-canon-train-1b-foundation.md) — Tasks 3–5.
3. [`2026-07-11-ambitions-canon-train-1c-foundation.md`](2026-07-11-ambitions-canon-train-1c-foundation.md) — Tasks 6–8.
4. [`2026-07-11-ambitions-canon-train-2a-reconciliation.md`](2026-07-11-ambitions-canon-train-2a-reconciliation.md) — Tasks 9–10.
5. [`2026-07-11-ambitions-canon-train-2b-reconciliation.md`](2026-07-11-ambitions-canon-train-2b-reconciliation.md) — Tasks 11–12.
6. [`2026-07-11-ambitions-canon-train-3a-atlas.md`](2026-07-11-ambitions-canon-train-3a-atlas.md) — Tasks 13–15.
7. [`2026-07-11-ambitions-canon-train-3b-atlas.md`](2026-07-11-ambitions-canon-train-3b-atlas.md) — Tasks 16–19.
8. [`2026-07-11-ambitions-canon-train-4a-consumption.md`](2026-07-11-ambitions-canon-train-4a-consumption.md) — Tasks 20–21.
9. [`2026-07-11-ambitions-canon-train-4b-consumption.md`](2026-07-11-ambitions-canon-train-4b-consumption.md) — Tasks 22–23.
10. [`2026-07-11-ambitions-canon-train-5a-cutover.md`](2026-07-11-ambitions-canon-train-5a-cutover.md) — Tasks 24–26.
11. [`2026-07-11-ambitions-canon-train-5b-cutover.md`](2026-07-11-ambitions-canon-train-5b-cutover.md) — Tasks 27–29.

The bounded plan files are authoritative for task steps. This master file owns sequence, global constraints, branch/PR posture, and program closeout. Execute slices serially within each train; the slice boundary is for Codex context quality, not permission to parallelize normative or implementation writes.

## Task Index

| Task | Train | Deliverable |
|---:|---:|---|
| 0 | 1 | Isolated worktree and immutable baseline |
| 1 | 1 | Authority-freeze guard |
| 2 | 1 | Typed model and thin CLI |
| 3 | 1 | Canonical Markdown parser |
| 4 | 1 | Manifest and registry |
| 5 | 1 | Dependency graph and audit |
| 6 | 1 | Deterministic build and shadow CI |
| 7 | 1 | Completeness profiles and gap model |
| 8 | 1 | Queries and bounded task packs |
| 9 | 2 | Amendment impact and supersession |
| 10 | 2 | Lossless migration source catalog |
| 11 | 2 | Atomic claim graph and dispositions |
| 12 | 2 | Conflict dockets and owner gate |
| 13 | 3 | Compact Constitution |
| 14 | 3 | App-level specifications |
| 15 | 3 | Surface and global specifications |
| 16 | 3 | Object specifications |
| 17 | 3 | Journey specifications |
| 18 | 3 | Runtime/platform system specifications |
| 19 | 3 | Cross-cutting standards and semantic coverage |
| 20 | 4 | Traceability and current implementation posture |
| 21 | 4 | Codex consumption benchmark and resume guard |
| 22 | 4 | Linear execution projection |
| 23 | 4 | Figma visual-authority projection |
| 24 | 5 | Shadow-only reusable Gate B verifier foundation, authorization/purge support, benchmark harness, and legacy-audit parity policy |
| 25 | 5 | Proof/generated-output-only Gate B run using merged Task 24 verifier bytes |
| 26 | 5 | Authority, handoff, and retained-skill routing cutover without protected-CI installation |
| 27 | 5 | Bounded repo and authorization-bypass purge |
| 28 | 5 | Linear/Figma destruction |
| 29 | 5 | Compact authorization negatives, one canary, one regression, and proof-bounded closeout |

## ChatGPT-to-Codex Authorization and Trust-Topology Allocation

The amendment preserves the serial Train 5 shape and one reviewable commit per numbered task while changing the trust bootstrap boundary:

- **Task 24** is a shadow-only verifier foundation. It retains the reusable purge, authorization, skill-conformance, task-pack, and reference-verification support required by Gate B and owns `task_pack.py` plus its schema/permanent tests, `cutover_readiness.py`, `authorization_benchmark.py`, required CLI integration, Gate B evidence schema/closed registry, the fixed Task 25 benchmark policy, validation-command-manifest binding, `task-authorization-policy.json` only if Gate B requires a byte change, the closed legacy-audit invariant-parity record, the exact fixtures/permanent tests listed in Train 5A, `docs/canon/migration/TASK_24_IMPLEMENTATION_REPORT.md`, and the ignored `.superpowers/sdd/progress.md` ledger. It preserves every existing non-release task-pack mapping, keeps `release→complex` at 30,000, and rejects absent task type `governance` rather than adding `governance: normal`. It derives from bounded reviewed patches in frozen speculative candidates `cc49f51f5397b6b83f0482d2056bd8617282f9ea` and `87e5cae34b46d1517cea595230af25ee0bfa12c6`; those branches are not repaired, tested, or merged in place. Task 24 receives independent review and merges before Task 25. That merge leaves `authority_state`, `AGENTS.md` routing, retained skills, replacement CI, protected ruleset configuration, and cutover unchanged.
- **Task 25** is proof/generated-output-only and runs the already-merged Task 24 verifier bytes. Its tracked files are limited to `docs/canon/generated/cutover-readiness.md`, `docs/canon/migration/purge-plan.toml`, deterministic generated outputs changed by frozen inputs, and `docs/canon/migration/TASK_25_IMPLEMENTATION_REPORT.md`; `.superpowers/sdd/progress.md` remains ignored. It introduces no verifier, schema, policy, registry, CLI, fixture, or test behavior. Gate B derives complete visual coverage from merged canon/UX/visual ledgers and fixed review dimensions from merged policy; requires digest-bound `figma-design-export` evidence; keeps any gap-blocked state Red; runs the old audit; enforces closed invariant parity plus all five replacement commands; binds real rollback evidence; uses bounded reads/timeouts; and proves the handoff, authorization, regeneration, skill freshness, and local-artifact rejection properties without self-certification. Any owner decision at this boundary is limited to Gate B bootstrap authorization for Task 26; destructive and purge approvals remain false and deferred to Gate C.
- **Task 26** activates canon authority, rewrites `AGENTS.md` routing, reduces retained skills to procedural adapters with canonical dependency metadata, generates `CHATGPT_CODEX_HANDOFF.md` and `AUTHORIZATION_GATE_TRANSITION.md`, stores the exact governed ChatGPT Project Instructions, and records/verifies their Project Instructions SHA-256. It does not create, rename, delete, configure, inspect, or require protected CI, required checks, or rulesets. The transition record binds owner decision `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z`, the exact locally authorized and reviewed SHA, the high-risk review receipt, and rollback. Project Instructions and skills remain explicitly non-authoritative.
- **Task 27** retains bounded purge and explicitly deletes or rewrites approved stale skills, old handoff documents, compatibility routers, and all other authorization bypass paths, with replacement IDs, inbound-reference rewrites, independent review, and rollback before deletion.
- **Task 28 remains unchanged.**
- **Task 29** retains a compact set of permanent authorization, proof-honesty, destructive-manifest, rollback, privacy/security, and Task 24 topology negatives; runs exactly one canary and one qualifying regression; records the owner-approved direct-integration decision and exact reviewed SHA; and closes with an explicit `protected_enforcement_proven = false` claim. It does not inspect GitHub protection, create ruleset evidence, install CI, repeat a live-boundary inspection, or claim no-drift/protected enforcement.

## Train 5 Execution Boundary

The five-train program model is preserved, but Train 5 has three integration boundaries:

1. Task 24 forms the **shadow verifier-foundation PR** from the amended merged Train 4 base. Reuse bounded speculative patches, integrate one Task 24 commit, independently review it, and merge it without changing active authority, routing, retained skills, replacement CI, protected ruleset configuration, or cutover.
2. Tasks 24–29 integrate directly under `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z` after exact SHA-bound local authorization/verification, one exact high-risk review, and current rollback evidence. Protected CI is not a prerequisite or claim.
3. Task 25 begins only from merged Task 24 and produces proof/generated outputs using those base bytes. Gate B must be Green and owner-approved before Task 26 changes authority, routing, or retained skills; it records `live_enforcement_proven = false` and `post_merge_receipt_required = false`.
4. Tasks 25–26 form the **Train 5A direct-integration range** from merged Task 24. Task 26 cuts authority and routing without protected-CI installation.
5. Gate C may become Green only after exact SHA-bound authorization, one exact high-risk review, rollback, privacy/security/proof-honesty review, owner-approved Search frames, and exact destructive manifests/dry-runs are current and Green. It then authorizes destructive Tasks 27–28 and destructive/migration-state-removal portions of Task 29.
6. Tasks 27–29 form the **Train 5B continuation** from merged Task 26 `main`, in a separate reviewed commit range. The `codex/canon-05-cutover` name may be updated/recreated only from the merged base.
7. Task 29 runs only compact permanent negatives, exactly one canary, and one qualifying regression. It omits GitHub protection inspection and explicitly excludes protected enforcement from final claims.

Final closeout records the Task 24 foundation integration, the Train 5A direct-integration range, the Train 5B continuation, all exact reviewed SHAs, owner decision `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z`, rollback, and `protected_enforcement_proven = false`. No protected-boundary receipt or no-drift claim is required.

## Program Closeout Contract

The final report must state:

```text
Baseline tag and SHA:
Cutover tag and SHA:
Final SHA:
Trains and PRs:
Task 24 shadow verifier-foundation exact integration SHA:
Train 5A direct-integration exact SHAs:
Train 5B continuation exact SHAs:
Files created:
Files deleted:
Linear entities destroyed/rewritten:
Figma nodes/files destroyed/retained:
Constitution law count:
Specification counts by kind:
Concept owner count:
Requirement count:
P0/P1 gap counts:
Traceability coverage:
Codex benchmark results:
ChatGPT Project Instructions SHA-256:
Protected enforcement: not installed or proven; explicitly excluded
Required authorization check: not required or installed by Tasks 24–29
Trusted snapshot revisions/digests:
Owner direct-integration decision: OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z
Protected-boundary receipt: not required or produced
Python 3.12 interpreter version/executable identity for Tasks 24, 25, and 29:
Single heavyweight ChatGPT-to-Codex canary result:
Eight deterministic handoff benchmark results:
Qualifying regression SHA/result:
Validation run with exit codes:
Validation not run and why:
Independent reviews:
Known residual risks:
External manual actions still required:
Rollback:
Claim ceiling (must explicitly exclude protected enforcement):
```

Allowed governance conclusion:

```text
Canon system Source Green / Governance Green for the exact verified scope; protected enforcement excluded
```

Forbidden conclusions without separate current evidence:

```text
Product complete
Runtime Green
Visual Green
Accessibility Green
Privacy/legal approved
Device ready
TestFlight ready
App Store ready
Release Green
```

## Execution Recommendation

Use **Subagent-Driven Development** within each train and stacked draft PRs between trains.

- Fresh implementer per task.
- Independent task review after every commit.
- Sol High for compiler/integration.
- Sol Max for conflict synthesis, normative writing, semantic-loss audit, and whole-train review.
- Ultra only for parallel read-only inventories and domain audits.
- One canonical writer for Constitution/Atlas changes.
- Mandatory owner gates after conflict dockets, before cutover, and before destructive external cleanup.
- Gate B blocks Task 26 until exact SHA-bound local authorization, proof, rollback, owner approval, and one exact high-risk review are Green while `live_enforcement_proven = false`. Gate C blocks destructive work until rollback, independent review, privacy/security/proof honesty, owner-approved Search frames, and exact destructive manifests/dry-runs are Green; protected enforcement is outside both gates for Tasks 24–29.
- Do not execute all 30 tasks as one uninterrupted branch. The five-train boundary is part of the safety architecture.

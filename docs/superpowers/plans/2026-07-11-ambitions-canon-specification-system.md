# Ambitions Canon and Specification System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Ambitions’ distributed truth network with a compact Constitution, a canonical modular Specification Atlas, and a deterministic compiler that gives Codex bounded context, exposes specification gaps, reconciles conceptual conflicts, traces law to source/tests/proof, and safely destroys superseded authority after owner-approved cutover.

**Architecture:** Build a Python 3.12 standard-library compiler beside the current authority and run it in shadow mode until the new canon proves coverage, determinism, traceability, conflict resolution, Codex-consumption quality, and rollback safety. Treat the Linear v3 canon as the primary migration corpus, decompose it and all other authority into atomic claims, serialize final normative writing through one canonical writer, then cut over routing and CI before bounded repo, Linear, and Figma purge trains.

**Tech Stack:** Python 3.12 standard library (`dataclasses`, `enum`, `tomllib`, `json`, `hashlib`, `sqlite3`, `argparse`, `pathlib`, `tempfile`, `unittest`), Markdown with TOML front matter, TOML/JSON registries, Git, GitHub Actions, Linear and Figma connectors for controlled external reconciliation.

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

## Program Execution Model

Use five stacked trains. Each train is independently reviewable and must be Green for its exact scope before the next train starts.

| Train | Branch | Base | Tasks | Purpose |
|---|---|---|---|---|
| 1 | `codex/canon-01-foundation` | `main` | 0–8 | Freeze, parser, manifest, audit, deterministic build, coverage, task packs |
| 2 | `codex/canon-02-reconciliation` | Train 1 head | 9–12 | Corpus catalog, claims, conflict dockets, owner decision gate |
| 3 | `codex/canon-03-atlas` | Train 2 head | 13–19 | Constitution, app/surface/object/journey/system/standard specifications |
| 4 | `codex/canon-04-consumption` | Train 3 head | 20–23 | Traceability, Codex packs/benchmarks, Linear and Figma reconciliation |
| 5 | `codex/canon-05-cutover` | merged Train 4 head | 24–29 | Dual-run proof, cutover, bounded purge, external destruction, closeout |

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
├── schemas/**
├── references/
│   ├── linear.toml
│   ├── figma.toml
│   └── proof-sources.toml
├── migration/
│   ├── authority-freeze-baseline.json
│   ├── source-catalog.json
│   ├── claim-dispositions.json
│   ├── linear-reconciliation.json
│   └── figma-reconciliation.json
└── generated/**
```

`references/**` contains stable external identifiers and reconciliation state only. It is not normative doctrine.

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
| 24 | 5 | Purge/sprawl/reference-verification engine |
| 25 | 5 | Dual-run cutover proof |
| 26 | 5 | Authority and CI cutover |
| 27 | 5 | Bounded repo purge |
| 28 | 5 | Linear/Figma destruction |
| 29 | 5 | Final anti-regression and closeout |

## Program Closeout Contract

The final report must state:

```text
Baseline tag and SHA:
Cutover tag and SHA:
Final SHA:
Trains and PRs:
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
Validation run with exit codes:
Validation not run and why:
Independent reviews:
Known residual risks:
External manual actions still required:
Rollback:
Claim ceiling:
```

Allowed governance conclusion:

```text
Canon system Source Green / Governance Green for the exact verified scope
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
- Do not execute all 30 tasks as one uninterrupted branch. The five-train boundary is part of the safety architecture.

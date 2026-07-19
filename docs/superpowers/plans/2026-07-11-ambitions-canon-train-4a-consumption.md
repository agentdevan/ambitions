# Ambitions Canon Train 4A — Traceability and Codex Consumption Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Compile requirement-to-source/test/proof traceability and prove bounded, resume-safe Codex context packs outperform the legacy read path.

**Architecture:** Create `codex/canon-04-consumption` from reviewed Train 3. Generate current implementation posture from evidence, then benchmark representative tasks without granting any product or release status.

**Tech Stack:** Python 3.12 standard library (`dataclasses`, `enum`, `tomllib`, `json`, `hashlib`, `sqlite3`, `argparse`, `pathlib`, `tempfile`, `unittest`), Markdown with TOML front matter, TOML/JSON registries, Git, GitHub Actions, Linear and Figma connectors where explicitly scoped.

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

---

### Task 20: Generate traceability and current implementation posture

**Files:**
- Create: `tools/ambitions_canon/traceability.py`
- Create: `tools/ambitions_canon/external_authority.py`
- Modify: `tools/ambitions_canon/cli.py`
- Create: `tests/canon/test_traceability.py`
- Create: `tests/canon/test_external_authority.py`
- Create:
  - `docs/canon/references/linear.toml`
  - `docs/canon/references/figma.toml`
  - `docs/canon/references/proof-sources.toml`
- Generate:
  - `law-source-map.json`
  - `law-test-map.json`
  - `law-proof-map.json`
  - `visual-authority-manifest.json`

**Interfaces:**
- `TraceabilityRecord`
- `build_traceability(registry, repo_root, references) -> TraceabilityReport`
- `external_reference_findings(registry, references) -> tuple[Finding, ...]`
- missing mapping is a gap, not proof of absent implementation.
- current file existence is generated, never normative.

- [ ] **Step 1: Write failing tests**

Cover:

- mapped source exists;
- intended owner path exists but no implementation file creates explicit gap;
- unknown requirement in Linear/Figma reference fails;
- superseded requirement reference fails;
- visual authority missing owner approval blocks UI readiness;
- proof source path outside repo or allowed external locator fails;
- generated maps sort by requirement ID;
- canon-to-code, code-to-canon, Figma-to-canon, and Linear-to-canon gaps remain distinct and never collapse into a generic “missing” finding.

- [ ] **Step 2: Run RED**

```bash
python3 -m unittest tests/canon/test_traceability.py \
  tests/canon/test_external_authority.py -v
```

- [ ] **Step 3: Implement traceability**

Read source-owner patterns from spec front matter, verification IDs from requirements, and stable external references from `references/**`. Inspect current repo paths with `Path.exists`; do not write implementation status into normative Markdown.

- [ ] **Step 4: Seed current references**

Populate stable Linear entity IDs and Figma file/node IDs from the migration catalog. Use only approved visual authority and explicit owner approval; candidates remain non-authoritative.

- [ ] **Step 5: Run GREEN**

```bash
python3 -m unittest tests/canon/test_traceability.py \
  tests/canon/test_external_authority.py -v
python3 scripts/ambitions-canon.py traceability --check
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
git diff --check
```

- [ ] **Step 6: Commit**

```bash
git add tools/ambitions_canon/traceability.py \
  tools/ambitions_canon/external_authority.py tools/ambitions_canon/cli.py \
  tests/canon/test_traceability.py tests/canon/test_external_authority.py \
  docs/canon/references docs/canon/generated
git commit -m "feat: trace canon to source tests and proof"
```

---
---

### Task 21: Benchmark Codex consumption and install resume-safe pack checks

**Files:**
- Modify: `tools/ambitions_canon/task_pack.py`
- Create: `tools/ambitions_canon/benchmark.py`
- Modify: `tools/ambitions_canon/cli.py`
- Create: `tests/canon/test_benchmark.py`
- Create fixtures under `tests/canon/fixtures/benchmarks/`
- Generate: `docs/canon/generated/codex-consumption-benchmark.md`

**Interfaces:**
- benchmark scenarios:
  - Today SwiftUI;
  - Time recurrence;
  - Capture proposal;
  - LocalRuntimeOS mutation;
  - CloudKit continuity;
  - Source Atlas boundary;
  - accessibility repair;
  - release-proof claim.
- deterministic measures: context characters/tokens, required-ID recall, contradictory active requirement count, source-owner mapping count, validation/proof presence.
- semantic quality review is separate evidence.

- [ ] **Step 1: Write failing benchmark tests**

Assert each fixture produces:

- exact required IDs;
- zero unrelated root-surface laws beyond shared Constitution;
- required source owner;
- required validation and proof;
- pack under its approved budget;
- stale-pack check fails after canon or git SHA changes.

- [ ] **Step 2: Run RED**

```bash
python3 -m unittest tests/canon/test_benchmark.py -v
```

- [ ] **Step 3: Implement benchmark and resume guard**

Add:

```bash
python3 scripts/ambitions-canon.py benchmark
PACK_JSON="$(find .codex/canon-packs -name '*.json' -type f | sort | tail -n 1)"
test -n "$PACK_JSON"
python3 scripts/ambitions-canon.py pack --check "$PACK_JSON"
```

Pack validation compares canon content SHA, current Git SHA, intake SHA, unresolved conflicts, and current manifest revision.

- [ ] **Step 4: Run deterministic benchmark**

```bash
python3 -m unittest tests/canon/test_benchmark.py -v
python3 scripts/ambitions-canon.py benchmark
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
git diff --check
```

- [ ] **Step 5: Run independent Codex quality comparison**

Use separate agents with old read path and new pack for the eight scenarios. Score relevant-law recall, contradiction, unauthorized assumptions, source-owner accuracy, validation completeness, and proof discipline. Record model, prompt SHA, canon SHA, and reviewer. Do not make benchmark CI depend on the model.

- [ ] **Step 6: Commit**

```bash
git add tools/ambitions_canon/task_pack.py tools/ambitions_canon/benchmark.py \
  tools/ambitions_canon/cli.py tests/canon/test_benchmark.py \
  tests/canon/fixtures/benchmarks docs/canon/generated/codex-consumption-benchmark.md
git commit -m "test: benchmark codex canon consumption"
```

---

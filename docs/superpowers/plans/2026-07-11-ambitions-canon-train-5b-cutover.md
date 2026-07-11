# Ambitions Canon Train 5B — Destructive Supersession and Final Closeout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Delete superseded repo authority in bounded commits, execute approved Linear/Figma destruction, and install final anti-regression proof.

**Architecture:** Continue `codex/canon-05-cutover` only after Train 5A cutover verification. Every deletion batch has a reviewed manifest and rollback ref; external destruction uses exact stable IDs and owner approval.

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

### Task 27: Purge superseded repo authority in bounded commits

**Files:**
- Delete only artifacts approved in `docs/canon/migration/purge-plan.toml`.
- Rewrite all tracked inbound references.
- Modify: `docs/canon/decisions/SUPERSESSION_LEDGER.toml`
- Remove temporary freeze baseline when no longer needed.

**Interfaces:**
- `purge verify` must pass before and after every batch;
- no active archive directory;
- rollback commit per batch.

- [ ] **Step 1: Batch A — product truth family**

Expected candidates after verified migration:

```text
docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/PRODUCT_ORIGIN_TRUTH.md
docs/truth/PRODUCT_MOAT_TRUTH.md
docs/truth/PRODUCT_EXPERIENCE_CANON.md
```

Delete only those marked eligible. Rewrite references and run purge verification. Commit:

```bash
git commit -m "docs: remove superseded product truth files"
```

- [ ] **Step 2: Batch B — implementation/process/release truth**

Expected candidates:

```text
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
docs/truth/CODEX_START_HERE.md
docs/truth/README.md
```

Delete only after their durable laws and generated implementation/proof projections are verified. Commit separately.

- [ ] **Step 3: Batch C — engineering constitution and registries**

Delete approved:

```text
docs/constitution/ENGINEERING_CONSTITUTION.md
docs/constitution/articles/**
docs/constitution/laws/**
docs/constitution/opportunities/**
docs/constitution/law-source-map/**
docs/constitution/law-test-map/**
docs/constitution/*.json
docs/constitution/README.md
```

Retain no compatibility copy. Commit separately.

- [ ] **Step 4: Batch D — subordinate duplicated authority**

Delete or rewrite approved Figma-gate mirrors, old product handoff docs, stale retained skills, and authority-like support docs. Preserve source-adjacent build/validation docs only when current and non-normative.

- [ ] **Step 5: Verify after every batch**

```bash
python3 scripts/ambitions-canon.py purge verify \
  --plan docs/canon/migration/purge-plan.toml
python3 scripts/ambitions-canon.py authority-sprawl --check
python3 scripts/ambitions-canon.py audit
python3 scripts/ambitions-canon.py coverage --fail-on-p0-gap
python3 scripts/ambitions-canon.py traceability --check
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
if git grep -nE 'docs/truth/|docs/constitution/' -- ':!docs/superpowers/**' \
  >.codex/canon-program/stale-authority-references.txt; then
  cat .codex/canon-program/stale-authority-references.txt
  exit 1
fi
git diff --check
```

Any active inbound reference blocks the batch.

- [ ] **Step 6: Remove migration-only freeze files after final repo batch**

Delete `scripts/ambitions-authority-freeze-check.py`, its test, and `authority-freeze-baseline.json` only when `authority-sprawl --check` is active and stronger.

---
---

### Task 28: Execute approved Linear and Figma destruction

**Files:**
- Modify tracked reconciliation/reference manifests.
- Delete temporary migration reconciliation files after completion.
- Generate final external-authority outputs.

**Interfaces:**
- external destruction uses owner-approved entity/node/file list;
- connector limitations remain explicit blockers;
- no false Green.

- [ ] **Step 1: Refresh every target before deletion**

For each Linear entity and Figma node/file, verify current title, modified state, authority status, replacement IDs, and owner approval still match the manifest.

- [ ] **Step 2: Destroy superseded Linear authority**

Delete superseded canon documents and remove copied canon prose from active execution objects. Preserve execution history, decisions referenced by the supersession ledger, and proof links. Archiving is only an interim Yellow blocker when deletion is technically unavailable; it does not satisfy this task.

If deletion is unsupported, produce a precise manual action packet and do not mark external purge Green until the owner confirms completion.

- [ ] **Step 3: Destroy superseded Figma authority**

Delete duplicate authority nodes after unique approved visual content is merged. Delete duplicate files where supported. Preserve canonical authority, failure evidence that remains materially useful, accessibility variants, and proof.

If file deletion is unsupported, produce exact file keys and owner action packet.

- [ ] **Step 4: Reconcile and validate**

```bash
python3 scripts/ambitions-canon.py external-authority --check
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
git diff --check
```

- [ ] **Step 5: Remove temporary reconciliation files and commit**

```bash
git rm docs/canon/migration/linear-reconciliation.json \
  docs/canon/migration/figma-reconciliation.json
git add docs/canon/references docs/canon/generated \
  docs/canon/decisions/SUPERSESSION_LEDGER.toml
git commit -m "docs: complete external authority supersession"
```

---
---

### Task 29: Install final anti-regression gates and close the program honestly

**Files:**
- Modify: `tools/ambitions_canon/audit.py`
- Modify: `tools/ambitions_canon/purge.py`
- Modify: `.github/workflows/ambitions-canon-audit.yml`
- Delete temporary migration catalogs that no longer serve active governance.
- Generate final:
  - `docs/canon/generated/INDEX.md`
  - `docs/canon/generated/specification-coverage.md`
  - `docs/canon/generated/codex-consumption-benchmark.md`
  - `docs/canon/generated/supersession-manifest.json`
  - `docs/canon/generated/external-reference-impact.md`

**Interfaces:**
- CI fails on authority outside canon, duplicate owner/ID, stale output, superseded reference, incomplete P0 profile, missing traceability, unknown external ID, unbuildable declared task pack, bypassed amendment, or deleted authority reference.

- [ ] **Step 1: Write final negative tests**

Add tests for:

- new `PRODUCT_TRUTH.md` outside canon;
- reused retired ID;
- stale generated output;
- active reference to deleted old truth;
- unknown Linear/Figma requirement;
- amendment without impact record;
- cutover manifest reverting to shadow;
- task pack for declared scope failing to build.

- [ ] **Step 2: Run RED, implement, and run GREEN**

Follow TDD for every new gate. Rename workflow only after tests pass.

- [ ] **Step 3: Remove migration-only state**

Delete tracked raw migration catalogs, claim dispositions, and purge plan only when their durable results exist in the supersession ledger and generated manifests. Keep no active archive.

- [ ] **Step 4: Run final full verification**

```bash
python3 -m unittest discover -s tests/canon -p 'test_*.py' -v
python3 -m compileall -q tools/ambitions_canon scripts/ambitions-canon.py
python3 scripts/ambitions-canon.py authority-sprawl --check
python3 scripts/ambitions-canon.py audit
python3 scripts/ambitions-canon.py coverage --fail-on-p0-gap
python3 scripts/ambitions-canon.py traceability --check
python3 scripts/ambitions-canon.py external-authority --check
python3 scripts/ambitions-canon.py conflicts report --require-resolved
python3 scripts/ambitions-canon.py build --check
python3 scripts/ambitions-canon.py benchmark
python3 scripts/ambitions-remediation-governance-check.py
python3 scripts/ambitions-truth-path-vocabulary-audit.py
bash scripts/canon-language-drift-scan.sh
if git grep -nE 'docs/truth/|docs/constitution/' -- ':!docs/superpowers/**' \
  >.codex/canon-program/stale-authority-references.txt; then
  cat .codex/canon-program/stale-authority-references.txt
  exit 1
fi
git diff --check
```

Expected: all required commands exit `0`; grep returns no active references outside retained historical implementation plans/specs. Historical plans may mention old paths as truthful history but cannot be routing authority.

- [ ] **Step 5: Final whole-branch review**

Use a fresh most-capable reviewer against the full Train 5 diff. Require explicit verdicts on:

- design/spec compliance;
- compiler quality;
- authority completeness;
- semantic loss;
- external reconciliation;
- deletion safety;
- rollback;
- proof/claim ceiling.

Repair and re-review all Critical/Important findings.

- [ ] **Step 6: Commit final gates**

```bash
git add tools/ambitions_canon tests/canon .github/workflows \
  docs/canon scripts/ambitions-canon.py
git commit -m "test: enforce the canonical specification system"
```

- [ ] **Step 7: Finish the development branch**

Use `superpowers:finishing-a-development-branch`. Prefer a reviewed draft PR, then merge Train 5 only after CI and owner acceptance.

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

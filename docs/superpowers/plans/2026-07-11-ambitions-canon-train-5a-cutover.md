# Ambitions Canon Train 5A — Purge Safety, Dual-Run Proof, and Authority Cutover Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prove purge eligibility and reference safety, pass the dual-run gate, then atomically switch repo routing and CI to the new canon.

**Architecture:** Create `codex/canon-05-cutover` from the merged reviewed Train 4 head. Cutover is serialized, owner-approved, independently reviewed, and reversible through named tags and a single routing/CI boundary commit.

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

### Task 24: Implement purge eligibility, authority-sprawl enforcement, and reference verification

**Files:**
- Create: `tools/ambitions_canon/purge.py`
- Modify: `tools/ambitions_canon/audit.py`
- Modify: `tools/ambitions_canon/cli.py`
- Create: `tests/canon/test_purge.py`
- Create: `tests/canon/test_integration.py`
- Create fixtures:
  - `tests/canon/fixtures/purge-eligible.toml`
  - `tests/canon/fixtures/purge-unresolved-claim.toml`
  - `tests/canon/fixtures/purge-active-reference.toml`
  - `tests/canon/fixtures/authority-outside-canon.txt`

**Interfaces:**
- `PurgeArtifact`
- `build_purge_plan(source_catalog, dispositions, references, rollback_ref) -> PurgePlan`
- `purge_findings(plan: PurgePlan, repo_root: Path, registry: CanonRegistry) -> tuple[Finding, ...]`
- `authority_sprawl_findings(repo_root, manifest, baseline=None) -> tuple[Finding, ...]`
- `purge plan` is read-only except for its named output file.
- `purge verify --dry-run` never deletes.
- Actual deletion remains explicit Git/connector work in later tasks.

- [ ] **Step 1: Write failing purge tests**

Cover:

1. eligible artifact has every claim disposition, replacement ID, inbound-link rewrite, owner approval, independent review, and rollback ref;
2. unresolved claim blocks with `PURGE_CLAIM_UNRESOLVED`;
3. missing replacement requirement blocks;
4. active inbound Git reference blocks;
5. unknown Linear/Figma reference blocks;
6. missing owner approval blocks;
7. no archive destination is accepted as a substitute for delete;
8. plan serialization is deterministic;
9. dry-run does not mutate files.

- [ ] **Step 2: Write failing authority-sprawl tests**

Assert:

- normative file under `docs/canon/` and listed by manifest passes;
- authority-like file outside `docs/canon/` fails after cutover;
- current legacy files are allowed only while `authority_state = "shadow"` or while explicitly present in the approved purge plan;
- source comments containing the word `authority` do not fail solely by wording;
- a new `PRODUCT_TRUTH.md`, `CANON.md`, or `CONSTITUTION.md` outside the manifest fails.

- [ ] **Step 3: Write failing integration tests**

Add full pipelines:

```text
parse → manifest → registry → graph → audit → build
amendment → impact → supersession
issue intake → task pack → stale check
source catalog → claims → conflict docket
purge plan → reference scan → verify
```

Use temporary repositories and fixtures; no network.

- [ ] **Step 4: Run RED**

```bash
python3 -m unittest tests/canon/test_purge.py tests/canon/test_integration.py -v
```

Expected: missing module/functions.

- [ ] **Step 5: Implement purge and sprawl checks**

Purge plan TOML artifact shape:

```toml
[[artifact]]
artifact_id = "REPO-PRODUCT-EXPERIENCE-CANON"
kind = "repo"
locator = "docs/truth/PRODUCT_EXPERIENCE_CANON.md"
action = "delete"
replacement_ids = ["EXPERIENCE-001", "USER-CONTROL-001", "LEARNING-004"]
claims_resolved = true
incoming_links_rewritten = true
external_references_reconciled = true
owner_approved = true
independent_review = true
rollback_ref = "canon-system-baseline-2026-07-11"
```

Do not execute deletion in Python. The compiler proves eligibility and validates the post-delete tree.

- [ ] **Step 6: Run GREEN**

```bash
python3 -m unittest tests/canon/test_purge.py tests/canon/test_integration.py -v
python3 scripts/ambitions-canon.py authority-sprawl --check
python3 scripts/ambitions-canon.py purge plan \
  --output .codex/canon-migration/sample-purge-plan.toml
python3 scripts/ambitions-canon.py purge verify \
  --plan .codex/canon-migration/sample-purge-plan.toml --dry-run
git diff --check
```

Expected: shadow authority-sprawl check permits only baseline legacy authority plus `docs/canon/`; sample plan verifies without mutation.

- [ ] **Step 7: Commit**

```bash
git add tools/ambitions_canon/purge.py tools/ambitions_canon/audit.py \
  tools/ambitions_canon/cli.py tests/canon/test_purge.py \
  tests/canon/test_integration.py tests/canon/fixtures
git commit -m "feat: prove authority purge eligibility"
```

---
---

### Task 25: Prove the dual-run cutover gate

**Files:**
- Create generated report: `docs/canon/generated/cutover-readiness.md`
- Create: `docs/canon/migration/purge-plan.toml`
- Modify generated outputs only.

**Interfaces:**
- old and new audits coexist;
- every old active authority has disposition;
- no accepted unique claim lost;
- no unresolved P0 conflict/gap;
- rollback tag exists;
- external reconciliation state explicit.

- [ ] **Step 1: Generate purge plan without deleting**

```bash
python3 scripts/ambitions-canon.py purge plan \
  --output docs/canon/migration/purge-plan.toml
```

Every artifact entry must contain action, replacement IDs, claim coverage, incoming-link status, external impact, owner approval, independent-review state, and rollback ref.

- [ ] **Step 2: Run the full dual-run matrix**

```bash
python3 -m unittest discover -s tests/canon -p 'test_*.py' -v
python3 -m unittest scripts/tests/test_ambitions_authority_freeze_check.py -v
python3 -m compileall -q tools/ambitions_canon scripts/ambitions-canon.py
python3 scripts/ambitions-authority-freeze-check.py
python3 scripts/ambitions-canon.py audit
python3 scripts/ambitions-canon.py coverage --fail-on-p0-gap
python3 scripts/ambitions-canon.py traceability --check
python3 scripts/ambitions-canon.py external-authority --check
python3 scripts/ambitions-canon.py conflicts report --require-resolved
python3 scripts/ambitions-canon.py migration claims coverage
python3 scripts/ambitions-canon.py build --check
python3 scripts/ambitions-canon.py benchmark
python3 scripts/ambitions-canon.py purge verify --plan docs/canon/migration/purge-plan.toml --dry-run
python3 scripts/ambitions-constitution-audit.py
python3 scripts/ambitions-remediation-governance-check.py
python3 scripts/ambitions-truth-path-vocabulary-audit.py
bash scripts/canon-language-drift-scan.sh
git diff --check
```

- [ ] **Step 3: Independent cutover review**

A fresh Sol Max reviewer verifies:

- all design acceptance criteria;
- old audit invariant parity;
- semantic coverage;
- external reconciliation;
- task-pack benchmark;
- purge eligibility;
- rollback.

Repair all Critical/Important findings.

- [ ] **Step 4: Record owner cutover decision**

The report must state `owner_cutover_approval = true` with date and approved purge scope. Without it, stop.

- [ ] **Step 5: Commit readiness evidence**

```bash
git add docs/canon/generated/cutover-readiness.md \
  docs/canon/migration/purge-plan.toml
git commit -m "docs: prove canon cutover readiness"
```

---
---

### Task 26: Cut over repo routing and CI to the new canon

**Files:**
- Modify: `docs/canon/MANIFEST.toml`
- Modify: `AGENTS.md`
- Modify: `README.md`
- Modify: `docs/README.md`
- Modify: `.agents/skills/README.md`
- Modify retained `.agents/skills/*/SKILL.md` references as required.
- Rename and modify: `.github/workflows/ambitions-canon-shadow-audit.yml` → `.github/workflows/ambitions-canon-audit.yml`
- Delete: `.github/workflows/ambitions-constitution-audit.yml`
- Delete: `scripts/ambitions-constitution-audit.py`
- Generate: `docs/canon/generated/CODEX_START_HERE.md`
- Create Git tag after commit: `ambitions-canon-v1-cutover`

**Interfaces:**
- `authority_state = "active"`;
- `canon_revision = 1`;
- `docs/canon/` is sole normative root;
- old docs remain temporarily present but non-normative and listed in purge plan;
- AGENTS is a thin router.

- [ ] **Step 1: Change manifest state**

```toml
authority_state = "active"
canon_revision = 1
```

Active audit now requires exactly one Constitution and all listed normative files.

- [ ] **Step 2: Rewrite AGENTS as thin routing contract**

AGENTS must:

1. point to generated `docs/canon/generated/CODEX_START_HERE.md`;
2. require `ambitions-canon pack` for nontrivial work;
3. preserve current local-first, proof, branch, XcodeGen, and resume safety;
4. avoid copying Constitution or surface law;
5. state old truth/constitution files are non-authoritative pending purge.

- [ ] **Step 3: Replace CI**

Rename the workflow file and workflow name:

```bash
git mv .github/workflows/ambitions-canon-shadow-audit.yml \
  .github/workflows/ambitions-canon-audit.yml
```

Set the workflow name to `Ambitions Canon Audit` and run:

```text
authority-sprawl --check
audit
coverage --fail-on-p0-gap
traceability --check
external-authority --check
build --check
unit tests
git diff --check
```

Delete old audit only after Task 25 proves invariant parity.

- [ ] **Step 4: Run cutover validation**

Run the full new matrix plus targeted scans showing no active router points to old truth. Do not run the deleted old audit after deletion.

- [ ] **Step 5: Commit and tag**

```bash
git add docs/canon/MANIFEST.toml AGENTS.md README.md docs/README.md \
  .agents/skills .github/workflows docs/canon/generated/CODEX_START_HERE.md
git rm .github/workflows/ambitions-constitution-audit.yml \
  scripts/ambitions-constitution-audit.py
git commit -m "docs: cut over to canonical specification system"
CUTOVER_SHA="$(git rev-parse HEAD)"
git tag -a ambitions-canon-v1-cutover "$CUTOVER_SHA" \
  -m "Ambitions canon and specification system authority cutover"
```

- [ ] **Step 6: Stop for post-cutover verification**

Do not purge in the same commit. Re-run pack generation for all benchmark scenarios from the tagged cutover.

---

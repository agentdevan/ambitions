# Ambitions Canon Train 1C — Deterministic Build, Coverage, and Task Packs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Generate deterministic shadow projections, measure specification completeness, and produce bounded, stale-safe Codex context packs.

**Architecture:** Finish `codex/canon-01-foundation` on top of Train 1B. Outputs remain shadow and non-authoritative; the current constitutional audit and routing stay active while the new build is verified independently.

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

### Task 6: Generate deterministic projections atomically and add shadow CI

**Files:**
- Create: `tools/ambitions_canon/render.py`
- Create: `tools/ambitions_canon/build.py`
- Modify: `tools/ambitions_canon/cli.py`
- Create: `tests/canon/test_build.py`
- Create: `tests/canon/golden/shadow/**`
- Generate: `docs/canon/generated/**`
- Create: `.github/workflows/ambitions-canon-shadow-audit.yml`

**Interfaces:**
- `canon_content_sha(manifest_path: Path, source_paths: Iterable[Path]) -> str`
- `render_outputs(registry: CanonRegistry) -> Mapping[Path, bytes]`
- `write_outputs_atomic(root: Path, outputs: Mapping[Path, bytes]) -> None`
- `check_outputs(root: Path, outputs: Mapping[Path, bytes]) -> tuple[Finding, ...]`
- `build` writes; `build --check` compares without mutation.

- [ ] **Step 1: Write failing build tests**

Cover:

- same input produces byte-identical output;
- document insertion order does not alter output;
- no timestamp appears;
- every text file ends in newline;
- failed render leaves existing generated directory untouched;
- `--check` reports changed, missing, and extra generated files.

- [ ] **Step 2: Run RED**

```bash
python3 -m unittest tests/canon/test_build.py -v
```

- [ ] **Step 3: Implement deterministic render and atomic swap**

JSON rendering:

```python
def stable_json(value: object) -> bytes:
    return (json.dumps(
        value,
        ensure_ascii=False,
        indent=2,
        sort_keys=True,
        separators=(",", ": "),
    ) + "\n").encode("utf-8")
```

Build into `tempfile.TemporaryDirectory(dir=generated.parent)`, validate all expected paths, then replace files with `os.replace`. Do not place the temporary directory inside tracked output.

- [ ] **Step 4: Generate and accept shadow goldens**

```bash
python3 scripts/ambitions-canon.py build
cp -R docs/canon/generated/. tests/canon/golden/shadow/
python3 scripts/ambitions-canon.py build --check
```

Expected: `build --check` prints `GREEN ambitions canon generated outputs`.

- [ ] **Step 5: Add shadow CI**

Workflow requirements:

- triggers on `docs/canon/**`, compiler/tests, freeze guard, and workflow changes;
- uses `actions/setup-python@v5` with Python `3.12`;
- runs freeze guard, unit tests, compileall, `audit`, `build --check`, and `git diff --check`;
- does not replace or modify `.github/workflows/ambitions-constitution-audit.yml`.

- [ ] **Step 6: Run GREEN**

```bash
python3 -m unittest discover -s tests/canon -p 'test_*.py' -v
python3 -m unittest scripts/tests/test_ambitions_authority_freeze_check.py -v
python3 -m compileall -q tools/ambitions_canon scripts/ambitions-canon.py
python3 scripts/ambitions-authority-freeze-check.py
python3 scripts/ambitions-canon.py audit
python3 scripts/ambitions-canon.py build --check
python3 scripts/ambitions-constitution-audit.py
git diff --check
```

Expected: both old and new audits are Green.

- [ ] **Step 7: Commit and end Train 1 foundation slice A**

```bash
git add tools/ambitions_canon tests/canon docs/canon/generated \
  .github/workflows/ambitions-canon-shadow-audit.yml
git commit -m "feat: compile deterministic canon projections"
```

---
---

### Task 7: Enforce specification completeness profiles and gap severities

**Files:**
- Create: `tools/ambitions_canon/coverage.py`
- Modify: `tools/ambitions_canon/cli.py`
- Create: `tests/canon/test_coverage.py`
- Create: `docs/canon/schemas/completeness-profiles.toml`
- Add fixtures:
  - `tests/canon/fixtures/incomplete-surface.md`
  - `tests/canon/fixtures/not-applicable-with-rationale.md`
  - `tests/canon/fixtures/not-applicable-without-owner.md`

**Interfaces:**
- `load_profiles(path: Path) -> Mapping[str, tuple[str, ...]]`
- `coverage_findings(registry: CanonRegistry, profiles: Mapping[str, tuple[str, ...]]) -> tuple[Finding, ...]`
- Gap classes are `canon_to_code`, `code_to_canon`, `figma_to_canon`, `linear_to_canon`, and `internal_specification`.
- Section markers are required body evidence.
- `not_applicable` entries require `rationale` and `owner`.
- CLI `coverage --fail-on-p0-gap`.

- [ ] **Step 1: Define exact profiles**

Create `surface-v1`, `object-v1`, `journey-v1`, and `system-v1` with the exact required cells in approved design sections 12.1–12.4. `surface-v1` must separately require Dynamic Type, Reduce Motion, and Reduce Transparency rather than accepting a generic accessibility paragraph. Create `standard-v1` with:

```text
purpose
scope
requirements
exceptions
verification
source-ownership
proof
amendment-impact
```

- [ ] **Step 2: Write failing tests**

Assert:

- missing `failure-rollback` in a surface creates `P0_BLOCKER CANON_PROFILE_SECTION_MISSING`;
- nonempty marker satisfies a cell;
- marker followed only by whitespace fails;
- `not_applicable` with rationale and owner satisfies;
- missing owner fails;
- unknown profile fails;
- the five gap classes serialize with stable severity and affected requirement/spec IDs.

- [ ] **Step 3: Run RED**

```bash
python3 -m unittest tests/canon/test_coverage.py -v
```

- [ ] **Step 4: Implement coverage**

Do not infer coverage from heading wording. Use explicit `canon-section` markers and the approved `not_applicable` table only. The exact TOML shape is:

```toml
[not_applicable.performance]
rationale = "This provenance-only specification performs no runtime work."
owner = "Devan Warner"
```

- [ ] **Step 5: Run GREEN**

```bash
python3 -m unittest tests/canon/test_coverage.py -v
python3 scripts/ambitions-canon.py coverage
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
git diff --check
```

Expected: shadow registry reports no normative profile findings.

- [ ] **Step 6: Commit**

```bash
git add tools/ambitions_canon/coverage.py tools/ambitions_canon/cli.py \
  tests/canon/test_coverage.py tests/canon/fixtures \
  docs/canon/schemas/completeness-profiles.toml docs/canon/generated
git commit -m "feat: detect application specification gaps"
```

---
---

### Task 8: Add queries, bounded task packs, and stale-pack rejection

**Files:**
- Create: `tools/ambitions_canon/query.py`
- Create: `tools/ambitions_canon/task_pack.py`
- Modify: `tools/ambitions_canon/cli.py`
- Create: `tests/canon/test_query.py`
- Create: `tests/canon/test_task_pack.py`
- Create fixture: `tests/canon/fixtures/issue-intake.json`

**Interfaces:**
- `query_by_id(registry: CanonRegistry, identifier: str) -> object`
- `query_by_concept(registry: CanonRegistry, concept: str) -> tuple[Requirement, ...]`
- `TaskIntake.from_json(data: Mapping[str, object]) -> TaskIntake`
- `build_task_pack(registry, intake, repository_sha, known_issues) -> TaskPack`
- `estimate_tokens(text: str) -> int` equals `(len(text) + 3) // 4`.
- `write_task_pack` writes ignored `.codex/canon-packs/$CANON_SHA/$PACK_NAME.md` and `.json`; the CLI derives both shell-safe values.
- `pack --check` rejects canon SHA, repository SHA, or intake SHA mismatch.

- [ ] **Step 1: Define the intake fixture**

```json
{
  "schema_version": 1,
  "issue_id": "AMB-1842",
  "task_type": "swiftui",
  "scope": ["surface.today"],
  "changed_files": ["Native/Ambitions/Surfaces/Today"],
  "claim_type": "source",
  "known_issue_ids": []
}
```

- [ ] **Step 2: Write failing tests**

Cover:

- ID and concept query;
- dependency closure includes inherited Constitution laws and object specs;
- unrelated Time spec excluded from Today pack;
- deterministic output;
- token estimate;
- mechanical/normal/complex budgets;
- over-budget pack fails rather than truncates required law;
- stale canon SHA and repository SHA fail;
- unresolved P0 conflict blocks pack.

- [ ] **Step 3: Run RED**

```bash
python3 -m unittest tests/canon/test_query.py tests/canon/test_task_pack.py -v
```

- [ ] **Step 4: Implement query and pack**

Pack section order is fixed:

```text
Identity
Constitutional laws
Owning specifications
Object lifecycles
Journeys
Cross-cutting standards
Source ownership
Implementation posture
Known risks
Visual authority
Required tests
Validation
Proof
Forbidden changes
Open conflicts
Claim ceiling
Rollback
```

Context budgets:

```python
PACK_BUDGETS = {
    "mechanical": 8_000,
    "normal": 16_000,
    "complex": 30_000,
    "constitutional-audit": None,
}

TASK_TYPE_BUDGET_CLASS = {
    "mechanical": "mechanical",
    "docs": "normal",
    "release": "normal",
    "swiftui": "complex",
    "runtime": "complex",
    "privacy": "complex",
    "constitutional-audit": "constitutional-audit",
}
```

Unknown task types fail `PACK_TASK_TYPE_UNKNOWN`. These are token ceilings, not targets.

- [ ] **Step 5: Run GREEN**

```bash
python3 -m unittest tests/canon/test_query.py tests/canon/test_task_pack.py -v
python3 scripts/ambitions-canon.py pack --issue-json tests/canon/fixtures/issue-intake.json
git diff --check
```

Expected: tests pass; shadow pack is generated but clearly states that no active normative canon exists yet and cannot authorize implementation.

- [ ] **Step 6: Commit and complete Train 1**

```bash
git add tools/ambitions_canon/query.py tools/ambitions_canon/task_pack.py \
  tools/ambitions_canon/cli.py tests/canon
git commit -m "feat: generate bounded codex canon packs"
```

Run whole-train review and open draft PR `codex/canon-01-foundation` → `main`. Do not start Train 2 until review findings are fixed and Train 1 is merged or the owner approves a stacked base.

---

# Ambitions Canon Train 1A — Freeze, Model, and CLI Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish the isolated baseline, prevent new authority sprawl during migration, and install the typed canon model plus thin CLI.

**Architecture:** Begin on `codex/canon-01-foundation` from current `main`. Preserve every existing authority as active while adding only the shadow migration baseline, freeze guard, and typed command surface that later compiler tasks consume.

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

### Task 0: Create the isolated program workspace and capture the immutable baseline

**Files:**
- Read: `docs/superpowers/specs/2026-07-11-ambitions-canon-specification-system-design.md`
- Read: `AGENTS.md`
- Read: `docs/truth/README.md`
- Read: `docs/truth/CODEX_START_HERE.md`
- Read: `scripts/ambitions-constitution-audit.py`
- Produce ignored evidence: `.codex/canon-program/baseline.json`
- Create Git tag: `canon-system-baseline-2026-07-11`

**Interfaces:**
- Consumes: clean current `main`.
- Produces: isolated worktree, Train 1 branch, baseline SHA/tag, baseline validation record.

- [ ] **Step 1: Detect or create isolation**

Use `superpowers:using-git-worktrees`. Detect existing isolation before creating anything. If a native worktree tool exists, use it. Otherwise verify `.worktrees/` is ignored and create:

```bash
git worktree add .worktrees/canon-01-foundation -b codex/canon-01-foundation main
cd .worktrees/canon-01-foundation
```

Expected: current branch is `codex/canon-01-foundation`; `git status --short` is empty.

- [ ] **Step 2: Capture baseline identity**

```bash
mkdir -p .codex/canon-program
BASELINE_SHA="$(git rev-parse HEAD)"
python3 - "$BASELINE_SHA" > .codex/canon-program/baseline.json <<'PY'
import json
import platform
import sys

sha = sys.argv[1]
print(json.dumps({
    "schema_version": 1,
    "baseline_sha": sha,
    "python": platform.python_version(),
    "platform": platform.platform(),
}, indent=2, sort_keys=True))
PY
if git rev-parse -q --verify refs/tags/canon-system-baseline-2026-07-11 >/dev/null; then
  test "$(git rev-list -n 1 canon-system-baseline-2026-07-11)" = "$BASELINE_SHA"
else
  git tag -a canon-system-baseline-2026-07-11 "$BASELINE_SHA" \
    -m "Ambitions canon system pre-migration baseline"
fi
```

Expected: the ignored JSON contains the exact baseline SHA; the annotated tag resolves to the same SHA.

- [ ] **Step 3: Run baseline governance checks**

```bash
python3 scripts/ambitions-constitution-audit.py
python3 scripts/ambitions-remediation-governance-check.py
python3 scripts/ambitions-truth-path-vocabulary-audit.py
bash scripts/canon-language-drift-scan.sh
git diff --check
```

Expected: capture exact exit codes and outputs in the task report. Any pre-existing Red blocks execution until the owner explicitly accepts investigation or repair; do not normalize it away.

- [ ] **Step 4: Record that Task 0 creates no tracked commit**

Expected: `git status --short` remains empty because `.codex/` is ignored.

---
---

### Task 1: Install the authority-freeze guard

**Files:**
- Create: `scripts/ambitions-authority-freeze-check.py`
- Create: `scripts/tests/test_ambitions_authority_freeze_check.py`
- Create: `docs/canon/migration/authority-freeze-baseline.json`

**Interfaces:**
- Consumes: tracked path list from `git ls-files`.
- Produces:
  - `authority_candidates(paths: Iterable[str]) -> tuple[str, ...]`
  - `new_authority_paths(paths: Iterable[str], baseline: set[str]) -> tuple[str, ...]`
  - CLI exit `0` when no new external authority appears, `1` for drift, `2` for invalid input.

- [ ] **Step 1: Write the failing tests**

```python
# scripts/tests/test_ambitions_authority_freeze_check.py
import importlib.util
import unittest
from pathlib import Path

SCRIPT = Path(__file__).parents[1] / "ambitions-authority-freeze-check.py"

def load_module():
    spec = importlib.util.spec_from_file_location("authority_freeze", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

class AuthorityFreezeTests(unittest.TestCase):
    def setUp(self):
        self.module = load_module()

    def test_detects_new_truth_file_outside_canon(self):
        paths = ["docs/truth/README.md", "docs/product/NEW_PRODUCT_TRUTH.md"]
        baseline = {"docs/truth/README.md"}
        self.assertEqual(
            self.module.new_authority_paths(paths, baseline),
            ("docs/product/NEW_PRODUCT_TRUTH.md",),
        )

    def test_allows_new_shadow_files_under_docs_canon(self):
        paths = ["docs/canon/MANIFEST.toml", "docs/canon/specifications/surfaces/today.md"]
        self.assertEqual(self.module.new_authority_paths(paths, set()), ())

    def test_ignores_superpowers_specs_and_plans(self):
        paths = [
            "docs/superpowers/specs/2026-07-11-design.md",
            "docs/superpowers/plans/2026-07-11-plan.md",
        ]
        self.assertEqual(self.module.new_authority_paths(paths, set()), ())

    def test_candidate_matching_is_case_insensitive_and_path_aware(self):
        paths = ["docs/Canon.md", "docs/design/AUTHORITY-notes.md", "Native/Foo.swift"]
        self.assertEqual(
            self.module.authority_candidates(paths),
            ("docs/Canon.md", "docs/design/AUTHORITY-notes.md"),
        )

if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run RED**

```bash
python3 -m unittest scripts/tests/test_ambitions_authority_freeze_check.py -v
```

Expected: import or missing-function failure because the script does not exist.

- [ ] **Step 3: Implement the guard**

```python
#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[1]
BASELINE = ROOT / "docs/canon/migration/authority-freeze-baseline.json"
AUTHORITY_WORD_RE = re.compile(
    r"(truth|canon|constitution|doctrine|authority)",
    re.IGNORECASE,
)
ALLOWED_PREFIXES = ("docs/canon/", "docs/superpowers/specs/", "docs/superpowers/plans/")

def authority_candidates(paths: Iterable[str]) -> tuple[str, ...]:
    candidates = set()
    for path in paths:
        if path.startswith(ALLOWED_PREFIXES):
            continue
        if any(AUTHORITY_WORD_RE.search(part) for part in Path(path).parts):
            candidates.add(path)
    return tuple(sorted(candidates))

def new_authority_paths(paths: Iterable[str], baseline: set[str]) -> tuple[str, ...]:
    return tuple(path for path in authority_candidates(paths) if path not in baseline)

def tracked_paths() -> tuple[str, ...]:
    output = subprocess.check_output(
        ["git", "ls-files"], cwd=ROOT, text=True
    )
    return tuple(line for line in output.splitlines() if line)

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--baseline", type=Path, default=BASELINE)
    args = parser.parse_args()
    if not args.baseline.exists():
        print(f"RED AUTHORITY_FREEZE_BASELINE_MISSING {args.baseline}", file=sys.stderr)
        return 2
    baseline = set(json.loads(args.baseline.read_text(encoding="utf-8"))["paths"])
    findings = new_authority_paths(tracked_paths(), baseline)
    if findings:
        for finding in findings:
            print(f"RED AUTHORITY_FREEZE_NEW_PATH {finding}", file=sys.stderr)
        return 1
    print(f"GREEN authority freeze baseline_paths={len(baseline)}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
```

Generate the baseline from current candidates:

```bash
mkdir -p docs/canon/migration
python3 - <<'PY'
import importlib.util
import json
import subprocess
from pathlib import Path

script = Path("scripts/ambitions-authority-freeze-check.py")
spec = importlib.util.spec_from_file_location("authority_freeze", script)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
paths = subprocess.check_output(["git", "ls-files"], text=True).splitlines()
payload = {"schema_version": 1, "paths": list(module.authority_candidates(paths))}
Path("docs/canon/migration/authority-freeze-baseline.json").write_text(
    json.dumps(payload, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)
PY
```

- [ ] **Step 4: Run GREEN and live guard**

```bash
python3 -m unittest scripts/tests/test_ambitions_authority_freeze_check.py -v
python3 scripts/ambitions-authority-freeze-check.py
git diff --check
```

Expected: 4 tests pass; live command prints `GREEN authority freeze`.

- [ ] **Step 5: Commit**

```bash
git add scripts/ambitions-authority-freeze-check.py \
  scripts/tests/test_ambitions_authority_freeze_check.py \
  docs/canon/migration/authority-freeze-baseline.json
git commit -m "test: freeze new authority sprawl"
```

---
---

### Task 2: Create the typed canon model and thin CLI

**Files:**
- Create: `tools/ambitions_canon/__init__.py`
- Create: `tools/ambitions_canon/model.py`
- Create: `tools/ambitions_canon/cli.py`
- Create: `scripts/ambitions-canon.py`
- Create: `tests/canon/test_model.py`

**Interfaces:**
- Produces:
  - `CanonError`
  - `AuthorityState`, `AuthorityClass`, `DocumentKind`, `Modality`, `GapSeverity`
  - immutable `Requirement`, `CanonDocument`, `ManifestEntry`, `CanonManifest`, `Finding`, `CanonRegistry`, and `NotApplicable`
  - `ensure_supported_python(version: tuple[int, int]) -> None`
  - `cli.main(argv: Sequence[str] | None = None) -> int`
  - `version` command.
- `DocumentKind` values are `constitution`, `app`, `surface`, `global`, `object`, `journey`, `system`, and `standard`.

- [ ] **Step 1: Write failing model tests**

```python
# tests/canon/test_model.py
import unittest
from pathlib import Path
from tools.ambitions_canon.model import CanonError, Modality, Requirement

class ModelTests(unittest.TestCase):
    def test_requirement_is_immutable(self):
        requirement = Requirement(
            requirement_id="TODAY-IDENTITY-001",
            title="Primary identity",
            concept="surface.today.primary-identity",
            modality=Modality.MUST,
            scope="Today root at rest",
            status="normative",
            verification=("SCENARIO-TODAY-001",),
            supersedes=(),
            body="Today presents actionable reality around now.",
            source_path=Path("today.md"),
            line=10,
        )
        with self.assertRaises(AttributeError):
            requirement.title = "Changed"

    def test_rejects_unsupported_python(self):
        from tools.ambitions_canon.cli import ensure_supported_python
        with self.assertRaisesRegex(CanonError, "PYTHON_VERSION_UNSUPPORTED"):
            ensure_supported_python((3, 10))

    def test_canon_error_formats_stable_code_path_and_line(self):
        error = CanonError(
            "CANON_PARSE_FRONT_MATTER",
            "missing closing delimiter",
            Path("today.md"),
            3,
        )
        self.assertEqual(
            str(error),
            "CANON_PARSE_FRONT_MATTER today.md:3 missing closing delimiter",
        )

if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run RED**

```bash
python3 -m unittest tests/canon/test_model.py -v
```

Expected: `ModuleNotFoundError`.

- [ ] **Step 3: Implement the model**

Implement `model.py` with `@dataclass(frozen=True, slots=True)` records and `StrEnum` values. The minimum exact fields are:

```python
@dataclass(frozen=True, slots=True)
class Requirement:
    requirement_id: str
    title: str
    concept: str
    modality: Modality
    scope: str
    status: str
    verification: tuple[str, ...]
    supersedes: tuple[str, ...]
    body: str
    source_path: Path
    line: int

@dataclass(frozen=True, slots=True)
class CanonDocument:
    spec_id: str
    title: str
    kind: DocumentKind
    status: str
    owner_domain: str
    canon_revision: int
    profile: str | None
    owns_concepts: tuple[str, ...]
    inherits: tuple[str, ...]
    depends_on: tuple[str, ...]
    source_owners: tuple[str, ...]
    sections: frozenset[str]
    not_applicable: tuple[NotApplicable, ...]
    requirements: tuple[Requirement, ...]
    source_path: Path

@dataclass(frozen=True, slots=True)
class Finding:
    code: str
    severity: GapSeverity
    message: str
    path: Path | None = None
    line: int | None = None
```

`CanonError.__str__` must format `CODE path:line message`, omitting path/line only when absent.

Implement CLI version output:

```text
ambitions-canon 0.1.0
```

The thin script checks `sys.version_info` before importing the package so Python 3.10 and older exit cleanly:

```python
#!/usr/bin/env python3
import sys

if sys.version_info < (3, 11):
    print("PYTHON_VERSION_UNSUPPORTED requires Python 3.11+", file=sys.stderr)
    raise SystemExit(2)

from tools.ambitions_canon.cli import main

raise SystemExit(main())
```

`ensure_supported_python` remains a testable package helper for embedded callers.

- [ ] **Step 4: Run GREEN**

```bash
python3 -m unittest tests/canon/test_model.py -v
python3 scripts/ambitions-canon.py version
python3 -m py_compile scripts/ambitions-canon.py tools/ambitions_canon/*.py
```

Expected: 3 tests pass; version prints exactly `ambitions-canon 0.1.0`.

- [ ] **Step 5: Commit**

```bash
git add tools/ambitions_canon scripts/ambitions-canon.py tests/canon/test_model.py
git commit -m "feat: add typed canon compiler foundation"
```

---

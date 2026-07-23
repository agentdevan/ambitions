# Wave 2 Visual Closure Installation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> `superpowers:subagent-driven-development` (recommended) or
> `superpowers:executing-plans` to implement this plan task-by-task.

**Goal:** Install the closed VC-07 through VC-12 visual authority as deterministic
human and machine canon, project it through the compiler, and leave product code,
Figma, SwiftUI, and implementation authorization unchanged.

**Architecture:** Add one human closure record and one machine peer beside the
Wave 1 records. Extend the existing canon compiler’s visual-closure projection
to load and validate both waves, then regenerate deterministic outputs. Update
only durable reference and status documentation required by the closure.

**Tech Stack:** Markdown, JSON, TOML, Python 3 standard library, the existing
Ambitions canon compiler, and the existing test suite.

## Global constraints

- Repository: `agentdevan/ambitions`
- Baseline observed when this package was generated:
  `184e364076af7b31ece1b1b98870bc647ed50fb7`
- Active AVF IDs remain unchanged.
- `VC-01` through `VC-12`: `CLOSED`.
- `VC-13`: `OPEN`.
- `VC-14`: `NOT_STARTED`.
- Figma, SwiftUI, and implementation authorization remain `false`.
- Do not edit app source, Xcode project files, design tokens, Figma artifacts,
  Code Connect, or screenshot baselines.
- Do not hand-edit generated canon.
- Stop rather than silently reconcile a conflict with newer owner or ADR
  authority.

---

## File map

### Create

- `docs/canon/design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md`
- `docs/canon/design/vc-wave-2-surface-journey-closure.json`
- `docs/superpowers/plans/2026-07-22-wave-2-visual-closure-installation.md`

### Modify

- `docs/canon/MANIFEST.toml`
- `docs/canon/README.md`
- `docs/canon/design/VISUAL_SYSTEM_R1.md`
- `tools/ambitions_canon/compiler.py`
- `tools/tests/test_ambitions_canon_compiler.py`

### Regenerate through the compiler

- `docs/canon/generated/CODEX_START_HERE.md`
- `docs/canon/generated/INDEX.md`
- `docs/canon/generated/canon-index.json`
- `docs/canon/generated/object-boundary-matrix.md`
- `docs/canon/generated/requirement-graph.json`
- `docs/canon/generated/requirement-traceability.json`
- `docs/canon/generated/visual-authority-manifest.json`

## Task 1: Preflight and isolate

- [ ] Verify a clean working tree.

```bash
git status --short
```

Expected: no output.

- [ ] Record branch and head.

```bash
git branch --show-current
git rev-parse HEAD
```

A newer head than the package baseline is permitted only after reviewing changes
to visual closure, the compiler, manifest, and generated canon.

- [ ] Create an isolated worktree.

```bash
git worktree add ../ambitions-wave-2-visual-closure \
  -b codex/wave-2-visual-closure main
cd ../ambitions-wave-2-visual-closure
```

- [ ] Validate the baseline.

```bash
python3 scripts/ambitions-canon.py check
python3 -m pytest tools/tests/test_ambitions_canon_compiler.py -q
```

Expected: both pass before editing.

## Task 2: Install source records

- [ ] Copy the supplied records exactly to:

```text
docs/canon/design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md
docs/canon/design/vc-wave-2-surface-journey-closure.json
```

- [ ] Validate the machine peer.

```bash
python3 - <<'PY'
import json
from pathlib import Path

p = Path("docs/canon/design/vc-wave-2-surface-journey-closure.json")
data = json.loads(p.read_text())
assert data["package_id"] == "AMB-VC-WAVE-2-SURFACE-JOURNEY-CLOSURE"
assert data["status"] == "CLOSED"
assert data["package_statuses"]["VC-12"] == "CLOSED"
assert data["package_statuses"]["VC-13"] == "OPEN"
assert data["package_statuses"]["VC-14"] == "NOT_STARTED"
assert data["authorization_state"] == {
    "figma": False,
    "implementation": False,
    "swiftui": False,
}
assert [x["package_id"] for x in data["packages"]] == [
    "VC-07", "VC-08", "VC-09", "VC-10", "VC-11", "VC-12"
]
print("Wave 2 peer valid")
PY
```

Expected: `Wave 2 peer valid`.

- [ ] Commit the source records.

```bash
git add docs/canon/design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md \
  docs/canon/design/vc-wave-2-surface-journey-closure.json
git commit -m "docs: add Wave 2 visual closure authority"
```

## Task 3: Register the references

- [ ] Add these entries to `reference_files` in `docs/canon/MANIFEST.toml`
immediately after the Wave 1 records:

```toml
  "design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md",
  "design/vc-wave-2-surface-journey-closure.json",
```

- [ ] Update `docs/canon/README.md` to state that Wave 2 installs closed VC-07
through VC-12 decisions, while Wave 3 and VC-14 remain incomplete and every
implementation authorization remains false.

- [ ] Update only package-status and source-traceability portions of
`docs/canon/design/VISUAL_SYSTEM_R1.md`:

```text
VC-01 through VC-12: CLOSED
VC-13: OPEN
VC-14: NOT_STARTED
Wave 2 surfaces and journeys: CLOSED
Wave 3 stress and matched baseline: OPEN
```

Do not change active AVF IDs, product scope, selected architecture, tokens, or
authorization.

- [ ] Commit reference wiring.

```bash
git add docs/canon/MANIFEST.toml docs/canon/README.md \
  docs/canon/design/VISUAL_SYSTEM_R1.md
git commit -m "docs: register Wave 2 visual closure"
```

## Task 4: Generalize visual-closure compilation

- [ ] Refactor the Wave-1-only projection in
`tools/ambitions_canon/compiler.py` to load these records in order:

```python
VISUAL_CLOSURE_MACHINE_PATHS = (
    Path("docs/canon/design/visual-closure-input-contract.json"),
    Path("docs/canon/design/vc-wave-1-foundation-closure.json"),
    Path("docs/canon/design/vc-wave-2-surface-journey-closure.json"),
)
```

- [ ] Add or minimally refactor one loader with this contract:

```python
def load_visual_closure_records(root: Path) -> tuple[dict[str, Any], ...]:
    """Load ordered visual-closure JSON records from the repository."""
```

It must reject missing files, invalid JSON, and non-object roots while preserving
declared order.

- [ ] Validate the exact effective direction and package state:

```python
EXPECTED_ACTIVE_VISUAL_DIRECTIONS = (
    "AVF-DNA-S07-R00",
    "AVF-SHELL-S07-R01",
    "AVF-CAPTURE-S07-R01",
    "AVF-GOALS-S08-R00",
    "AVF-TIME-S07-R01",
    "AVF-TODAY-S10-R00",
    "AVF-SEARCH-D07-R01",
    "AVF-YOU-D07-R02",
    "AVF-RECOVERY-S07-R01",
    "AVF-A11Y-S07-R00",
    "AVF-COHERENCE-S07-R00",
)

EXPECTED_EFFECTIVE_PACKAGE_STATUSES = {
    **{f"VC-{number:02d}": "CLOSED" for number in range(1, 13)},
    "VC-13": "OPEN",
    "VC-14": "NOT_STARTED",
}
```

The compiler must reject changed or reordered active directions, package status
regression, duplicate package IDs, Wave 2 package IDs outside VC-07–VC-12, true
Figma/SwiftUI/implementation authorization, human/machine mismatch, missing Wave
1 inheritance, and any new AVF direction introduced by a VC closure label.

- [ ] Project an effective `closure_packages` object into
`generated/visual-authority-manifest.json` containing all package statuses, the
existing full Wave 1 record, a full Wave 2 record, and Wave 3 `OPEN`.

- [ ] Project structured Wave 2 summaries into `active_baseline`:

```text
Today: Balanced Semantic Execution Day
Goals: Singular Living Pursuit Passage
Time: Adaptive Dual-Truth Period Passage
Capture: Full-Screen Adaptive Meaning Passage
Search: Full-Screen Semantic Command Passage
You: Personal Control Passage
Resilience: Contextual Combined-State Passage
```

Preserve ownership, truth, density, accessibility, and capability boundaries.
Do not replace structured records with flattened prose.

- [ ] Keep compiler output deterministic. No network, wall-clock timestamp,
random ordering, signing, approval, or merge-authorization behavior.

## Task 5: Add focused tests

- [ ] Add a positive test asserting VC-01 through VC-12 are closed, VC-13 is
open, VC-14 is not started, and Wave 2 is closed.

- [ ] Add a positive test asserting the exact active direction list.

- [ ] Add a positive test asserting all implementation authorization remains
false.

- [ ] Add negative tests for:

```text
changed active direction
VC-13 marked CLOSED
VC-14 marked CLOSED
implementation authorization true
duplicate Wave 2 package ID
missing human peer
```

Use the existing temporary-repository fixture and `CanonError` conventions.
Do not create a second compiler test harness.

- [ ] Run focused tests.

```bash
python3 -m pytest tools/tests/test_ambitions_canon_compiler.py -q
```

Expected: pass.

- [ ] Commit compiler and test changes.

```bash
git add tools/ambitions_canon/compiler.py \
  tools/tests/test_ambitions_canon_compiler.py
git commit -m "build: project Wave 2 visual closure"
```

## Task 6: Build deterministic canon

- [ ] Build.

```bash
python3 scripts/ambitions-canon.py build
```

- [ ] Check.

```bash
python3 scripts/ambitions-canon.py check
```

- [ ] Run focused tests again.

```bash
python3 -m pytest tools/tests/test_ambitions_canon_compiler.py -q
```

- [ ] Inspect the generated manifest.

```bash
python3 - <<'PY'
import json
from pathlib import Path

data = json.loads(Path(
  "docs/canon/generated/visual-authority-manifest.json"
).read_text())
statuses = data["closure_packages"]["package_statuses"]
assert all(statuses[f"VC-{n:02d}"] == "CLOSED" for n in range(1, 13))
assert statuses["VC-13"] == "OPEN"
assert statuses["VC-14"] == "NOT_STARTED"
assert data["closure_packages"]["wave_2"]["status"] == "CLOSED"
assert data["authority_state"]["figma"] is False
assert data["authority_state"]["swiftui"] is False
assert data["authority_state"]["implementation"] is False
print("Generated Wave 2 authority valid")
PY
```

Expected: `Generated Wave 2 authority valid`.

- [ ] Confirm no unauthorized path changed.

```bash
git diff --name-only main...HEAD
```

Permitted paths are limited to the files listed in this plan and deterministic
`docs/canon/generated/*` output.

- [ ] Commit the plan and generated outputs.

```bash
git add docs/canon/generated \
  docs/superpowers/plans/2026-07-22-wave-2-visual-closure-installation.md
git commit -m "docs: publish Wave 2 generated visual authority"
```

## Task 7: Final verification and report

- [ ] Run:

```bash
python3 scripts/ambitions-canon.py check
python3 -m pytest tools/tests/test_ambitions_canon_compiler.py -q
git diff --check main...HEAD
git status --short
```

Expected: all pass and working tree clean.

- [ ] Report:

```text
base commit
branch
commit SHAs
files created
files modified
generated files rebuilt
validation commands and outcomes
authorization state
Wave 2 CLOSED
VC-13 OPEN
VC-14 NOT_STARTED
product code changed: no
Figma changed: no
SwiftUI approved: no
implementation authorized: no
```

A suitable final squash title is:

```text
docs: install Wave 2 visual surface closure
```

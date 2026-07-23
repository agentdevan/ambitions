# Wave 3 Accessibility Stress Closure Installation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> `superpowers:subagent-driven-development` (recommended) or
> `superpowers:executing-plans` to implement this plan task-by-task. Steps use
> checkbox syntax for tracking.

**Goal:** Install the closed VC-13 accessibility and content stress validation as
human and machine visual authority, project it through the hardened canon
compiler, and preserve VC-14 and all implementation authorization as unopened.

**Architecture:** Add one Wave 3 human closure record and one deterministic
machine peer after the closed Wave 1 and Wave 2 records. Reuse the current
compiler’s hardened ordered-closure validation and projection model; make only
the smallest compiler/test changes needed to register and validate VC-13. Rebuild
all deterministic canon outputs and leave product source untouched.

**Tech Stack:** Markdown, JSON, TOML, Python 3 standard library, the existing
Ambitions canon compiler, and its existing focused test suite.

## Global constraints

- Repository: `agentdevan/ambitions`
- Required local baseline: `4eeebd2ff4619b3798d23d2592e6ce5bb40aa46c`
- The supplied baseline was reported merged to local `main`, clean, validated,
  and not pushed when this plan was prepared.
- Active AVF direction IDs must remain unchanged.
- `VC-01` through `VC-13` must be `CLOSED`.
- `VC-14` must remain `NOT_STARTED`.
- Wave 1 and Wave 2 remain `CLOSED`.
- Wave 3 accessibility/content stress validation becomes `CLOSED`.
- The overall visual-closure program remains open pending `VC-14`.
- Figma, SwiftUI, and implementation authorization remain `false`.
- Do not modify app source, Xcode project files, SwiftUI views, design tokens,
  Figma, Code Connect, or screenshot baselines.
- Do not hand-edit generated canon.
- Do not claim direct-device proof has been completed.
- Stop rather than silently reconcile any conflict with newer owner, ADR, UX
  Blueprint, or closure authority.

---

## File map

### Create

- `docs/canon/design/VC_WAVE_3_ACCESSIBILITY_STRESS_CLOSURE.md`
- `docs/canon/design/vc-wave-3-accessibility-stress-closure.json`
- `docs/superpowers/plans/2026-07-23-wave-3-accessibility-stress-installation.md`

### Modify as required by the current repository pattern

- `docs/canon/MANIFEST.toml`
- `docs/canon/README.md`
- `docs/canon/design/VISUAL_SYSTEM_R1.md`
- `tools/ambitions_canon/compiler.py`
- `tools/tests/test_ambitions_canon_compiler.py`
- current digest-binding or source-integrity references already maintained by the
  compiler, only when deterministic build/check requires them

### Regenerate through the compiler

- every file currently listed in `generated_files` in `docs/canon/MANIFEST.toml`

Never edit a generated file directly.

## Task 1: Preflight and isolate installation

- [ ] Confirm local `main` is at the required baseline or a reviewed descendant.

```bash
git switch main
git status --short
git rev-parse HEAD
```

Expected at package preparation:

```text
4eeebd2ff4619b3798d23d2592e6ce5bb40aa46c
```

The working tree must be clean. A later descendant is permitted only after
reviewing intervening changes for closure-authority, manifest, compiler, test,
or generated-canon conflicts.

- [ ] Verify the baseline before edits.

```bash
python3 scripts/ambitions-canon.py check
python3 -m pytest tools/tests/test_ambitions_canon_compiler.py -q
```

Expected: both commands pass.

- [ ] Create an isolated worktree and branch.

```bash
git worktree add ../ambitions-wave-3-accessibility-stress \
  -b codex/wave-3-accessibility-stress main
cd ../ambitions-wave-3-accessibility-stress
```

## Task 2: Install exact Wave 3 source records

- [ ] Copy the supplied files exactly to:

```text
docs/canon/design/VC_WAVE_3_ACCESSIBILITY_STRESS_CLOSURE.md
docs/canon/design/vc-wave-3-accessibility-stress-closure.json
```

- [ ] Validate the machine peer before integration.

```bash
python3 - <<'PY'
import json
from pathlib import Path

path = Path('docs/canon/design/vc-wave-3-accessibility-stress-closure.json')
data = json.loads(path.read_text())

assert data['package_id'] == 'AMB-VC-WAVE-3-ACCESSIBILITY-STRESS-CLOSURE'
assert data['status'] == 'CLOSED'
assert data['repository_baseline'] == '4eeebd2ff4619b3798d23d2592e6ce5bb40aa46c'
assert data['package_statuses']['VC-13'] == 'CLOSED'
assert data['package_statuses']['VC-14'] == 'NOT_STARTED'
assert data['authorization_state'] == {
    'figma': False,
    'implementation': False,
    'swiftui': False,
}
assert data['package']['selected_closure']['id'] == 'VC13-A11Y-S01'
assert data['package']['overall_result']['structural_branch_required'] is False
print('Wave 3 source record valid')
PY
```

Expected: `Wave 3 source record valid`.

- [ ] Confirm the supplied human and machine files remain byte-identical after copy.

```bash
shasum -a 256 \
  docs/canon/design/VC_WAVE_3_ACCESSIBILITY_STRESS_CLOSURE.md \
  docs/canon/design/vc-wave-3-accessibility-stress-closure.json
```

Compare the results with `PACKAGE_SHA256.json` in the supplied package.

- [ ] Commit source authority.

```bash
git add \
  docs/canon/design/VC_WAVE_3_ACCESSIBILITY_STRESS_CLOSURE.md \
  docs/canon/design/vc-wave-3-accessibility-stress-closure.json
git commit -m "docs: add Wave 3 accessibility stress authority"
```

## Task 3: Register closure authority

- [ ] Add both Wave 3 records to `reference_files` in
  `docs/canon/MANIFEST.toml` immediately after the Wave 2 records:

```toml
  "design/VC_WAVE_3_ACCESSIBILITY_STRESS_CLOSURE.md",
  "design/vc-wave-3-accessibility-stress-closure.json",
```

- [ ] Update the design-canon section in `docs/canon/README.md` with:

```markdown
- [Wave 3 Accessibility and Content Stress Closure](design/VC_WAVE_3_ACCESSIBILITY_STRESS_CLOSURE.md)
  and its JSON peer install the closed VC-13 validation beneath the Wave 1 and
  Wave 2 authority. VC-14 remains not started; Figma, SwiftUI, and
  implementation remain unauthorized.
```

- [ ] Update only closure status, stress-refinement summary, direct-proof
  register, and traceability in `docs/canon/design/VISUAL_SYSTEM_R1.md`.

Required status:

```text
VC-01 through VC-13: CLOSED
VC-14: NOT_STARTED
Wave 3 accessibility/content stress validation: CLOSED
Overall visual-closure program: OPEN pending VC-14
Figma: false
SwiftUI: false
Implementation: false
```

Do not change active AVF IDs, root ownership, selected surface hierarchy,
appearance doctrine, or authorization.

- [ ] Update current digest-binding/source-integrity records only if the existing
  compiler and repository pattern require them. Use the current Wave 2
  installation as the exact pattern. Do not invent another integrity system.

- [ ] Commit authority wiring.

```bash
git add docs/canon/MANIFEST.toml docs/canon/README.md \
  docs/canon/design/VISUAL_SYSTEM_R1.md
# Add only current deterministic digest-binding source files if required.
git commit -m "docs: register Wave 3 accessibility closure"
```

## Task 4: Extend the hardened closure compiler minimally

- [ ] Inspect the current Wave 2 closure-loading implementation and tests before
  editing.

```bash
rg -n "wave_2|closure_records|visual_closure|package_statuses|VC-13|VC-14" \
  tools/ambitions_canon/compiler.py \
  tools/tests/test_ambitions_canon_compiler.py
```

- [ ] Reuse the existing ordered-closure model.

If the compiler has an explicit ordered machine-path sequence, append:

```python
Path("docs/canon/design/vc-wave-3-accessibility-stress-closure.json")
```

If it discovers closure records through a validated manifest mechanism, register
Wave 3 through that existing mechanism instead. Do not introduce a parallel
loader.

- [ ] Set effective expected package status to:

```python
EXPECTED_EFFECTIVE_PACKAGE_STATUSES = {
    **{f"VC-{number:02d}": "CLOSED" for number in range(1, 14)},
    "VC-14": "NOT_STARTED",
}
```

Use the current constant or validation structure rather than duplicating it.

- [ ] Extend validation to reject:

```text
changed or reordered active AVF direction IDs
VC-13 not CLOSED
VC-14 anything other than NOT_STARTED
any true Figma, SwiftUI, or implementation authorization
Wave 3 human/machine peer mismatch
Wave 3 missing Wave 1 or Wave 2 inheritance
new active AVF ID introduced through VC13-A11Y-S01
structural_branch_required set true without a new reviewed AVF direction
Wave 1 or Wave 2 package-status regression
missing direct-device proof register
```

- [ ] Project Wave 3 into the generated visual-authority manifest without
  deleting the complete Wave 1 or Wave 2 projection.

The effective projection must include semantics equivalent to:

```json
{
  "package_statuses": {
    "VC-01": "CLOSED",
    "VC-02": "CLOSED",
    "VC-03": "CLOSED",
    "VC-04": "CLOSED",
    "VC-05": "CLOSED",
    "VC-06": "CLOSED",
    "VC-07": "CLOSED",
    "VC-08": "CLOSED",
    "VC-09": "CLOSED",
    "VC-10": "CLOSED",
    "VC-11": "CLOSED",
    "VC-12": "CLOSED",
    "VC-13": "CLOSED",
    "VC-14": "NOT_STARTED"
  },
  "wave_3": {
    "status": "ACCESSIBILITY_STRESS_CLOSED_VC14_NOT_STARTED",
    "human_record": "docs/canon/design/VC_WAVE_3_ACCESSIBILITY_STRESS_CLOSURE.md",
    "machine_record": "docs/canon/design/vc-wave-3-accessibility-stress-closure.json",
    "package_id": "AMB-VC-WAVE-3-ACCESSIBILITY-STRESS-CLOSURE",
    "selected_record": "VC13-A11Y-S01 — Stress-Proven Adaptive Semantic Continuity"
  }
}
```

Adapt field names to the hardened compiler's existing schema while preserving
these exact semantics.

- [ ] Project structured VC-13 content into `active_baseline`, including:

```text
shared first-viewport doctrine
compression and never-compress rules
per-package targeted accessibility refinements
crown and dock stress refinements
keyboard-safe action boundary
reduced-effects contract
RTL semantic invariants
focus entry and return
hidden sensitive-value contract
combined-state order and precedence
architecture dependency register
direct-device proof register
VC-14 entry criteria
```

Do not flatten the package into one prose blob.

- [ ] Preserve compiler determinism. No wall-clock timestamps, network access,
  random order, approval commands, or task/status-policing behavior.

## Task 5: Extend focused compiler tests

- [ ] Add a positive test for effective closure state using the current fixture
  style:

```python
def test_visual_manifest_closes_vc_13_and_leaves_vc_14_unstarted(compiled_repo):
    manifest = compiled_repo.generated_json(
        "docs/canon/generated/visual-authority-manifest.json"
    )
    statuses = manifest["closure_packages"]["package_statuses"]
    assert all(statuses[f"VC-{n:02d}"] == "CLOSED" for n in range(1, 14))
    assert statuses["VC-14"] == "NOT_STARTED"
```

Adapt `compiled_repo` access to the current fixture; do not create a parallel
compiler harness.

- [ ] Add a positive test for selected closure and authorization:

```python
def test_wave_3_projects_stress_closure_without_authorizing_implementation(compiled_repo):
    manifest = compiled_repo.generated_json(
        "docs/canon/generated/visual-authority-manifest.json"
    )
    wave_3 = manifest["closure_packages"]["wave_3"]
    assert wave_3["selected_record"] == (
        "VC13-A11Y-S01 — Stress-Proven Adaptive Semantic Continuity"
    )
    assert manifest["authority_state"]["figma"] is False
    assert manifest["authority_state"]["swiftui"] is False
    assert manifest["authority_state"]["implementation"] is False
```

- [ ] Add a positive test that the active direction list remains exact.

- [ ] Add a positive test that the direct-device proof register is nonempty and
  includes at least:

```text
left-handed dock reach
VoiceOver focus restoration
RTL inspection
reduced-effects proof
sensitive-value exclusion
```

- [ ] Add negative tests using the existing temporary-repository fixture for:

```text
changed active direction ID
VC-13 OPEN
VC-14 CLOSED
implementation authorization true
human peer missing
Wave 2 inheritance missing
structural_branch_required true
proof register missing
Wave 1 or Wave 2 status regression
```

- [ ] Run the focused suite.

```bash
python3 -m pytest tools/tests/test_ambitions_canon_compiler.py -q
```

Expected: all tests pass.

- [ ] Commit compiler and tests.

```bash
git add tools/ambitions_canon/compiler.py \
  tools/tests/test_ambitions_canon_compiler.py
git commit -m "build: project Wave 3 accessibility closure"
```

## Task 6: Rebuild deterministic canon

- [ ] Build generated canon.

```bash
python3 scripts/ambitions-canon.py build
```

Expected: successful deterministic rebuild.

- [ ] Run canon drift/source validation.

```bash
python3 scripts/ambitions-canon.py check
```

Expected: pass.

- [ ] Run focused tests again.

```bash
python3 -m pytest tools/tests/test_ambitions_canon_compiler.py -q
```

Expected: pass.

- [ ] Assert generated authority state.

```bash
python3 - <<'PY'
import json
from pathlib import Path

path = Path("docs/canon/generated/visual-authority-manifest.json")
data = json.loads(path.read_text())
statuses = data["closure_packages"]["package_statuses"]
assert all(statuses[f"VC-{n:02d}"] == "CLOSED" for n in range(1, 14))
assert statuses["VC-14"] == "NOT_STARTED"
assert data["authority_state"]["figma"] is False
assert data["authority_state"]["swiftui"] is False
assert data["authority_state"]["implementation"] is False
print("Generated Wave 3 authority valid")
PY
```

Expected: `Generated Wave 3 authority valid`.

- [ ] Confirm Wave 1 and Wave 2 source records are unchanged from `main`.

```bash
git diff --exit-code main -- \
  docs/canon/design/VC_WAVE_1_FOUNDATION_CLOSURE.md \
  docs/canon/design/vc-wave-1-foundation-closure.json \
  docs/canon/design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md \
  docs/canon/design/vc-wave-2-surface-journey-closure.json
```

Expected: no output and exit code 0.

- [ ] Confirm no unauthorized path changed.

```bash
git diff --name-only main...HEAD
```

Permitted changes are limited to:

```text
docs/canon/MANIFEST.toml
docs/canon/README.md
docs/canon/design/VC_WAVE_3_ACCESSIBILITY_STRESS_CLOSURE.md
docs/canon/design/VISUAL_SYSTEM_R1.md
docs/canon/design/vc-wave-3-accessibility-stress-closure.json
docs/canon/generated/*
docs/superpowers/plans/2026-07-23-wave-3-accessibility-stress-installation.md
tools/ambitions_canon/compiler.py
tools/tests/test_ambitions_canon_compiler.py
current compiler-managed digest-binding source files required by deterministic check
```

No app, Xcode, Figma, token, Code Connect, or screenshot path is permitted.

- [ ] Commit generated and plan outputs.

```bash
git add docs/canon/generated \
  docs/superpowers/plans/2026-07-23-wave-3-accessibility-stress-installation.md
# Include only deterministic digest-binding source files required by the current compiler.
git commit -m "docs: publish Wave 3 generated accessibility authority"
```

## Task 7: Final verification and handoff

- [ ] Run fresh final verification.

```bash
python3 scripts/ambitions-canon.py check
python3 -m pytest tools/tests/test_ambitions_canon_compiler.py -q
git diff --check main...HEAD
git status --short
```

Expected:

- canon check passes;
- focused tests pass;
- diff check passes;
- worktree is clean.

- [ ] Review final diff and commits.

```bash
git diff --stat main...HEAD
git log --oneline --decorate main..HEAD
```

- [ ] Produce a final report containing:

```text
base commit
branch
worktree
commit SHAs
files created
files modified
generated outputs rebuilt
canon check result
focused test result
diff check result
Wave 1 and Wave 2 source-integrity result
VC-01 through VC-13 CLOSED
VC-14 NOT_STARTED
Wave 3 stress validation CLOSED
overall program OPEN pending VC-14
Figma false
SwiftUI false
Implementation false
product source changed: no
Xcode changed: no
Figma or Code Connect changed: no
tokens or screenshots changed: no
direct-device proof claimed: no
```

- [ ] Merge only after review. Suitable squash title:

```text
docs: install Wave 3 accessibility stress closure
```

Do not begin VC-14 in this installation branch.

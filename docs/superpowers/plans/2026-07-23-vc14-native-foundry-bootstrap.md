# VC-14 Native Visual Foundry Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close VC-14 under the unchanged AVF direction set and produce the first three fixture-driven native Today frames plus a repeatable warm-loop benchmark, then stop for owner review.

**Architecture:** Add the VC-14 human/machine authority as a fourth installed closure layer after Waves 1–3 and project it through the existing canon compiler. Add one `AmbitionsNativeVisualFoundry` target inside the existing `AmbitionsPresentation` package; its production-intended view consumes a small value snapshot, while a named synthetic fixture and a separate fixture-only Xcode host keep the work outside the live app path.

**Tech Stack:** Python 3 canon compiler and `unittest`; Swift 6.2/SwiftUI on iOS 26; Swift Package Manager; XcodeGen; XcodeBuildMCP; `ios-simulator-browser`; XCTest; git.

## Global Constraints

- Base SHA is exactly `8ae1a587fa6400cbf5495dd0c6457e8cb17016f3`.
- Branch is `codex/vc14-native-foundry-bootstrap`; do not edit, merge into, or push `main`.
- The owner-approved `VC14-NATIVE-S01 — Matched Native Flagship Proof` synthesis is fixed and must not be re-brainstormed.
- Figma authorization, `APPROVED FOR SWIFTUI`, broad production implementation, broad frontend reconstruction, and legacy cutover remain `false`.
- Only Foundry bootstrap, fixture-driven previews, the Today calibration slice, and screenshot owner review are authorized.
- Direct-device proof remains required and incomplete.
- No new dependency, plugin, custom MCP, custom CLI, InjectionNext, hot-injection dependency, snapshot dependency, production screenshot baseline, runtime integration, or live app-entry change.
- The task stops after Typical Light, Typical Dark, Accessibility Dynamic Type Dark, and the two-path benchmark report.

---

### Task 1: Install VC-14 source authority

**Files:**
- Create: `docs/canon/design/VC_14_NATIVE_MATCHED_CLOSURE.md`
- Create: `docs/canon/design/vc-14-native-matched-closure.json`
- Modify: `docs/canon/design/VISUAL_CLOSURE_INPUT_CONTRACT.md`
- Modify: `docs/canon/design/visual-closure-input-contract.json`
- Create: `docs/superpowers/plans/2026-07-23-vc14-native-foundry-bootstrap.md`

**Interfaces:**
- Consumes: the unchanged active AVF direction array and Waves 1–3 authority.
- Produces: machine package `AMB-VC-14-NATIVE-MATCHED-CLOSURE`, selected record `VC14-NATIVE-S01`, all-closed package statuses, four narrow calibration booleans, and explicit broad-authorization false values.

- [ ] **Step 1: Write the human authority record**

  Record the exact synthesis, proving environments, authorized/unauthorized lists, direct-device proof ceiling, and effective status:

  ```text
  VC-01 through VC-14: CLOSED
  Visual-closure planning program: CLOSED
  Figma authorization: false
  APPROVED FOR SWIFTUI: false
  Broad production implementation authorization: false
  Broad frontend reconstruction authorization: false
  Legacy frontend cutover authorization: false
  Direct-device proof: required and incomplete
  ```

- [ ] **Step 2: Write the deterministic machine peer**

  Use these top-level keys and exact selected record:

  ```json
  {
    "schema_version": 1,
    "package_id": "AMB-VC-14-NATIVE-MATCHED-CLOSURE",
    "status": "CLOSED",
    "selected_record": {
      "id": "VC14-NATIVE-S01",
      "kind": "native_matched_closure_synthesis",
      "name": "Matched Native Flagship Proof"
    }
  }
  ```

- [ ] **Step 3: Close the input contract without widening authorization**

  Set all `VC-01` through `VC-14` statuses to `CLOSED`, close the planning program, make native previews/running app primary, make Figma optional comparison only, and retain global SwiftUI/implementation false values alongside the four narrowly true calibration fields.

- [ ] **Step 4: Validate JSON syntax and review the authority diff**

  Run: `python3 -m json.tool docs/canon/design/vc-14-native-matched-closure.json >/dev/null && python3 -m json.tool docs/canon/design/visual-closure-input-contract.json >/dev/null && git diff --check`

  Expected: exit `0`; no generated canon edited yet.

- [ ] **Step 5: Commit**

  ```sh
  git add docs/canon/design/VC_14_NATIVE_MATCHED_CLOSURE.md \
    docs/canon/design/vc-14-native-matched-closure.json \
    docs/canon/design/VISUAL_CLOSURE_INPUT_CONTRACT.md \
    docs/canon/design/visual-closure-input-contract.json \
    docs/superpowers/plans/2026-07-23-vc14-native-foundry-bootstrap.md
  git commit -m "docs: close VC-14 with native matched proof"
  ```

### Task 2: Wire and test canon projection

**Files:**
- Modify: `tools/tests/test_ambitions_canon_compiler.py`
- Modify: `tools/ambitions_canon/compiler.py`
- Modify: `docs/canon/MANIFEST.toml`
- Modify: `docs/canon/README.md`
- Modify: `docs/canon/design/VISUAL_SYSTEM_R1.md`
- Modify generated files under `docs/canon/generated/` only through `scripts/ambitions-canon.py build`

**Interfaces:**
- Consumes: Task 1 machine peer.
- Produces: `load_visual_closure_records(...)[4]`, `_validate_vc_14_closure(...)`, `active_baseline.native_visual_foundry`, `closure_packages.vc_14`, and generated navigation links.

- [ ] **Step 1: Write failing compiler tests**

  Add tests that require five ordered closure records, all fourteen statuses closed, the four narrow permissions true, all broad permissions false, direct-device proof required/incomplete, Figma optional-only, and VC-14 projection into the generated manifest.

- [ ] **Step 2: Run tests to verify RED**

  Run: `python3 -m unittest tools.tests.test_ambitions_canon_compiler.Wave3VisualClosureLoaderTests tools.tests.test_ambitions_canon_compiler.AmbitionsCanonCompilerTests.test_visual_manifest_closes_vc_14_without_broad_authorization`

  Expected: failure because the compiler loads only four records and does not project VC-14.

- [ ] **Step 3: Implement minimal compiler validation and projection**

  Extend `VISUAL_CLOSURE_MACHINE_PATHS`, add exact VC-14 schema/content validation, project `VC14-NATIVE-S01`, close the planning state, and retain false broad authorization.

- [ ] **Step 4: Register and route the authority**

  Add both VC-14 records to `MANIFEST.toml`, add the VC-14 link to generated navigation rendering, update the canon README and active Visual System section, and add VC-14 provenance hashes.

- [ ] **Step 5: Rebuild generated canon and verify GREEN**

  Run: `python3 scripts/ambitions-canon.py build && python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py' && python3 scripts/ambitions-canon.py check`

  Expected: all focused tests pass and generated drift is zero.

- [ ] **Step 6: Commit**

  ```sh
  git add tools/ambitions_canon/compiler.py tools/tests/test_ambitions_canon_compiler.py \
    docs/canon/MANIFEST.toml docs/canon/README.md docs/canon/design/VISUAL_SYSTEM_R1.md \
    docs/canon/generated
  git commit -m "feat: project VC-14 native closure authority"
  ```

### Task 3: Create and validate the single repository-local skill

**Files:**
- Create: `.agents/skills/ambitions-native-visual-foundry/SKILL.md`
- Create: `docs/qa/evidence/2026-07-23-vc14-native-foundry-bootstrap/skill-validation.md`

**Interfaces:**
- Consumes: relevant canon, one semantic object, one fixture, one viewport.
- Produces: the exact before/during/after workflow, nine-part report contract, and full-app escalation predicates from the brief.

- [ ] **Step 1: Run three baseline scenarios without the skill**

  Test copy-pressure, dock-behavior, and unsupported-runtime-state scenarios with fresh agents; capture their exact omissions or rationalizations.

- [ ] **Step 2: Write the minimal skill**

  Use frontmatter:

  ```yaml
  ---
  name: ambitions-native-visual-foundry
  description: Use when calibrating fixture-driven native SwiftUI previews or proposing an Ambitions viewport for owner visual review.
  ---
  ```

  Keep the skill below 500 words and orchestrate existing SwiftUI, simulator, debugger, TDD, and verification skills rather than repeating them.

- [ ] **Step 3: Run the same scenarios with the skill**

  Expected: each agent selects one viewport/fixture, preserves native behavior, avoids runtime invention, captures native evidence, emits all nine report headings, and escalates dock/navigation cases to full-app verification.

- [ ] **Step 4: Refine only observed gaps and re-run**

  Expected: no new rationalization or missing required report field.

- [ ] **Step 5: Commit**

  ```sh
  git add .agents/skills/ambitions-native-visual-foundry/SKILL.md \
    docs/qa/evidence/2026-07-23-vc14-native-foundry-bootstrap/skill-validation.md
  git commit -m "docs: add native visual foundry skill"
  ```

### Task 4: Add the Foundry target and deterministic fixture

**Files:**
- Modify: `Packages/AmbitionsPresentation/Package.swift`
- Create: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayBootstrapContent.swift`
- Create: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayBootstrapFixture.swift`
- Create: `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayBootstrapFixtureTests.swift`
- Create: `docs/adr/ADR-2026-07-23-native-visual-foundry-bootstrap-boundary.md`

**Interfaces:**
- Produces: `TodayBootstrapContent`, `TodayBootstrapTimelineEntry`, and `TodayBootstrapFixture.preparingForBaby` with fixture ID `today-bootstrap/preparing-for-baby/typical/v1`.
- The eventual runtime adapter constructs `TodayBootstrapContent`; the view does not import runtime or legacy app modules.

- [ ] **Step 1: Add the target and failing tests**

  Tests require a stable fixture ID, one dominant Start Here identity, sparse current truth, one consequence, `Open step`, and at least one timeline entry related to family, home, health, and meaningful work.

- [ ] **Step 2: Run tests to verify RED**

  Run: `swift test --package-path Packages/AmbitionsPresentation --filter TodayBootstrapFixtureTests`

  Expected: compile failure because the Foundry content types do not exist.

- [ ] **Step 3: Implement minimal value models and fixture**

  Define immutable `Sendable`, `Equatable`, and `Identifiable` values. The fixture is explicitly synthetic and makes no runtime-capability claim.

- [ ] **Step 4: Verify GREEN and write the boundary ADR**

  Run: `swift test --package-path Packages/AmbitionsPresentation --filter TodayBootstrapFixtureTests`

  Expected: tests pass. ADR selects a new target in the existing package and rejects modifying the live app module, reusing legacy views, and creating a new package.

- [ ] **Step 5: Commit**

  ```sh
  git add Packages/AmbitionsPresentation docs/adr/ADR-2026-07-23-native-visual-foundry-bootstrap-boundary.md
  git commit -m "feat: add native foundry fixture boundary"
  ```

### Task 5: Render and benchmark the Today bootstrap

**Files:**
- Create: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayBootstrapView.swift`
- Create: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayBootstrapPreviews.swift`
- Create: `Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift`
- Modify: `project.yml`
- Create files under: `docs/qa/evidence/2026-07-23-vc14-native-foundry-bootstrap/`

**Interfaces:**
- `TodayBootstrapView(content:onOpenStep:onOpenDock:)` renders production-intended matte content and native functional controls.
- Preview names are exactly `Today Bootstrap — Typical Light`, `Today Bootstrap — Typical Dark`, and `Today Bootstrap — Accessibility Dynamic Type Dark`.
- Host launch argument is `-FoundryVariant typical-light|typical-dark|accessibility-dark`.

- [ ] **Step 1: Implement the view and three previews**

  Use a mineral/light or graphite/dark opaque plane, compact crown/date, Start Here identity, current truth, consequence, native `Open step` button, beginning of Today’s Timeline, and right-edge Peek dock. Apply Liquid Glass only to functional dock chrome and use an opaque path when Reduce Transparency is enabled.

- [ ] **Step 2: Add the fixture-only Xcode host**

  Add an `AmbitionsNativeFoundryHost` application target and scheme in `project.yml` that depends only on the Foundry package product. Do not add the Foundry product to the `Ambitions` target.

- [ ] **Step 3: Regenerate and warm both paths**

  Run: `xcodegen generate` and `swift build --package-path Packages/AmbitionsPresentation --target AmbitionsNativeVisualFoundry`.

  Start the package preview launcher on simulator `DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6`, then warm `AmbitionsNativeFoundryHost` through XcodeBuildMCP.

- [ ] **Step 4: Benchmark the five mutations on Path A and Path B**

  Mutate and restore, one at a time: copy, padding, typography, functional material/tonal treatment, and a small conditional state. Record failures and observed save-to-visible latency. Re-run the apparently fastest path at least twice.

- [ ] **Step 5: Restore intended source and capture three native frames**

  Launch each host variant, verify its semantic UI tree, and save a native Simulator screenshot with fixture/device/appearance/Dynamic Type metadata. Screenshots are evaluation references, not production baselines.

- [ ] **Step 6: Write the benchmark and evidence report**

  Include device, OS, exact commands/tools, all latency observations, reliability, selected inner loop, fixture ID, settings, changed files, validation, limitations, and proof ceiling.

- [ ] **Step 7: Commit**

  ```sh
  git add Packages/AmbitionsPresentation Native/AmbitionsNativeFoundryHost project.yml \
    docs/qa/evidence/2026-07-23-vc14-native-foundry-bootstrap
  git commit -m "feat: render and benchmark Today foundry bootstrap"
  ```

### Task 6: Final verification and review repairs

**Files:**
- Modify only files already in scope when verification finds a concrete defect.

**Interfaces:**
- Produces: clean, committed, unmerged branch with exact evidence and no unauthorized integration.

- [ ] **Step 1: Run fresh validation**

  ```sh
  python3 scripts/ambitions-canon.py build --check
  python3 scripts/ambitions-canon.py check
  python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
  swift test --package-path Packages/AmbitionsPresentation
  swift build --package-path Packages/AmbitionsPresentation --target AmbitionsNativeVisualFoundry
  xcodegen generate
  git diff --check
  ```

- [ ] **Step 2: Prove the changed-path boundary**

  Run repository searches showing `Native/Ambitions/App`, legacy frontend views, and the production `Ambitions` target dependencies are unchanged; verify no new package dependency declaration and no third-party lockfile change.

- [ ] **Step 3: Re-capture or repair only concrete failures**

  If a native frame, test, or report is wrong, make the smallest in-scope repair and repeat the proving command.

- [ ] **Step 4: Commit final review repairs**

  ```sh
  git add --all
  git commit -m "chore: finalize VC-14 foundry review evidence"
  ```

- [ ] **Step 5: Prove clean unmerged handoff**

  Run: `git status --short --branch && git log --oneline 8ae1a587fa6400cbf5495dd0c6457e8cb17016f3..HEAD && git branch --merged main`

  Expected: clean branch, six reviewable commits, and `codex/vc14-native-foundry-bootstrap` absent from branches merged into `main`.

## Self-review

- Spec coverage: authority, compiler projection, one skill, package boundary, fixture, three previews, two benchmark paths, screenshots, validation, and stop condition are each mapped to one task.
- Implementation specificity: every action names its files, interface, command, and expected result.
- Type consistency: `TodayBootstrapContent`, `TodayBootstrapFixture.preparingForBaby`, `TodayBootstrapView(content:onOpenStep:onOpenDock:)`, preview names, fixture ID, host scheme, and launch variants are consistent across Tasks 4–6.
- Scope check: the plan excludes the eight-frame matrix, complete Today journey, other roots, runtime integration, legacy cutover, and production app entry.

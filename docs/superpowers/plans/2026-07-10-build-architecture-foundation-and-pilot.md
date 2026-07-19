# Ambitions Build Architecture Foundation and Pilot Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the repo-root Swift package scan, install measured build-throughput enforcement, create an evidence-backed source-destruction inventory, and prove one canonical-path static framework pilot without weakening Ambitions quality or runtime law.

**Architecture:** Preserve XcodeGen and every canonical source owner under Native/Ambitions. Relocate only the existing design-system Swift package to Packages/AmbitionsDesignSystem, then extract the pure clock/time-policy leaf as AmbitionsTimeFoundation after moving its app-owned factory back to App/Bootstrap. Use one aggregate module-test target, an acyclic generated-project audit, stable DerivedData, and a single Xcode lane. Stop after the pilot so the next decomposition plan is based on measured dependencies and deletion evidence rather than guesses.

**Tech Stack:** Swift 6, SwiftUI, XCTest, Xcode 26.x on the supported Intel host, XcodeGen 2.45.4, Swift Package Manager, Bash, Python 3 standard library, plutil, Git.

## Global Constraints

- This plan implements ADR-BUILD-001 in docs/superpowers/specs/2026-07-10-build-architecture-throughput-design.md.
- Do not begin until the paused Today Task 6 source slice is independently reviewed, validated, and committed. Documentation-only dirt outside the scoped paths may remain; overlapping production or build-tool dirt may not.
- Work on main. Preserve the existing untracked docs/superpowers/plans/2026-07-09-architecture-10-of-10-modernization.md; do not stage or alter it from this plan.
- The Final Architecture Tree remains exact source-path law. Build target names are compiler boundaries, not a replacement IA or source tree.
- Do not move app source into Packages. Do not create new Features ownership, numbered suffix files, broad Models.swift files, architecture nouns, or mutation authority.
- Do not modularize code that should be deleted. Unknown source remains retained until dynamic discovery, persistence, migration, replay, extension, preview, and test evidence are checked.
- No mass public conversion. Every public symbol in the pilot must have a named downstream consumer.
- Keep Command -> Event -> Projection -> Receipt -> Replay unchanged. No persistence schema, runtime event identity, product behavior, IA, copy, rendering, or release change belongs in this plan.
- Use .codex/DerivedData/Ambitions for all retained Xcode work. Never clean it except for the explicit cold benchmark.
- Allow exactly one active xcodebuild/xctest/Ambitions runner lane. A foreign active lane is a stop condition, not permission to run concurrently.
- Use -disableAutomaticPackageResolution and -skipPackageUpdates for steady-state commands after one deliberate dependency refresh.
- Xcode 27 and physical-device proof are not gates for this build-only phase. Simulator proof does not imply device, visual, accessibility, TestFlight, App Store, or release readiness.
- Each numbered task ends in its own reviewable commit when it changes tracked files. Run git diff --check before every commit and stage only the files named by that task.
- After every tracked implementation commit, use superpowers:requesting-code-review (or an equivalent independent review when inline execution was selected), repair all High and Medium findings, and rerun the task gates before continuing.
- After Task 8, stop. Do not extract Domain, Runtime, Projection, UI foundation, Trust, Composer, surfaces, Stage, or app composition until the measured Phase 2 plan is owner-approved.

---

### Task 1: Establish the clean handoff and capture the pre-relocation baseline

**Files:**

- Read: docs/superpowers/specs/2026-07-10-build-architecture-throughput-design.md
- Read: project.yml
- Read: Package.swift
- Produce ignored evidence only: .codex/xcode-benchmarks/BUILD-ARCH-PRE/**

- [ ] **Step 1: Rehydrate current authority and verify the implementation boundary**

Run:

~~~bash
git status --short --branch
git rev-parse HEAD
git status --short -- Native/Ambitions Native/AmbitionsTests Native/AmbitionsModuleTests project.yml Package.swift Sources AppUI Packages scripts
~~~

Expected: main; the last command prints nothing. If it prints any path, stop and finish or reconcile that active slice before this plan.

- [ ] **Step 2: Verify the Xcode lane is idle**

Run:

~~~bash
pgrep -fl 'xcodebuild|xctest|AmbitionsUITests-Runner|Ambitions.app' || true
~~~

Expected: no active build/test/app runner. Do not kill an unexplained user-owned process; stop and identify it.

- [ ] **Step 3: Record the root-package startup baseline with a hard bound**

Run:

~~~bash
bash scripts/ambitions-xcode-benchmark.sh --batch BUILD-ARCH-PRE --lane project-list-root-package -- scripts/ambitions-bounded-xcodebuild.sh --timeout 4m --kill-after 15s -- xcodebuild -list -disableAutomaticPackageResolution -skipPackageUpdates -project Ambitions.xcodeproj
~~~

Expected: a BENCHMARK_SUMMARY path. Exit 124 is acceptable baseline evidence if the root scan exceeds four minutes; it is not a passing build claim.

- [ ] **Step 4: Record environment and cache identity**

Run:

~~~bash
sw_vers
xcodebuild -version
xcodegen --version
sysctl -n hw.logicalcpu hw.memsize
git rev-parse HEAD
test -d .codex/DerivedData/Ambitions && echo warm || echo cold
~~~

Expected: Xcode 26.x, a compatible XcodeGen version, and an explicit warm/cold cache label in the benchmark notes. Task 1 creates no tracked files and no commit.

---

### Task 2: Add a generated-project build graph and package-root audit

**Files:**

- Create: scripts/ambitions-build-graph-audit.py
- Create: scripts/tests/test_ambitions_build_graph_audit.py
- Test: Ambitions.xcodeproj/project.pbxproj

- [ ] **Step 1: Write failing unit tests**

Use standard-library unittest with in-memory PBX object dictionaries. Cover:

Name the five test methods test_rejects_repo_root_local_package,
test_accepts_nested_design_system_package,
test_reports_missing_expected_target_edge,
test_reports_dependency_cycle, and
test_accepts_acyclic_time_foundation_graph. Each test must construct its PBX
fixture directly, call the public audit function, and assert the exact finding
set or empty result.

The pilot fixture must model:

~~~text
Ambitions -> AmbitionsTimeFoundation
AmbitionsTests -> Ambitions
AmbitionsTests -> AmbitionsTimeFoundation
AmbitionsModuleTests -> AmbitionsTimeFoundation
~~~

- [ ] **Step 2: Run RED**

~~~bash
python3 -m unittest scripts/tests/test_ambitions_build_graph_audit.py -v
~~~

Expected: FAIL/ERROR because the implementation is absent.

- [ ] **Step 3: Implement the minimal audit**

The script must convert the PBX project to JSON with plutil, read PBXNativeTarget, PBXTargetDependency, PBXContainerItemProxy, XCLocalSwiftPackageReference, and XCSwiftPackageProductDependency objects, then report package paths, nodes, edges, and cycles.

Use pure functions named native_targets, target_edges, package_paths,
dependency_cycles, and audit. Their return types are respectively a name-to-ID
dictionary, an edge set, a path set, an ordered cycle list, and an ordered
finding list. Tests call these functions without invoking plutil.

CLI requirements:

~~~text
--project
--expected-package-path
--require-target (repeatable)
--require-edge FROM:TO (repeatable)
--json
~~~

Exit 0 is Green, 1 is structural drift, and 2 is invalid invocation. A local package path of dot is always a finding.

- [ ] **Step 4: Run Green and prove the live RED**

~~~bash
python3 -m unittest scripts/tests/test_ambitions_build_graph_audit.py -v
python3 scripts/ambitions-build-graph-audit.py --project Ambitions.xcodeproj --expected-package-path Packages/AmbitionsDesignSystem
~~~

Expected: five tests pass; the live audit exits 1 and reports the repo-root local package.

- [ ] **Step 5: Commit tooling only**

~~~bash
git diff --check -- scripts/ambitions-build-graph-audit.py scripts/tests/test_ambitions_build_graph_audit.py
git add scripts/ambitions-build-graph-audit.py scripts/tests/test_ambitions_build_graph_audit.py
git commit -m "test: enforce the native build graph"
~~~

---

### Task 3: Relocate the design-system package out of the repository root

**Files:**

- Move: Package.swift -> Packages/AmbitionsDesignSystem/Package.swift
- Move: Sources/ -> Packages/AmbitionsDesignSystem/Sources/
- Move: AppUI/ -> Packages/AmbitionsDesignSystem/AppUI/
- Modify: project.yml
- Modify current path authorities: README.md, AGENTS.md, docs/truth/README.md, docs/truth/CODEX_START_HERE.md, docs/truth/IMPLEMENTATION_TRUTH.md, docs/truth/CODEX_PROCESS_TRUTH.md
- Modify current graph evidence: docs/qa/architecture/current-module-graph.json, docs/qa/architecture/architecture-10-scorecard.json
- Modify law path maps: docs/constitution/law-source-map/map-02.json, docs/constitution/law-source-map/map-03.json
- Modify workflow guards: .github/workflows/ambitions-pr-review.yml, .github/workflows/ambitions-strict-build-launch.yml
- Modify package-path scripts: scripts/ambitions-architecture-inventory.py, scripts/ambitions-component-inventory-generate.py, scripts/ambitions-copy-contract-lint.py, scripts/ambitions-legacy-runtime-production-use-guard.py, scripts/ambitions-quality-gate.py, scripts/ambitions-remediation-governance-check.py, scripts/ambitions-runtime-direct-write-audit.py, scripts/ambitions-senior-code-audit.py, scripts/ambitions-swift6-modernization-scan.py, scripts/ambitions-truth-path-vocabulary-audit.py, scripts/ambitions-xcodegen-needed.sh, scripts/changed-file-boundary-check.sh, scripts/dev/toolkit-snapshot.sh
- Modify moved self-audits: Packages/AmbitionsDesignSystem/Sources/Accessibility/AccessibilityAutomatedNutritionGate.swift, AccessibilityNutrition.swift, AccessibilityNutrition+02-EB28PlainLanguageExplanationEvidence.swift, Components/AccessibilityAdaptiveInterfacePrimitives+03-SI15AccessibilityAdaptiveInterfaceReview.swift, Previews/SI16PreviewFixtureCatalog.swift
- Regenerate: Ambitions.xcodeproj/project.pbxproj

- [ ] **Step 1: Move the package intact**

~~~bash
mkdir -p Packages/AmbitionsDesignSystem
git mv Package.swift Packages/AmbitionsDesignSystem/Package.swift
git mv Sources Packages/AmbitionsDesignSystem/Sources
git mv AppUI Packages/AmbitionsDesignSystem/AppUI
~~~

Expected: no root Package.swift, Sources, or AppUI.

- [ ] **Step 2: Point XcodeGen at the nested package**

Use:

~~~yaml
packages:
  AmbitionsPackages:
    path: Packages/AmbitionsDesignSystem
~~~

Update current authority, workflow, law-map, and script references to the three nested paths. In scripts/ambitions-xcodegen-needed.sh set:

~~~bash
PACKAGE_FILE="Packages/AmbitionsDesignSystem/Package.swift"
~~~

Update the five moved Swift self-audits so literal owner paths begin Packages/AmbitionsDesignSystem/Sources. Do not rewrite retained historical evidence that truthfully records an old commit.

- [ ] **Step 3: Update current graph facts conservatively**

In current-module-graph.json, update capturedAt, commit, and authorities.reusableModuleGraph. Keep the monolithic-app assessment Red until the pilot lands. Do not change duplicate-compilation risks without generated evidence.

- [ ] **Step 4: Regenerate and prove the package graph**

~~~bash
xcodegen generate
swift package --package-path Packages/AmbitionsDesignSystem describe --type json >/tmp/ambitions-design-system-package.json
python3 - <<'PY'
import json
data = json.load(open('/tmp/ambitions-design-system-package.json'))
assert {p['name'] for p in data['products']} == {'AmbitionsDesignSystem', 'AmbitionsWidgetUI'}
print('package-products=Green')
PY
python3 scripts/ambitions-build-graph-audit.py --project Ambitions.xcodeproj --expected-package-path Packages/AmbitionsDesignSystem
~~~

Expected: both products are present; audit is Green with no repo-root package.

- [ ] **Step 5: Measure startup three times**

Run the command three times with lanes post-relocation-1, -2, and -3:

~~~bash
bash scripts/ambitions-xcode-benchmark.sh --batch BUILD-ARCH-POST-PACKAGE --lane post-relocation-1 -- xcodebuild -list -disableAutomaticPackageResolution -skipPackageUpdates -project Ambitions.xcodeproj
~~~

Expected: all exit 0 and median startup <=15 seconds. If slower, keep a materially beneficial and correct relocation but report the target Yellow and stop before module extraction.

- [ ] **Step 6: Run behavior-neutral build and governance proof**

~~~bash
bash scripts/ambitions-xcode-build-for-testing.sh --batch BUILD-ARCH-PACKAGE --scheme AmbitionsUnitTests
python3 scripts/ambitions-constitution-audit.py
python3 scripts/ambitions-remediation-governance-check.py
python3 scripts/ambitions-architecture-inventory.py
python3 scripts/ambitions-truth-path-vocabulary-audit.py
bash scripts/canon-language-drift-scan.sh
git diff --check
~~~

Expected: build-for-testing passes and changed-scope path checks are Green. Record unrelated pre-existing findings exactly.

- [ ] **Step 7: Commit relocation separately**

Stage only Task 3 paths and commit:

~~~bash
git commit -m "build: isolate the design system package"
~~~

---

### Task 4: Install the single-lane lock and benchmark metadata

**Files:**

- Create: scripts/ambitions-xcode-lane-lock.py
- Create: scripts/tests/test_ambitions_xcode_lane_lock.py
- Create: scripts/ambitions-build-benchmark-report.py
- Create: scripts/tests/test_ambitions_build_benchmark_report.py
- Modify: scripts/ambitions-bounded-xcodebuild.sh
- Modify: scripts/ambitions-xcode-benchmark.sh
- Modify: scripts/ambitions-xcode-build-for-testing.sh
- Modify: scripts/ambitions-xcode-test-focused.sh

- [ ] **Step 1: Write failing tests**

Cover first-owner acquisition, live foreign-owner rejection, unlocked foreign-Xcode-process rejection from an injected process snapshot, dead-owner reclamation, token-protected release, warm/cold separation, median/worst calculation, and mixed-identity rejection.

~~~bash
python3 -m unittest scripts/tests/test_ambitions_xcode_lane_lock.py scripts/tests/test_ambitions_build_benchmark_report.py -v
~~~

Expected: RED because implementations are absent.

- [ ] **Step 2: Implement atomic ownership**

Use atomic directory creation at .codex/xcode-lane.lock and owner.json containing PID, parent PID, command, commit, host, and UTC start. CLI:

~~~text
ambitions-xcode-lane-lock.py acquire --command TEXT
ambitions-xcode-lane-lock.py release --token UUID
ambitions-xcode-lane-lock.py status --json
~~~

Acquire prints a token, rejects a live foreign owner, rejects an active foreign xcodebuild/xctest/Ambitions runner even when it predates the lock, reclaims a dead owner, and never kills a process. Process discovery must be dependency-injected for unit tests. Only the matching token releases.

- [ ] **Step 3: Wrap bounded Xcode work**

In ambitions-bounded-xcodebuild.sh, acquire before launch and release from its existing EXIT cleanup path. Preserve targeted timeout cleanup. Delete the Actions-runner quarantine watchdog and its process-killing helpers after the lock test proves that foreign work is rejected safely. Reject concurrent live work; never kill an unrelated lane merely to obtain the lock.

- [ ] **Step 4: Enrich benchmark samples**

Each sample records commit, dirty state, Xcode/macOS, CPU, memory, DerivedData, warm/cold state, package path, scenario, command, duration, and exit. Add package resolution disabling flags to steady-state arrays. Add explicit --refresh-packages mode that never activates implicitly.

The report groups only identical commit/package/cache identities and returns sample count, median, worst, exits, and target state.

- [ ] **Step 5: Prove Green and commit**

~~~bash
python3 -m unittest scripts/tests/test_ambitions_xcode_lane_lock.py scripts/tests/test_ambitions_build_benchmark_report.py -v
python3 scripts/ambitions-xcode-lane-lock.py status --json
bash scripts/ambitions-xcode-benchmark.sh --status
bash -n scripts/ambitions-bounded-xcodebuild.sh scripts/ambitions-xcode-benchmark.sh scripts/ambitions-xcode-build-for-testing.sh scripts/ambitions-xcode-test-focused.sh
git diff --check -- scripts
git add scripts/ambitions-xcode-lane-lock.py scripts/tests/test_ambitions_xcode_lane_lock.py scripts/ambitions-build-benchmark-report.py scripts/tests/test_ambitions_build_benchmark_report.py scripts/ambitions-bounded-xcodebuild.sh scripts/ambitions-xcode-benchmark.sh scripts/ambitions-xcode-build-for-testing.sh scripts/ambitions-xcode-test-focused.sh
git commit -m "build: serialize and measure Xcode work"
~~~

Expected: all tests and syntax checks pass; lane is idle.

---

### Task 5: Generate the evidence-backed source disposition inventory

**Files:**

- Create: scripts/ambitions-source-disposition-audit.py
- Create: scripts/tests/test_ambitions_source_disposition_audit.py
- Produce ignored evidence: .codex/architecture/source-disposition.json

- [ ] **Step 1: Write failing safety tests**

Use these exact dispositions:

~~~python
CANONICAL_RETAINED = "canonical_retained"
CANONICAL_CONSOLIDATE = "canonical_requires_consolidation"
MISOWNED_REQUIRED = "misowned_required"
DUPLICATE_AUTHORITY = "duplicate_authority"
OBSOLETE_SHIM = "obsolete_compatibility_shim"
HISTORICAL_RESIDUE = "historical_residue"
GENERATED = "generated_source"
TEST_PREVIEW_ONLY = "test_preview_only"
UNKNOWN = "unknown_pending_stronger_evidence"
~~~

Prove that zero static references remains UNKNOWN when App Intents, SwiftData, reflection, extensions, previews, registries, migration, persistence, or replay may discover the file.

- [ ] **Step 2: Run RED, then implement a fact collector**

~~~bash
python3 -m unittest scripts/tests/test_ambitions_source_disposition_audit.py -v
~~~

Expected: RED before implementation.

For every production Swift file under Native/Ambitions, both extension roots, and Packages/AmbitionsDesignSystem, record canonical path, generated target membership, declarations and reference counts, imports, suffix/LOC signals, discovery markers, migration/replay markers, preview/generated markers, registry references, disposition, and evidence.

Default to UNKNOWN. The script never deletes, moves, or edits source.

- [ ] **Step 3: Test and generate live ignored evidence**

~~~bash
python3 -m unittest scripts/tests/test_ambitions_source_disposition_audit.py -v
python3 scripts/ambitions-source-disposition-audit.py --project Ambitions.xcodeproj --output .codex/architecture/source-disposition.json
python3 - <<'PY'
import json
data = json.load(open('.codex/architecture/source-disposition.json'))
assert data['schema_version'] == 1
assert data['files']
assert all('disposition' in row and 'evidence' in row for row in data['files'])
print(f"inventory-files={len(data['files'])}")
PY
~~~

Expected: every file has evidence; no production file changes.

- [ ] **Step 4: Commit the audit only**

~~~bash
git diff --check -- scripts/ambitions-source-disposition-audit.py scripts/tests/test_ambitions_source_disposition_audit.py
git add scripts/ambitions-source-disposition-audit.py scripts/tests/test_ambitions_source_disposition_audit.py
git commit -m "build: inventory source before decomposition"
~~~

The first deletion wave belongs in the evidence-derived Phase 2 plan, where exact files and proof can be named.

---

### Task 6: Write module-only clock contract tests and prove RED

**Files:**

- Create: Native/AmbitionsModuleTests/TimeFoundationModuleTests.swift
- Modify: project.yml

- [ ] **Step 1: Add the aggregate module-test target and scheme**

Add:

~~~yaml
  AmbitionsModuleTests:
    type: bundle.unit-test
    platform: iOS
    deploymentTarget: "26.0"
    sources:
      - path: Native/AmbitionsModuleTests
    settings:
      base:
        GENERATE_INFOPLIST_FILE: YES
    dependencies:
      - target: AmbitionsTimeFoundation
~~~

Add scheme AmbitionsModuleTests that builds and tests only that target.

- [ ] **Step 2: Add direct behavior tests**

Create TimeFoundationModuleTests.swift:

~~~swift
import AmbitionsTimeFoundation
import Foundation
import XCTest

final class TimeFoundationModuleTests: XCTestCase {
    func testUTCPolicyParsesAndAdvancesDatesDeterministically() throws {
        let policy = RuntimeTickPolicy.utc
        let start = try XCTUnwrap(policy.parseISODate("2026-07-10T12:00:00Z"))
        let next = try XCTUnwrap(policy.date(byAdding: .day, value: 1, to: start))
        XCTAssertEqual(policy.dayDistance(from: start, to: next), 1)
    }

    func testFixedSystemClockUsesInjectedTimeZone() {
        let clock = SystemClock(timeZoneProvider: .utc)
        XCTAssertEqual(clock.timeZone.secondsFromGMT(for: clock.now), 0)
        XCTAssertTrue(clock.advancesAutomatically)
    }

    func testDayBoundaryRefreshDetectsTimeZoneChange() throws {
        let policy = TodayDayBoundaryRefreshPolicy()
        let now = try XCTUnwrap(RuntimeTickPolicy.utc.parseISODate("2026-07-10T12:00:00Z"))
        let utc = TimeZone(secondsFromGMT: 0)!
        let west = TimeZone(secondsFromGMT: -7_200)!
        let loaded = policy.loadedClockContext(for: now, calendar: RuntimeTickPolicy.utc.calendar, timeZone: utc)
        XCTAssertFalse(policy.shouldRefresh(lastLoadedClockContext: loaded, now: now, calendar: RuntimeTickPolicy.utc.calendar, timeZone: utc))
        let westPolicy = RuntimeTickPolicy(timeZoneProvider: TimeZoneProvider(timeZone: west))
        XCTAssertTrue(policy.shouldRefresh(lastLoadedClockContext: loaded, now: now, calendar: westPolicy.calendar, timeZone: west))
    }
}
~~~

- [ ] **Step 3: Regenerate to verify RED**

~~~bash
xcodegen generate
~~~

Expected: missing AmbitionsTimeFoundation target dependency. Do not commit RED; proceed directly to Task 7.

---

### Task 7: Extract the canonical-path AmbitionsTimeFoundation pilot

**Files:**

- Modify: Native/Ambitions/Core/Time/AmbitionsClock.swift
- Modify: Native/Ambitions/Core/Time/DayBoundaryScheduler.swift
- Modify: Native/Ambitions/Core/Time/PreviewClock.swift
- Modify: Native/Ambitions/Core/Time/RuntimeTickPolicy.swift
- Modify: Native/Ambitions/Core/Time/SystemClock.swift
- Modify: Native/Ambitions/Core/Time/TimeZoneProvider.swift
- Modify: Native/Ambitions/Core/Time/TodayDayBoundaryRefreshPolicy.swift
- Create: Native/Ambitions/App/Bootstrap/AmbitionsClockFactory.swift
- Modify: project.yml
- Modify exact production and test consumers listed below
- Regenerate: Ambitions.xcodeproj/project.pbxproj

- [ ] **Step 1: Correct ownership before extraction**

Move AmbitionsClockFactory from Core/Time/AmbitionsClock.swift to App/Bootstrap/AmbitionsClockFactory.swift. The new file imports AmbitionsTimeFoundation and retains the existing internal factory API. Core/Time must no longer reference AppSession.

- [ ] **Step 2: Add the exact static target**

~~~yaml
  AmbitionsTimeFoundation:
    type: framework
    platform: iOS
    deploymentTarget: "26.0"
    sources:
      - path: Native/Ambitions/Core/Time/AmbitionsClock.swift
      - path: Native/Ambitions/Core/Time/DayBoundaryScheduler.swift
      - path: Native/Ambitions/Core/Time/PreviewClock.swift
      - path: Native/Ambitions/Core/Time/RuntimeTickPolicy.swift
      - path: Native/Ambitions/Core/Time/SystemClock.swift
      - path: Native/Ambitions/Core/Time/TimeZoneProvider.swift
      - path: Native/Ambitions/Core/Time/TodayDayBoundaryRefreshPolicy.swift
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.ambitions.timefoundation
        GENERATE_INFOPLIST_FILE: YES
        MACH_O_TYPE: staticlib
        SKIP_INSTALL: YES
~~~

Exclude those same seven relative paths from the broad Native/Ambitions source entry. Add the target as a dependency of Ambitions and AmbitionsTests. Keep LifeShapeBucketizer.swift in the app target.

- [ ] **Step 3: Expose only named consumers**

Make AmbitionsClock, DEBUG TestClock/PreviewClock, RuntimeTickPolicy, SystemClock, TimeZoneProvider, DayBoundaryScheduler and LoadedClockContext, and TodayDayBoundaryRefreshPolicy public, including necessary explicit initializers and used members. AmbitionsClockFactory stays internal. Do not use @_exported import.

- [ ] **Step 4: Add explicit imports**

Add import AmbitionsTimeFoundation only to:

~~~text
Native/Ambitions/App/AppCapabilities.swift
Native/Ambitions/App/AppContainer.swift
Native/Ambitions/App/Bootstrap/RuntimeBootstrap.swift
Native/Ambitions/App/Bootstrap/SystemSurfaceBootstrap.swift
Native/Ambitions/Core/LocalRuntimeOS/Boundary/AmbitionsRuntimeFactory.swift
Native/Ambitions/Core/LocalRuntimeOS/Boundary/AppServices.swift
Native/Ambitions/Core/LocalRuntimeOS/Scheduling/ClosureEngine.swift
Native/Ambitions/DesignSystem/ProductObjects/RealityMeridianView.swift
Native/Ambitions/DesignSystem/ProductObjects/TodayBackground.swift
Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailView.swift
Native/Ambitions/DesignSystem/ProductObjects/TodayMasthead.swift
Native/Ambitions/PreviewSupport/PreviewAppContainer.swift
Native/Ambitions/Quality/LifeShapeFixtureAudit.swift
Native/Ambitions/Stage/StageStore.swift
Native/Ambitions/Surfaces/Time/Projection/RepositoryBackedTimeService.swift
Native/Ambitions/Surfaces/Time/Projection/TimeLens.swift
Native/Ambitions/Surfaces/Time/Projection/TimeProjectionUtilityDatePressure.swift
Native/Ambitions/Surfaces/Time/Projection/TimeRitualsProjectionService.swift
Native/Ambitions/Surfaces/Time/Projection/TimeWeekShapeProjection.swift
Native/Ambitions/Surfaces/Time/TimeObjectView.swift
Native/Ambitions/Surfaces/Time/TimeRitualsSurface.swift
Native/Ambitions/Surfaces/Time/TimeSurface.swift
Native/Ambitions/Surfaces/Time/TimeViewModel.swift
Native/Ambitions/Surfaces/Time/WeeklyReviewScreen.swift
Native/Ambitions/Surfaces/Today/Overlays/TodayStepReplacementSheet+02-TodayStepReplacementSheetState+03-id.swift
Native/Ambitions/Surfaces/Today/Projection/TodayFeatureService+02-RepositoryBackedTodayService+Repository08-nextStepSchedulingSelection.swift
Native/Ambitions/Surfaces/Today/Projection/TodayFeatureService.swift
Native/Ambitions/Surfaces/Today/Projection/TodayLens.swift
Native/Ambitions/Surfaces/Today/Projection/TodayReadModelProjector.swift
Native/Ambitions/Surfaces/Today/TodayObjectView.swift
Native/Ambitions/Surfaces/Today/TodaySurface+03-applyDebugScreenshotSheetIfNeeded.swift
Native/Ambitions/Surfaces/Today/TodayViewModel.swift
~~~

Also import it in LifeShapeAntiFakeAuditTests.swift, TimeClockTests.swift, TodayClockTests.swift, TodayFreshGoalVisibilityTests.swift, TodayRealityMeridianExperienceElevationTests.swift, and TodayRecoveryViewModelTests.swift. Preserve @testable import Ambitions for integration-only symbols.

- [ ] **Step 5: Regenerate and prove target shape**

~~~bash
xcodegen generate
python3 scripts/ambitions-build-graph-audit.py --project Ambitions.xcodeproj --expected-package-path Packages/AmbitionsDesignSystem --require-target AmbitionsTimeFoundation --require-target AmbitionsModuleTests --require-edge Ambitions:AmbitionsTimeFoundation --require-edge AmbitionsTests:AmbitionsTimeFoundation --require-edge AmbitionsModuleTests:AmbitionsTimeFoundation
xcodebuild -project Ambitions.xcodeproj -target AmbitionsTimeFoundation -showBuildSettings | rg 'MACH_O_TYPE = staticlib'
~~~

Expected: graph Green, no cycles, staticlib verified.

- [ ] **Step 6: Prove module-only and integration behavior**

~~~bash
bash scripts/ambitions-xcode-build-for-testing.sh --batch BUILD-ARCH-TIME-MODULE --scheme AmbitionsModuleTests
bash scripts/ambitions-xcode-test-focused.sh --batch BUILD-ARCH-TIME-MODULE --scheme AmbitionsModuleTests --only-testing AmbitionsModuleTests/TimeFoundationModuleTests --without-building
bash scripts/ambitions-xcode-build-for-testing.sh --batch BUILD-ARCH-TIME-INTEGRATION --scheme AmbitionsUnitTests
~~~

Then run these six classes with ambitions-xcode-test-focused.sh, scheme AmbitionsUnitTests, and --without-building:

~~~text
AmbitionsTests/TimeClockTests
AmbitionsTests/TodayClockTests
AmbitionsTests/TodayFreshGoalVisibilityTests
AmbitionsTests/TodayRealityMeridianExperienceElevationTests
AmbitionsTests/TodayRecoveryViewModelTests
AmbitionsTests/LifeShapeAntiFakeAuditTests
~~~

Expected: three module tests and all integration classes pass.

- [ ] **Step 7: Run gates and public API review**

~~~bash
python3 scripts/ambitions-remediation-governance-check.py
python3 scripts/ambitions-architecture-inventory.py
python3 scripts/ambitions-constitution-audit.py
git diff --check
git diff --unified=0 -- Native/Ambitions/Core/Time | rg '^\+.*public'
rg -n '\bAppSession\b|import (SwiftUI|UIKit|AmbitionsDesignSystem|AmbitionsWidgetUI)' Native/Ambitions/Core/Time/{AmbitionsClock,DayBoundaryScheduler,PreviewClock,RuntimeTickPolicy,SystemClock,TimeZoneProvider,TodayDayBoundaryRefreshPolicy}.swift || true
~~~

Expected: changed-scope gates pass, public additions are limited to the named clock contracts, and the dependency-direction search is empty.

- [ ] **Step 8: Commit the pilot**

Stage only Tasks 6-7 paths and commit:

~~~bash
git commit -m "build: extract the time foundation module"
~~~

---

### Task 8: Benchmark the pilot, update graph truth, and stop

**Files:**

- Modify: docs/qa/architecture/current-module-graph.json
- Modify only if exact evidence changes: docs/qa/architecture/architecture-10-scorecard.json
- Produce ignored evidence: .codex/xcode-benchmarks/BUILD-ARCH-PILOT/**
- Produce ignored evidence: .codex/architecture/source-disposition.json

- [ ] **Step 1: Capture three warm samples per scenario**

Measure project-startup, no-change module build-for-testing, module test-without-building, leaf-module edit through proof, and no-change app-unit build-for-testing. For the leaf edit, change only a comment in RuntimeTickPolicy.swift, measure, then reverse it with apply_patch. Never use git checkout or reset.

Targets:

~~~text
project startup median <=15s
no-change focused invocation median <=30s
module test-without-building median <=30s
leaf edit through focused proof median <=60s
~~~

- [ ] **Step 2: Generate the report and refreshed disposition inventory**

~~~bash
python3 scripts/ambitions-build-benchmark-report.py --input .codex/xcode-benchmarks/BUILD-ARCH-PILOT --json > .codex/xcode-benchmarks/BUILD-ARCH-PILOT/report.json
python3 scripts/ambitions-source-disposition-audit.py --project Ambitions.xcodeproj --output .codex/architecture/source-disposition.json
~~~

Expected: one identity-consistent benchmark report; the seven pilot files each have exactly one production target membership.

- [ ] **Step 3: Update current module graph truth**

Record current commit/date, AmbitionsTimeFoundation and AmbitionsModuleTests nodes, three pilot edges, reduced app file count, nested package authority, and current duplicate-compilation risks. Overall assessment remains Yellow until the intended graph is compiler-enforced.

- [ ] **Step 4: Run final Phase 1 verification**

~~~bash
python3 -m unittest discover -s scripts/tests -p 'test_ambitions_*build*.py' -v
python3 scripts/ambitions-build-graph-audit.py --project Ambitions.xcodeproj --expected-package-path Packages/AmbitionsDesignSystem --require-target AmbitionsTimeFoundation --require-target AmbitionsModuleTests
python3 scripts/ambitions-remediation-governance-check.py
python3 scripts/ambitions-architecture-inventory.py
python3 scripts/ambitions-constitution-audit.py
python3 scripts/ambitions-truth-path-vocabulary-audit.py
bash scripts/canon-language-drift-scan.sh
git diff --check
~~~

Expected: all plan-owned tests and structural gates pass. Unrelated pre-existing truth-path failures remain named non-claims.

- [ ] **Step 5: Commit graph evidence**

~~~bash
git add docs/qa/architecture/current-module-graph.json
git diff --cached --check
git commit -m "docs: record the build module pilot"
~~~

Include architecture-10-scorecard.json only if its evidence actually changed.

- [ ] **Step 6: Apply the Phase 2 gate and stop**

Continue to Phase 2 planning only when package relocation build proof, generated graph, module test discovery, affected integration tests, target membership, public API review, throughput, and current disposition inventory are all Green or explicitly owner-accepted where the target is merely provisional.

Present startup before/after, median/worst scenarios, current target graph, public API delta, disposition counts, evidence-backed deletion candidates, recommended next boundary, and proof ceilings.

Do not begin the next module. The next owner-approved plan must name exact files for the first destruction wave and next boundary. Likely labels from ADR-BUILD-001 are not authorization to move them.

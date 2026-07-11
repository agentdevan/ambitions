# Ambitions Domain Module Extraction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract all canonical `Native/Ambitions/Core/Domain` production source into one compiler-enforced static `AmbitionsDomain` module while preserving behavior, serialization, replay compatibility, exact source paths, and a fast edit-build-test loop.

**Architecture:** `AmbitionsDomain` owns every Swift file recursively below `Native/Ambitions/Core/Domain` and depends only on Foundation and CryptoKit. `Ambitions`, `AmbitionsTests`, and `AmbitionsModuleTests` depend explicitly on it; the application target excludes the same recursive source set so every Domain file has exactly one production membership. A generated, compiler-refined boundary manifest and independent review gate control every public declaration before extraction can proceed.

**Tech Stack:** Swift 6, XcodeGen 2.38+, Xcode project static frameworks, XCTest, Python 3 `unittest`, Foundation, CryptoKit, existing bounded Xcode and benchmark helpers.

## Global Constraints

- Work on `main` only and preserve unrelated user changes.
- Use `project.yml` as build-graph source truth and regenerate `Ambitions.xcodeproj`; never hand-edit `project.pbxproj`.
- The iOS deployment target remains `26.0`; do not require Xcode 27 or physical-device proof.
- Keep every production Swift file at its existing canonical path under `Native/Ambitions/Core/Domain`.
- Create exactly one new production target: `AmbitionsDomain`; do not create GoalEngine, ProofMode, Reschedule, DomainModels, DomainContracts, or Shared targets.
- `AmbitionsDomain` may import Foundation and CryptoKit only. It must not depend on the app, Time, UI, runtime, persistence, projection, trust, composer, surfaces, Stage, or package products.
- `AmbitionsDomain` and `AmbitionsTimeFoundation` remain sibling modules with no edge between them.
- All declarations remain internal unless a named outside consumer and compiler diagnostic prove a stable Domain contract is required.
- Do not use `@_exported`, blanket access-control rewrites, public storage for test convenience, or public helpers used only inside Domain.
- Do not add numbered `+02`, `+03`, or `+04` files or broad `Models.swift` files.
- Delete or consolidate no Domain source unless compiler membership, runtime construction, serialization, migration, replay, dynamic discovery, fixtures, registries, and focused behavior proof all authorize it. The initial deletion authorization is zero files.
- Use `@testable import AmbitionsDomain` only in `AmbitionsModuleTests`; application integration tests import `AmbitionsDomain` only when directly testing public contracts.
- Use `.codex/DerivedData/Ambitions`, the single-lane lock, authoritative package identity, and three warm samples per benchmark scenario.
- Debug module build, Debug application build-for-testing, and Release application build with code signing disabled are mandatory.
- Stop before any Runtime source change or Runtime extraction design.
- Do not claim device, visual, accessibility, privacy/legal, CI, TestFlight, App Store, or release readiness.

---

## File Map

| Path | Responsibility |
|---|---|
| `scripts/ambitions-domain-boundary-audit.py` | Generate and validate the exact Domain source, consumer, declaration-candidate, risk-marker, import, and target-membership census. |
| `scripts/tests/test_ambitions_domain_boundary_audit.py` | Prove deterministic census generation, recursive membership checks, forbidden imports, duplicated production membership, and reviewed-public-contract validation. |
| `docs/qa/architecture/domain-module-boundary.json` | Current machine-readable boundary evidence; generated from live source and refined with compiler diagnostics and review decisions. |
| `Native/AmbitionsModuleTests/DomainModuleBoundaryTests.swift` | Fast module-only value, Codable, GoalEngine, Reschedule, ProofMode, and CryptoKit identity proofs. |
| `project.yml` | Declare `AmbitionsDomain`, recursive source ownership/exclusion, and explicit consumer edges. |
| `Ambitions.xcodeproj/project.pbxproj` | XcodeGen output generated from `project.yml`. |
| Domain source files named by `domain-module-boundary.json` | Add only individually reviewed public access required by exact outside consumers. No paths move. |
| Outside-Domain Swift files named by compiler diagnostics | Add explicit `import AmbitionsDomain`; make no unrelated behavior changes. |
| `scripts/tests/test_ambitions_build_graph_audit.py` | Lock the new target and three required dependency edges into graph-audit behavior. |
| `docs/qa/architecture/current-module-graph.json` | Record the generated post-extraction graph and single-membership evidence. |
| `.codex/architecture/source-disposition.json` | Regenerated ignored working evidence for source disposition; no deletion authorization is inferred from unknown rows. |
| `docs/qa/architecture/architecture-10-scorecard.json` | Update only claims earned by generated graph, build, test, API, and benchmark evidence. |
| `docs/qa/architecture/domain-module-extraction-report.md` | Human-readable closeout, benchmark table, proof ceiling, architecture ownership, and Phase 3 decision. |
| `.superpowers/sdd/domain-boundary-public-api-review.md` | Ignored independent-review artifact whose first line is `Reviewer: agent-name`; used to stamp the reviewed manifest without invented identity. |

### Boundary manifest schema

`docs/qa/architecture/domain-module-boundary.json` must use schema version 1:

```json
{
  "schemaVersion": 1,
  "module": "AmbitionsDomain",
  "sourceRoot": "Native/Ambitions/Core/Domain",
  "allowedImports": ["CryptoKit", "Foundation"],
  "files": [],
  "outsideConsumers": [],
  "publicContracts": [],
  "compilerDiagnostics": [],
  "compilerPublicInterface": [],
  "consolidationCandidates": [],
  "consolidationReview": {
    "status": "unreviewed",
    "runtimeConstructionChecked": false,
    "serializationMigrationReplayChecked": false,
    "appIntentsWidgetsShareChecked": false,
    "reflectionFixturesRegistriesChecked": false,
    "provenCandidatePaths": [],
    "decision": "retain_unknown"
  },
  "deletionAuthorizations": [],
  "review": {
    "status": "unreviewed",
    "reviewedContentHash": "",
    "reviewer": "",
    "findings": []
  }
}
```

Each `files` row contains `path`, `imports`, `loc`, `suffixSignals`, `riskMarkers`, `xcodeTargets`, and `disposition`. Each `outsideConsumers` row contains `path`, `target`, and `candidateSymbols`. Each `publicContracts` row contains `preciseIdentifier`, `symbol`, `kind`, `declarationPath`, `consumerTarget`, `consumerPaths`, `compilerDiagnostic`, `reason`, `coverage`, `narrowerInterfaceDecision`, and `status`. Allowed statuses are `candidate`, `approved`, and `rejected`. `preciseIdentifier` is the compiler-interface declaration signature, including nesting and member labels; it is the bijection key between the generated Swift interface and the manifest.

---

### Task 1: Generate and review the Domain boundary census

**Files:**
- Create: `scripts/ambitions-domain-boundary-audit.py`
- Create: `scripts/tests/test_ambitions_domain_boundary_audit.py`
- Create: `docs/qa/architecture/domain-module-boundary.json`

**Interfaces:**
- Consumes: repo root, `Ambitions.xcodeproj/project.pbxproj`, `.codex/architecture/source-disposition.json`, and recursive Swift source below `Native/Ambitions/Core/Domain`.
- Produces: `collect_boundary(root: Path, project: Path, disposition: Path) -> dict[str, object]`, `validate_boundary(payload: dict[str, object], require_review: bool) -> list[str]`, `reviewed_content_hash(root: Path, payload: dict[str, object]) -> str`, `approve_review(root: Path, payload: dict[str, object], reviewer: str, review_artifact: Path) -> dict[str, object]`, and the schema-version-1 boundary manifest.

- [ ] **Step 1: Write failing audit tests**

Create fixture-backed `unittest` cases with these exact behaviors:

```python
class DomainBoundaryAuditTests(unittest.TestCase):
    def test_collects_recursive_domain_files_and_outside_consumers(self) -> None:
        payload = collect_boundary(self.root, self.project, self.disposition)
        self.assertEqual(
            [row["path"] for row in payload["files"]],
            [
                "Native/Ambitions/Core/Domain/GoalEngine/Planner.swift",
                "Native/Ambitions/Core/Domain/Step.swift",
            ],
        )
        self.assertEqual(
            payload["outsideConsumers"],
            [{
                "path": "Native/Ambitions/Surfaces/Goals/GoalView.swift",
                "target": "Ambitions",
                "candidateSymbols": ["Step"],
            }],
        )

    def test_rejects_forbidden_domain_import(self) -> None:
        self.write_domain("Bad.swift", "import SwiftUI\nstruct Bad {}\n")
        findings = validate_boundary(self.collect(), require_review=False)
        self.assertIn("forbidden Domain import: SwiftUI in Native/Ambitions/Core/Domain/Bad.swift", findings)

    def test_rejects_duplicate_production_membership(self) -> None:
        payload = self.collect()
        payload["files"][0]["xcodeTargets"] = ["Ambitions", "AmbitionsDomain"]
        findings = validate_boundary(payload, require_review=False)
        self.assertIn("Domain source has multiple production targets: Native/Ambitions/Core/Domain/GoalEngine/Planner.swift", findings)

    def test_review_gate_rejects_unreviewed_or_candidate_contracts(self) -> None:
        payload = self.collect()
        payload["publicContracts"] = [{"symbol": "Step", "status": "candidate"}]
        findings = validate_boundary(payload, require_review=True)
        self.assertIn("boundary review is not approved", findings)
        self.assertIn("public contract lacks approved decision: Step", findings)

    def test_review_gate_accepts_only_complete_approved_contracts(self) -> None:
        payload = self.complete_reviewed_payload()
        self.assertEqual(validate_boundary(payload, require_review=True), [])

    def test_public_interface_and_approved_manifest_must_be_bijective(self) -> None:
        payload = self.complete_reviewed_payload()
        payload["compilerPublicInterface"] = ["public struct Step", "public init(id: Swift.String)"]
        payload["publicContracts"] = [self.approved_contract("public struct Step")]
        findings = validate_boundary(payload, require_review=True)
        self.assertIn("unapproved compiler public declaration: public init(id: Swift.String)", findings)

    def test_rejects_approved_contract_absent_from_compiler_interface(self) -> None:
        payload = self.complete_reviewed_payload()
        payload["publicContracts"].append(self.approved_contract("public var phantom: Swift.String"))
        findings = validate_boundary(payload, require_review=True)
        self.assertIn("approved public contract absent from compiler interface: public var phantom: Swift.String", findings)

    def test_rejects_incomplete_contract_evidence_and_review_findings(self) -> None:
        payload = self.complete_reviewed_payload()
        payload["publicContracts"][0]["coverage"] = []
        payload["review"]["findings"] = ["Important: initializer is broader than its consumer"]
        findings = validate_boundary(payload, require_review=True)
        self.assertIn("public contract has incomplete evidence: public struct Step", findings)
        self.assertIn("boundary review retains Critical or Important findings", findings)

    def test_content_hash_invalidates_review_after_source_or_manifest_change(self) -> None:
        payload = self.complete_reviewed_payload()
        payload["review"]["reviewedContentHash"] = "sha256:stale"
        findings = validate_boundary(payload, require_review=True)
        self.assertIn("reviewed content hash does not match current boundary content", findings)

    def test_consolidation_review_requires_all_dynamic_safety_checks(self) -> None:
        payload = self.complete_reviewed_payload()
        payload["consolidationReview"]["appIntentsWidgetsShareChecked"] = False
        findings = validate_boundary(payload, require_review=True)
        self.assertIn("consolidation review is incomplete: appIntentsWidgetsShareChecked", findings)
```

- [ ] **Step 2: Run the tests and verify RED**

Run:

```bash
python3 -m unittest scripts.tests.test_ambitions_domain_boundary_audit -v
```

Expected: import failure because `scripts/ambitions-domain-boundary-audit.py` does not exist.

- [ ] **Step 3: Implement the census and validator**

Implement deterministic pathlib traversal, Swift import/declaration token extraction, PBX target membership reuse, and JSON output. The CLI must be:

```text
python3 scripts/ambitions-domain-boundary-audit.py \
  --project Ambitions.xcodeproj \
  --disposition .codex/architecture/source-disposition.json \
  --output docs/qa/architecture/domain-module-boundary.json \
  --validate-only \
  --require-review
```

Generation is the same command without `--validate-only --require-review`. Review stamping adds `--approve-review --reviewer "$REVIEWER" --review-artifact .superpowers/sdd/domain-boundary-public-api-review.md`; the script records the current content hash rather than a commit identifier.

The implementation must:

```python
DOMAIN_ROOT = "Native/Ambitions/Core/Domain"
ALLOWED_IMPORTS = {"Foundation", "CryptoKit"}
PRODUCTION_TARGETS = {"Ambitions", "AmbitionsDomain"}
PUBLIC_STATUSES = {"candidate", "approved", "rejected"}

def collect_boundary(root: Path, project: Path, disposition: Path) -> dict[str, object]:
    """Return a sorted schema-version-1 census without authorizing public API or deletion."""

def validate_boundary(payload: dict[str, object], require_review: bool) -> list[str]:
    """Return stable ordered findings; an empty list is Green."""

def reviewed_content_hash(root: Path, payload: dict[str, object]) -> str:
    """Hash normalized generated facts, diagnostics, compiler interface, and every declaration/consumer file."""
```

Outside consumers must be drawn from current production/test target membership and candidate symbols must come from declarations in Domain, excluding comments and string literals. Mark lexical references as candidates only. Parse the compiler-generated `.swiftinterface` supplied with `--swift-interface` into exact public nominal, extension, initializer, method, subscript, enum-case, property, and typealias signatures. Validation requires a one-to-one mapping between every compiler-public signature and one approved manifest row; it rejects approved rows absent from the interface, incomplete evidence fields, candidate/rejected public signatures, or nonempty Critical/Important review findings. `reviewed_content_hash` includes normalized manifest facts excluding the `review` object, the compiler diagnostics, parsed public interface, and bytes of every Domain declaration and outside-consumer file. Any content change invalidates approval.

Generate `consolidationCandidates` from numbered suffix, compatibility/legacy naming, duplicate nominal declarations, and unusually high file size. The generator records dynamic/persistence/migration/replay/App Intents/widget/share/reflection/fixture/registry signals for every candidate. Set initial deletion authorization to `[]` and consolidation review to `unreviewed`.

- [ ] **Step 4: Run audit unit tests and generate current evidence**

Run:

```bash
python3 -m unittest scripts.tests.test_ambitions_domain_boundary_audit -v
xcodegen generate
python3 scripts/ambitions-source-disposition-audit.py \
  --project Ambitions.xcodeproj \
  --output .codex/architecture/source-disposition.json
python3 scripts/ambitions-domain-boundary-audit.py \
  --project Ambitions.xcodeproj \
  --disposition .codex/architecture/source-disposition.json \
  --output docs/qa/architecture/domain-module-boundary.json
```

Expected: all audit tests pass; the generated manifest has 166 `files` rows, allowed imports only, no deletion authorizations, and review status `unreviewed`.

- [ ] **Step 5: Perform the independent census review gate**

Dispatch a fresh reviewer to compare the generated manifest with recursive source, PBX membership, disposition evidence, LocalRuntimeOS construction references, Codable/schema/migration/replay references, App Intents, widget/share sources, reflection, fixtures, and registries. For each consolidation candidate, record either a proven consolidation path or `retain_unknown` with the blocking evidence. The reviewer must record no source changes and return Critical/Important/Minor findings. Repair Critical and Important findings, regenerate, and repeat review until none remain. Set all four consolidation safety booleans true, `status` to `approved`, and keep `provenCandidatePaths` empty unless all destructive evidence is current and Green. Leave public API `review.status` as `unreviewed`; public-contract approval occurs only after compiler diagnostics in Task 3.

- [ ] **Step 6: Commit the census tooling and evidence**

Run:

```bash
git diff --check -- \
  scripts/ambitions-domain-boundary-audit.py \
  scripts/tests/test_ambitions_domain_boundary_audit.py \
  docs/qa/architecture/domain-module-boundary.json
git add \
  scripts/ambitions-domain-boundary-audit.py \
  scripts/tests/test_ambitions_domain_boundary_audit.py \
  docs/qa/architecture/domain-module-boundary.json
git commit -m "test: add domain boundary census"
```

Expected: one commit containing only census tooling, tests, and current boundary evidence.

---

### Task 2: Establish the uncommitted Domain module RED checkpoint

**Files:**
- Create: `Native/AmbitionsModuleTests/DomainModuleBoundaryTests.swift`
- Modify: `scripts/tests/test_ambitions_build_graph_audit.py`

**Interfaces:**
- Consumes: future module name `AmbitionsDomain` and representative existing types `Step`, `GoalDraft`, `RescheduleEngine`, `AppDrivingProofModeRouter`, and CryptoKit-backed Domain identity behavior selected from the manifest.
- Produces: `DomainModuleBoundaryTests` and graph expectations for `AmbitionsDomain` plus its three consumer edges.

- [ ] **Step 1: Add the missing-module RED suite**

Create `DomainModuleBoundaryTests.swift` beginning with:

```swift
@testable import AmbitionsDomain
import Foundation
import XCTest

final class DomainModuleBoundaryTests: XCTestCase {
    func testRepresentativeValueRoundTripsWithoutChangingIdentity() throws {
        let original = AppDrivingProofModeRouter().route(
            intent: AppDrivingProofModeRouter.certificationExamIntent,
            context: AppDrivingProofModeRouter.protectedTimeHeavyContext
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AppDrivingProofModeRouter.ProofOutput.self, from: data)
        XCTAssertEqual(decoded, original)
    }

    func testRepresentativeTypeIsOwnedByDomainModule() {
        XCTAssertEqual(
            String(reflecting: AppDrivingProofModeRouter.self).split(separator: ".").first,
            "AmbitionsDomain"
        )
    }
}
```

Use the exact router API shown above. Do not add a production initializer or test-only hook for this test.

- [ ] **Step 2: Run the module suite and verify RED**

Run:

```bash
xcodegen generate
bash scripts/ambitions-bounded-xcodebuild.sh --timeout 4m --kill-after 15s -- \
  xcodebuild build-for-testing \
  -project Ambitions.xcodeproj \
  -scheme AmbitionsModuleTests \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath .codex/DerivedData/Ambitions \
  -disableAutomaticPackageResolution \
  -skipPackageUpdates \
  -only-testing:AmbitionsModuleTests/DomainModuleBoundaryTests
```

Expected: fail with `no such module 'AmbitionsDomain'`. Any other failure must be repaired before continuing.

- [ ] **Step 3: Extend graph-audit tests with exact required edges**

Add a fixture assertion requiring:

```python
required_targets=["AmbitionsDomain", "AmbitionsModuleTests", "AmbitionsTimeFoundation"],
required_edges=[
    ("Ambitions", "AmbitionsDomain"),
    ("AmbitionsTests", "AmbitionsDomain"),
    ("AmbitionsModuleTests", "AmbitionsDomain"),
],
```

Expected finding for the pre-extraction fixture:

```text
missing required target: AmbitionsDomain
missing required target edge: Ambitions -> AmbitionsDomain
missing required target edge: AmbitionsModuleTests -> AmbitionsDomain
missing required target edge: AmbitionsTests -> AmbitionsDomain
```

- [ ] **Step 4: Run the Python graph tests**

Run:

```bash
python3 -m unittest scripts.tests.test_ambitions_build_graph_audit -v
```

Expected: all graph-audit tests pass.

- [ ] **Step 5: Preserve the RED checkpoint without committing it**

Run:

Run `git diff --check` and record the missing-module RED output in the task report. Do not stage or commit `DomainModuleBoundaryTests.swift` yet: committing a test that cannot compile would leave `main` unresolved. Task 3 turns this same working-tree RED into Green and includes it in the atomic extraction commit. The graph-audit test remains in the same working tree for the same commit.

---

### Task 3: Extract `AmbitionsDomain` with compiler-reviewed public contracts

**Files:**
- Modify: `project.yml`
- Modify: `Ambitions.xcodeproj/project.pbxproj` by running XcodeGen
- Modify: `docs/qa/architecture/domain-module-boundary.json`
- Modify: exact Domain declaration files listed in approved `publicContracts`
- Modify: exact outside consumer files listed in approved `publicContracts`

**Interfaces:**
- Consumes: reviewed census, module RED test, current Xcode compiler diagnostics, and existing Domain behavior.
- Produces: static target `AmbitionsDomain`, three target edges, recursive single ownership, explicit imports, and a reviewed minimal public contract manifest.

- [ ] **Step 1: Add the static target and recursive exclusion**

Modify `project.yml` so the app source exclusion includes:

```yaml
          - "Core/Domain/**"
```

Add immediately before `AmbitionsTimeFoundation`:

```yaml
  AmbitionsDomain:
    type: framework
    platform: iOS
    deploymentTarget: "26.0"
    sources:
      - path: Native/Ambitions/Core/Domain
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.ambitions.domain
        GENERATE_INFOPLIST_FILE: YES
        MACH_O_TYPE: staticlib
        SKIP_INSTALL: YES
```

Add `- target: AmbitionsDomain` to `Ambitions`, `AmbitionsTests`, and `AmbitionsModuleTests` dependencies. Keep existing Time and package edges unchanged.

- [ ] **Step 2: Regenerate and capture compiler diagnostics without mass edits**

Run:

```bash
xcodegen generate
python3 scripts/ambitions-build-graph-audit.py \
  --project Ambitions.xcodeproj \
  --expected-package-path Packages/AmbitionsDesignSystem \
  --require-target AmbitionsDomain \
  --require-target AmbitionsTimeFoundation \
  --require-target AmbitionsModuleTests \
  --require-edge Ambitions:AmbitionsDomain \
  --require-edge AmbitionsTests:AmbitionsDomain \
  --require-edge AmbitionsModuleTests:AmbitionsDomain
bash scripts/ambitions-bounded-xcodebuild.sh --timeout 8m --kill-after 15s -- \
  xcodebuild build-for-testing \
  -project Ambitions.xcodeproj \
  -scheme AmbitionsUnitTests \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath .codex/DerivedData/Ambitions \
  -disableAutomaticPackageResolution \
  -skipPackageUpdates \
  2>&1 | tee .codex/architecture/domain-extraction-compiler.log
```

Expected: graph audit exits zero. The first build may fail only with missing imports or access-control diagnostics caused by the new boundary; syntax, package, cycle, linker, or unrelated test failures are stop conditions.

- [ ] **Step 3: Refine the public-contract manifest from exact diagnostics**

For each compiler error, add or update one `publicContracts` row with the exact diagnostic, declaration path, consumer target and files, reason, focused coverage, narrower-interface decision, and `candidate` status. Add `import AmbitionsDomain` only to the exact consumer file needing Domain symbols. Reject candidates used only by Domain, only for test convenience, or satisfiable through an already approved facade.

After each batch, run:

```bash
python3 scripts/ambitions-domain-boundary-audit.py \
  --project Ambitions.xcodeproj \
  --disposition .codex/architecture/source-disposition.json \
  --output docs/qa/architecture/domain-module-boundary.json
```

The generator must preserve human review fields while refreshing generated facts. Never use a regex-wide `public` rewrite.

- [ ] **Step 4: Perform the candidate public-API review**

Dispatch a fresh reviewer with the design, manifest, compiler log, and current diff. For every candidate, the reviewer must choose `approved` or `rejected`, verify nested/member access is no broader than the named consumer needs, and report Critical/Important/Minor findings. If the reviewer finds the surface mechanically broad or unstable, revert Task 3 source/config changes, keep the phase Yellow, and redesign the boundary; do not force compilation.

Record candidate decisions in the manifest, but do not stamp the binding review yet because the public compiler interface does not exist until approved access changes are applied.

- [ ] **Step 5: Apply approved access changes and bind review to compiler output**

For each approved candidate, make the nominal declaration and only compiler-required members public. Repeat the bounded application build until it succeeds. Every new diagnostic requires a manifest row and a fresh candidate review. Do not silently widen access.

Generate the compiler interface with the candidate-reviewed access changes present:

```bash
bash scripts/ambitions-bounded-xcodebuild.sh --timeout 6m --kill-after 15s -- \
  xcodebuild build \
  -project Ambitions.xcodeproj \
  -target AmbitionsDomain \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath .codex/DerivedData/Ambitions \
  -disableAutomaticPackageResolution \
  -skipPackageUpdates \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  CODE_SIGNING_ALLOWED=NO
DOMAIN_INTERFACE="$(find .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/AmbitionsDomain.framework/Modules/AmbitionsDomain.swiftmodule -name '*.swiftinterface' -type f | sort | head -1)"
test -f "$DOMAIN_INTERFACE"
```

The reviewer writes `.superpowers/sdd/domain-boundary-public-api-review.md` with `Reviewer: agent-name` as its first line, followed by the reviewed content hash, declaration decisions, and findings. When no Critical or Important findings remain, stamp the manifest with:

```bash
REVIEWER="$(sed -n 's/^Reviewer: //p' .superpowers/sdd/domain-boundary-public-api-review.md | head -1)"
test -n "$REVIEWER"
python3 scripts/ambitions-domain-boundary-audit.py \
  --project Ambitions.xcodeproj \
  --disposition .codex/architecture/source-disposition.json \
  --output docs/qa/architecture/domain-module-boundary.json \
  --swift-interface "$DOMAIN_INTERFACE" \
  --approve-review \
  --reviewer "$REVIEWER" \
  --review-artifact .superpowers/sdd/domain-boundary-public-api-review.md
```

The script must set `review.status` to `approved`, `review.reviewedContentHash` to `reviewed_content_hash(root, payload)` over the current working-tree content, `review.reviewer` to the non-empty argument, and `review.findings` to the review artifact's resolved Critical/Important list, which must be empty. Then run:

```bash
python3 scripts/ambitions-domain-boundary-audit.py \
  --project Ambitions.xcodeproj \
  --disposition .codex/architecture/source-disposition.json \
  --output docs/qa/architecture/domain-module-boundary.json \
  --swift-interface "$DOMAIN_INTERFACE" \
  --validate-only \
  --require-review
```

Expected: exit zero with no findings. Any change to a Domain declaration, consumer file, diagnostic, compiler interface, or contract decision clears `review.status` and `reviewedContentHash`; rerun candidate review, compiler-interface generation, and binding approval before `--require-review` can pass.

Run module proof:

```bash
bash scripts/ambitions-bounded-xcodebuild.sh --timeout 4m --kill-after 15s -- \
  xcodebuild build-for-testing \
  -project Ambitions.xcodeproj \
  -scheme AmbitionsModuleTests \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath .codex/DerivedData/Ambitions \
  -disableAutomaticPackageResolution \
  -skipPackageUpdates \
  -only-testing:AmbitionsModuleTests/DomainModuleBoundaryTests
```

Expected: `** TEST BUILD SUCCEEDED **`.

- [ ] **Step 6: Prove exact production membership**

Regenerate disposition and boundary evidence:

```bash
python3 scripts/ambitions-source-disposition-audit.py \
  --project Ambitions.xcodeproj \
  --output .codex/architecture/source-disposition.json
python3 scripts/ambitions-domain-boundary-audit.py \
  --project Ambitions.xcodeproj \
  --disposition .codex/architecture/source-disposition.json \
  --output docs/qa/architecture/domain-module-boundary.json \
  --swift-interface "$DOMAIN_INTERFACE" \
  --validate-only \
  --require-review
```

Expected: 166 Domain rows; every row has `xcodeTargets: ["AmbitionsDomain"]`; no forbidden imports; no deletion authorizations; no findings.

- [ ] **Step 7: Commit the extraction atomically**

Review `git diff --name-status` and confirm there are no source moves or deletions. Stage only `project.yml`, generated `project.pbxproj`, `DomainModuleBoundaryTests.swift`, `test_ambitions_build_graph_audit.py`, the boundary manifest, exact approved Domain declaration files, and exact consumer import files. Commit:

```bash
git commit -m "build: extract ambitions domain module"
```

Expected: one revertible extraction commit with no behavior change and no unrelated files.

---

### Task 4: Prove Domain behavior, serialization, replay, integration, and Release compilation

**Files:**
- Modify: `Native/AmbitionsModuleTests/DomainModuleBoundaryTests.swift`
- Modify: only existing integration tests selected below if explicit module imports are compiler-required

**Interfaces:**
- Consumes: extracted `AmbitionsDomain` public contracts.
- Produces: deterministic module-only proof plus named application integration and Release proof.

- [ ] **Step 1: Add focused module-only behavior cases**

Extend `DomainModuleBoundaryTests` with the following exact live contracts. `@testable import AmbitionsDomain` permits internal fixture access and must not cause any fixture or helper to become public.

```swift
func testGoalEngineFeedbackAnalysisIsDeterministic() throws {
    let fixture = try XCTUnwrap(GoalEngineFixtures.feedbackFixture(id: "recovery-gentle"))
    let analyzer = GoalEngineFeedbackAnalyzer()
    let first = analyzer.analyze(input: fixture.input)
    let second = analyzer.analyze(input: fixture.input)
    XCTAssertEqual(first, second)
    XCTAssertEqual(first.signals.executionMode, .recovery)
    XCTAssertEqual(first.signals.primaryCauseOfDrift, .oversizedStep)
}

func testRescheduleEngineReturnsTheSameDecisionForTheSameConflict() {
    let timing = GoalTiming(
        tempo: .deadlineBased, timingType: .dueAt, startsOn: nil,
        dueAt: "2026-04-16T18:00:00Z", targetBy: nil,
        windowStart: nil, windowEnd: nil,
        suggestedNextAt: "2026-04-15T13:00:00Z",
        repeatEveryDays: nil, progressReviewCadenceDays: 7
    )
    let input = RescheduleEngineInput(
        stepID: "step-1", timing: timing, feedbackHistory: [], trigger: .delay,
        fallbackMicroStep: "Write one paragraph.",
        now: Date(timeIntervalSince1970: 1_745_798_400)
    )
    let engine = RescheduleEngine()
    XCTAssertEqual(engine.decide(input), engine.decide(input))
}

func testProofModeRouterSelectsStableOutputForStableContext() {
    let router = AppDrivingProofModeRouter()
    let first = router.route(
        intent: AppDrivingProofModeRouter.certificationExamIntent,
        context: AppDrivingProofModeRouter.protectedTimeHeavyContext
    )
    let second = router.route(
        intent: AppDrivingProofModeRouter.certificationExamIntent,
        context: AppDrivingProofModeRouter.protectedTimeHeavyContext
    )
    XCTAssertEqual(first, second)
    XCTAssertEqual(first.plannedMinutes, 15)
}

func testCryptoKitBackedSnapshotIdentitySurvivesEncodingRoundTrip() throws {
    let original = RuntimeSnapshotLedgerEnvelope(
        generatedAt: "2026-06-01T04:00:00Z",
        sourceRecordIDs: ["source-2", "source-1"], receiptIDs: ["receipt-1"],
        replayTraceIDs: ["trace-1"], recommendationInputReferenceIDs: ["recommendation-1"],
        proofInputReferenceIDs: ["proof-1"], afep02LineageReferenceIDs: ["afep02-lineage-1"]
    )
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(RuntimeSnapshotLedgerEnvelope.self, from: data)
    XCTAssertEqual(decoded, original)
    XCTAssertEqual(decoded.checksum, original.checksum)
    XCTAssertTrue(decoded.checksum.hasPrefix("sha256:"))
}
```

Together with the two RED tests from Task 2, this yields six module tests. Each test compares complete Equatable values or stable identifiers; none asserts only non-nil, counts, or absence of crashes. The graph/import audit—not reflected type names—is the proof that no application dependency is transitively exposed.

- [ ] **Step 2: Run module tests**

Run:

```bash
bash scripts/ambitions-bounded-xcodebuild.sh --timeout 4m --kill-after 15s -- \
  xcodebuild test-without-building \
  -project Ambitions.xcodeproj \
  -scheme AmbitionsModuleTests \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath .codex/DerivedData/Ambitions \
  -disableAutomaticPackageResolution \
  -skipPackageUpdates \
  -only-testing:AmbitionsModuleTests/DomainModuleBoundaryTests
```

Expected: six tests, zero failures.

- [ ] **Step 3: Run exact integration classes**

Build the app test bundle once, then run these existing classes without rebuilding:

```bash
bash scripts/ambitions-bounded-xcodebuild.sh --timeout 8m --kill-after 15s -- \
  xcodebuild build-for-testing \
  -project Ambitions.xcodeproj \
  -scheme AmbitionsUnitTests \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath .codex/DerivedData/Ambitions \
  -disableAutomaticPackageResolution \
  -skipPackageUpdates

bash scripts/ambitions-bounded-xcodebuild.sh --timeout 6m --kill-after 15s -- \
  xcodebuild test-without-building \
  -project Ambitions.xcodeproj \
  -scheme AmbitionsUnitTests \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath .codex/DerivedData/Ambitions \
  -disableAutomaticPackageResolution \
  -skipPackageUpdates \
  -only-testing:AmbitionsTests/GoalCreationServiceTests \
  -only-testing:AmbitionsTests/GoalPathCompilerModelsTests \
  -only-testing:AmbitionsTests/RescheduleEngineTests \
  -only-testing:AmbitionsTests/LivingPlanSchemaMigrationTests \
  -only-testing:AmbitionsTests/AmbitionLifecycleGoldenScenarioTests \
  -only-testing:AmbitionsTests/AmbitionsOSProofTrustModelsTests \
  -only-testing:AmbitionsTests/GoalsShellIntegrationTests \
  -only-testing:AmbitionsTests/TimeDurableMutationIntegrationTests
```

Expected: all selected tests pass with zero failures. Record the exact eight class names in the closeout report.

- [ ] **Step 4: Prove Release compilation**

Run:

```bash
bash scripts/ambitions-bounded-xcodebuild.sh --timeout 10m --kill-after 15s -- \
  xcodebuild build \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath .codex/DerivedData/Ambitions \
  -disableAutomaticPackageResolution \
  -skipPackageUpdates \
  CODE_SIGNING_ALLOWED=NO
```

Expected: `** BUILD SUCCEEDED **`, with no test-only import in production and no DEBUG-only public contract required by Release.

- [ ] **Step 5: Run architecture and remediation gates**

Run:

```bash
python3 scripts/ambitions-remediation-governance-check.py
python3 scripts/ambitions-constitution-audit.py
bash scripts/canon-language-drift-scan.sh
python3 scripts/ambitions-truth-path-vocabulary-audit.py
python3 scripts/ambitions-build-graph-audit.py \
  --project Ambitions.xcodeproj \
  --expected-package-path Packages/AmbitionsDesignSystem \
  --require-target AmbitionsDomain \
  --require-target AmbitionsTimeFoundation \
  --require-target AmbitionsModuleTests \
  --require-edge Ambitions:AmbitionsDomain \
  --require-edge AmbitionsTests:AmbitionsDomain \
  --require-edge AmbitionsModuleTests:AmbitionsDomain
git diff --check
```

Expected: remediation, constitution, canon, graph, and diff gates Green. Record truth-path findings exactly and do not claim this phase repaired unrelated pre-existing failures.

- [ ] **Step 6: Independent behavior and API review**

Dispatch a fresh reviewer to inspect the extraction commit, module tests, selected integration output, Release log, public-contract manifest, and source membership. Repair all Critical and Important findings and rerun affected proof.

- [ ] **Step 7: Commit proof additions**

Run:

```bash
git add Native/AmbitionsModuleTests/DomainModuleBoundaryTests.swift
git commit -m "test: prove domain module behavior"
```

Add existing integration test files only if explicit `import AmbitionsDomain` was required. Expected: one focused test/proof commit.

---

### Task 5: Measure throughput and publish current architecture truth

**Files:**
- Modify: `docs/qa/architecture/current-module-graph.json`
- Modify: `docs/qa/architecture/architecture-10-scorecard.json`
- Create: `docs/qa/architecture/domain-module-extraction-report.md`
- Regenerate ignored: `.codex/architecture/source-disposition.json`

**Interfaces:**
- Consumes: Green module/integration/Release proof, benchmark helper, reviewed public API manifest, and generated graph.
- Produces: seven-scenario three-sample benchmark evidence, current graph truth, scorecard claims, closeout, and an explicit Phase 3 go/no-go decision.

- [ ] **Step 1: Verify benchmark identity and single-lane readiness**

Run:

```bash
bash scripts/ambitions-xcode-benchmark.sh --identity
bash scripts/ambitions-xcode-benchmark.sh --status
python3 scripts/ambitions-xcode-lane-lock.py status
```

Expected: package identity status `resolved`, source `workspace-resolved`, `package-resolved`, or `manifest-fallback`; benchmark helper installed; no competing lane owner. An ambiguous or unknown identity blocks timing capture.

- [ ] **Step 2: Capture three warm samples for all seven scenarios**

Use batch `DOMAIN-MODULE-PHASE2` and lanes:

```text
startup-{1,2,3}
domain-build-{1,2,3}
domain-test-{1,2,3}
domain-leaf-{1,2,3}
goal-engine-leaf-{1,2,3}
app-unit-build-{1,2,3}
domain-integration-{1,2,3}
```

Define the exact wrapper once:

```bash
run_lane() {
  local lane="$1"
  shift
  bash scripts/ambitions-xcode-benchmark.sh \
    --batch DOMAIN-MODULE-PHASE2 \
    --lane "$lane" -- "$@"
}
```

Define these executable scenario functions in the same Bash session as `run_lane`:

```bash
bounded() { bash scripts/ambitions-bounded-xcodebuild.sh --timeout 8m --kill-after 15s -- "$@"; }
startup() { bounded xcodebuild -list -project Ambitions.xcodeproj -disableAutomaticPackageResolution -skipPackageUpdates; }
domain_build() { bounded xcodebuild build-for-testing -project Ambitions.xcodeproj -scheme AmbitionsModuleTests -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath .codex/DerivedData/Ambitions -disableAutomaticPackageResolution -skipPackageUpdates -only-testing:AmbitionsModuleTests/DomainModuleBoundaryTests; }
domain_test() { bounded xcodebuild test-without-building -project Ambitions.xcodeproj -scheme AmbitionsModuleTests -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath .codex/DerivedData/Ambitions -disableAutomaticPackageResolution -skipPackageUpdates -only-testing:AmbitionsModuleTests/DomainModuleBoundaryTests; }
domain_leaf_proof() { domain_build && domain_test; }
app_unit_build() { bounded xcodebuild build-for-testing -project Ambitions.xcodeproj -scheme AmbitionsUnitTests -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath .codex/DerivedData/Ambitions -disableAutomaticPackageResolution -skipPackageUpdates; }
domain_integration() { bounded xcodebuild test-without-building -project Ambitions.xcodeproj -scheme AmbitionsUnitTests -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath .codex/DerivedData/Ambitions -disableAutomaticPackageResolution -skipPackageUpdates -only-testing:AmbitionsTests/GoalCreationServiceTests -only-testing:AmbitionsTests/GoalPathCompilerModelsTests -only-testing:AmbitionsTests/RescheduleEngineTests -only-testing:AmbitionsTests/LivingPlanSchemaMigrationTests -only-testing:AmbitionsTests/AmbitionLifecycleGoldenScenarioTests -only-testing:AmbitionsTests/AmbitionsOSProofTrustModelsTests -only-testing:AmbitionsTests/GoalsShellIntegrationTests -only-testing:AmbitionsTests/TimeDurableMutationIntegrationTests; }
export -f bounded startup domain_build domain_test domain_leaf_proof app_unit_build domain_integration

run_lane startup-1 bash -lc startup
run_lane startup-2 bash -lc startup
run_lane startup-3 bash -lc startup
run_lane domain-build-1 bash -lc domain_build
run_lane domain-build-2 bash -lc domain_build
run_lane domain-build-3 bash -lc domain_build
run_lane domain-test-1 bash -lc domain_test
run_lane domain-test-2 bash -lc domain_test
run_lane domain-test-3 bash -lc domain_test
run_lane app-unit-build-1 bash -lc app_unit_build
run_lane app-unit-build-2 bash -lc app_unit_build
run_lane app-unit-build-3 bash -lc app_unit_build
run_lane domain-integration-1 bash -lc domain_integration
run_lane domain-integration-2 bash -lc domain_integration
run_lane domain-integration-3 bash -lc domain_integration
```

For `domain-leaf-1`, use `apply_patch` to add the single comment `// DOMAIN-MODULE-PHASE2 benchmark touch` after the imports in `FixedPoint.swift`, run `run_lane domain-leaf-1 bash -lc domain_leaf_proof`, reverse that exact line with `apply_patch`, and run the first diff check below. Repeat the same add/run/reverse/check sequence for `domain-leaf-2` and `domain-leaf-3`.

For `goal-engine-leaf-1`, add the same single comment after the imports in `GoalEnginePlanner.swift`, run `run_lane goal-engine-leaf-1 bash -lc domain_leaf_proof`, reverse, and check. Repeat for `goal-engine-leaf-2` and `goal-engine-leaf-3`.

The six exact edit-sample invocations are:

```bash
run_lane domain-leaf-1 bash -lc domain_leaf_proof
run_lane domain-leaf-2 bash -lc domain_leaf_proof
run_lane domain-leaf-3 bash -lc domain_leaf_proof
run_lane goal-engine-leaf-1 bash -lc domain_leaf_proof
run_lane goal-engine-leaf-2 bash -lc domain_leaf_proof
run_lane goal-engine-leaf-3 bash -lc domain_leaf_proof
```

After each invocation and reversal, verify:

```bash
git diff --exit-code -- Native/Ambitions/Core/Domain/FixedPoint.swift
git diff --exit-code -- Native/Ambitions/Core/Domain/GoalEngine/GoalEnginePlanner.swift
```

Expected: 21 zero-exit warm samples and both benchmarked files byte-identical to `HEAD` after every sample.

- [ ] **Step 3: Generate the benchmark report and apply thresholds**

Resolve the three JSON files for each scenario by their embedded lane names, then call the live helper once per threshold:

```bash
samples_for() { rg -l "\"lane\": \"$1-[123]\"" .codex/xcode-benchmarks/DOMAIN-MODULE-PHASE2 -g benchmark-summary.json | sort; }
python3 scripts/ambitions-build-benchmark-report.py $(samples_for startup) --target-seconds 15 --output .codex/xcode-benchmarks/DOMAIN-MODULE-PHASE2/startup-report.json
python3 scripts/ambitions-build-benchmark-report.py $(samples_for domain-build) --target-seconds 30 --output .codex/xcode-benchmarks/DOMAIN-MODULE-PHASE2/domain-build-report.json
python3 scripts/ambitions-build-benchmark-report.py $(samples_for domain-test) --target-seconds 30 --output .codex/xcode-benchmarks/DOMAIN-MODULE-PHASE2/domain-test-report.json
python3 scripts/ambitions-build-benchmark-report.py $(samples_for domain-leaf) --target-seconds 60 --output .codex/xcode-benchmarks/DOMAIN-MODULE-PHASE2/domain-leaf-report.json
python3 scripts/ambitions-build-benchmark-report.py $(samples_for goal-engine-leaf) --target-seconds 90 --output .codex/xcode-benchmarks/DOMAIN-MODULE-PHASE2/goal-engine-leaf-report.json
python3 scripts/ambitions-build-benchmark-report.py $(samples_for app-unit-build) --target-seconds 30 --output .codex/xcode-benchmarks/DOMAIN-MODULE-PHASE2/app-unit-build-report.json
python3 scripts/ambitions-build-benchmark-report.py $(samples_for domain-integration) --target-seconds 30 --output .codex/xcode-benchmarks/DOMAIN-MODULE-PHASE2/domain-integration-report.json
```

Each `samples_for` call must return exactly three files. Record medians/worst values and apply exactly:

```text
startup median <= 15 seconds
domain-build median <= 30 seconds
domain-test median <= 30 seconds
domain-leaf median <= 60 seconds
goal-engine-leaf median <= 90 seconds
app-unit-build median <= 30 seconds
domain-integration median <= 30 seconds
```

Any missed threshold makes throughput Yellow and blocks Phase 3 planning, even when correctness proof remains Green.

- [ ] **Step 4: Regenerate current graph and disposition evidence**

Run:

```bash
python3 scripts/ambitions-source-disposition-audit.py \
  --project Ambitions.xcodeproj \
  --output .codex/architecture/source-disposition.json
python3 scripts/ambitions-build-graph-audit.py \
  --project Ambitions.xcodeproj \
  --expected-package-path Packages/AmbitionsDesignSystem \
  --require-target AmbitionsDomain \
  --require-target AmbitionsTimeFoundation \
  --require-target AmbitionsModuleTests \
  --require-edge Ambitions:AmbitionsDomain \
  --require-edge AmbitionsTests:AmbitionsDomain \
  --require-edge AmbitionsModuleTests:AmbitionsDomain \
  --json > .codex/architecture/domain-module-graph.json
```

Update `current-module-graph.json` only from those generated artifacts. It must state 166 Domain sources, exactly one production membership each, zero dependency cycles, the three Domain edges, and the zero-file deletion authorization. Update the scorecard only for newly earned evidence.

- [ ] **Step 5: Write the closeout report and Phase 3 gate**

`domain-module-extraction-report.md` must include:

```text
Final Architecture Tree inspected: yes
Canonical owner touched: Native/Ambitions/Core/Domain
Files moved or created: no production source moved; one module test file created
Old/non-canonical paths removed: none
Compatibility shims left: none
Equivalent folder/path interpretation used: no
Public contracts approved/rejected: exact counts and manifest link
Deletion/consolidation outcomes: exact count; zero unless separately proven
Module, integration, Release, graph, membership, serialization/replay, governance results
Seven benchmark medians, worst samples, thresholds, and artifact roots
Known pre-existing findings and exact non-claims
Phase 3 gate: Green or Blocked with exact failed condition
```

Do not describe overall architecture as Green. This report can mark only the scoped `AmbitionsDomain` extraction Green when every Phase 3 gate passes.

- [ ] **Step 6: Run final independent review and all final gates**

Dispatch a fresh whole-phase reviewer. Repair Critical and Important findings. Then run:

```bash
python3 -m unittest \
  scripts.tests.test_ambitions_domain_boundary_audit \
  scripts.tests.test_ambitions_build_graph_audit \
  scripts.tests.test_ambitions_source_disposition_audit -v
python3 scripts/ambitions-domain-boundary-audit.py \
  --project Ambitions.xcodeproj \
  --disposition .codex/architecture/source-disposition.json \
  --output docs/qa/architecture/domain-module-boundary.json \
  --validate-only \
  --require-review
python3 scripts/ambitions-remediation-governance-check.py
python3 scripts/ambitions-constitution-audit.py
bash scripts/canon-language-drift-scan.sh
python3 scripts/ambitions-truth-path-vocabulary-audit.py
git diff --check
```

Expected: all plan-owned unit, boundary, remediation, constitution, canon, and diff gates Green; unrelated truth-path findings recorded exactly; independent review has no Critical or Important findings.

- [ ] **Step 7: Commit the evidence and stop before Runtime**

Run:

```bash
git add \
  docs/qa/architecture/domain-module-boundary.json \
  docs/qa/architecture/current-module-graph.json \
  docs/qa/architecture/architecture-10-scorecard.json \
  docs/qa/architecture/domain-module-extraction-report.md
git commit -m "docs: prove domain module extraction"
```

Expected: evidence-only commit. Do not begin Runtime source work. If every Phase 3 gate is Green, the next authorized action is a separate Runtime decomposition design and plan based on the resulting compiler graph and API manifest.

---

## Completion Criteria

- `AmbitionsDomain` is a static target containing exactly the 166 recursive Domain Swift files at their canonical paths.
- Each Domain file has exactly one production membership and no forbidden import.
- `Ambitions`, `AmbitionsTests`, and `AmbitionsModuleTests` have explicit edges to `AmbitionsDomain`.
- `AmbitionsDomain` and `AmbitionsTimeFoundation` have no dependency edge in either direction.
- Every public declaration has an approved manifest row tied to exact compiler evidence, consumers, coverage, and narrower-interface review.
- Module-only tests, named integration tests, Debug app build-for-testing, and Release build pass.
- Serialization, migration, replay, proof, receipt, GoalEngine, Reschedule, and proof-mode behavior remain covered.
- The generated graph has zero cycles and all benchmark edits are restored byte-identically.
- Twenty-one warm benchmark samples meet all seven provisional median targets.
- Current graph, scorecard, disposition, boundary manifest, and closeout report agree.
- Independent whole-phase review has no Critical or Important findings.
- Runtime source is untouched and overall architecture remains honestly Yellow pending later phases.

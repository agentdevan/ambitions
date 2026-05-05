# PFC01 Repo And Build System Inventory Report
<!-- markdownlint-disable MD013 -->

Date: 2026-05-05
Result: Green
Train: PFC Platform / Framework / Compliance
Batch: PFC01

## Result

PFC01 completed as a docs-only repo/build inventory. It did not edit app code,
project generation source, workflow files, dependency manifests, signing,
entitlements, generated output, or release/platform claim files.

## Source Truth Used

- `README.md`
- `AGENTS.md`
- `docs/native-build-and-release.md`
- `docs/canon/Ambitions_Platform_Legal_And_Framework_Completion_Plan.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Files Changed

- `docs/codex/batches/PFC01_Repo_And_Build_System_Inventory_Prompt.md`
- `docs/audits/pfc01-repo-build-system-inventory-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Repo Layout Inventory

| Area | Evidence | PFC01 classification |
| --- | --- | --- |
| App source | `Native/Ambitions/**` with App, Domain, Services, Persistence, Runtime, Features, UI, PreviewSupport, AppIntents, Notifications, Integrations, ExternalSnapshots, and Resources. | Source-owned by app architecture; inspect-only in PFC01. |
| App extensions | `Native/AmbitionsWidgetExtension/**` and `Native/AmbitionsShareExtension/**`. | Platform-sensitive; future PFC13-PFC20 owners. |
| Tests | `Native/AmbitionsTests/**` and `Native/AmbitionsUITests/**`. | Existing focused/unit/UI test lanes; future PFC/implementation batches run targeted tests when touching source. |
| Shared packages | `Sources/**` and `AppUI/Sources/**`. | SwiftPM local package surfaces for design system and widget UI. |
| Docs / Codex OS | `docs/**` and `.codex/**`. | Active governance, canon, train, skills, operations, validation, and audit surfaces. |
| Assets | `assets/**` and native asset catalogs under `Native/Ambitions/Resources`. | Product/resource assets; generated icon script exists but not run in PFC01. |
| Local output | `output/**`, `.swiftpm/**`, `Ambitions.xcodeproj/`, and `.DS_Store` observed locally. | Generated/local artifacts; ignored or non-source. |

## Build System Inventory

| Build concern | Current repo evidence | Status |
| --- | --- | --- |
| Project generation | `project.yml` is XcodeGen source truth; README and AGENTS say do not rely on checked-in `.xcodeproj`. | Green. |
| Generated project | `Ambitions.xcodeproj/` exists locally but is ignored by `.gitignore`; not tracked. | Green with local-artifact awareness. |
| App target | `Ambitions` iOS app target, iOS 17, Swift 5.10, bundle id `com.ambitions.ios`. | Green inventory. |
| Extensions | Widget and share extension targets embedded by app target. | Green inventory; future platform proof still required. |
| Tests | `AmbitionsTests` and `AmbitionsUITests` configured in `project.yml` scheme. | Green inventory. |
| Swift package | `Package.swift` defines local `AmbitionsDesignSystem` and `AmbitionsWidgetUI` products. | Green inventory. |
| External dependencies | No remote SwiftPM dependencies in `Package.swift`; local package path in XcodeGen. | Green for PFC01; PFC04 owns supply-chain ledger. |
| Local setup | `scripts/setup_macos_ios_dev.sh`, `Brewfile`, and `docs/native-build-and-release.md`. | Yellow: reproducibility exists but PFC05 owns hardening/proof. |
| Build wrapper | `scripts/build-local.sh` generates project and builds on available iPhone simulator. | Green inventory; not run in docs-only PFC01. |
| Test wrapper | `scripts/test-local.sh` generates project and runs full scheme tests, with known UI-suite caution. | Yellow: broad test command may include known UI debt; focused tests remain preferred. |
| CI | `.github/workflows/ios-validate.yml` regenerates project, resolves packages, builds, runs unit tests, archives unsigned, and runs UI tests. | Green inventory; PFC05 owns reproducibility hardening. |
| Release proof | CI explicitly does not prove signing, TestFlight, App Store Connect, physical-device, or public accessibility conformance. | Green no-claim boundary. |

## Script Inventory

The repo has broad script coverage for build/test, doc QA, batch gates,
boundary checks, product drift, CQS advisory review, SI/DAV/SIG visual gates,
External Brain checks, LDI checks, release claim scans, and tool validation.

Key PFC-relevant scripts:

- `scripts/validate-dev-tools.sh`
- `scripts/setup_macos_ios_dev.sh`
- `scripts/build-local.sh`
- `scripts/test-local.sh`
- `scripts/run-doc-qa.sh`
- `scripts/batch-train-gate-check.sh`
- `scripts/changed-file-boundary-check.sh`
- `scripts/cqs-architecture-boundary-scan.sh`
- `scripts/cqs-prompt-built-smell-scan.sh`
- `scripts/cqs-privacy-security-claim-scan.sh`
- `scripts/cqs-product-drift-scan.sh`
- `scripts/release-claim-safety-scan.sh`
- `scripts/global-order-topology-check.sh`

## Cleanliness Scorecard

| Dimension | Rating | Evidence | Owner / next action |
| --- | --- | --- | --- |
| Build source truth | Green | XcodeGen `project.yml`; generated project ignored. | PFC05 validates reproducible flow. |
| Dependency shape | Green/Yellow | Local SwiftPM products only; no remote package lock observed. | PFC04 creates dependency/license/privacy SDK ledger. |
| CI presence | Green | One macOS GitHub Actions workflow covers generation, build, unit tests, UI tests, unsigned archive. | PFC05 proves parity and failure classification. |
| Local setup docs | Yellow | README, native build doc, setup script, Brewfiles exist. | PFC05 tightens deterministic runbook. |
| Generated artifacts | Yellow | Local ignored `Ambitions.xcodeproj/`, `.swiftpm/`, `output/`, `.DS_Store`. | PFC05/PFC03 document cleanup expectations; no source change in PFC01. |
| Workflow scope | Yellow | CI is present but not audited for current result freshness or local parity. | PFC05. |
| Broad test truth | Yellow | Full wrapper exists, but docs warn known UI smoke debt. | PFC05 and later focused owner batches. |
| Release/platform claims | Green | README and native release doc explicitly bound non-claims. | REC/PFC release gates. |

## Repair Map

| Future batch | Repair / hardening owner |
| --- | --- |
| PFC02 | Architecture boundary and module map, including domain/view/service/package direction and large-file risk. |
| PFC03 | Dead code, prompt artifact, stale generated/local artifact, and naming-smell audit. |
| PFC04 | Dependency, license, lockfile, SDK privacy manifest, Brewfile, and supply-chain ledger. |
| PFC05 | Deterministic local setup, CI/local parity, command freshness, validation result capture, and build/test reproducibility. |

## Non-Claims

PFC01 does not claim:

- build currently passes
- tests currently pass
- CI is currently green
- signed archive readiness
- TestFlight readiness
- App Store readiness
- physical-device proof
- public accessibility conformance
- privacy/legal compliance
- sync/cloud behavior
- monetization readiness

## Validation

Commands required for PFC01:

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/validate-dev-tools.sh || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

Result summary:

- `git status --short`: expected dirty tree before commit.
- `git diff --check`: PASS.
- Touched-doc trailing whitespace scan: PASS.
- `scripts/validate-dev-tools.sh || true`: PASS WITH YELLOW. Required local
  tools were found: `xcodebuild`, `xcode-select`, `xcodegen`, `rg`, `git`,
  `gh`, `jq`, `xcbeautify`, `markdownlint-cli2`, and `lychee`. Optional
  `swiftlint` and `fastlane` are present; optional `swift-format` is absent.
- `scripts/run-doc-qa.sh || true`: PASS WITH ADVISORY. Existing stale-guidance,
  deprecated-language, and markdownlint backlog remains; lychee reports 650 OK
  and 0 errors.
- `scripts/batch-train-gate-check.sh || true`: PASS WITH YELLOW. The only
  current hint is expected dirty-worktree state before commit.
- No build/test command was required because PFC01 is docs-only and touched no
  production code.

## Rollback Path

Revert the PFC01 commit to remove this docs-only inventory, generated prompt,
and associated train-state updates. No app behavior rollback is needed because
PFC01 changes no production code.

## Next Eligible Batch

PFC02 Architecture Boundary And Module Map is the next eligible full-stack batch
under `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md` after PFC01 closes.

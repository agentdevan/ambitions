# PFC04 Dependency And Supply Chain Policy Enforcement Report
<!-- markdownlint-disable MD013 -->

Date: 2026-05-05
Result: Green
Train: PFC Platform / Framework / Compliance
Batch: PFC04

## Result

PFC04 completed as a docs-only dependency and supply-chain audit. It inventories
runtime packages, local tools, workflow actions, privacy manifests,
entitlements, lockfile posture, and review gaps without changing production
Swift, shared packages, tests, previews, project generation, workflows,
dependencies, signing, entitlements, privacy manifests, or generated output.

## Source Truth Used

- `README.md`
- `AGENTS.md`
- `Package.swift`
- `project.yml`
- `.github/workflows/ios-validate.yml`
- `Brewfile`
- `Brewfile.optional-later`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `Native/Ambitions/Support/Ambitions.entitlements`
- `Native/AmbitionsWidgetExtension/AmbitionsWidgetExtension.entitlements`
- `Native/AmbitionsShareExtension/AmbitionsShareExtension.entitlements`
- `docs/canon/Ambitions_3_0_Dependency_Management_Policy.md`
- `docs/canon/Ambitions_3_0_Dependency_Promotion_Ladder.md`
- `docs/audits/pfc01-repo-build-system-inventory-report.md`
- `docs/audits/pfc02-architecture-boundary-module-map-report.md`
- `docs/audits/pfc03-dead-code-prompt-artifact-naming-smell-audit-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Files Changed

- `docs/codex/batches/PFC04_Dependency_And_Supply_Chain_Policy_Enforcement_Prompt.md`
- `docs/audits/pfc04-dependency-supply-chain-policy-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Runtime Dependency Ledger

| Area | Evidence | Classification | Risk |
| --- | --- | --- | --- |
| Swift package dependencies | `Package.swift` defines local products `AmbitionsDesignSystem` and `AmbitionsWidgetUI`; no remote package URLs. | Green | No third-party runtime SPM dependency found. |
| XcodeGen package wiring | `project.yml` references local path package `AmbitionsPackages: path: .`. | Green | Local package only; XcodeGen remains source truth. |
| Lockfiles | No `Package.resolved`, `Podfile.lock`, `Cartfile.resolved`, or `Gemfile.lock` found. | Green/Yellow | Green for no remote runtime packages; Yellow if future remote packages are added without lockfile policy. |
| CocoaPods/Carthage/Gems/Mint | No active Podfile, Cartfile, Gemfile, Mintfile, or corresponding lockfiles found. | Green | No alternate package manager dependency surface found. |
| Runtime SDKs | Search found no active Firebase, Supabase, Sentry, RevenueCat, analytics, remote config, hosted AI API, or backend SDK dependency. | Green | Runtime SDK introduction remains forbidden without dependency proposal. |

## Local Tooling Ledger

| Tool source | Evidence | Classification | Risk / owner |
| --- | --- | --- | --- |
| Required Homebrew tools | `Brewfile` lists `xcodegen`, `ripgrep`, `gh`, `jq`, `xcbeautify`, `markdownlint-cli2`, and `lychee`. | Yellow | Tools are unversioned Homebrew formulas; PFC05 owns deterministic setup tightening. |
| Optional later tools | `Brewfile.optional-later` lists `swiftlint`, `swift-format`, and `fastlane`. | Yellow | Optional only; do not promote until dependency policy and signing/release scope approve. |
| CI install | `.github/workflows/ios-validate.yml` installs `xcodegen` with Homebrew. | Yellow | CI tool version is not pinned; PFC05 owns reproducibility. |

## Workflow And Action Ledger

| Workflow dependency | Evidence | Classification | Risk / owner |
| --- | --- | --- | --- |
| GitHub checkout action | `.github/workflows/ios-validate.yml` uses `actions/checkout@v4`. | Yellow | Major-version tag, not commit SHA. PFC05/CI security owner may pin SHAs. |
| GitHub artifact action | `.github/workflows/ios-validate.yml` uses `actions/upload-artifact@v4`. | Yellow | Major-version tag, not commit SHA. PFC05/CI security owner may pin SHAs. |
| macOS runner | Workflow uses `macos-15`. | Yellow | Hosted runner image can drift; PFC05 owns deterministic local/CI parity. |
| Unsigned archive/IPA packaging | Workflow explicitly documents unsigned artifact limits. | Green | No signing, TestFlight, App Store, or installability claim is made. |

## Privacy Manifest And Entitlement Ledger

| Surface | Evidence | Classification | Risk / owner |
| --- | --- | --- | --- |
| App privacy manifest | `Native/Ambitions/Resources/PrivacyInfo.xcprivacy` declares no tracking, no collected data types, and no accessed API types. | Yellow | PFC24/PFC25 must reconcile privacy labels and required-reason API declarations before release claims. |
| Required-reason quick scan | Read-only scan found `FileManager` path/temp-directory usage but no direct `UserDefaults`, file timestamp, disk-space, active keyboard, or system boot-time API matches in the sampled active roots. | Yellow | This is not final App Store privacy proof; PFC25 owns authoritative API review. |
| App group entitlement | App, widget extension, and share extension all use `group.com.ambitions.shared`. | Yellow | PFC12 owns shared-storage privacy map and App Group data minimization proof. |
| Signing/provisioning | No signing/provisioning change made by PFC04. | Green | Human/developer-account proof remains gated. |

## License And Policy Ledger

| Item | Evidence | Classification | Risk / owner |
| --- | --- | --- | --- |
| Repo license file | No top-level `LICENSE` or `NOTICE` file found in the initial file inventory. | Yellow | Legal/business owner should decide repo licensing or private-repo posture; do not infer public license. |
| Third-party license inventory | No third-party runtime package found, but workflow actions and Homebrew tools are external dependencies. | Yellow | PFC05/PFC39 can attach external tool/action license/review notes if required for handoff. |
| Dependency promotion policy | `Ambitions_3_0_Dependency_Management_Policy.md` and `Ambitions_3_0_Dependency_Promotion_Ladder.md` exist. | Green | Future dependencies must route through policy before implementation. |

## Supply-Chain Enforcement Rules For Later Batches

- Do not add runtime dependencies without an approved dependency proposal,
  license/privacy/security review, and focused validation.
- Do not add analytics, hosted AI, backend, crash reporting, remote config,
  monetization, or tracking SDKs by implication.
- Do not edit workflows, signing, entitlements, project generation, privacy
  manifests, or lockfiles outside their named PFC owner batch.
- Pinning GitHub Actions and tool versions is a PFC05/CI reproducibility owner
  decision, not an ad hoc edit.
- Privacy manifest and App Privacy Labels cannot be claimed accurate until
  PFC24/PFC25 complete with evidence.
- App Group shared storage must be mapped before widget/share/Live Activity
  data exposure claims change.

## Non-Claims

PFC04 does not claim legal compliance, privacy compliance, App Store readiness,
TestFlight readiness, public accessibility conformance, device proof, signed
archive readiness, supply-chain perfection, or FAANG handoff readiness. It
creates the current dependency and supply-chain ledger and assigns remaining
review work.

## Validation

Commands required for PFC04:

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/cqs-privacy-security-claim-scan.sh . || true`
- `rg --files | rg 'Package.resolved|Podfile.lock|Cartfile.resolved|Gemfile.lock|PrivacyInfo.xcprivacy|entitlements' || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

Result summary:

- `git status --short`: expected dirty tree before commit.
- `git diff --check`: PASS.
- Touched-doc trailing whitespace scan: PASS.
- `scripts/cqs-privacy-security-claim-scan.sh . || true`: PASS WITH YELLOW. Existing docs/scripts contain guardrail terms and release-claim scan patterns; no new secret or unsupported product claim was introduced by PFC04.
- Lockfile/privacy/entitlement inventory: PASS WITH YELLOW. The only privacy manifest found is `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`; app/widget/share entitlements use the shared app group; no remote package lockfile was found.
- `scripts/run-doc-qa.sh || true`: PASS WITH ADVISORY. Existing stale-guidance, deprecated-language, and markdownlint backlog remains; lychee reports no link errors.
- `scripts/batch-train-gate-check.sh || true`: PASS WITH YELLOW. The only current hint is expected dirty-worktree state before commit.
- No build/test command was required because PFC04 is docs-only and touched no
  production code or config.

## Rollback Path

Revert the PFC04 commit to remove this docs-only dependency ledger, generated
prompt, and associated train-state updates. No app behavior rollback is needed
because PFC04 changes no production code or dependency/config files.

## Next Eligible Batch

PFC05 CI / Local Toolchain Reproducibility is the next eligible full-stack batch
under `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md` after PFC04 closes.

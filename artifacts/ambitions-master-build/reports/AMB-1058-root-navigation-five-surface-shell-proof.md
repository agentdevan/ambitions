# AMB-1058 Root Navigation Five-surface Shell Proof

Ambitions Master Build train closeout

Linear project: Ambitions Personal Life OS Runtime + Native iPhone App Master Build Program (`ca716546-e3d4-4d5b-a399-03076ccba9ee`)

Linear issue: `AMB-1058`

Train label: `M04.T01`

Parent or umbrella issue: `AMB-1046`

Green/Yellow/Red status: Green for the focused AMB-1058 root navigation architecture source/control-plane scope; source/control-plane commit `efd6957c9022f66f3316d06e9862c92a61832990` is pushed and remote-verified on `origin/main`. Closeout metadata and proof-index reconciliation are in progress and will be recorded in follow-up metadata commits before Linear Done.

Pushed to main: yes; source/control-plane commit `efd6957c9022f66f3316d06e9862c92a61832990` is pushed and remote-verified.

Push hash: `efd6957c9022f66f3316d06e9862c92a61832990`

Closeout metadata hash: pending until metadata commit is pushed and remote-verified.

Final reconciliation hash: pending until proof-index reconciliation is pushed and remote-verified.

App source changed: yes

Runtime behavior changed: yes, root navigation behavior changed by removing `capture` as an `AppTab` enum case/raw root tab, keeping `AppTab.allCases` limited to Today / Goals / Time / Motion / You, routing legacy Capture inputs through Today/global Capture overlay or capture-inbox compatibility, preserving Motion as the fifth root surface, preserving Plan as Time compatibility only, and adding shell-owned top-clearance geometry so root content is not pulled under top chrome.

Linear identifiers used: AMB issue identifiers only

Files changed:
- `Native/Ambitions/App/AppTab.swift` - removes `capture` as a root enum case/raw tab, keeps canonical root cases to Today / Goals / Time / Motion / You, maps legacy Capture to Today compatibility, maps Pulse to Motion compatibility, maps Plan to Time compatibility, and keeps Capture icon metadata separate from root tab identity.
- `Native/Ambitions/App/AppNavigation.swift` - removes stale `.capture` tab switching/reset handling while preserving global Capture overlay routing.
- `Native/Ambitions/App/AppExternalRouting.swift` - removes `.openTab(.capture)` generation/dispatch branches and leaves Capture compatibility on `captureInbox` / global overlay paths.
- `Native/Ambitions/App/ShellCommandModels.swift` - removes Capture root-tab toolbar handling and centralizes the global Capture action icon/accessibility metadata.
- `Native/Ambitions/App/ShellCommandRouter.swift` - removes `.tab(.capture)` routing and leaves Capture to explicit overlay/inbox destinations.
- `Native/Ambitions/App/AppShellView.swift` - adds `AppShellGeometry` and shell-owned top content clearance to avoid unsafe top-header overlap.
- `Native/Ambitions/App/AmbitionsRootView.swift` - reserves Today root top clearance through the app-shell owner.
- `Native/Ambitions/Features/Onboarding/ProgressiveIntelligenceOnboarding.swift` - routes capture-first onboarding to Today plus quick Capture overlay, not a Capture tab.
- `Native/Ambitions/Features/Shared/DegradedStateOrchestrator.swift` - uses global Capture icon metadata for the Capture action.
- `Native/Ambitions/PreviewSupport/ToolbarPreviewCatalog.swift` - removes unreachable Capture root primary-object branch.
- Focused app/runtime tests under `Native/AmbitionsTests/App/` and `Native/AmbitionsTests/Runtime/GoldenVerticalSliceRuntimeTests.swift` - assert the five root surfaces, nil raw Capture tab, legacy Capture/Pulse/Plan compatibility routes, global Capture overlay behavior, launch-surface normalization, and shell top-clearance behavior.
- `scripts/codex/amb-master-canon-ia-validate.py` - repairs stale AMB master canon validator expectations so Capture compatibility is checked through raw-value rejection, Today fallback, and capture-inbox/global overlay routing rather than the removed `AppTab.capture` enum case.
- `artifacts/ambitions-master-build/validation/AMB-1058-parallel-guard-prompt.md` - records the AMB-1058 source-changing guard prompt.
- `build/reports/parallel-implementation-guard/AMB-1058-pre.md` and `.json` - records pre-change parallel guard Green evidence.
- `build/reports/parallel-implementation-guard/AMB-1058-post.md` and `.json` - records post-change parallel guard Green evidence.
- `artifacts/ambitions-master-build/validation/AMB-1058/focused-root-shell-tests.log` - records focused XCTest output after the guard-compliant repair.
- `artifacts/ambitions-master-build/screenshots/AMB-1058/root-shell-*.png` and launch logs - records current root-shell screenshots for Today, Goals, Time, Motion, and You.

Validation run:
- `xcodegen generate` - pass; generated project successfully.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-1058 --prompt artifacts/ambitions-master-build/validation/AMB-1058-parallel-guard-prompt.md --batch-type source-changing` - Green; `build/reports/parallel-implementation-guard/AMB-1058-pre.md`.
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8' -derivedDataPath /Users/devan/Documents/GitHub/ambitions-local-bulk-20260614T1518/DerivedData-AMB1058 -only-testing:AmbitionsTests/AppShellNavigationTests -only-testing:AmbitionsTests/ExternalRoutingTests -only-testing:AmbitionsTests/ShellCommandRouterTests -only-testing:AmbitionsTests/OnboardingAndDegradedStateTests -only-testing:AmbitionsTests/ActivationContractTests -only-testing:AmbitionsTests/ShellPreviewMatrixTests -only-testing:AmbitionsTests/GoldenVerticalSliceRuntimeTests -enableCodeCoverage NO` - pass; 133 selected tests with 0 failures; `artifacts/ambitions-master-build/validation/AMB-1058/focused-root-shell-tests.log`; `.xcresult` at `/Users/devan/Documents/GitHub/ambitions-local-bulk-20260614T1518/DerivedData-AMB1058/Logs/Test/Test-Ambitions-2026.06.15_00-32-20--0400.xcresult`.
- Visual screenshot capture and visual inspection for Today, Goals, Time, Motion, and You - pass for scoped root-shell contract; screenshots under `artifacts/ambitions-master-build/screenshots/AMB-1058/`.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-1058 --prompt artifacts/ambitions-master-build/validation/AMB-1058-parallel-guard-prompt.md --changed-from d3a3560a19c364c20e775cc499f887620b9537e3 --batch-type source-changing` - Green; no duplicate risks, no supersession updates required, no runtime wiring gaps, no old-term violations, no locked concepts touched; `build/reports/parallel-implementation-guard/AMB-1058-post.md`.
- `python3 scripts/codex/amb-master-canon-ia-validate.py` - pass after stale validator repair; Capture raw root tab remains rejected and legacy Capture compatibility maps to Today / capture-inbox overlay paths.
- `git diff --check` - pass before source/control-plane commit.
- `git diff --cached --check` - pass after normalizing the focused XCTest log trailing whitespace.
- `bash scripts/codex/program-preflight.sh amb-master` - Green on clean source/control-plane commit `efd6957c9022f66f3316d06e9862c92a61832990`; `artifacts/ambitions-master-build/script-output/program-preflight-20260615T004417.log`.
- `bash scripts/codex/program-phase-gate.sh amb-master M04` - pass on clean source/control-plane commit `efd6957c9022f66f3316d06e9862c92a61832990`; `artifacts/ambitions-master-build/script-output/program-phase-gate-M04-20260615T004417.log`.
- `git push origin main` - pushed source/control-plane commit `efd6957c9022f66f3316d06e9862c92a61832990`.
- `git rev-parse HEAD` and `git ls-remote origin refs/heads/main` - local HEAD and `origin/main` both returned `efd6957c9022f66f3316d06e9862c92a61832990` after source/control-plane push.
- `python3 -m json.tool artifacts/ambitions-master-build/AMB_MASTER_EXECUTION_QUEUE.json`, `python3 -m json.tool artifacts/ambitions-master-build/AMB_MASTER_LINEAR_ISSUE_MAP.json`, and `python3 -m json.tool artifacts/ambitions-master-build/validation/AMB-1058-validation.json` - pass after closeout metadata updates.
- `python3 scripts/codex/linear-closeout-validate.py --program amb-master --scope child artifacts/ambitions-master-build/reports/AMB-1058-root-navigation-five-surface-shell-proof.md` - pass after closeout metadata updates.
- `python3 scripts/codex/amb-master-readiness-validate.py --phase M04` - pass after advancing next train to AMB-1059.
- `python3 scripts/codex/amb-master-repository-wiring-validate.py` - pass after updating the program registry and repository wiring validator to expect AMB-1059 as the next runnable gate.
- `bash scripts/codex/program-phase-gate.sh amb-master M04` - pass after closeout metadata updates; local ignored log `artifacts/ambitions-master-build/script-output/program-phase-gate-M04-20260615T005000.log`.
- `bash scripts/codex/program-preflight.sh amb-master` - Green after closeout metadata updates; local ignored log `artifacts/ambitions-master-build/script-output/program-preflight-20260615T005012.log`.
- `bash scripts/release-claim-safety-scan.sh` - Green; local ignored log `artifacts/ambitions-master-build/script-output/AMB-1058-release-claim-safety-scan.log`.
- `bash scripts/no-unsupported-ai-claim-scan.sh` - Yellow advisory only; local ignored log `artifacts/ambitions-master-build/script-output/AMB-1058-no-unsupported-ai-claim-scan.log`.
- `bash scripts/sa-no-claim-scan.sh` - pass with no output; local ignored log `artifacts/ambitions-master-build/script-output/AMB-1058-sa-no-claim-scan.log`.
- `bash scripts/privacy-boundary-scan.sh` - Yellow advisory on existing privacy/local-first/control-plane/proof-ledger terminology; local ignored log `artifacts/ambitions-master-build/script-output/AMB-1058-privacy-boundary-scan.log`.
- `git diff --check` - pass after closeout metadata updates.

Reviewer passes:
- Deterministic pre/post parallel implementation guard passed Green.
- Main agent visually inspected current screenshot artifacts. No separate read-only reviewer produced source edits for this focused root-shell train.

Proof artifacts:
- `artifacts/ambitions-master-build/validation/AMB-1058-validation.json`
- `artifacts/ambitions-master-build/validation/AMB-1058-parallel-guard-prompt.md`
- `artifacts/ambitions-master-build/validation/AMB-1058/focused-root-shell-tests.log`
- `artifacts/ambitions-master-build/screenshots/AMB-1058/root-shell-today.png`
- `artifacts/ambitions-master-build/screenshots/AMB-1058/root-shell-goals.png`
- `artifacts/ambitions-master-build/screenshots/AMB-1058/root-shell-time.png`
- `artifacts/ambitions-master-build/screenshots/AMB-1058/root-shell-motion.png`
- `artifacts/ambitions-master-build/screenshots/AMB-1058/root-shell-you.png`
- `build/reports/parallel-implementation-guard/AMB-1058-pre.md`
- `build/reports/parallel-implementation-guard/AMB-1058-post.md`
- `artifacts/ambitions-master-build/script-output/program-preflight-20260615T004417.log`
- `artifacts/ambitions-master-build/script-output/program-phase-gate-M04-20260615T004417.log`
- `artifacts/ambitions-master-build/script-output/program-preflight-20260615T005012.log` - local ignored script output.
- `artifacts/ambitions-master-build/script-output/program-phase-gate-M04-20260615T005000.log` - local ignored script output.
- `artifacts/ambitions-master-build/script-output/AMB-1058-release-claim-safety-scan.log` - local ignored script output.
- `artifacts/ambitions-master-build/script-output/AMB-1058-no-unsupported-ai-claim-scan.log` - local ignored script output.
- `artifacts/ambitions-master-build/script-output/AMB-1058-sa-no-claim-scan.log` - local ignored script output.
- `artifacts/ambitions-master-build/script-output/AMB-1058-privacy-boundary-scan.log` - local ignored script output.

Red blockers: none

Yellow limits:
- AMB-1058 proves root navigation architecture and shell behavior only; it does not complete broad feature behavior inside Today, Goals, Time, Motion, or You.
- Screenshot proof was visually evaluated for the root-shell contract; it is not full visual approval for every body fixture. The Goals body fixture remains dense/truncated in screenshot context and is not claimed as final Goals surface polish.
- Source-level and focused test coverage exists for root IA, Capture compatibility, stale-root regression, and shell clearance; public accessibility certification, physical-device proof, measured performance proof, privacy/legal approval, external security audit approval, release readiness, TestFlight readiness, and App Store readiness are not claimed.
- `AppTab.capture.systemImage` remains as metadata-only compatibility for existing Capture icon references in locked feature owners. It is not an `AppTab` case, not a raw-value root tab, and not a route target.
- `bash scripts/no-unsupported-ai-claim-scan.sh` and `bash scripts/privacy-boundary-scan.sh` completed as advisory scans; they do not prove privacy/legal approval, external security review, or release readiness.

Owner approval claimed: no

Release/TestFlight/App Store readiness claimed: no

Accessibility certification claimed: no

Privacy/legal approval claimed: no

Rollback:
- Revert source/control-plane commit `efd6957c9022f66f3316d06e9862c92a61832990` and follow-up AMB-1058 metadata/proof-index commits if root navigation regresses or stale IA reappears.

Linear reconciliation:
- AMB-1058 source-push issue comment: `14edf5ca-bde7-4caa-aa6a-615abe883ed8`.
- AMB-1058 source-push project comment: `28c1c493-4209-4c1a-9b41-5068ef09f5db`.
- AMB-1058 project status update: `5fbf9688-4367-4ef2-bcf8-7e1fb13d1154`.
- AMB-1058 Done transition: pending closeout metadata and proof-index reconciliation.

Next train: `AMB-1059` / `M04.T02`

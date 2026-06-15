# AMB-1115 First-run Activation Runtime

Ambitions Master Build train closeout

Linear project: Ambitions Personal Life OS Runtime + Native iPhone App Master Build Program (`ca716546-e3d4-4d5b-a399-03076ccba9ee`)

Linear issue: `AMB-1115`

Train label: `M03.T02`

Parent or umbrella issue: `AMB-1114`

Green/Yellow/Red status: Green for the focused AMB-1115 First-run Activation runtime source scope; source/control-plane commit `7ea6a1de182443d87f02898a2510fc2f251ac08c` is pushed and remote-verified; closeout metadata and final Linear Done reconciliation are in progress.

Pushed to main: yes; source/control-plane commit `7ea6a1de182443d87f02898a2510fc2f251ac08c` is pushed and remote-verified.

Push hash: `7ea6a1de182443d87f02898a2510fc2f251ac08c`

Closeout metadata hash: pending

Final reconciliation hash: pending

App source changed: yes

Runtime behavior changed: yes, a local deterministic First-run Activation runtime now evaluates the AMB-1114 golden vertical slice into a first goal, first Recommended step, first recovery option, activation receipt, replay evidence, You / What Ambitions knows inspection route, active five-tab IA, and global Capture role. It fails closed when the golden slice is not ready, the first-goal flow is not selected, the Recommended step or recovery option is missing, generic onboarding theater appears, calm continuity is missing, receipt/replay/inspection proof is absent, or the activation boundary is not local-only.

Linear identifiers used: AMB issue identifiers only

Files changed:
- `Native/Ambitions/Runtime/FirstRunActivationRuntime.swift` - adds the local first-run activation value model, issue taxonomy, activation receipt, receipt/replay/inspection checks, and fail-closed runtime evaluator.
- `Native/AmbitionsTests/Runtime/GoldenVerticalSliceRuntimeTests.swift` - covers ready activation tied to first goal, Recommended step, recovery option, SourceRecord, Receipt, ReplayTrace, You inspection route, five-tab IA, and global Capture role; adds fail-closed tests for generic onboarding theater, unready golden program, and non-first-goal entry.
- `artifacts/ambitions-master-build/validation/AMB-1115-parallel-guard-prompt.md` - records the AMB-1115 source-changing guard prompt.
- `docs/codex/concept-lock-registry.yml` - adds AMB-1115 to the locked runtime recommendation compiler and proof/receipt/replay allowlists without weakening those locks.
- `docs/codex/existing-code-champion-coverage.yml` - classifies `FirstRunActivationRuntime.swift` and extends Golden Vertical Slice test ownership evidence for AMB-1115.
- `build/reports/intelligence-consolidation/champion-coverage-check.json` - records updated champion coverage count.
- `build/reports/intelligence-consolidation/champion-coverage-check.md` - records updated champion coverage count.
- `artifacts/ambitions-master-build/validation/AMB-1115-validation.json` - records AMB-1115 validation evidence.
- `artifacts/ambitions-master-build/reports/AMB-1115-first-run-activation-runtime.md` - records this closeout.
- AMB master run-state, queue, issue map, program registry, validators, proof ledger, and proof index artifacts - advance the next train from AMB-1115/M03.T02 to AMB-1058/M04.T01 after metadata validation.

Validation run:
- `xcodegen generate` - pass.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-1115 --prompt artifacts/ambitions-master-build/validation/AMB-1115-parallel-guard-prompt.md --batch-type source-changing` - Green after adding AMB-1115 to the locked runtime recommendation compiler and proof/receipt/replay allowlists; `build/reports/parallel-implementation-guard/AMB-1115-pre.md`.
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8' -derivedDataPath /Users/devan/Documents/GitHub/ambitions-local-bulk-20260614T1518/DerivedData-AMB1115 -only-testing:AmbitionsTests/GoldenVerticalSliceRuntimeTests -enableCodeCoverage NO` - pass; 8 tests with 0 failures; `artifacts/ambitions-master-build/validation/AMB-1115/focused-first-run-activation-tests.log`.
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8' -derivedDataPath /Users/devan/Documents/GitHub/ambitions-local-bulk-20260614T1518/DerivedData-AMB1115 -only-testing:AmbitionsTests/ActivationContractTests -only-testing:AmbitionsTests/OnboardingAndDegradedStateTests -only-testing:AmbitionsTests/StepQualityFirewallTests -only-testing:AmbitionsTests/StepElasticityEngineTests -only-testing:AmbitionsTests/ScheduleInstallKernelTests -only-testing:AmbitionsTests/GoldenVerticalSliceRuntimeTests -enableCodeCoverage NO` - pass; 41 tests with 0 failures; `artifacts/ambitions-master-build/validation/AMB-1115/adjacent-first-run-activation-tests.log`.
- `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-1115` - Green after classifying the new runtime owner; `build/reports/intelligence-consolidation/champion-coverage-check.md`.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-1115 --prompt artifacts/ambitions-master-build/validation/AMB-1115-parallel-guard-prompt.md --changed-from 7506ef4ba985259bb1f3ef19978186855d167b6b --batch-type source-changing` - Green; `build/reports/parallel-implementation-guard/AMB-1115-post.md`.
- `bash scripts/codex/program-preflight.sh amb-master` - Red while source paths were dirty, as expected before commit; `artifacts/ambitions-master-build/script-output/AMB-1115-program-preflight.log`.
- `bash scripts/codex/program-phase-gate.sh amb-master M03` - pass; `artifacts/ambitions-master-build/script-output/AMB-1115-program-phase-gate-M03.log`.
- `python3 scripts/codex/amb-master-readiness-validate.py --phase M03` - pass; `artifacts/ambitions-master-build/script-output/AMB-1115-amb-master-readiness-validate.log`.
- `python3 scripts/codex/amb-master-repository-wiring-validate.py` - pass; `artifacts/ambitions-master-build/script-output/AMB-1115-repository-wiring-validate.log`.
- `python3 scripts/codex/source-atlas-readiness-validate.py` - pass; `artifacts/ambitions-master-build/script-output/AMB-1115-source-atlas-readiness-validate.log`.
- `bash scripts/release-claim-safety-scan.sh` - Green after clarifying one scanner-sensitive false-positive test fixture line as a non-claim; `artifacts/ambitions-master-build/script-output/AMB-1115-release-claim-safety-scan-rerun.log`.
- `bash scripts/no-unsupported-ai-claim-scan.sh` - Yellow advisory only on the same explicit non-claim test fixture line; `artifacts/ambitions-master-build/script-output/AMB-1115-no-unsupported-ai-claim-scan-rerun.log`.
- `bash scripts/sa-no-claim-scan.sh` - pass; `artifacts/ambitions-master-build/script-output/AMB-1115-sa-no-claim-scan-rerun.log`.
- `bash scripts/privacy-boundary-scan.sh` - Yellow advisory on existing recommendation/inference terminology in registry files; `artifacts/ambitions-master-build/script-output/AMB-1115-privacy-boundary-scan.log`.
- `git diff --check` - pass.
- `git diff --cached --check` - pass before source/control-plane commit.
- `git commit -m "AMB-1115 implement first-run activation runtime"` - created source/control-plane commit `7ea6a1de182443d87f02898a2510fc2f251ac08c`.
- `scripts/codex/program-preflight.sh amb-master` - Green on committed source/control-plane SHA `7ea6a1de182443d87f02898a2510fc2f251ac08c`; `artifacts/ambitions-master-build/script-output/program-preflight-20260614T232030.log`.
- `scripts/codex/program-phase-gate.sh amb-master M03` - pass on committed source/control-plane SHA `7ea6a1de182443d87f02898a2510fc2f251ac08c`; `artifacts/ambitions-master-build/script-output/program-phase-gate-M03-20260614T232030.log`.
- `git push origin main` - pushed source/control-plane commit `7ea6a1de182443d87f02898a2510fc2f251ac08c`.
- `git rev-parse HEAD` and `git ls-remote origin refs/heads/main` - local HEAD and `origin/main` both returned `7ea6a1de182443d87f02898a2510fc2f251ac08c` after source/control-plane push.
- `bash scripts/codex/program-proof-index.sh amb-master` - pass after AMB-1115 proof-ledger entry and M04 queue/map advance; latest rerun `artifacts/ambitions-master-build/script-output/program-proof-index-20260614T232924.log`.
- `python3 -m json.tool artifacts/proof-ledger/proof-index.json && python3 -m json.tool artifacts/ambitions-master-build/validation/AMB-1115-validation.json && python3 -m json.tool artifacts/ambitions-master-build/AMB_MASTER_EXECUTION_QUEUE.json && python3 -m json.tool artifacts/ambitions-master-build/AMB_MASTER_LINEAR_ISSUE_MAP.json` - pass after metadata advance.
- `python3 scripts/codex/linear-closeout-validate.py --program amb-master --scope child artifacts/ambitions-master-build/reports/AMB-1115-first-run-activation-runtime.md` - pass after metadata advance.
- `python3 scripts/codex/amb-master-readiness-validate.py --phase M03` - pass after metadata advance.
- `python3 scripts/codex/amb-master-repository-wiring-validate.py` - pass after metadata advance; validator now expects `AMB-1058` as next issue.
- `bash scripts/release-claim-safety-scan.sh` - Green after metadata advance.
- `bash scripts/no-unsupported-ai-claim-scan.sh` - Yellow advisory after metadata advance; no blocking unsupported-AI claim accepted.
- `bash scripts/sa-no-claim-scan.sh` - pass after metadata advance.
- `bash scripts/privacy-boundary-scan.sh` - Yellow advisory after metadata advance; advisory hits are not privacy/legal approval proof.
- `bash scripts/codex/program-phase-gate.sh amb-master M04` - pass after queue/map next-train advance; `artifacts/ambitions-master-build/script-output/program-phase-gate-M04-20260614T232803.log`.
- `git diff --check` - pass after metadata advance.

Reviewer passes:
- Deterministic guard pass via pre/post parallel implementation guard; no separate read-only reviewer produced source edits.

Proof artifacts:
- `artifacts/ambitions-master-build/validation/AMB-1115-validation.json`
- `artifacts/ambitions-master-build/validation/AMB-1115-parallel-guard-prompt.md`
- `artifacts/ambitions-master-build/validation/AMB-1115/focused-first-run-activation-tests.log`
- `artifacts/ambitions-master-build/validation/AMB-1115/adjacent-first-run-activation-tests.log`
- `artifacts/ambitions-master-build/script-output/program-preflight-20260614T232030.log`
- `artifacts/ambitions-master-build/script-output/program-phase-gate-M03-20260614T232030.log`
- `artifacts/ambitions-master-build/script-output/program-proof-index-20260614T232924.log`
- `artifacts/ambitions-master-build/script-output/program-phase-gate-M04-20260614T232803.log`
- `artifacts/ambitions-master-build/script-output/AMB-1115-release-claim-safety-scan-rerun.log`
- `artifacts/ambitions-master-build/script-output/AMB-1115-no-unsupported-ai-claim-scan-rerun.log`
- `artifacts/ambitions-master-build/script-output/AMB-1115-sa-no-claim-scan-rerun.log`
- `artifacts/ambitions-master-build/script-output/AMB-1115-privacy-boundary-scan.log`
- `build/reports/intelligence-consolidation/champion-coverage-check.md`
- `build/reports/parallel-implementation-guard/AMB-1115-pre.md`
- `build/reports/parallel-implementation-guard/AMB-1115-post.md`
- `artifacts/proof-ledger/PROOF_LEDGER.md`
- `artifacts/proof-ledger/proof-index.json`

Red blockers: none

Yellow limits:
- AMB-1115 adds local First-run Activation runtime value-model proof and tests only; no user-facing UI or visual screenshot approval is claimed.
- Activation receipt proof is deterministic fixture proof tied to the AMB-1114 golden music-release slice, not private user data.
- No persistence mutation, Calendar/EventKit integration, notification scheduling, visible Time UI, visible Step launch, Source Atlas/R2 publication, live source-pack download, or autonomous mutation is claimed.
- `bash scripts/no-unsupported-ai-claim-scan.sh` and `bash scripts/privacy-boundary-scan.sh` completed as advisory scans; they do not prove privacy/legal approval or external security review.
- Physical-device, performance, release, TestFlight, App Store, owner approval, accessibility certification, privacy/legal approval, and external security audit approval were not in scope and are not claimed.

Owner approval claimed: no

Release/TestFlight/App Store readiness claimed: no

Accessibility certification claimed: no

Privacy/legal approval claimed: no

Rollback:
- Revert source/control-plane commit `7ea6a1de182443d87f02898a2510fc2f251ac08c` and the follow-up AMB-1115 closeout metadata commit if the train must be backed out.

Linear reconciliation:
- AMB-1115 progress issue comment: `9bbaa9d7-79f7-43c2-a79d-cbea58fb1be0`.
- AMB-1115 progress project comment: `3aee4a01-e8fb-440c-8ec4-bb509f11ab99`.
- AMB-1115 source-push issue comment: `63bd19b1-dadf-4b86-a5fb-11eeba9ea963`.
- AMB-1115 source-push project comment: `3f432d84-939f-42d8-a510-9679391265b9`.
- AMB-1115 Done transition: pending final metadata validation and Linear update.

Next train: `AMB-1058` / `M04.T01`

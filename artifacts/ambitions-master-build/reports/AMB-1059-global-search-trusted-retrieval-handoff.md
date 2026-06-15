# AMB-1059 Global Search Trusted Retrieval Handoff

Ambitions Master Build train closeout

Linear project: Ambitions Personal Life OS Runtime + Native iPhone App Master Build Program (`ca716546-e3d4-4d5b-a399-03076ccba9ee`)

Linear issue: `AMB-1059`

Train label: `M04.T02`

Parent or umbrella issue: `AMB-1046`

Green/Yellow/Red status: Green for the focused AMB-1059 global search entry and trusted retrieval handoff source/control-plane scope; source/control-plane commit `7d45c59f6f3f0e449f92e023f73a25e4ce02a34a` is pushed and remote-verified on `origin/main`. Closeout metadata and final proof-index reconciliation are in progress before Linear Done.

Pushed to main: yes; source/control-plane commit `7d45c59f6f3f0e449f92e023f73a25e4ce02a34a` is pushed and remote-verified.

Push hash: `7d45c59f6f3f0e449f92e023f73a25e4ce02a34a`

Closeout metadata hash: pending this metadata commit

Final reconciliation hash: pending final proof-index reconciliation

App source changed: yes

Runtime behavior changed: yes, Memory Lens now presents local search from the shell, filters results through trusted handoff records, routes trusted results into owning surfaces, records source/trust continuity receipts, blocks stale top-level IA destinations, and keeps Capture as Global Capture rather than a root tab.

Linear identifiers used: AMB issue identifiers only

Files changed:
- `Native/Ambitions/App/ShellCommandModels.swift` - adds `ShellTrustedSearchHandoffOwner`, `ShellTrustedSearchHandoff`, destination ownership mapping, stale IA destination blockers, and Memory Lens result handoff construction.
- `Native/Ambitions/App/ShellCommandRouter.swift` - adds trusted search result routing, held-route behavior for untrusted destinations, and search continuity receipts.
- `Native/Ambitions/App/AppShellView.swift` - replaces static Memory Lens copy with local search controls, trusted result rows, result count/status handling, and a taller Memory Lens sheet detent that keeps the first handoff row legible.
- `Native/AmbitionsTests/App/MemoryLensServiceTests.swift` - covers trusted handoff owner exposure, no stale root destinations, Goals and Time ownership, Global Capture ownership, and absence of Capture/Pulse/Plan root tabs.
- `Native/AmbitionsTests/App/ShellCommandRouterTests.swift` - covers trusted Goals handoff routing and Global Capture handoff routing without adding Capture as a root tab.
- `artifacts/ambitions-master-build/validation/AMB-1059-parallel-guard-prompt.md` - records the AMB-1059 source-changing guard prompt.
- `build/reports/parallel-implementation-guard/AMB-1059-pre.md` and `.json` - records pre-change parallel guard Green evidence.
- `build/reports/parallel-implementation-guard/AMB-1059-post.md` and `.json` - records post-change parallel guard Green evidence.
- `artifacts/ambitions-master-build/validation/AMB-1059/focused-search-routing-tests.log` - records focused XCTest output after the visual layout repair.
- `artifacts/ambitions-master-build/screenshots/AMB-1059/memory-lens-trusted-handoff.png` - records the visually evaluated Memory Lens trusted handoff sheet.

Validation run:
- `bash scripts/codex/program-preflight.sh amb-master` - Green before AMB-1059 source edits; `artifacts/ambitions-master-build/script-output/program-preflight-20260615T084729.log`.
- `bash scripts/codex/program-phase-gate.sh amb-master M04` - pass before AMB-1059 source edits; `artifacts/ambitions-master-build/script-output/program-phase-gate-M04-20260615T084729.log`.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-1059 --prompt artifacts/ambitions-master-build/validation/AMB-1059-parallel-guard-prompt.md --batch-type source-changing` - Green; `build/reports/parallel-implementation-guard/AMB-1059-pre.md`.
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8' -derivedDataPath /Users/devan/Documents/GitHub/ambitions/output/DerivedData-AMB1059 -only-testing:AmbitionsTests/MemoryLensServiceTests -only-testing:AmbitionsTests/ShellCommandRouterTests -enableCodeCoverage NO` - pass; 18 selected tests with 0 failures; `artifacts/ambitions-master-build/validation/AMB-1059/focused-search-routing-tests.log`; `.xcresult` at `output/DerivedData-AMB1059/Logs/Test/Test-Ambitions-2026.06.15_09-22-41--0400.xcresult`.
- XcodeBuildMCP `install_app_sim`, `launch_app_sim`, and `screenshot` with `AMBITIONS_USE_PREVIEW_DATA=1` and `AMBITIONS_LAUNCH_URL=ambitions://overlay/memory-lens` - pass for scoped visual proof after visual inspection; `artifacts/ambitions-master-build/screenshots/AMB-1059/memory-lens-trusted-handoff.png`.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-1059 --prompt artifacts/ambitions-master-build/validation/AMB-1059-parallel-guard-prompt.md --changed-from 90780953d9fb170895a7a0d657b03493f500d7e4 --batch-type source-changing` - Green; no duplicate risks, no supersession updates required, no runtime wiring gaps, no old-term violations, no locked concepts touched; `build/reports/parallel-implementation-guard/AMB-1059-post.md`.
- `git diff --check` - pass before source/control-plane commit.
- `git diff --cached --check` - pass after normalizing generated focused XCTest log trailing whitespace.
- `git push origin main`, `git rev-parse HEAD`, and `git ls-remote origin refs/heads/main` - pushed source/control-plane commit `7d45c59f6f3f0e449f92e023f73a25e4ce02a34a`; local HEAD and `origin/main` both returned `7d45c59f6f3f0e449f92e023f73a25e4ce02a34a` after source/control-plane push.
- `python3 -m json.tool artifacts/ambitions-master-build/AMB_MASTER_EXECUTION_QUEUE.json`, `python3 -m json.tool artifacts/ambitions-master-build/AMB_MASTER_LINEAR_ISSUE_MAP.json`, and `python3 -m json.tool artifacts/ambitions-master-build/validation/AMB-1059-validation.json` - pass after closeout metadata updates.
- `python3 scripts/codex/linear-closeout-validate.py --program amb-master --scope child artifacts/ambitions-master-build/reports/AMB-1059-global-search-trusted-retrieval-handoff.md` - pass after closeout metadata updates.
- `python3 scripts/codex/amb-master-readiness-validate.py --phase M04` - pass after advancing next train to AMB-1060.
- `python3 scripts/codex/amb-master-repository-wiring-validate.py` - pass after updating the program registry and repository wiring validator to expect AMB-1060 as the next runnable gate.
- `bash scripts/codex/program-preflight.sh amb-master` - Green after closeout metadata updates; local ignored log `artifacts/ambitions-master-build/script-output/program-preflight-20260615T093202.log`.
- `bash scripts/codex/program-phase-gate.sh amb-master M04` - pass after closeout metadata updates; local ignored log `artifacts/ambitions-master-build/script-output/program-phase-gate-M04-20260615T093202.log`.

Reviewer passes:
- Deterministic pre/post parallel implementation guard passed Green.
- Main agent visually inspected current screenshot artifact after rejecting earlier clipped layouts. No separate read-only reviewer produced source edits for this focused Memory Lens train.

Proof artifacts:
- `artifacts/ambitions-master-build/validation/AMB-1059-validation.json`
- `artifacts/ambitions-master-build/validation/AMB-1059-parallel-guard-prompt.md`
- `artifacts/ambitions-master-build/validation/AMB-1059/focused-search-routing-tests.log`
- `artifacts/ambitions-master-build/screenshots/AMB-1059/memory-lens-trusted-handoff.png`
- `build/reports/parallel-implementation-guard/AMB-1059-pre.md`
- `build/reports/parallel-implementation-guard/AMB-1059-post.md`
- `artifacts/ambitions-master-build/script-output/program-preflight-20260615T084729.log` - local ignored script output.
- `artifacts/ambitions-master-build/script-output/program-phase-gate-M04-20260615T084729.log` - local ignored script output.
- `artifacts/ambitions-master-build/script-output/program-preflight-20260615T093202.log` - local ignored script output.
- `artifacts/ambitions-master-build/script-output/program-phase-gate-M04-20260615T093202.log` - local ignored script output.

Red blockers: none

Yellow limits:
- AMB-1059 proves shell-owned Memory Lens search entry, local retrieval presentation, trusted handoff routing, and stale-root blockers only; it does not certify broad search ranking quality or every search surface.
- Screenshot proof was visually evaluated on the iPhone 17 simulator with preview data; it is not public accessibility certification or physical-device proof.
- Focused test coverage exists for Memory Lens search handoff ownership and shell routing; full app test suite, measured performance proof, privacy/legal approval, external security audit approval, release readiness, TestFlight readiness, and App Store readiness are not claimed.

Owner approval claimed: no

Release/TestFlight/App Store readiness claimed: no

Accessibility certification claimed: no

Privacy/legal approval claimed: no

Rollback:
- Revert source/control-plane commit `7d45c59f6f3f0e449f92e023f73a25e4ce02a34a` and follow-up AMB-1059 metadata/proof-index commits if Memory Lens routing, stale IA blockers, or Capture global-action behavior regress.

Linear reconciliation:
- AMB-1059 start issue comment: `c62a1746-f955-4154-a7b1-2e7dbd424320`.
- AMB-1059 start project comment: `36b9b328-dfe4-4638-8d4a-316ddb25cc88`.
- AMB-1059 start project status update: `53e4c33a-9bc1-45cf-a463-b5f0eec401e4`.
- AMB-1059 source-push issue comment: `ce3ed50b-e3e8-4bd7-8371-fd20320946d6`.
- AMB-1059 source-push project comment: `f6cbd30a-5cc5-46e8-856c-b94f35bfaf98`.
- AMB-1059 source-push project status update: `62dadcf6-0dd0-4642-ae9b-9414d88e1d91`.

Next train: `AMB-1060` / `M04.T03`

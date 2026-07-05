# AMB-1799 Messy Intent Loop Scenario Gate

Status: Linear source remediation proof packet
Date: 2026-07-05T10:26:11Z
Baseline main SHA: `385d0ba45fb1d4ce96c7b492219b51a716dbad62`
Project: Architecture Simplification + Flagship Readiness Remediation (`59c3917f-f662-4ca3-b412-b532613f3a7a`)
Issue: `AMB-1799` Domain Loop Leaf - Messy intent to proof scenario gate

## Scope

This packet records one bounded deterministic LocalRuntimeOS scenario gate for a
single messy user intent. The scenario proves a local, inspectable path through:

- quick capture persistence without silent Time mutation
- explicit commitment routing into a Time-owned planning seed
- local path planning with a selected candidate
- protected time-fit review that blocks silent movement
- proof attachment through command, runtime event, projection, receipt, and replay

This is a scenario gate only. It does not claim the full Private Life
Orchestration loop, full app readiness, or rendered product acceptance.

## Live Inputs Inspected

- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `.agents/skills/README.md`
- `.agents/skills/ambitions-source-truth-authority/SKILL.md`
- `.agents/skills/ambitions-architecture-tree-enforcement/SKILL.md`
- `.agents/skills/ambitions-ios-quality-gate/SKILL.md`
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md`
- `.agents/skills/ambitions-runtime-contract-engineering/SKILL.md`
- Live Linear state for `AMB-1799`

## Source Changes

Added focused runtime scenario test:

- `Native/AmbitionsTests/LocalRuntimeOS/Planning/MessyIntentLoopScenarioTests.swift`

The test uses existing production runtime contracts only. No production Swift
source changed in this AMB-1799 leaf.

Scenario assertions include:

- quick capture succeeds, trims raw text, stays in `captureInbox`, and emits a
  command record plus runtime event
- explicit `routeCommitment` moves the same capture to `timeSeed` without silent
  scheduling
- `GoalPathPlanner` produces a local replay-ready plan with source provenance and
  deadline target
- `PlacementEngine` blocks automatic protected-time movement and requires review
  before mutation
- `RuntimeTransactionCoordinator` plus `InspectionCommitPlanner` produce a
  complete command-event-projection-receipt-replay flow
- the proof ledger attaches proof to the selected step while retaining the messy
  capture as source context

## Tooling Repair

The XcodeBuildMCP transport issue had two layers:

- repo wrapper/config: fixed on `main` in commit
  `385d0ba45fb1d4ce96c7b492219b51a716dbad62`
- installed Codex Build iOS Apps plugin manifests: patched locally so plugin
  discovery also routes through the repo wrapper and excludes the `debugging`
  workflow

Local installed manifests patched:

- `/Users/devan/.codex/plugins/cache/openai-curated-remote/build-ios-apps/0.1.2/.mcp.json`
- `/Users/devan/.codex/plugins/cache/openai-curated/build-ios-apps/d6169bef/.mcp.json`
- `/Users/devan/.codex/.tmp/plugins/plugins/build-ios-apps/.mcp.json`

The current in-turn `mcp__xcodebuildmcp` handle still reported `Transport closed`
after the patch because the Codex host did not hot-reload the already-dead
transport. Direct SDK stdio probes against the patched entrypoint passed.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched:
  - `Native/AmbitionsTests/LocalRuntimeOS/Planning`
  - `docs/linear/reconciliation`
- Files moved or created:
  - `Native/AmbitionsTests/LocalRuntimeOS/Planning/MessyIntentLoopScenarioTests.swift`
  - `docs/linear/reconciliation/2026-07-05-amb-1799-messy-intent-loop-scenario.md`
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- New `+02`, `+03`, or `+04` split files added: none.
- New broad `Models.swift` files added: none.
- New production runtime, persistence, projection, receipt, or mutation authority
  added: none.
- No alternate folder/path interpretation was used.

Remaining Yellow architecture debt:

- This scenario does not close M02 Runtime Strangler or any parent architecture
  remediation. It proves only this one messy-intent loop gate.

Next repair train:

- Continue with the next bounded loop or parent-remediation child only after a
  new scoped issue or instruction names the target.

## Validation

Completed before closeout:

- XcodeBuildMCP SDK stdio probe through
  `scripts/ambitions-xcodebuildmcp-stdio.sh`
  - `probe_ok=true`
  - `tool_count=50`
  - `has_session_show_defaults=true`
  - `has_build_run_sim=true`
  - `has_debugging=false`
- XcodeBuildMCP SDK `session_show_defaults` tool call through the same wrapper:
  - project path:
    `/Users/devan/Documents/GitHub/ambitions/Ambitions.xcodeproj`
  - scheme: `Ambitions`
  - simulator: `iPhone 17 Pro Max`
    `0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`
  - derived data:
    `/Users/devan/Documents/GitHub/ambitions/output/DerivedData-XcodeBuildMCP`
- `gtimeout 20s xcrun simctl list devices available`: passed and listed the
  iOS 26.5 `iPhone 17 Pro Max`
  `0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`.
- Focused simulator test:
  - command: `scripts/ambitions-bounded-xcodebuild.sh --timeout 15m --kill-after 60s --log .codex/xcode-logs/AMB-1799-messy-intent-loop/direct/focused-test-after-proof-object.patch.log -- xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsUnitTests -sdk iphonesimulator -destination 'platform=iOS Simulator,id=0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E' -derivedDataPath .codex/DerivedData/Ambitions -parallel-testing-enabled NO test -only-testing:AmbitionsTests/MessyIntentLoopScenarioTests CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO COMPILER_INDEX_STORE_ENABLE=NO ONLY_ACTIVE_ARCH=YES -resultBundlePath .codex/xcode-results/AMB-1799-messy-intent-loop/direct/focused-test-after-proof-object.patch.xcresult`
  - result: `** TEST SUCCEEDED **`
  - executed tests: `1`
  - failures: `0`
  - result bundle:
    `.codex/xcode-results/AMB-1799-messy-intent-loop/direct/focused-test-after-proof-object.patch.xcresult`
- `git diff --check`
- `bash -n scripts/ambitions-xcodebuildmcp-stdio.sh`
- `scripts/ambitions-xcodegen-needed.sh`: `XCODEGEN_NEEDED=0`
- `python3 scripts/ambitions-remediation-governance-check.py`: Green
  remediation governance guard passed.
- `python3 scripts/ambitions-quality-gate.py`: Green all strict quality gates
  passed.
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py`: valid, zero
  invalid Accepted Yellow issues.
- `python3 scripts/ambitions-local-runtime-proof.py`: Green, 20 checks passed.

Observed simulator/app-group `NOT_CODESIGNED` log lines are local simulator test
noise from unsigned test execution and were not treated as product proof.

## Non-Claims

- No full Private Life Orchestration Green is claimed.
- No M02 Runtime Strangler Green is claimed.
- No visual acceptance, accessibility acceptance, physical device proof,
  privacy/legal approval, TestFlight/App Store readiness, R2 readiness, or
  release readiness is claimed.
- No hosted AI, network, sync, or user-data backend behavior is introduced or
  claimed.
- No production runtime behavior changed in this AMB-1799 leaf.

## Rollback

If this leaf must be reverted, delete
`Native/AmbitionsTests/LocalRuntimeOS/Planning/MessyIntentLoopScenarioTests.swift`
and this proof packet. The local Codex plugin manifest patch can be reverted by
restoring the Build iOS Apps `.mcp.json` files from the plugin cache, but doing
so will reintroduce the broken `debugging` workflow transport path on this host.

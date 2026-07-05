# XcodeBuildMCP Transport and Simulator Preflight Repair

Date: 2026-07-05
Branch: `main`
Repo HEAD before this slice: `19967c9f4d5523131aed02c91213b14eb40587b7`
Commit SHA: original repair commit already on `main`; post-reload proof recorded
at repo HEAD `691b303b38cd3f92442e54619e0d46213d2c7e24`
Environment: local Codex macOS workspace at
`/Users/devan/Documents/GitHub/ambitions`
Xcode version: Xcode 26.6, build version 17F113
Simulator or device: simulator preflight only for `iPhone 17 Pro Max` /
`0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`; no physical-device procedure
Exit code(s): listed in Validation Run and Gates below
Artifact paths: this packet, `scripts/ambitions-xcodebuildmcp-stdio.sh`,
`scripts/ambitions-xcodebuildmcp-probe.py`, and
`docs/validation/xcode_timeout_policy.md`
Scope: local tooling repair for Codex XcodeBuildMCP transport and simulator preflight health.

## Claim

Implemented Yellow for tooling infrastructure:

- The repo XcodeBuildMCP stdio wrapper no longer performs peer cleanup during
  startup.
- The local Codex registration no longer passes
  `AMBITIONS_XCODEBUILDMCP_CLEAN_PEERS` into the server startup environment.
- The wrapper supports explicit maintenance cleanup only through
  `scripts/ambitions-xcodebuildmcp-stdio.sh --cleanup-peers-and-exit`.
- The repo has a direct JSON-RPC probe that verifies `session_show_defaults`
  returns the configured `ambitions-ios` profile.
- Simulator preflight has a clean steady state after resetting stale
  CoreSimulator and repo-owned validation-runner state.

This is not release proof, UI visual acceptance, App Store readiness, TestFlight
readiness, device proof, accessibility proof, or product completeness proof.

## Root Cause

The previous wrapper ran peer cleanup during normal stdio startup when
`AMBITIONS_XCODEBUILDMCP_CLEAN_PEERS=1`. Its broad `pgrep -f` patterns could
match shell/probe command lines containing `xcodebuildmcp ... mcp`, not only real
server peers. In Codex desktop this closed the active MCP transport and left the
host with a cached `Transport closed` handle.

The simulator preflight lane was also blocked by stale local CoreSimulator state
and a repo-owned self-hosted Actions runner executing
`scripts/ci/local_runtime_proof_ci.sh` with a stuck `simctl list devices
available` process.

## Changes

- `scripts/ambitions-xcodebuildmcp-stdio.sh`
  - Removed environment-triggered startup cleanup.
  - Added explicit maintenance cleanup mode:
    `--cleanup-peers-and-exit`.
  - Restricted cleanup matching to exact `xcodebuildmcp` executable process
    shapes.
  - Ignores stale `AMBITIONS_XCODEBUILDMCP_CLEAN_PEERS=1` during stdio startup.
- `scripts/ambitions-xcodebuildmcp-probe.py`
  - Added a direct MCP JSON-RPC initialize plus `session_show_defaults` probe.
  - Verifies the `ambitions-ios` profile, scheme `Ambitions`, simulator
    `iPhone 17 Pro Max`, and UDID
    `0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`.
- `docs/validation/xcode_timeout_policy.md`
  - Documented the no-cleanup startup contract.
  - Documented the explicit maintenance cleanup command.
  - Added the current probe command.
  - Added the local `.codex` proof ceiling: local result/screenshot paths are
    local working evidence and not visual acceptance by themselves.
- `/Users/devan/.codex/config.toml`
  - Removed the local `AMBITIONS_XCODEBUILDMCP_CLEAN_PEERS` env override from
    `mcp_servers.xcodebuildmcp`.

## Evidence

- `codex mcp get xcodebuildmcp`
  - status: passed
  - command:
    `/Users/devan/Documents/GitHub/ambitions/scripts/ambitions-xcodebuildmcp-stdio.sh`
  - env: none
  - startup timeout: `180`
- `scripts/ambitions-xcodebuildmcp-probe.py --json`
  - status: passed
  - `ok=true`
  - profile: `ambitions-ios`
  - scheme: `Ambitions`
  - simulator: `iPhone 17 Pro Max`
  - UDID: `0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`
- `AMBITIONS_XCODEBUILDMCP_CLEAN_PEERS=1 scripts/ambitions-xcodebuildmcp-probe.py --json`
  - status: passed
  - proves stale cleanup env no longer triggers startup cleanup
- `mcp__xcodebuildmcp.session_show_defaults`
  - status: passed before the explicit cleanup stress test
  - returned `currentProfile=ambitions-ios`, `scheme=Ambitions`,
    `simulatorName=iPhone 17 Pro Max`, and
    `simulatorId=0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`

## Post-Reload Live Transport Verification

At 2026-07-05T16:07:42Z on repo HEAD
`691b303b38cd3f92442e54619e0d46213d2c7e24`, the current Codex desktop process
proved the repaired transport again after the previous cached-handle ceiling:

- `mcp__xcodebuildmcp.session_show_defaults`
  - status: passed in this live Codex session
  - returned `currentProfile=ambitions-ios`, `scheme=Ambitions`,
    `projectPath=/Users/devan/Documents/GitHub/ambitions/Ambitions.xcodeproj`,
    `simulatorName=iPhone 17 Pro Max`, `simulatorId=0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`,
    `derivedDataPath=/Users/devan/Documents/GitHub/ambitions/output/DerivedData-XcodeBuildMCP`,
    and `bundleId=com.ambitions.ios`
- `codex mcp get xcodebuildmcp`
  - status: passed
  - transport: `stdio`
  - command:
    `/Users/devan/Documents/GitHub/ambitions/scripts/ambitions-xcodebuildmcp-stdio.sh`
  - env: none
  - startup timeout: `180`
- `scripts/ambitions-xcodebuildmcp-probe.py --json`
  - status: passed
  - `ok=true`
  - profile: `ambitions-ios`
  - scheme: `Ambitions`
  - simulator: `iPhone 17 Pro Max`
  - UDID: `0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`
- `AMBITIONS_XCODEBUILDMCP_CLEAN_PEERS=1 scripts/ambitions-xcodebuildmcp-probe.py --json`
  - status: passed
  - proves stale cleanup env still does not trigger startup cleanup
- `scripts/ambitions-xcode-sim-health.sh --json --timeout 30s`
  - status: passed
  - selected simulator: `iPhone 17 Pro Max`
  - UDID: `0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`
  - state: `Booted`
  - booted simulator count: `1`
  - Ambitions app PID count: `0`
  - Xcode process blockers: `0`
- `bash -n scripts/ambitions-xcodebuildmcp-stdio.sh && python3 -m py_compile scripts/ambitions-xcodebuildmcp-probe.py`
  - status: passed

This clears the previous current-process `Transport closed` ceiling for the
live Codex process used by this continuation. It remains local tooling proof
only; it is not build, test, app-launch, UI, device, accessibility, privacy,
release, TestFlight, App Store, or product-completion proof.

## Validation Run

Post-reload verification completed for this local tooling packet:

| Command / procedure | Exit code | Result |
| --- | ---: | --- |
| `mcp__xcodebuildmcp.session_show_defaults` | n/a | Passed in the live Codex session; returned the `ambitions-ios` profile. |
| `codex mcp get xcodebuildmcp` | 0 | Passed; stdio transport points at the repo wrapper with no environment override. |
| `scripts/ambitions-xcodebuildmcp-probe.py --json` | 0 | Passed; `ok=true` for `ambitions-ios`. |
| `AMBITIONS_XCODEBUILDMCP_CLEAN_PEERS=1 scripts/ambitions-xcodebuildmcp-probe.py --json` | 0 | Passed; stale cleanup env no longer closes transport on startup. |
| `scripts/ambitions-xcode-sim-health.sh --json --timeout 30s` | 0 | Passed; selected simulator booted, one booted simulator, no Ambitions app PID, no Xcode process blocker. |
| `bash -n scripts/ambitions-xcodebuildmcp-stdio.sh && python3 -m py_compile scripts/ambitions-xcodebuildmcp-probe.py` | 0 | Passed. |
| `git diff --check` | 0 | Passed after post-reload packet patch. |
| `python3 scripts/ambitions-unsupported-claim-scan.py docs/linear/reconciliation/2026-07-05-xcodebuildmcp-transport-and-simulator-preflight-repair.md` | 0 | Passed after post-reload packet patch. |
| `python3 scripts/ambitions-remediation-governance-check.py` | 0 | Passed after post-reload packet patch. |

## Validation Not Run

- No xcodebuild build, xcodebuild test, XCTest, build-for-testing, focused test,
  app launch, rendered UI, screenshot, accessibility walkthrough, performance
  profiling, physical-device procedure, privacy/legal review, TestFlight,
  App Store, archive export, or upload procedure was run for this tooling
  packet.

## Non-Claims

- This packet does not prove build success, test success, app runtime behavior,
  rendered product quality, accessibility conformance, device readiness,
  privacy/legal approval, release readiness, TestFlight readiness,
  App Store readiness, or product completion.
- The post-reload proof only proves the local Codex/XcodeBuildMCP transport,
  direct probe, and simulator preflight state named above.

## Simulator Preflight Evidence

Stale state was removed by terminating the repo-owned self-hosted runner lane
and restarting local CoreSimulator process state. After repair:

- `scripts/ambitions-xcode-sim-health.sh --repair --json --timeout 30s`
  - status: passed
  - selected simulator: `iPhone 17 Pro Max`
  - UDID: `0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`
  - state: `Booted`
  - booted simulator count: `1`
  - Ambitions app PID count: `0`
  - Xcode process blockers: `0`
- `scripts/ambitions-xcode-sim-health.sh --json`
  - status: passed
  - selected simulator: `iPhone 17 Pro Max`
  - UDID: `0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`
  - state: `Booted`
  - booted simulator count: `1`
  - Ambitions app PID count: `0`
  - Xcode process blockers: `0`

## Gates

- `bash -n scripts/ambitions-xcodebuildmcp-stdio.sh`: passed
- `python3 -m py_compile scripts/ambitions-xcodebuildmcp-probe.py`: passed
- `git diff --check`: passed
- `python3 scripts/ambitions-remediation-governance-check.py`: passed
- `python3 scripts/ambitions-quality-gate.py`: passed
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py`: passed
  - checked Accepted Yellow issues: `19`
  - invalid Accepted Yellow issues: `0`
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/validation/xcode_timeout_policy.md scripts/ambitions-xcodebuildmcp-stdio.sh scripts/ambitions-xcodebuildmcp-probe.py`: passed

## Architecture Closeout

- Final Architecture Tree inspected: yes, during the active remediation run.
- Canonical owners touched: validation tooling and validation documentation only.
- Files moved or created:
  - created `scripts/ambitions-xcodebuildmcp-probe.py`
  - created this reconciliation artifact
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt: none introduced by this tooling slice.
- Next repair train if debt remains: not applicable for this slice.
- Confirmation: no equivalent-folder or alternate-path interpretation was used.

## Host Ceiling Resolution

The explicit cleanup stress test intentionally killed the already-open in-app
`xcodebuildmcp` peer, after which that earlier Codex host reported
`Transport closed` for its cached handle. That was expected for an already-open
stdio client after its child process was intentionally killed.

The post-reload verification above proves that the current Codex process now
has a live `xcodebuildmcp` handle again. Future stale-handle failures should be
treated as host-process state first: rerun `mcp__xcodebuildmcp.session_show_defaults`,
`codex mcp get xcodebuildmcp`, and
`scripts/ambitions-xcodebuildmcp-probe.py --json` before changing repo tooling.

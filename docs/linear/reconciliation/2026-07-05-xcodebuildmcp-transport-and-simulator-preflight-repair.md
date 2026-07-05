# XcodeBuildMCP Transport and Simulator Preflight Repair

Date: 2026-07-05
Repo HEAD before this slice: `19967c9f4d5523131aed02c91213b14eb40587b7`
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

## Remaining Host Ceiling

An explicit cleanup stress test intentionally killed the already-open in-app
`xcodebuildmcp` peer, after which the running Codex host again reported
`Transport closed` for its cached handle. That is expected for an already-open
stdio client after its child process is intentionally killed. The repo launch
contract and local Codex registration are now repaired; a Codex app-server
reload is required to prove the live in-process handle again after that stress
test.

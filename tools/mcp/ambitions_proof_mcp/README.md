# Ambitions Controlled Proof MCP

MCP02 is a local-only, stdlib-only MCP server for allowlisted validation commands.

It is not a generic shell. It does not provide write tools, network tools,
secrets access, signing, App Store upload, hosted CI creation, or git mutation.

## Tools

- `list_available_validations`
- `run_named_validation`
- `collect_latest_logs`
- `generate_proof_packet`
- `check_validation_policy`
- `xcode_latest_summary`
- `xcode_failure_classification`
- `xctest_recovery_plan`
- `xcode_job_submit`
- `xcode_job_status`
- `xcode_job_result`
- `xcode_job_cancel`

## Allowed Validation Names

Core local proof validations:

- `mcp01_self_test`
- `repo_claim_scan`
- `architecture_applicability_scan`
- `doc_link_scan_basic`
- `git_status_summary`
- `xcodegen_check_dry_run`

Preferred Xcode Build Lab wrapper validations:

- `xcode_validate_build`
- `xcode_validate_build_for_testing`
- `xcode_validate_focused_test`
- `xcode_validate_test_plan`

Legacy fallback validations:

- `build_local`
- `focused_tests`

`build_local` is disabled by default and should run only when an app-source
batch explicitly requires the existing `./scripts/build-local.sh` proof.
`focused_tests` is retained as a deprecated fallback and requires explicit
target/test arguments. Prefer `xcode_validate_focused_test` because it routes
through `scripts/ambitions-xcode-validate.sh`, inherits Xcode Build Lab logging,
summaries, and failure classification, and uses a simulator-safe 1800-second
timeout instead of the short generic MCP path.

## Proof Shape

Named validation output includes the command that ran, the exit code, the local
log path, the failure category, wrapper timeout metadata, the latest Xcode
summary when available, and explicit non-claims. That output is local
engineering evidence only; it is not release proof, device proof,
accessibility proof, or legal/privacy signoff.

## Wrapper-Native Xcode Usage

Focused simulator tests should use the wrapper-native validation path:

```json
{
  "name": "xcode_validate_focused_test",
  "args": ["--batch", "MCP-SMOKE-01", "--test", "AmbitionsTests/Focused"]
}
```

Build validation should use:

```json
{
  "name": "xcode_validate_build",
  "args": ["--batch", "MCP-SMOKE-01"]
}
```

Test-plan validation should use:

```json
{
  "name": "xcode_validate_test_plan",
  "args": ["--batch", "MCP-SMOKE-01", "--test-plan", "Ambitions-Focused"]
}
```

The Xcode wrapper validations allow only `--batch`, plus lane-appropriate
`--test` or `--test-plan`. Archive, export, provisioning, signing, and upload
paths remain blocked.

## Resumable Xcode Jobs

Long Xcode Build Lab validations can run independently of one MCP request:

```json
{
  "validation": "xcode_validate_build",
  "args": ["--batch", "MCP-RESUME-01"]
}
```

Call `xcode_job_submit` with that payload, retain the returned `job_id`, and use
`xcode_job_status` or `xcode_job_result` from any later MCP connection.
`xcode_job_cancel` requests bounded cancellation of only the persisted worker
process group after verifying that the worker command owns the exact job id.

Job state, logs, and terminal results are written atomically beneath
`.codex/xcode-jobs/<job-id>/`. The detached worker reconstructs the command from
the allowlisted validation and validated arguments instead of executing the
persisted command text. It records the starting branch, SHA, and working-tree
state, refuses to claim success if the source SHA changes during execution, and
retains the existing local-proof non-claims.

These tools accept only the four `xcode_validate_*` Xcode Build Lab wrapper
validations. They do not make the server a generic background shell.

## Timeout Policy

Short repo checks keep the 120-second default. Simulator and Xcode wrapper
validations use 1800 seconds because simulator boot, project generation,
build-for-testing, focused test execution, and result collection can exceed
120 seconds on the Mac VM.

The Codex host entry for XcodeBuildMCP should set
`tool_timeout_sec = 1800.0` so synchronous XcodeBuildMCP calls have the same
30-minute envelope. Resumable jobs remain the preferred path when work should
survive an MCP request timeout or connection restart.

## Local Validation

```bash
python3 tools/mcp/ambitions_proof_mcp/server.py --self-test
python3 -m unittest tools.mcp.ambitions_proof_mcp.tests.test_server_tools -v
python3 -m pytest tools/mcp/ambitions_proof_mcp/tests
```

Pytest is optional in the Mac VM. If it is unavailable, use the standard-library
`unittest` command above for the local server tool coverage and record pytest as
not installed, not as a validation failure.

## Non-Claims

MCP proof output is local engineering evidence only. It is not release
readiness, App Store readiness, TestFlight readiness, physical-device proof,
public accessibility proof, or legal/privacy signoff.

# Ambitions Controlled Proof MCP

MCP02 is a local-only, stdlib-only MCP server for allowlisted validation commands.

It is not a generic shell. It does not provide write tools, network tools, secrets access, signing, App Store upload, hosted CI creation, or git mutation.

## Tools

- `list_available_validations`
- `run_named_validation`
- `collect_latest_logs`
- `generate_proof_packet`
- `check_validation_policy`
- `xcode_latest_summary`
- `xcode_failure_classification`

## Allowed Validation Names

Core local proof validations:

- `mcp01_self_test`
- `repo_claim_scan`
- `efc_applicability_scan`
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

`build_local` is disabled by default and should run only when an app-source batch explicitly requires the existing `./scripts/build-local.sh` proof. `focused_tests` is retained as a deprecated fallback and requires explicit target/test arguments. Prefer `xcode_validate_focused_test` because it routes through `scripts/ambitions-xcode-validate.sh`, inherits Xcode Build Lab logging/summaries/failure classification, and uses a simulator-safe 1800-second timeout instead of the short generic MCP path.

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

The Xcode wrapper validations allow only `--batch`, plus lane-appropriate `--test` or `--test-plan`. Archive/export/provisioning/signing/upload paths remain blocked.

## Timeout Policy

Short repo checks keep the 120-second default. Simulator/Xcode wrapper validations use 1800 seconds because simulator boot, project generation, build-for-testing, focused test execution, and result collection can exceed 120 seconds on the Mac VM.

If a client-side MCP host still enforces a shorter timeout, run the same validation through the local command line or move the host config to a longer timeout. The server-side timeout is now long enough for the approved simulator path.

## Local Validation

```bash
python3 tools/mcp/ambitions_proof_mcp/server.py --self-test
python3 -m pytest tools/mcp/ambitions_proof_mcp/tests
```

Pytest is optional in the Mac VM. If it is unavailable, record Yellow and rely on self-test plus manual JSON-RPC until the test runner is installed through an approved tooling batch.

## Non-Claims

MCP proof output is local engineering evidence only. It is not release readiness, App Store readiness, TestFlight readiness, physical-device proof, public accessibility proof, or legal/privacy signoff.
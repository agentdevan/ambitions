# MCP02 Controlled Proof MCP

Status: Installed as local scaffold and stdlib server.
Scope: local Codex validation acceleration only.

MCP02 adds a second local MCP server at `tools/mcp/ambitions_proof_mcp/`.

It exposes named validation actions only:

- `list_available_validations`
- `run_named_validation`
- `collect_latest_logs`
- `generate_proof_packet`
- `check_validation_policy`
- `xcode_latest_summary`
- `xcode_failure_classification`

Allowed validation names:

- `mcp01_self_test`
- `repo_claim_scan`
- `efc_applicability_scan`
- `doc_link_scan_basic`
- `git_status_summary`
- `xcodegen_check_dry_run`
- `xcode_validate_build`
- `xcode_validate_build_for_testing`
- `xcode_validate_focused_test`
- `xcode_validate_test_plan`
- `build_local` legacy fallback
- `focused_tests` deprecated legacy fallback

## Xcode Build Lab Alignment

Preferred Xcode proof now routes through `scripts/ambitions-xcode-validate.sh` and the Xcode Build Lab lanes instead of the older raw focused-test path.

Use:

```json
{"name":"xcode_validate_build","args":["--batch","MCP-SMOKE-01"]}
```

```json
{"name":"xcode_validate_focused_test","args":["--batch","MCP-SMOKE-01","--test","AmbitionsTests/Focused"]}
```

```json
{"name":"xcode_validate_test_plan","args":["--batch","MCP-SMOKE-01","--test-plan","Ambitions-Focused"]}
```

Wrapper-native Xcode validations use an 1800-second server-side timeout to account for simulator boot, build preparation, test execution, result bundle creation, and summary generation. Short repo checks keep the 120-second default.

The summary helpers read Xcode Build Lab artifacts:

- `xcode_latest_summary`
- `xcode_failure_classification`

## Boundaries

MCP02 forbids arbitrary command execution, network commands, secrets commands, destructive commands, signing commands, App Store upload, hosted CI creation, and git push/merge/rebase/reset.

Generated packets are local proof packets under `.codex/logs/proof/`. They are engineering evidence only.

## Non-Claims

MCP02 does not prove release readiness, TestFlight readiness, App Store readiness, physical-device validation, public accessibility conformance, legal/privacy signoff, hosted CI, or production app behavior.
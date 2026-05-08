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

Allowed validation names:

- `mcp01_self_test`
- `repo_claim_scan`
- `efc_applicability_scan`
- `doc_link_scan_basic`
- `git_status_summary`
- `xcodegen_check_dry_run`
- `build_local`
- `focused_tests`

## Boundaries

MCP02 forbids arbitrary command execution, network commands, secrets commands, destructive commands, signing commands, App Store upload, hosted CI creation, and git push/merge/rebase/reset.

Generated packets are local proof packets under `.codex/logs/proof/`. They are engineering evidence only.

## Non-Claims

MCP02 does not prove release readiness, TestFlight readiness, App Store readiness, physical-device validation, public accessibility conformance, legal/privacy signoff, hosted CI, or production app behavior.

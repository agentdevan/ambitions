# Ambitions Controlled Proof MCP

MCP02 is a local-only, stdlib-only MCP server for allowlisted validation commands.

It is not a generic shell. It does not provide write tools, network tools, secrets access, signing, App Store upload, hosted CI creation, or git mutation.

## Tools

- `list_available_validations`
- `run_named_validation`
- `collect_latest_logs`
- `generate_proof_packet`
- `check_validation_policy`

## Allowed Validation Names

- `mcp01_self_test`
- `repo_claim_scan`
- `efc_applicability_scan`
- `doc_link_scan_basic`
- `git_status_summary`
- `xcodegen_check_dry_run`
- `build_local`
- `focused_tests`

`build_local` is disabled by default and should run only when an app-source batch requires the existing `./scripts/build-local.sh` proof. `focused_tests` requires explicit target/test arguments.

## Local Validation

```bash
python3 tools/mcp/ambitions_proof_mcp/server.py --self-test
python3 -m pytest tools/mcp/ambitions_proof_mcp/tests
```

Pytest is optional in the Mac VM. If it is unavailable, record Yellow and rely on self-test plus manual JSON-RPC until the test runner is installed through an approved tooling batch.

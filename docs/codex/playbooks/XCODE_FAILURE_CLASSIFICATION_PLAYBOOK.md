# Playbook: Failure Classification

## Core failure classes

- `compile_error` → compile failures
- `test_failure` / `test_discovery_failure`
- `simulator_boot_failure`
- `stale_derived_data` / `xcodegen_project_drift`
- `missing_destination`
- `signing_error`
- `tool_missing`
- `test_timeout`
- `unknown`

## Procedure

1. Use validator summary exit code and `failure_category`.
2. Confirm wrapper emitted class by checking logs and mapped code.
3. Apply targeted repair:
   - `compile_error`, `xcodegen_project_drift`, `stale_derived_data` → compile fix or local DerivedData cleanup
   - `simulator_boot_failure` → simulator repair playbook (one retry)
   - `tool_missing` → install missing tool or run with available fallback
   - `missing_destination` / `test_discovery_failure` → check test selectors or simulator availability

## Rollover policy

- Unknown classes default to exit 26 and must be manually diagnosed before retrying.

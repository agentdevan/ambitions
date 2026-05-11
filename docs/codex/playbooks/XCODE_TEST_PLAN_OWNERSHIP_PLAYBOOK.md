# Playbook: Test Plan Ownership

## Principle

Use test plans for segment gates only when the owning batch has deterministic segment
coverage and test-plan files are available.

## Command pattern

- `scripts/ambitions-xcode-validate.sh --batch <BATCH> --lane test-plan --test-plan <PlanName>`

## Missing plan handling

- If test plan is missing, the validation wrapper returns code 24 with
  `tool_missing`-compatible message and suggests focused fallback.
- In that case run focused seam tests immediately:
  - `scripts/ambitions-xcode-validate.sh --batch <BATCH> --lane focused-test --test <focused test id>`

## Audit requirement

- Prefer plan-backed segment commands only for gates where segment matrix indicates
  deterministic plan coverage.

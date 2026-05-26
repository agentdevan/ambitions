# Anti-Card Validator Install Proof

Status: Yellow

## Validator

- Script: `scripts/ios26-anti-card-check.py`
- Report root: `build/reports/frontend-object-purity/`
- Supported surfaces: `shell`, `today`, `time`, `goals`, `capture`, `you`, `proof`, `global`

## Validation Run

- `python3 -m py_compile scripts/ios26-anti-card-check.py`: Green
- `python3 scripts/ios26-anti-card-check.py --surface global --batch IOS26-FRONTEND-INSTALL`: ran and wrote Markdown/JSON reports.

## Validator Result

The global installer run reported Red against current source:

- Files scanned: 444
- Red findings: 124
- Yellow findings: 0
- Report: `build/reports/frontend-object-purity/IOS26-FRONTEND-INSTALL-anti-card.md`
- JSON: `build/reports/frontend-object-purity/IOS26-FRONTEND-INSTALL-anti-card.json`

## No-Claim Boundary

The Red result is a gating signal for the newly installed implementation train, not proof of object-purity completion. Do not claim active top-level card architecture has been removed until the relevant implementation batches repair and rerun this validator Green or close accepted Yellow with owner, reason, no-claim boundary, and follow-up gate.

# CS06 Historical Docs Truth Ledger

Status: CS06A historical truth ledger. Historical `failed` / `failure` references are not automatically product-copy debt. Many are factual validation records, Red/Yellow reports, or tooling protocols.

## Preserve As Historical Truth

| Area | Evidence pattern | Classification | CS06 action |
|---|---|---|---|
| `.codex/reports/current-run-state.md` and `.codex/reports/current-batch-train-state.md` | Past validation failures, dry-run Red state, failed checks | historical/audit truth | Preserve; update only current CS06A truth |
| `docs/audits/**` reports | Test failure counts, Red repair records, known failure classifications | historical/audit truth | Preserve; do not rewrite old outcomes |
| `output/logs/**` if referenced by reports | Command/test logs with failure language | historical/audit truth | Preserve; not part of CS06A docs edits |
| `docs/codex/GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL.md` and validation protocols | Failure/Red classification policy | tooling truth | Preserve unless future tooling batch owns wording |
| `scripts/run-doc-qa.sh` and other scripts | Deprecated-language scan and pass/fail reporting | tooling truth | Preserve |
| Canon docs that explicitly list `failed` as forbidden user-facing copy | Product-language source truth | source truth | Preserve |
| Historical compatibility reports for CS02-CS05 | Red stop states and accepted Yellow reports | historical/audit truth | Preserve |

## Rewrite-Prohibited Examples

- Do not change old "failed test" records to "needs recovery" because that would falsify validation history.
- Do not remove `failed` from scripts/checklists where pass/fail is the technical validation vocabulary.
- Do not claim CS06 retired the failed taxonomy when CS06A only mapped it.
- Do not treat a historical Red report as current product copy.

## CS06A Decision

Historical docs truth is preserved. Only current CS06A status docs may be updated to say CS06 is repaired into staged map/proof/retire work.

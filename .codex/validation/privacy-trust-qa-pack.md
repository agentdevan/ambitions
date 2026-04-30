# Privacy Trust QA Pack

## Purpose

Validate privacy/trust-sensitive changes.

## Commands

```bash
rg -n "sync|account|calendar|permission|memory|consent|receipt|external|privacy|redact" Native Sources AppUI docs/canon || true
scripts/build-local.sh || true
```

## Evidence

Local-first status, confirmation/correction/redaction checks, unsupported
claims blocked.

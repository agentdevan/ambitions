# Codex Gate Engine

Status: Active advisory gate engine plan.  
Date: 2026-05-07  
Scope: ACX and CQS scan usage.

## Current Gate Sources

- `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md`
- `scripts/cqs-*.sh`
- `scripts/ai/acx.py gate ...`

## ACX Advisory Gates

```bash
python3 scripts/ai/acx.py gate deprecated-language
python3 scripts/ai/acx.py gate release-claims
python3 scripts/ai/acx.py gate all
python3 scripts/ai/acx.py gate-report
```

By default, findings are Accepted Yellow advisories. Use `--strict` only in closeout or CI-like proof contexts.

## Gate Philosophy

A gate should make hidden risk visible. It should not delete files, stage changes, rewrite source, or claim proof beyond its scan.

## Required Gate Families

| Family | Purpose |
| --- | --- |
| Source truth | Confirms active owner files were read. |
| Scope | Confirms allowed/forbidden paths. |
| Canon drift | Protects tabs, IA, product laws, naming. |
| Anti-generic UI | Prevents dashboard/card/task/habit/chatbot drift. |
| Accessibility/motion | Protects Dynamic Type, VoiceOver order, Reduce Motion. |
| Privacy/security | Prevents unsupported compliance and sensitive-data claims. |
| Release claims | Blocks production/release/App Store/TestFlight claims without proof. |
| Validation | Ensures commands and exit codes are named. |
| Report | Forces Green/Yellow/Red closeout. |

# Ambitions 3.0 — Copy QA Protocol

Status: Active content QA protocol

## Triggers

Run for user-facing copy, accessibility labels, App Intents, screenshots,
receipts, recommendations, errors, onboarding, and release/App Store text.

## Required Docs

- `Ambitions_3_0_Product_Language_System.md`
- `Ambitions_3_0_Content_QA_And_Copy_Guard.md`
- `Ambitions_3_0_Migration_And_Deprecation_Plan.md`

## Checks

- Copy is calm, plain, adult, and specific.
- Deprecated terms are absent from new user-facing copy.
- No fake AI certainty, productivity scores, shame, or release claims.
- Receipts distinguish what changed, what did not, and what still counts.

## Commands

```bash
scripts/run-doc-qa.sh || true
rg -n --hidden --glob '!/.git/**' 'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|missed' Native Sources AppUI docs .codex || true
```

## Stop Conditions

Stop when copy implies unimplemented behavior or unsupported release readiness.

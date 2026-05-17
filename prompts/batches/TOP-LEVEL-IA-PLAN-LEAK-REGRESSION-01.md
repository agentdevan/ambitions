<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01

## Objective

Install regression coverage that prevents `Plan` from reappearing as an active top-level destination while preserving internal compatibility seams where current source/truth allows them.

## Active Source Truth To Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `Native/Ambitions/App/AppTab.swift`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`
- `Native/AmbitionsTests/App/AppShellChromeTests.swift`
- `scripts/validate-repo-authority.sh`

## Allowed Scope

- `Native/Ambitions/App/AppTab.swift` only if a small compatibility bug is found
- `Native/Ambitions/App/AmbitionsRootView.swift` only if a user-facing Plan leak is found
- `Native/AmbitionsTests/App/**`
- `scripts/ambitions-vocabulary-drift-scan.py` or adjacent validation script only if needed for automated guard coverage
- status docs only to record conservative proof limits

## Required Work

- Add focused tests proving top-level user-facing destinations are exactly `Today / Goals / Capture / Time / You`.
- Add or repair tests proving legacy `plan` routes map to Time rather than a Plan tab.
- Scan front-door/status docs for active `Today / Goals / Capture / Plan / You` leaks and repair only active/supporting files, not historical archives.

## Validation Expectations

- Focused app shell/navigation tests.
- `bash scripts/validate-repo-authority.sh .`
- `git diff --check`

## Forbidden Scope

- No product IA redesign.
- No sixth tab.
- No deletion of compatibility aliases unless tests and truth require it.

## Runner Command

```bash
make batch BATCH=TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01 PROMPT=prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md
```

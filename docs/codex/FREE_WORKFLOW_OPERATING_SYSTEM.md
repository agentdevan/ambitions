# Ambitions Free Workflow Operating System

This is the no-paid-service, local-first operating layer for Codex work on Ambitions.

Ambitions 3.0 is the active source of truth. This workflow supports the 3.0 Codex Performance Operating System and does not replace product canon, the batch registry, or release gates.

## Non-Overlap Contract

| Need | Use |
|---|---|
| Active product/source hierarchy | `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md` and `docs/canon/Ambitions_3_0_Documentation_System_Index.md` |
| Codex performance rules | `docs/canon/Ambitions_3_0_Codex_Performance_Operating_System.md` |
| Context/task routing | `docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md` |
| Implementation status only | `docs/codex/BATCH_REGISTRY.md` |
| Dependency policy | `docs/canon/Ambitions_3_0_Dependency_Management_Policy.md` |
| Local Mac setup | `docs/codex/MAC_CODEX_5_5_TOOLCHAIN_SETUP.md` |
| Validation packs | `.codex/validation/` |
| Operations protocols | `.codex/operations/` |

Do not create duplicate roadmaps, duplicate source-of-truth maps, duplicate decision logs, or duplicate master product specs.

## Default Loop

1. Preflight: `git status --short`, branch, HEAD, target docs, target code.
2. Reconcile: confirm Ambitions 3.0 source docs and implementation status.
3. Route: choose context pack, skill, operation, validation pack.
4. Plan: name touch budget and validation commands.
5. Execute: make smallest safe change.
6. Validate: run focused pack, then build when meaningful.
7. Report: separate PASS, PARTIAL, FAIL, not run, and human/device follow-up.
8. Closeout: stage exact paths, commit logically, push only when coherent.

## Base Local Commands

```bash
git status --short
git branch --show-current
git rev-parse HEAD
xcodegen generate
xcrun simctl list devices available | grep -E 'iPhone' | head -20
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' build CODE_SIGNING_ALLOWED=NO
```

Use `iPhone 17` when `iPhone 16` is unavailable locally and record the exact destination.

## Current Known Risk

The full UI suite is not green after the FAANG handoff audit. Prefer focused UI validation for touched surfaces, then document existing full-suite failures until F00/F01 rebaselines or fixes them with evidence.

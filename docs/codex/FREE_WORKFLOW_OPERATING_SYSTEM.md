# Ambitions Free Workflow Operating System

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, finish-real-source-proof
> Dispositions: proof-readiness, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->

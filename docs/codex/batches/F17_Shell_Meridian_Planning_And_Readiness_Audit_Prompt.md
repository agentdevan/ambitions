# F17 Shell / Meridian Planning And Readiness Audit Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Historical completed batch prompt
Train: F17-F30 FAANG Handoff Completion Train

Run F17 as planning/readiness only. Do not implement Shell/Meridian UI.

Inspect:

- `AppUI/`
- `Native/Ambitions/App`
- `Native/Ambitions/Features/Today`
- `Native/Ambitions/Features/Captures`
- `Native/Ambitions/Features/Plan`
- `Native/Ambitions/Features/Goals`
- `Native/Ambitions/Features/Profile`
- `Native/AmbitionsTests`
- `Native/AmbitionsUITests`
- widget and App Intent files if present

Create `docs/audits/ambitions-3-0-f17-shell-meridian-readiness-report.md` with:

- current shell/navigation architecture
- current top-level destination access
- route ownership map
- deep link map
- App Intent handoff map
- widget/external surface implications
- fallback navigation plan
- feature flag plan
- rollback plan
- one-tap destination access plan
- accessibility fallback plan
- UI tests needed
- files F18 may touch
- files F18 may not touch
- F18 implementation plan
- F17 gate: Green / Yellow / Red

F17 Green requires:

- F18 can be feature-flagged
- fallback navigation remains available
- top-level destinations remain reachable
- route parity can be tested
- accessibility fallback is clear
- rollback is clear
- no shell ownership ambiguity remains
- no dependency/workflow changes are needed

Validate:

```bash
git status --short
scripts/build-local.sh
scripts/batch-train-gate-check.sh || true
scripts/swiftui-architecture-scan.sh || true
git diff --check
```

If Green, commit and push F17, then continue to F18. If Yellow/Red, stop and write a repair/decision prompt.

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

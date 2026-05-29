# AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: duplicate_stable_id, retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge, Rewrite
> Candidate references: AMB28-duplicate_stable_id-30694637, AMB28-retired_ia_or_terminology_reference-3940871, AMB28-same_source_file_targeted_by_multiple_active_batches-83525689, AMB28-same_surface_multiple_active_batches-66075429

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-authority, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: supporting install report

Supporting note: This report documents a docs/control-plane-only install layer.
It does not override `docs/truth/*`.

## Summary

Installed a subordinate ChatGPT-to-Codex handoff layer under
`docs/codex/chatgpt/` and added matching prompt templates under
`prompts/templates/` without changing app source, runner scripts, or active
canon.

## Existing repo OS paths discovered

- `docs/truth/README.md`
- `docs/codex/CODEX_OS_INDEX.md`
- `docs/codex/os/README.md`
- `.codex/README.md`
- `docs/governance/CODEX_OS_INTEGRATION.md`
- `docs/governance/GOVERNANCE_DASHBOARD.md`
- `docs/governance/AUTONOMY_COMMANDS.md`
- `prompts/_BATCH_TEMPLATE.md`
- `prompts/templates/AMBITIONS_REMAINING_BATCH_EXECUTION_STANDARD.md`

## ChatGPT OS artifacts installed

- `docs/codex/chatgpt/README.md`
- `docs/codex/chatgpt/AMB-CHATGPT-HANDOFF-OS.md`
- `docs/codex/chatgpt/AMB-CHATGPT-TO-CODEX-PROMPT-STANDARD.md`
- `docs/codex/chatgpt/AMB-CHATGPT-REPO-QUESTION-PATTERNS.md`
- `docs/codex/chatgpt/AMB-CHATGPT-DECISION-LOG-STANDARD.md`
- `docs/codex/chatgpt/AMB-CHATGPT-LAUNCH-SCOPE-DECISIONS.md`
- `docs/codex/chatgpt/AMB-CHATGPT-FLAGSHIP-BAR.md`
- `docs/codex/chatgpt/AMB-CHATGPT-CODEX-HANDOFF-TEMPLATE.md`
- `docs/codex/chatgpt/AMB-CHATGPT-REVIEW-PROMPT-TEMPLATE.md`
- `docs/codex/chatgpt/AMB-CHATGPT-UI-PROMPT-TEMPLATE.md`
- `docs/codex/chatgpt/AMB-CHATGPT-BACKEND-PROMPT-TEMPLATE.md`
- `docs/codex/chatgpt/AMB-CHATGPT-APPLE-CONTINUITY-PROMPT-TEMPLATE.md`
- `docs/codex/chatgpt/AMB-CHATGPT-APP-STORE-HONESTY-PROMPT-TEMPLATE.md`
- `docs/codex/chatgpt/AMB-CHATGPT-REVIEW-BOARD-STANDARD.md`

## Templates installed

- `prompts/templates/ambitions-runner-batch-template.md`
- `prompts/templates/ambitions-audit-template.md`
- `prompts/templates/ambitions-repair-template.md`
- `prompts/templates/ambitions-ui-flagship-template.md`
- `prompts/templates/ambitions-backend-local-first-template.md`
- `prompts/templates/ambitions-apple-continuity-template.md`
- `prompts/templates/ambitions-launch-gate-template.md`

## Decision log installed or updated

- `docs/codex/chatgpt/AMB-CHATGPT-LAUNCH-SCOPE-DECISIONS.md`

The log keeps `Time` as active top-level IA and treats `Plan` as an internal
compatibility seam only where active truth allows it.

## Review boards installed or updated

- `docs/codex/chatgpt/AMB-CHATGPT-REVIEW-BOARD-STANDARD.md`

The standard covers the eight required review-board categories and points back
to existing `.codex/review-boards/` operational precedent rather than creating
a competing repo OS.

## Validation

- `git diff --check` passed.
- `rg -n "[ \t]+$" docs/codex/chatgpt docs/codex/reports/AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01.md prompts/templates/ambitions-*.md prompts/batches/AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01.md` found no trailing whitespace in the installed docs/templates/prompt.
- `make batch-self-check` passed Green.
- `make prompt-audit` returned Yellow as expected for prompt-like
  support/eval/template files; no active runnable prompt was missing metadata.
- `python3 scripts/ambitions-codex-os-validate.py` passed Green.
- `build/reports/ambitions-codex-os-validate.json` was restored after validation
  so generated report churn is not part of this install.

No app build, simulator test, device test, accessibility proof run, privacy
review, continuity proof, TestFlight validation, or App Store validation was run
because this is a docs/control-plane-only install.

## Risks

The main risk is duplication if future work starts treating `docs/codex/chatgpt/`
as an authority root instead of a support layer. That risk is controlled here by
linking back to `docs/truth/*` and the existing Codex OS docs.

## Worktree hygiene

Current branch is `main` at `0d90ad8270f0caadcd556f543549ae3d26d244f9`.
This pass remained path-limited to the approved docs/template additions, the
batch prompt, and this report file. A separate untracked prompt,
`prompts/batches/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md`, is present and
was not inspected as part of this batch scope. No app source, runner script,
active truth file, project file, package manifest, or generated run directory
was changed.

## Rollback

Path-limited restore:

```bash
git restore -- docs/codex/chatgpt docs/codex/reports/AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01.md prompts/templates
```

If the new files need to be removed instead of restored, delete only the
approved new paths.

## Recommended next command

```bash
git diff --check
```

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

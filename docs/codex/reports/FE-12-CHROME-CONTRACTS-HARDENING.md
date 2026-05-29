# FE-12 Chrome Contracts Hardening

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: duplicate_stable_id, same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-duplicate_stable_id-9737119, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-authority, merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: YELLOW

## Summary

Docs-only hardening landed for the frontend chrome contract and anti-generic control plane.

The patch:

- binds the shell to the active five destinations and flagship objects
- makes source freshness, local proof, receipt paths, and accessibility fallbacks explicit contract terms
- strengthens the chrome doctrine with proof/fallback language
- tightens anti-slop and anti-generic filters
- keeps `docs/canon/frontend/` out of the authority path and points to the live `frontend/visual-encyclopedia/` root
- adds rollback guidance scoped to the edited docs

No app source was changed.

## Repo OS / Repo Doctor Integration

- Not run for app validation.
- This phase stayed in docs/control-plane scope only.

## Files Changed

- `docs/codex/batch-trains/amb-fe-be/AMB-FE-BE-CONTRACTS.md`
- `docs/codex/batch-trains/amb-fe-be/AMB-FE-BE-IMPLEMENTATION-RISKS.md`
- `frontend/visual-encyclopedia/CHROME_ENRICHMENT_DOCTRINE.md`
- `frontend/visual-encyclopedia/VISUAL_ANTI_SLOP_RULES.md`
- `frontend/visual-encyclopedia/behavior/ANTI_GENERIC_KILL_SWITCHES.md`
- `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`
- `docs/codex/reports/FE-12-CHROME-CONTRACTS-HARDENING.md`

## Installed Train Location

- `docs/codex/batch-trains/amb-fe-be/`
- `prompts/batches/amb-fe-be/`
- live frontend authority root: `frontend/visual-encyclopedia/`

## Recommended Next Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  FE-12-CHROME-CONTRACTS-HARDENING \
  prompts/batches/amb-fe-be/FE-12-CHROME-CONTRACTS-HARDENING.md
```

## Validation

### Passed

- `git diff --check`
- `make prompt-audit`
- `make visual-validators`
- `make frontend-proof-contract-check`
- `make design-system-contracts` returned YELLOW with classification counts, not a hard failure

### Red

- `make frontend-drift-check`
- `make visual-100-anti-generic`

### Notes on Red

- `frontend-drift-check` reports pre-existing signature-instrument drift in generated frontend prompt material, including a missing signature instrument requirements section and missing root bindings for the top-level surfaces.
- `visual-100-anti-generic` flags an existing anti-pattern phrase in `frontend/visual-encyclopedia/DESIGN_LANGUAGE_DOCTRINE.md`.
- Those failures sit outside the approved Phase 02 edit seam, so they were not repaired here.

## Classification

- Docs-only control-plane hardening
- No implementation proof
- No visual proof
- No accessibility conformance proof
- No release proof

## Risks / Blockers

- Repo-wide drift gates are still red outside the approved patch boundary.
- UI-affecting handoff references are now required by the docs, but this batch did not produce screenshots or accessibility evidence.
- The generated prompt and the anti-generic doctrine still need a separate repair batch if the repo is expected to go fully green.

## Worktree Hygiene

- `git diff --check` passed.
- The worktree is intentionally dirty only with the approved docs/report edits from this phase.

## Rollback

Restore only the edited docs and remove the report file:

```bash
git restore -- \
  docs/codex/batch-trains/amb-fe-be/AMB-FE-BE-CONTRACTS.md \
  docs/codex/batch-trains/amb-fe-be/AMB-FE-BE-IMPLEMENTATION-RISKS.md \
  frontend/visual-encyclopedia/CHROME_ENRICHMENT_DOCTRINE.md \
  frontend/visual-encyclopedia/VISUAL_ANTI_SLOP_RULES.md \
  frontend/visual-encyclopedia/behavior/ANTI_GENERIC_KILL_SWITCHES.md \
  frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md
rm -f docs/codex/reports/FE-12-CHROME-CONTRACTS-HARDENING.md
```

## Next Decision Needed From User

- Approve a separate repair batch for the pre-existing drift gates, or stop here with the docs-only hardening.

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

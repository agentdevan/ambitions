# FE-12 Chrome Contracts Hardening

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

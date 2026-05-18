# AMB-FE-BE-IMPLEMENTATION-TRAIN-INSTALL-00

Status: YELLOW

## Summary

Installed the AMB-FE-BE train as a docs/prompts package only.

- Added train docs under `docs/codex/batch-trains/amb-fe-be/`
- Added 23 runner prompts under `prompts/batches/amb-fe-be/`
- Added discoverability links in `docs/README.md`, `docs/codex/BATCH_REGISTRY.md`, and `docs/codex/CONTEXT_INDEX.md`
- Did not touch app source, tests, project wiring, signing, or workflows

## Repo OS / Repo Doctor integration

- `make runner-access-check`: GREEN
- `make batch-self-check`: GREEN
- `make prompt-audit`: YELLOW, but no active runnable prompt was missing metadata
- `scripts/ambitions-codex-train.sh --help`: GREEN
- `python3 scripts/ambitions-swift6-modernization-scan.py --help`: GREEN

## Files changed

- `docs/codex/batch-trains/amb-fe-be/README.md`
- `docs/codex/batch-trains/amb-fe-be/AMB-FE-BE-IMPLEMENTATION-MANIFEST.md`
- `docs/codex/batch-trains/amb-fe-be/AMB-FE-BE-IMPLEMENTATION-STATUS.md`
- `docs/codex/batch-trains/amb-fe-be/AMB-FE-BE-IMPLEMENTATION-RISKS.md`
- `docs/codex/batch-trains/amb-fe-be/AMB-FE-BE-EXECUTION-ORDER.md`
- `docs/codex/batch-trains/amb-fe-be/AMB-FE-BE-CONTRACTS.md`
- `prompts/batches/AMB-FE-BE-IMPLEMENTATION-TRAIN-INSTALL-00.md`
- `prompts/batches/amb-fe-be/AMB-FE-BE-PREFLIGHT-00.md`
- `prompts/batches/amb-fe-be/AMB-FE-BE-CONTRACT-FREEZE-01.md`
- `prompts/batches/amb-fe-be/BE-01-RUNTIME-BASELINE.md`
- `prompts/batches/amb-fe-be/BE-02-LEDGER-REPLAY.md`
- `prompts/batches/amb-fe-be/BE-03-REALITY-MERIDIAN-CAPACITY.md`
- `prompts/batches/amb-fe-be/BE-04-RECOMMENDATION-DETERMINISM.md`
- `prompts/batches/amb-fe-be/BE-05-PROOF-FRESHNESS-RECEIPTS.md`
- `prompts/batches/amb-fe-be/BE-06-PROTECTED-TIME-PRIVACY.md`
- `prompts/batches/amb-fe-be/BE-07-VERTICAL-SLICE-PROOF.md`
- `prompts/batches/amb-fe-be/BE-08-DIAGNOSTICS-MIGRATION-HARDENING.md`
- `prompts/batches/amb-fe-be/FE-01-CANON-FREEZE.md`
- `prompts/batches/amb-fe-be/FE-02-DESIGN-LANGUAGE.md`
- `prompts/batches/amb-fe-be/FE-03-TOKENS.md`
- `prompts/batches/amb-fe-be/FE-04-PRIMITIVES.md`
- `prompts/batches/amb-fe-be/FE-05-GEOMETRY-REALITY-MERIDIAN.md`
- `prompts/batches/amb-fe-be/FE-06-SHELL-MIGRATION.md`
- `prompts/batches/amb-fe-be/FE-07-ROOT-SURFACES.md`
- `prompts/batches/amb-fe-be/FE-08-PROOF-RECEIPTS-TRUST.md`
- `prompts/batches/amb-fe-be/FE-09-COMPONENT-SYSTEM.md`
- `prompts/batches/amb-fe-be/FE-10-INTERACTION-ACCESSIBILITY.md`
- `prompts/batches/amb-fe-be/FE-11-PREVIEWS-VISUAL-QA.md`
- `prompts/batches/amb-fe-be/FE-12-CHROME-CONTRACTS-HARDENING.md`
- `prompts/batches/amb-fe-be/AMB-FE-BE-INTEGRATED-PROOF-99.md`
- `docs/README.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`

## Installed train location

- `docs/codex/batch-trains/amb-fe-be/`
- `prompts/batches/amb-fe-be/`

## Recommended next runner command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  AMB-FE-BE-PREFLIGHT-00 \
  prompts/batches/amb-fe-be/AMB-FE-BE-PREFLIGHT-00.md
```

## Full recommended execution order

1. `AMB-FE-BE-PREFLIGHT-00`
2. `AMB-FE-BE-CONTRACT-FREEZE-01`
3. `BE-01-RUNTIME-BASELINE`
4. `BE-02-LEDGER-REPLAY`
5. `BE-03-REALITY-MERIDIAN-CAPACITY`
6. `BE-04-RECOMMENDATION-DETERMINISM`
7. `BE-05-PROOF-FRESHNESS-RECEIPTS`
8. `BE-06-PROTECTED-TIME-PRIVACY`
9. `BE-07-VERTICAL-SLICE-PROOF`
10. `BE-08-DIAGNOSTICS-MIGRATION-HARDENING`
11. `FE-01-CANON-FREEZE`
12. `FE-02-DESIGN-LANGUAGE`
13. `FE-03-TOKENS`
14. `FE-04-PRIMITIVES`
15. `FE-05-GEOMETRY-REALITY-MERIDIAN`
16. `FE-06-SHELL-MIGRATION`
17. `FE-07-ROOT-SURFACES`
18. `FE-08-PROOF-RECEIPTS-TRUST`
19. `FE-09-COMPONENT-SYSTEM`
20. `FE-10-INTERACTION-ACCESSIBILITY`
21. `FE-11-PREVIEWS-VISUAL-QA`
22. `FE-12-CHROME-CONTRACTS-HARDENING`
23. `AMB-FE-BE-INTEGRATED-PROOF-99`

## Validation

- `git status --short --branch`: showed the installer prompt, new train package files, report, and discoverability edits
- `make runner-access-check`: GREEN
- `make batch-self-check`: GREEN
- `make prompt-audit`: YELLOW, but no active runnable prompt missing metadata
- `scripts/ambitions-codex-train.sh --help`: GREEN
- `python3 scripts/ambitions-swift6-modernization-scan.py --help`: GREEN
- `git diff --check`: GREEN
- `make help`, `make doctor`, `make validate`, and `make test`: unavailable in this Makefile

## Classification

- Docs-only installer
- No app source changed
- No implementation proof claimed
- No release proof claimed
- No device, accessibility, or privacy approval claimed

## Risks / blockers

- `python3 scripts/ambitions-codex-os-validate.py --help` behaved as validation, rewrote `build/reports/ambitions-codex-os-validate.json`, and that generated report was restored before closeout.
- The saved installer prompt remains untracked as part of this installer: `prompts/batches/AMB-FE-BE-IMPLEMENTATION-TRAIN-INSTALL-00.md`
- Future batches must keep the new train docs supporting-only and avoid duplicating active authority

## Worktree hygiene

- Kept the batch bounded to the allowed docs/prompts/discoverability surfaces
- Did not stage or touch `.codex/runs/`
- Restored the generated `build/reports/ambitions-codex-os-validate.json` rewrite caused by validation discovery

## Rollback

```bash
git restore -- docs/README.md docs/codex/BATCH_REGISTRY.md docs/codex/CONTEXT_INDEX.md
rm -rf docs/codex/batch-trains/amb-fe-be prompts/batches/amb-fe-be prompts/batches/AMB-FE-BE-IMPLEMENTATION-TRAIN-INSTALL-00.md .codex/reports/AMB-FE-BE-IMPLEMENTATION-TRAIN-INSTALL-00.md
```

`build/reports/ambitions-codex-os-validate.json` was restored before closeout.

## Next decision needed from user

- Run `AMB-FE-BE-PREFLIGHT-00`
- Or revise the installed train docs/prompts before execution

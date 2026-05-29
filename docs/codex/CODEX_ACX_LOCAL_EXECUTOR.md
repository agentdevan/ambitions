# ACX Local Executor

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-28141868, AMB28-same_source_file_targeted_by_multiple_active_batches-32243448, AMB28-same_surface_multiple_active_batches-13212827

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active local-only executor protocol for Ambitions Codex OS; not build, test, release, or app behavior proof.
Date: 2026-05-07

## Separation Of Duties

- `scripts/ai/acx.py` is non-executing. It reads bounded files, summarizes saved logs, groups saved status text, runs advisory scans, and prints gate reports.
- `scripts/ai/acx_local.py` is the only ACX command runner. It runs named allowlisted profiles only.
- `scripts/ai/acx` and `scripts/ai/acx-local` are thin wrappers.

## Safety Rules

- No arbitrary shell strings.
- No `shell=True`.
- Commands are argv arrays.
- Unknown profiles fail with exit code `2` and execute nothing.
- Destructive command terms fail before execution with exit code `2`.
- ACX Local never stages, commits, pushes, resets, cleans, deletes, switches branches, runs `sudo`, or runs `bash -c` / `sh -c`.
- Optional unavailable tools produce Yellow summaries, not hard Red.

## Raw Logs

Each run writes:

- full raw output to `.codex/logs/YYYY-MM-DDTHH-MM-SS/<profile>.raw.log`
- compact summary to `.codex/logs/YYYY-MM-DDTHH-MM-SS/<profile>.summary.md`

The terminal summary must always print the raw log path. `.codex/logs/` is local-only and gitignored.

## Profiles

The active profile map lives in `.codex/manifests/acx-command-profiles.yml`.

Required examples:

```bash
python3 scripts/ai/acx.py --help
python3 scripts/ai/acx_local.py list
python3 scripts/ai/acx_local.py run status
python3 scripts/ai/acx_local.py run changed-files
python3 scripts/ai/acx_local.py run diff-compact
python3 scripts/ai/acx_local.py run acx-gate-all
python3 scripts/ai/acx_local.py run xcodegen-generate
scripts/ai/acx-local run status
```

## Local Overrides

Optional local overrides may live at `.codex/local/acx-local-overrides.yml`. They must stay gitignored, must use argv arrays, and still pass destructive-term checks. They are for local operator convenience only and are not source truth.

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

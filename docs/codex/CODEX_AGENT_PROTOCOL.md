# Codex Agent Protocol

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-file-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active agent behavior protocol.  
Date: 2026-05-07  
Scope: How repo-enabled Codex sessions should operate in Ambitions.

## Start Sequence

1. Read the current user directive.
2. Read `AGENTS.md`.
3. Read `docs/codex/CODEX_OS_INDEX.md`.
4. Select one route file under `.codex/routes/`.
5. Name allowed files, forbidden files, validation tier, and stop conditions.
6. Execute the smallest safe patch.
7. Close with Green / Yellow / Red and evidence.

## Default Bounded Reads

```bash
python3 scripts/ai/acx.py read AGENTS.md --lines 140
python3 scripts/ai/acx.py read docs/codex/CODEX_OS_INDEX.md --lines 160
python3 scripts/ai/acx.py read .codex/reports/current-batch-train-state.md --lines 180
```

## Editing Rules

- Preserve existing Codex OS history.
- Prefer additive owner files over rewriting old reports.
- Use `.codex/state/` for compact durable snapshots, not historical proof.
- Use `.codex/routes/` to reduce context load.
- Do not modify app source during Codex OS tooling/docs passes.
- Do not add dependencies for tooling unless explicitly approved.
- Keep scripts deterministic and advisory by default.

## Reporting Rules

Every meaningful run ends with:

```text
Result: Green / Yellow / Red
Files changed:
Commands run:
Exit codes:
Evidence:
Known limitations:
Next eligible action:
```

## Fall Back Rules

If ACX is unavailable, use normal file reads and bounded shell output. ACX is an efficiency layer, not a hard dependency.

If route files are stale, use the peak protocol and current batch-train state as the higher-trust source, then update the route file in a Codex OS maintenance pass.

## Stop Rules

Stop on unrecoverable Red, unknown dirty tree, source-truth conflict, destructive overwrite need, privacy/security ambiguity, unsupported release claim, or repeated same-root Red after two repair attempts.

## Continue Rules

Continue through Green and accepted Yellow only when the selected protocol permits it. For global trains, follow `docs/codex/CODEX_BATCH_TRAIN_PROTOCOL.md` and `.codex/reports/current-batch-train-state.md`.

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

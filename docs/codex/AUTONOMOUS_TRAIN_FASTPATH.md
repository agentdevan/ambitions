# Autonomous Train Fastpath

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active speed-layer governance  
Date: 2026-05-13

## Purpose

The autonomous train fastpath exists to speed up the existing Ambitions loop:

```text
Install -> Review -> Advance Train -> Push -> Repeat
```

It does not replace the Ambitions runner. It routes to the next batch, applies HBI/MRI guardrails, delegates execution to the runner, and reduces repeated manual decision overhead.

## Primary command

```bash
make autonomous-train
```

The fastpath wrapper is:

```bash
python3 scripts/ambitions-autonomous-train-fastpath.py --until-complete
```

## Installed helpers

```text
scripts/ambitions-next-batch-router.py
scripts/ambitions-owned-files-detector.py
scripts/ambitions-batch-closeout-accelerator.py
scripts/ambitions-red-repair-router.py
scripts/ambitions-autonomous-train-fastpath.py
```

## Operating rules

- Do not add new tests for speed-layer operation.
- Use existing guards and validators only.
- Do not bypass `scripts/ambitions-codex-train.sh`.
- Do not bypass canonical queue truth.
- Do not stage unrelated files.
- Do not stage `.codex/runs`, Xcode logs/results, DerivedData, or unrelated generated artifacts.
- Do not make release, device, App Store, TestFlight, accessibility, privacy/legal, or commercial-readiness claims.
- HBI and MRI overlays must be factored into every applicable batch.

## Quick commands

```bash
python3 scripts/ambitions-autonomous-train-fastpath.py --status
python3 scripts/ambitions-autonomous-train-fastpath.py --next
python3 scripts/ambitions-autonomous-train-fastpath.py --once --dry-run --no-push
python3 scripts/ambitions-next-batch-router.py --dry-run --prefer-hbi
python3 scripts/ambitions-owned-files-detector.py --batch <BATCH_ID> --print-git-add
python3 scripts/ambitions-red-repair-router.py --json < failure.log
```

## Claim boundary

This speed layer is orchestration support only. It is not product implementation proof, test proof, build proof, release proof, or device proof.

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

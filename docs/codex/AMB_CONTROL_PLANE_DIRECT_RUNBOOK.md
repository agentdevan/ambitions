# Ambitions Direct Control-Plane Runbook

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: active supporting runbook  
Date: 2026-05-10  
Owner posture: local read-only control-plane checks, not product implementation proof

## Purpose

This runbook records the direct Pro-installed control-plane checks that can be run without Codex to prevent unsafe queue advancement, stale state mirrors, generic Source Atlas labels, weak final reports, and forbidden release/readiness claims.

These checks do not mutate the repo and do not replace the Ambitions runner. They are preflight/adjudication gates.

## Commands

### Queue/state snapshot

```bash
python3 scripts/ambitions-queue-snapshot.py
python3 scripts/ambitions-queue-snapshot.py --strict
python3 scripts/ambitions-queue-snapshot.py --json
```

Use before running the next batch. `--strict` returns non-zero on Red conditions.

### Source Atlas title check

```bash
python3 scripts/ambitions-source-atlas-title-check.py
python3 scripts/ambitions-source-atlas-title-check.py --strict
python3 scripts/ambitions-source-atlas-title-check.py --json
```

Use after queue/reference updates. Generic `SA11`, `SA12`, etc. titles are defects when the SA train manifest has normalized titles.

### Final report gate

```bash
python3 scripts/ambitions-final-report-gate.py docs/audits/<report>.md
python3 scripts/ambitions-final-report-gate.py docs/audits/<report>.md --strict
```

Use before accepting a Codex/runner final report as Green or Accepted Yellow.

### Aggregate control-plane gate

```bash
python3 scripts/ambitions-control-plane-check.py
python3 scripts/ambitions-control-plane-check.py --json
python3 scripts/ambitions-control-plane-check.py --final-report docs/audits/<report>.md
```

Use as the single high-level gate before advancing the train.

## Expected current posture

The live repo state observed during installation had already advanced beyond the earlier PK16 assumption:

```text
PK16 Trust History Query: Green
Next eligible: PK17 Today Read Model Extraction
```

Therefore the checks are intentionally state-driven. They should follow current live mirrors and should not pull the repo backward to stale assumptions.

## Red conditions these checks are designed to catch

- active queue mirrors disagree on the next batch
- stale PK14/PK15 references remain active-looking after PK16 Green
- canonical or remaining queue data contains generic Source Atlas titles where manifest titles exist
- required queue/reference JSON is invalid
- required control-plane files are missing
- final report lacks required Ambitions closeout sections
- final report contains release/readiness phrases without clear non-claim framing

## Non-claims

These checks do not prove:

- app build success
- XcodeGen success
- unit test success
- UI visual quality
- accessibility conformance
- performance readiness
- privacy/legal approval
- TestFlight/App Store readiness
- physical-device behavior
- production readiness
- global train completion

## Next integration target

A future bounded control-plane batch may wire these scripts into Makefile targets after local validation. Until then, use the Python commands directly.

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

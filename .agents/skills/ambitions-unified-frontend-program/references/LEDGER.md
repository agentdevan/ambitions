# Unified ledger contract

`PROGRAM.json` is the durable program record. Generated `STATUS.md` is a view,
not authority. The repository tracker accepts schema version 2 only.

## Unified identity

The ledger must declare:

- `program`: `Ambitions Unified Maximum Polish Frontend Program`;
- `program_kind`: `unified_frontend`;
- `single_authoritative_program`: `true`;
- `foundry.role`: `fixture_rendering_and_proof_harness`;
- `foundry.authority`: `subordinate`;
- `foundry.renders_canonical_ui`: `true`;
- `foundry.owns_canonical_ui`: `false`.

Milestones are exactly `UFP-0` through `UFP-8` in order. Each has a label, a
`COMPLETE`, `ACTIVE`, or `QUEUED` status, a nonempty `owner`, nonempty
`entry_conditions`, `exit_conditions`, and `proof_required` arrays, an
`evidence` array, and a `depends_on` array containing only earlier milestones.
Completed milestones require evidence. At most one milestone is active,
completed milestones form a prefix, and active/completed dependencies are
complete.

## Approval separation

`approvals` has five independent boolean fields:

- `frontend_design`
- `runtime_integration`
- `production_cutover`
- `legacy_deletion`
- `release`

All default false. The legacy `authorization` object remains only as a
fail-closed compatibility surface. Unified approvals may advance while either
legacy alias remains `false`. `production_integration_authorized=true` requires
`runtime_integration=true`. `approved_for_swiftui=true` is reserved for the
stricter historical ceiling: all five unified approvals, completed UFP-8,
verified zero legacy with evidence, and complete native/device proof for every
retained component. Neither alias replaces or collapses unified approvals.

## Legacy contract

`legacy_frontend` must declare:

- `disposition`: `delete_all`;
- `reuse_boundary`: `nonvisual_runtime_behavior_only`;
- `zero_legacy_required`: `true`;
- `verification.status`: `not_started` or `complete`;
- `verification.evidence`: an array, nonempty when status is complete.

Zero legacy means no prior frontend source, component, package product, target,
dependency, import, asset, route, preview, UI test, feature flag, compatibility
wrapper, or unclassified frontend file remains. Version control and the prior
release are rollback; dormant legacy source is not.

## Component compatibility

Schema v2 preserves the established component records and checks:

- unique nonempty component IDs and one existing `next_component_id`;
- the `next_component_id` record has design status `next` or `active`;
- at most one active component;
- design states `queued`, `next`, `active`, `owner_approved_direction`,
  `complete`, or `blocked`;
- research, audit, exploration, and five ordered pass statuses;
- current source and access-date evidence for completed research;
- evidence for every completed stage;
- nonempty SWOT, review, repair, gap, polish, and evidence for each completed
  pass;
- completed prerequisites and prior passes before a pass starts;
- completed research, audit, exploration, and five passes before an approved
  or complete design;
- P01-P15 dispositions and a proof ceiling at owner review;
- native and physical-device proof for any retained legacy
  `approved_for_swiftui=true` claim.

Owner decisions are append-only. Preserve rejected and superseded records.

## Gate contract

- `owner-review`: component research, audit, exploration, five passes, P01-P15,
  and proof ceiling.
- `frontend-complete`: UFP-5 complete and `approvals.frontend_design=true`.
- `runtime-integration`: frontend-complete plus
  `approvals.runtime_integration=true`.
- `cutover`: UFP-6 complete plus `approvals.production_cutover=true` and
  `approvals.legacy_deletion=true`.
- `release`: UFP-7 and UFP-8 complete, zero-legacy verification complete with
  evidence, and `approvals.release=true`.

## Drift and commands

Compare live branch, HEAD, and status against `repository.last_verified`. Drift
blocks execution until the ledger is refreshed from live truth. Never clean or
reset user changes to force parity.

```bash
TRACKER=.agents/skills/ambitions-unified-frontend-program/scripts/program_tracker.py
LEDGER=/Users/devan/.codex/output/Ambitions_Maximum_Polish_Program/PROGRAM.json

python3 "$TRACKER" status --ledger "$LEDGER"
python3 "$TRACKER" check --ledger "$LEDGER" --repo /Users/devan/Documents/GitHub/ambitions
python3 "$TRACKER" gate --ledger "$LEDGER" --component time-owner-taste-reselection --kind owner-review
python3 "$TRACKER" gate --ledger "$LEDGER" --kind frontend-complete
python3 "$TRACKER" gate --ledger "$LEDGER" --kind runtime-integration
python3 "$TRACKER" gate --ledger "$LEDGER" --kind cutover
python3 "$TRACKER" gate --ledger "$LEDGER" --kind release
python3 "$TRACKER" render --ledger "$LEDGER" --output /Users/devan/.codex/output/Ambitions_Maximum_Polish_Program/STATUS.md
```

# Visual 100 Source Debt Ledger

Status: Active source-link debt ledger

## Status Definitions

- `linked`: live source exists for the seam and the recipe can cite concrete source candidates.
- `weak_link`: source exists, but the match is approximate or compatibility-bound.
- `intended_only`: the recipe is canon, but the live source is not final-state matched.
- `missing`: no current source candidate is known.
- `needs_direction`: the canon has not resolved the shape well enough to link honestly.
- `obsolete`: the recipe is no longer active canon.
- `historical_only`: preserved only for traceability.

## Debt Rule

Source-present never means implementation-complete.

## P0 Debt Rule

Every P0 recipe marked `intended_only`, `weak_link`, or `missing` must be surfaced in the registry and dashboard.

## Closed Debt Rule

Debt only closes when the source-link status changes and the validator report reflects the change.

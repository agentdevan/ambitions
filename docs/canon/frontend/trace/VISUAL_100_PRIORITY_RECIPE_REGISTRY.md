# Visual 100 Priority Recipe Registry

Status: Active P0/P1/P2 recipe registry

This registry tracks the priority recipes that the final proof authority cares about first.

## Tier Rules

- `P0`: must be visible in the gate system and scorecards.
- `P1`: important support surface; gaps must be visible.
- `P2`: lower-risk support surface; preserve intent and note drift.

## Registry Contract

Each row records:

- tier
- surface ID
- surface name
- destination
- primary object
- recipe path
- source-link status
- implementation proof status
- required gates
- canon gate status; source-link debt is recorded separately and does not by itself mean the recipe failed
- notes

## Notes

- P0 source-link debt is expected to remain visible until implementation proves otherwise; intended-only rows may still have canon gate status `pass` when schema, object, accessibility, proof, transaction, and anti-generic gates pass.
- A `linked` source status does not imply implementation proof.

# Visual 100 Source Link Distribution

Status: Active source-link distribution note

This document is the human-facing distribution view for the source-link manifest. The machine-readable counts are produced by `scripts/ambitions-visual-100-source-debt-check.py`.

## Distribution Buckets

- linked
- weak_link
- intended_only
- missing
- needs_direction
- obsolete
- historical_only

## Reporting Rule

- linked counts do not imply implementation proof.
- intended_only counts are implementation debt, not failure of the canon itself.
- P0 intended_only debt must stay visible in the dashboard.

## Current Source of Truth

- `frontend/visual-encyclopedia/VISUAL_SOURCE_LINKS.yaml`

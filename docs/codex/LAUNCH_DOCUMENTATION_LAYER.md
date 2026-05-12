# Launch Documentation Layer

## Purpose

Generate local launch packet drafts from evidence files without readiness overclaim.

## Component

- `tools/openai/launch_docs/generate_launch_packet.py`

## Behavior

- Reads docs/audits reports.
- Identifies proof-backed lines.
- Lists missing-proof claim areas.
- Produces a dry-run JSON packet.

No release/availability claim is generated unless proof is present.

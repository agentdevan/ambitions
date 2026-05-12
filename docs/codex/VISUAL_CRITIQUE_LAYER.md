# Visual Critique Layer

## Purpose

Run local non-network visual review checks with fixed rubric dimensions.

## Components

- `tools/openai/visual_critique/rubrics/ambitions_visual_canon.json`
- `tools/openai/visual_critique/critique_visual_packet.py`

## Behavior

- Validates rubric JSON.
- Accepts screenshot file paths.
- Reports missing files.
- Prints dimension list for operator review.
- Does not upload screenshots.
- Never emits visual approval claims.

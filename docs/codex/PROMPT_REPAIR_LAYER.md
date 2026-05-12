# Prompt Repair Layer

## Purpose

Normalize and validate future prompts before batch execution.

## Components

- `scripts/ambitions-prompt-queue-consistency.py`: validates classification labels against live queue and run-state.
- `tools/openai/prompt_repair/repair_batch_prompt.py`: local metadata repair utility.

## Contract

- No PK28 execution.
- No core product changes.
- No host calls.
- No claims beyond local validation coverage.

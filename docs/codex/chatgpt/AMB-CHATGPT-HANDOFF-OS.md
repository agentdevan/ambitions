# AMB-CHATGPT-HANDOFF-OS

Status: supporting operating guide

This document defines the subordinate ChatGPT handoff layer for Ambitions.
It exists to turn a ChatGPT conversation into a bounded, executable Codex
prompt without creating a second authority root.

## What this layer does

- Converts user intent into a runner-compatible batch prompt.
- Forces active truth inspection before any patching or claim writing.
- Keeps scope narrow enough for a single bounded Codex pass.
- Preserves the active Ambitions canon and top-level IA.

## What this layer does not do

- It does not change product canon.
- It does not override `docs/truth/*`.
- It does not replace `scripts/ambitions-codex-train.sh`.
- It does not authorize app behavior, release claims, or implementation claims.

## Required flow

1. Identify the task type.
2. Inspect active truth first.
3. Identify the smallest safe file set.
4. Choose the correct prompt template.
5. Add the runner header.
6. State exact allowed and forbidden scope.
7. State validation and proof requirements.
8. State rollback expectations.

## Canon preserved by default

- Today / Goals / Capture / Time / You
- Time is active top-level IA.
- Plan is only an internal compatibility seam where active truth allows it.
- Local-first and proof-first behavior stays mandatory.

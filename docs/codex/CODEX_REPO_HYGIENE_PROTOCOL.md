# Codex Repo Hygiene Protocol

Status: Active Codex OS hygiene protocol.
Date: 2026-05-07

## Purpose

Keep Ambitions inspectable without deleting history or weakening source truth.

## Hygiene Coverage

- stale docs
- superseded docs
- duplicate concepts
- orphan scripts
- orphan Swift files
- dead routes
- generated artifacts
- local-only files
- ACX logs
- old batch reports
- accepted Yellow history
- no-overwrite rule
- no-double-work rule

## Rules

- Do not delete historical docs in a hygiene pass unless an owner doc explicitly says they are safe to remove.
- Prefer marking supersession and ownership over deletion.
- Do not rewrite accepted Yellow or hard Red history.
- Do not stage local-only logs, overrides, DerivedData, generated projects, or scratch output.
- Before creating a file, search for existing owner equivalents and update them when safe.
- Treat `.codex/state/*` and `.codex/manifests/*` as maps, not source truth.

## Generated And Local-Only Artifacts

Gitignored local-only paths include `.codex/logs/`, `.codex/local/`, and `output/logs/`.

## No-Overwrite Rule

Do not erase prior batch history, audit reports, Yellow truth, source-truth decisions, or validation failures. Append, supersede, or reconcile with an owner note.

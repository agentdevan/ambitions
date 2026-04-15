---
name: repo-truth-enforcer
description: Audit and fix mismatches between current Ambitions repo behavior and the claims made in docs, previews, comments, placeholder copy, or feature descriptions. Use when cleaning stale docs, making README or in-app copy truthful, removing outdated claims, or checking preview fixtures and profile/service messaging against the current native codebase; do not use for net-new feature implementation unless the task is specifically about truthfulness cleanup.
---

# Repo Truth Enforcer

## Purpose

Keep the repo honest by replacing stale or speculative claims with statements grounded in the code that exists today.

## When To Use

- `clean up stale docs`
- `make repo copy truthful`
- `remove outdated claims`
- audit README, docs, preview copy, profile copy, comments, or placeholders after architectural shifts

## When Not To Use

- The task is a normal feature build with only incidental text edits.
- The user wants product marketing copy detached from current repo behavior.
- The request is mainly UI styling; use `design-system-guard`.

## Required Inputs

- Current source files implementing the relevant behavior.
- Current docs and copy files.
- Preview fixtures and placeholder messaging when applicable.

## Execution Steps

1. Inspect current repo truth first. Prefer live native source files, `project.yml`, and the current doc index over older historical notes.
2. Audit the likely drift surfaces:
   - `README.md`
   - `docs/README.md`
   - native docs under `docs/`
   - preview fixtures and preview copy
   - profile/service/user-facing copy
   - inline comments that describe removed behavior
3. Replace stale statements with precise, current wording. Do not soften drift by leaving ambiguous language in place.
4. Flag absolute local paths, dead references, removed legacy files, and claims about unshipped sync/auth/backend features.
5. Keep the cleanup narrow. Update only the files needed to restore truth.

Use the audit templates in `templates/`:

- `templates/repo-truth-audit-checklist.md`
- `templates/stale-copy-audit-checklist.md`

## Output Format Expectations

When reporting the cleanup, include:

1. source of truth used
2. stale claims removed or corrected
3. files updated
4. any remaining docs that still look historical or ambiguous

## Validation Requirements

- Cross-check each corrected claim against current repo files.
- Avoid introducing new product promises or future-state wording unless explicitly labeled as planned.
- Re-read edited docs/copy after changes to ensure the language is crisp and not contradictory.

## Ambitions-Specific Guardrails

- The native SwiftUI app is the shipping product surface.
- Older TypeScript, Expo, Supabase-auth, and sync material may remain in history; do not treat it as live truth without current code evidence.
- Review preview fixtures and profile copy, not just Markdown docs.
- Treat `docs/implementation-backlog.md` and `docs/codex/repo-audit-baseline.md` as high-value truth sources, but still confirm against current files because docs can drift too.

## Trigger Phrases

- `clean up stale docs`
- `make repo copy truthful`
- `remove outdated claims`
- `audit repo truth after this refactor`

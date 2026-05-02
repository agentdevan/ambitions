# Global Batch Repair Loop Protocol

<!-- markdownlint-disable MD013 -->

Status: Ambitions 4.0 global Codex OS control; no queued train started
Date: 2026-05-02

## Purpose

This protocol defines how future Codex sessions repair Red failures and classify Yellow advisories without weakening Ambitions.

## Red Repair Loop

1. Stop forward progress.
2. Name the failing gate.
3. Identify the root cause from evidence, not guesswork.
4. Determine whether repair is in scope.
5. If in scope, make the smallest safe repair.
6. Do not remove tests to pass.
7. Do not weaken product canon to pass.
8. Do not delete compatibility safeguards to pass.
9. Do not loosen accessibility requirements to pass.
10. Do not remove validation requirements to pass.
11. Do not hide the failure in docs.
12. Do not replace Ambitions-specific product quality with generic language.
13. Do not broaden scope to avoid a hard problem.
14. Rerun the failing validation and any dependent gates.
15. Repeat until Green or accepted Yellow.
16. If safe repair is impossible, stop and write a Red repair report.

## Yellow Advisory Loop

1. Classify the Yellow.
2. Decide whether it must be fixed now.
3. Fix now if it affects the next batch, safety, release claims, product identity, architecture, compatibility, accessibility, or testing strength.
4. Defer only if already planned for a future batch or existing backlog.
5. Document the deferral owner.
6. Document why continuation is safe.
7. Continue only if all Red gates are clear.

## Forbidden Repair Tactics

- Making UI more generic to pass tests.
- Replacing visual orientation surfaces with stacked cards.
- Deleting product rules to avoid violations.
- Weakening PXOS canon or top-level composition law.
- Reducing accessibility expectations.
- Changing copy to vague productivity language.
- Removing trust/proof/receipt requirements.
- Hiding uncertainty.
- Claiming unsupported readiness.
- Adding new top-level surfaces.
- Turning Ambitions into a task app, habit tracker, calendar clone, dashboard, chatbot, or notes app.
- Bloated files instead of extraction.
- Adding dependencies to avoid clean implementation.
- Disabling tests without documented replacement or retirement.
- Editing tests to match broken behavior.
- Bypassing ME/CS gates.
- Making private assumptions about user data or personalization.
- Weakening release-claim gates.
- Weakening validation strength requirements.

## Safe Repair Criteria

A repair is safe only when it is scoped to the failing gate, preserves product intent, preserves compatibility, keeps validation at least as strong, avoids unrelated refactors, documents evidence, and leaves rollback possible.

## Test Rerun Expectations

- Rerun the exact failing command.
- Rerun adjacent focused tests or scans affected by the repair.
- For code repairs, run build/tests appropriate to the changed owner files.
- For docs repairs, rerun `git diff --check`, changed-file boundary, and relevant grep scans.
- Do not declare Green from a command that did not exercise the failure.

## Repair Report Criteria

Write a Red repair report when:

- Red cannot be repaired in scope.
- Human proof is required.
- Validation tooling is unavailable and no substitute is safe.
- A source-truth conflict blocks implementation.
- Repair would require forbidden files or explicit user approval.

The report must include failing gate, root cause, attempted repairs, validation results, why continuation is blocked, and exact next repair prompt.

## Rollback Criteria

Rollback or revert only the current batch's own changes when:

- The repair cannot be made safely.
- The batch introduced product/canon/compatibility/validation degradation.
- The branch cannot be made safe for commit.

Do not revert unrelated user changes.

## Product-Quality Protection

Product quality is part of correctness. A batch that passes tests by weakening Ambitions identity, accessibility, trust, compatibility, or release truth is Red.

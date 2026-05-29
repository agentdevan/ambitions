# Global Batch Repair Loop Protocol

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, terminology-quarantine
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

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
2. Classify it as Fix Now, Already Owned by Later Batch, Existing Repo-Wide
   Advisory, Tooling/Environment Advisory, Human-Proof Advisory, or Needs New
   Repair Batch.
3. Decide whether it must be fixed now.
4. Fix now if it affects the current batch, next batch safety, release claims,
   product identity, architecture, maintainability, compatibility,
   accessibility, validation strength, or source-truth integrity.
5. Defer only if it is already owned by a later batch, already part of the docs
   QA backlog, environment/tooling-only, human-proof-only, or fixing it now
   would create unsafe scope creep.
6. Document the deferral owner, why deferral is safe, whether it blocks later
   batches, and when it must be revisited.
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
- Turning Ambitions into a task app, habit tracker, calendar clone, surface, chatbot, or notes app.
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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->

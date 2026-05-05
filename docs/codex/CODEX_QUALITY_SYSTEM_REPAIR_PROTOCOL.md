# Codex Quality System Repair Protocol
<!-- markdownlint-disable MD013 -->

Status: Active CQS repair protocol
Date: 2026-05-05

## Classifications

- Green: batch scope complete, validation adequate or strong, no unresolved
  safety risk.
- Accepted Yellow: nonblocking risk is documented with owner, repair path, and
  explicit no-claim boundary.
- Recoverable Red: failure is caused by current work and can be repaired in
  scope without weakening canon, broad refactor, hidden mutation, or product
  invention.
- Hard Red: continuing would break the app, corrupt data, weaken canon, hide a
  security/privacy issue, require human proof, require unsupported legal/
  release claims, or require deleting tests/weakening gates.

## Repair Loop

1. Reproduce or identify the failure.
2. Classify whether it is current-batch-caused.
3. Repair only the smallest in-scope owner files.
4. Rerun the failed validation plus the minimum adjacent proof.
5. Repeat once if the second repair is narrower and evidence improves.
6. Split a repair batch only when the split lowers risk and has clear owner
   files.
7. Stop as Hard Red when no safe repair path remains.

## Accepted Yellow Rules

Accepted Yellow is allowed only when the remaining issue is non-destructive,
bounded, documented, and has an owner. It must not cover build failure, data
loss, security exposure, hidden mutation, unsupported claims, or product drift.

## Stop Report Requirements

A Hard Red stop report must include exact blocker, files touched, rollback path,
operator checklist, validation logs, evidence gaps, and the exact resume prompt
after the blocker is resolved.

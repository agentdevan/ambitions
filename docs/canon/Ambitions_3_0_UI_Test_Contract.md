# Ambitions 3.0 — UI Test Contract

Status: Active QA canon

## Purpose

UI tests protect user promises, routing contracts, copy contracts, and
accessibility contracts. They should not freeze arbitrary layout details or
block legitimate Ambitions 3.0 redesign work before classification.

## UI Test Classes

- Product contract test: protects a user promise or product outcome.
- Routing contract test: protects destination, deep link, App Intent, or shell
  route behavior.
- Copy contract test: protects user-facing language and deprecated-term
  migration.
- Accessibility contract test: protects labels, identifiers, focus order,
  Dynamic Type, or touch target behavior.
- Fixture/smoke test: proves a representative surface loads in a known state.
- Legacy compatibility test: protects old persisted/deep-link values during
  migration.
- Visual structure test: protects required hierarchy, not pixel-perfect layout.

## Required Metadata

Every UI test should be declared or classifiable by:

- user promise protected,
- owning canon doc,
- owning primitive,
- owning surface,
- stable accessibility identifier,
- fixture state,
- update trigger,
- whether it should survive redesigns.

## Failure Classification

Classify before fixing:

- outdated test expectation,
- real implementation bug,
- fixture drift,
- accessibility identifier drift,
- navigation drift,
- copy migration,
- product canon conflict,
- simulator/environment issue,
- flake.

## Rules

- UI tests protect user promises, not arbitrary layout structure.
- Accessibility identifiers are stable contracts.
- Visual layout changes should not break product contract tests.
- Tests failing after canon changes must be classified before being fixed.
- No UI test deletion without replacement or documented retirement.
- Every F-series implementation batch must update affected UI test contracts.

## Current Known State

The FAANG handoff and developer tooling reports record full UI smoke failures.
Do not claim FAANG handoff readiness until those failures are classified and
resolved or retired through this contract.

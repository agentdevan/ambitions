# Ambitions 3.0 Canon To Test Traceability Rules

Status: Active QA governance

## Purpose

Canon should produce testable user promises. Tests should point back to canon, not arbitrary implementation shape.

## Traceability Fields

- Canon doc.
- User promise.
- Primitive.
- Surface.
- Expected behavior.
- Test class.
- Test file/name.
- Fixture state.
- Accessibility identifier.
- Validation command.
- Release gate impact.

## Rules

- Product contract tests should survive visual redesign.
- Copy contract tests should protect canonical wording only when copy is itself the product promise.
- Accessibility identifiers are stable contracts and need migration plans.
- Canon changes that alter user promises require a test ownership review.

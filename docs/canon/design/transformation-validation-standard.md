# Transformation Validation Standard

## Purpose

Define the reusable validation doctrine for later front-end transformation batches.

This file covers how future implementation batches should be validated.
It does not require Batch 39 to claim app or runtime validation that was not run.

## Program-Wide Validation Expectations

Later transformation batches should validate, as applicable:

- docs-truth consistency across touched canon and product docs
- `xcodegen generate`
- native build validation
- targeted tests for touched surface, service, routing, or adapter areas
- full `AmbitionsTests`
- `AmbitionsUITests` where user-critical flows changed
- manual simulator review for the affected surface family
- accessibility review for hierarchy, readability, control clarity, and assistive-flow truth
- motion and reduce-motion review when interaction or transition behavior changes
- platform-truth review when a batch affects external or future-device surfaces

## Batch 39 Exception

Batch 39 is a docs/control-file batch only.
Its validation should report:

- docs truth sweep results
- link and file existence checks
- consistency across touched control files
- confirmation that Batch 39 docs do not contain shell or surface implementation instructions

Batch 39 must not claim:

- `xcodegen generate`
- native build validation
- targeted tests
- `AmbitionsTests`
- `AmbitionsUITests`
- manual simulator review

unless those were actually run for a separate justified reason and reported as such.

## Reporting Rules

- Separate `verified` from `not verified`.
- State clearly when a validation item is deferred to a later implementation batch.
- Do not describe expected later-batch validation as already completed work.

> Superseded document.
>
> This file is preserved for historical context only.
> Active canon now lives in:
> - `docs/canon/design/Ambitions_Design_Constitution.md`
> - `docs/canon/Ambitions_2_0_Implementation_Gap_Audit.md`
> - `docs/canon/Ambitions_2_0_Roadmap.md`
> - `docs/canon/Ambitions_2_0_Batch_Plan.md`
>
> Do not use this file as implementation source of truth.

# Transformation Validation Standard

Historical/superseded note: This file is preserved pre-Batch-61 frontend transformation context. Active Ambitions 2.0 validation truth now lives in [Ambitions_Design_Constitution.md](Ambitions_Design_Constitution.md), [accessibility-nutrition-screen-matrix.md](accessibility-nutrition-screen-matrix.md), and the current Ambitions 2.0 canon.

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

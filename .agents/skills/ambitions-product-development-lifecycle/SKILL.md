---
name: ambitions-product-development-lifecycle
description: Use when creating, reviewing, or consuming an Ambitions research, scope, or design document for a material product, UX, or architecture change; do not use for routine work whose behavior is already canonical.
---

# Ambitions product development lifecycle

## Choose the role

Choose exactly one role before acting: Producer, Content review, or Consumer.
Load the [lifecycle contract](references/lifecycle-contract.md), the applicable
role contract, and the matching phase rubric. Use the
[Research rubric](references/research-review-rubric.md),
[Scope rubric](references/scope-review-rubric.md), or
[Design rubric](references/design-review-rubric.md) for the document phase.
Do not blend authoring and review in one pass.

## Producer

Read the [producer contract](references/producer-contract.md). Select the exact
[Research template](assets/templates/v1/research.md),
[Scope template](assets/templates/v1/scope.md), or
[Design template](assets/templates/v1/design.md). Inspect current canon, source,
tests, evidence, and initiative files; record committed inputs and owner paths.
Create one self-contained canonical document, commit the completed draft, seal
that exact revision, then request Content review. Stop when evidence, access, or
owner decisions are insufficient.

## Content review

Review only a committed, sealed revision. Use the matching phase rubric to test
factual support, product logic, boundaries, privacy, accessibility, alternatives,
and internal consistency. Return the rubric's exact `PASS` or `NEEDS REVISION`
form and bind it to the revision and contract hash. Do not perform Consumer work.

## Consumer

Read the [consumer contract](references/consumer-contract.md). Verify the active
instruction chain, committed document, historical package, current compatibility,
seal, reviews, inputs, evidence, and relevant repository drift. Read the handoff
summary before needed detail. Use the matching phase rubric and return `PASS` or
`NEEDS REVISION` without inventing missing authority. Record a verdict only with
an explicit lifecycle command.

## Lifecycle boundaries

Use this workflow only for material behavior not already resolved by current
canon. Research gathers evidence; Scope commits product behavior; Design defines
implementation design. Research and Scope cannot authorize implementation.
Lifecycle documents propose canon changes but do not activate them.
A document PASS cannot authorize merge. This workflow grants no edit, approval, release, or
deployment authority.

## Commands

Run the [lifecycle CLI](scripts/ambitions_product_docs.py) from the repository
root. Use `package --check`, `new`, `check`, `hash`, `seal`, `review`, `reconcile`,
`consume`, and `supersede`. Write commands must be explicit; `package --check`,
`check`, `hash`, and `consume` are read-only.

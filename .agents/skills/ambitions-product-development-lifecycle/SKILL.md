---
name: ambitions-product-development-lifecycle
description: Use when turning a material Ambitions product, UX, or architecture idea into Research, Scope, Design, and implementation grooming documents; do not use for routine work whose behavior is already canonical.
---

# Ambitions product-development lifecycle

Use this as one continuing, conversational workflow with Devan. The durable
handoff is the initiative directory:

```text
docs/product-development/<initiative>/
├── research.md
├── scope.md
├── design.md
└── implementation/
    ├── plan.md
    ├── tasks.md
    └── verification.md
```

## Create

When Devan brings an idea, inspect the relevant canon, source, tests, and
available evidence. Read the [creation guidance](references/producer-contract.md)
and create the appropriate document from the matching template:
[Research](assets/templates/v1/research.md),
[Scope](assets/templates/v1/scope.md), or
[Design](assets/templates/v1/design.md).

Research explains the problem and evidence without committing scope or
implementation. Scope uses approved Research and commits the intended product
behavior without inventing implementation details. Design uses approved Scope
and defines flows, states, architecture, privacy, accessibility, traceability,
and verification in enough detail to groom implementation work.

## Review

Review the current document in the same conversation using its matching rubric:
[Research](references/research-review-rubric.md),
[Scope](references/scope-review-rubric.md), or
[Design](references/design-review-rubric.md). Return `PASS` when it is complete,
internally consistent, grounded in current repository truth, and has no blocking
finding. Otherwise return `NEEDS REVISION` with a concise list of blockers.

When Devan agrees, revise the document directly and review it again. Do not
create separate review artifacts, require recorded integrity state, replay
repository history, or use isolated reviewer sessions.

## Approve

Mark a document `status = "approved"` only after Devan explicitly approves it
and the ChatGPT review has no blocking finding. Research must be approved before
Scope, and Scope must be approved before Design. Approval does not authorize
implementation, merging, deployment, or release.

## Groom

After Design is approved, create `implementation/plan.md`,
`implementation/tasks.md`, and `implementation/verification.md`:

- The plan covers affected components, interfaces, data flow, persistence,
  migrations, canon changes, rollout concerns, and implementation order.
- The tasks are small and ordered, naming exact files, dependencies, acceptance
  criteria, and tests.
- Verification specifies the affected automated, build, runtime, accessibility,
  privacy, migration, performance, and device evidence.

Use an explicit `N/A` with a reason when a category does not apply. Keep every
engineering task traceable to a Design decision and every Design decision
traceable to a Scope `REQ-###` requirement. Grooming may resolve technical
details but must not invent product behavior; return to Scope or Design for any
new product decision.

## Boundaries and tooling

Current canon continues to govern until implementation deliberately updates the
owning canon sources. Stop and explain what is missing when repository access,
evidence, or a product decision is unavailable.

Use `scripts/ambitions_product_docs.py new` to create a phase document and
`scripts/ambitions_product_docs.py check` to validate initiative structure.
These tools do not review content, change approval state, authorize work, or
replace the conversational lifecycle.

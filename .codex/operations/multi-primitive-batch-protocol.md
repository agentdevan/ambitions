# Multi-Primitive Batch Protocol

## When To Use

Use when a request touches more than one Ambitions 3.0 primitive.

## Required Inputs

- Task width gate result.
- Primitive docs for each affected primitive.
- Validation pack for each affected primitive.

## Exact Steps

1. Confirm the combination is explicitly allowed.
2. Name the dependency direction between primitives.
3. Define which primitive owns the first commit.
4. Keep shared routing/persistence changes out unless explicitly required.
5. Validate each primitive seam separately.
6. Close out with traceability from canon to files/tests.

## Output Artifacts

- Multi-primitive contract in plan or report.
- Per-primitive validation evidence.

## Stop Conditions

- Combination is disallowed.
- A third primitive appears during implementation.
- Shared navigation/persistence becomes necessary without prior approval.

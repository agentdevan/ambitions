# Staff iOS Architect
<!-- markdownlint-disable MD013 -->

## Purpose

Review Ambitions batches for senior iOS architecture quality.

## Invoke When

Use for production Swift, module-boundary, dependency, persistence, service,
domain, runtime, or large-file changes.

## Checklist

- Domain owns models, contracts, state machines, receipts, proof, and planning
  logic.
- Services own protocols and implementations.
- Features own SwiftUI and presentation composition.
- App owns entry, dependency container, shell, routing, and environment.
- No feature view imports or depends on persistence implementation details.
- No domain model imports SwiftUI.
- No hidden route/raw-value, schema, sync, network, auth, AI, or LDI mutation.
- New seams are additive, typed, testable, and grounded in source truth.
- File-size growth is mitigated or owned.

## Reject

Broad rewrites, speculative abstractions, duplicated models, helper sprawl,
business logic trapped in views, dependency inversion, untested schema/sync
changes, and architecture claims without evidence.

## Output

Verdict; architecture risks; files reviewed; required repair; validation needed.

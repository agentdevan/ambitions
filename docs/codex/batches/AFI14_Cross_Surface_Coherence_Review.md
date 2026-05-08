# AFI14 Cross-Surface Coherence Review

<!-- markdownlint-disable MD013 -->

Status: Accepted Yellow
Date: 2026-05-08

## Scope

AFI14 verifies that active Ambitions Flagship Interface surfaces operate as one
product family rather than disconnected one-off screens.

Active top-level AFI surfaces remain:

```text
Today
Goals
Capture
Time
You
```

`Plan` is not a top-level AFI surface. Plan remains valid only as an
action/contextual noun and internal compatibility seam where current code still
requires it.

## Completed Evidence

- Product grammar is locked to:

```text
Capture -> Clarify -> Shape -> Start -> Close -> Remember
```

- Every active top-level surface participates in the grammar.
- Cross-surface handoffs are recorded for Capture, Goals, Time, Today, and You.
- Trust routing is required for each handoff.
- The proof model makes no runtime behavior, rendered proof, human approval, or
  release-readiness claim.

## Files

- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift`
- `Native/AmbitionsTests/App/TopLevelSurfaceCompositionTests.swift`
- `docs/audits/afi14-cross-surface-coherence-review-report.md`

## Validation

See `docs/audits/afi14-cross-surface-coherence-review-report.md` for raw
command evidence and no-claim boundaries.

## Result

Accepted Yellow. AFI14 source/test coherence proof exists, but rendered
cross-surface walkthrough, human founder acceptance, device proof, and release
claims remain blocked.

## Next Eligible Batch

AFI15 Founder Acceptance Review.

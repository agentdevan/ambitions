# AFI13 Visual QA And Drift Gallery

<!-- markdownlint-disable MD013 -->

Status: Accepted Yellow
Date: 2026-05-08

## Scope

AFI13 adds source/test visual QA scorecard and drift-gallery proof for the
active Ambitions Flagship Interface surfaces:

```text
Today
Goals
Capture
Time
You
```

`Plan` is not a top-level AFI surface. ACUI remains superseded by AFI for
active product/IA/UI/visual/copy decisions.

## Completed Evidence

- Active top-level surfaces are locked to Today / Goals / Capture / Time / You.
- Top-level scorecard targets are recorded:
  - Today: target 98, minimum 95.
  - Goals: target 95, minimum 95.
  - Capture: target 98, minimum 95.
  - Time: target 95, minimum 95.
  - You: target 95, minimum 95.
- Required rendered screenshot inventories are named for each surface.
- Drift gallery examples now carry Pass and Fail patterns for native shell,
  material grammar, Today, Goals, Capture, Time, You, Trust, and Continuity Dock.
- All scorecards remain Yellow until rendered screenshots and human visual
  review exist.

## Files

- `Sources/Previews/SignatureInterfaceVisualQAFixtures.swift`
- `Sources/Previews/SignatureInterfaceVisualQAPreviews.swift`
- `Native/AmbitionsTests/App/SignatureInterfaceVisualQAFixtureTests.swift`
- `docs/audits/afi13-visual-qa-and-drift-gallery-report.md`

## Validation

See `docs/audits/afi13-visual-qa-and-drift-gallery-report.md` for raw command
evidence and no-claim boundaries.

## Result

Accepted Yellow. AFI13 source/test scorecard and drift-gallery proof exists, but
rendered screenshot proof, human visual review, device proof, and public visual
QA claims remain blocked.

## Next Eligible Batch

AFI14 Cross-Surface Coherence Review.

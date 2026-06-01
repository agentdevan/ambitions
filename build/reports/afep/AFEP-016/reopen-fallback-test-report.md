# AFEP-016 Reopen Fallback Test Report

Batch: AFEP-016

## Scope

This report covers the reopen fallback tests for canonical root records, safe continuation tokens, and route payloads.
It does not claim platform-level exact reopen proof.

## Verified Tests

- Canonical root records were generated for Today, Goals, Capture, Time, and You.
- Canonical root records use safe titles and canonical root fallback URLs.
- Continuation tokens preserve only safe identifiers and metadata/redaction classes.
- Goal and step continuations route through the existing goal-detail surface.
- Receipt continuations route through the existing memory-lens overlay surface when a receipt identifier exists.
- Missing identifiers fall back to the canonical root tab.

## Safety Checks

- Raw goal text is absent from generated records and URLs.
- Raw capture text is absent from generated records and URLs.
- Raw schedule detail, proof content, and receipt body text are absent from generated records and URLs.
- Encoded payloads remain identifier-only and do not include private narrative text.

## Validation Evidence

- `xcodegen generate`
- `make xcode-build-for-testing BATCH=AFEP-016`
- `make xcode-focused-test BATCH=AFEP-016 TEST=AmbitionsTests/ExternalSurfaceActionPayloadTests`
- `make xcode-focused-test BATCH=AFEP-016 TEST=AmbitionsTests/ExternalRoutingTests`
- `git diff --check`

The unqualified focused-test filters `ExternalSurfaceActionPayloadTests` and `ExternalRoutingTests` are not accepted as XCTest proof because the wrapper log showed Xcode rejected those filters. The qualified reruns above are the accepted focused-test evidence.

## Non-Claims

- No device-level Spotlight rendering was exercised.
- No Siri, Shortcuts, widget, or Live Activity proof was collected.
- No privacy or release approval is implied by these tests.

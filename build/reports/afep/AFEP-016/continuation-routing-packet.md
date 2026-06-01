# AFEP-016 Continuation Routing Packet

Batch: AFEP-016

## Scope

This packet documents the safe continuation token model and route fallbacks added for the batch.
It is a routing contract packet only; it does not claim platform continuation indexing proof.

## Token Model

The continuation token carries:

- `kind`
- `root`
- safe IDs only when already proven by source
- `metadataClass`
- `redaction`

The token does not carry raw goal text, capture text, schedule detail, proof content, or receipt body.

## Routing Behavior

| Kind | Proven route behavior | Fallback |
| --- | --- | --- |
| Goal | Opens goal detail when a goal ID is present | Canonical Goals root |
| Current step | Reuses goal detail with a safe step identifier when present | Canonical Goals root |
| Receipt | Opens the memory-lens receipt context when a receipt ID is present | Canonical Today root |
| Capture | Opens the capture inbox when a capture ID is present | Canonical Capture root |

## Payload Behavior

- Route payloads now include `kind`, `root`, `metadataClass`, and `redaction`.
- Safe IDs are preserved as identifiers only.
- No generated payload or deep link in this batch embeds private user text.

## Validation Evidence

- `make xcode-build-for-testing BATCH=AFEP-016`
- `make xcode-focused-test BATCH=AFEP-016 TEST=AmbitionsTests/ExternalRoutingTests`
- `make xcode-focused-test BATCH=AFEP-016 TEST=AmbitionsTests/ExternalSurfaceActionPayloadTests`

The unqualified focused-test filters `ExternalRoutingTests` and `ExternalSurfaceActionPayloadTests` are not accepted as XCTest proof because the wrapper log showed Xcode rejected those filters. The qualified reruns above are the accepted focused-test evidence.

## Non-Claims

- No claim of full Spotlight or device indexing parity.
- No claim of exact step or receipt native destination support beyond the existing app router surface.
- No claim of production release readiness.

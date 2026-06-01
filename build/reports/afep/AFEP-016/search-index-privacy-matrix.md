# AFEP-016 Search Index Privacy Matrix

Batch: AFEP-016

## Scope

Contract-level privacy matrix for canonical root records and continuation metadata.
This report does not claim Spotlight runtime proof, Siri proof, device proof, or platform indexing enablement.

## Verified Behavior

| Surface | Safe metadata behavior |
| --- | --- |
| Today | Canonical root record uses the safe root title and `ambitions://tab/today` fallback URL |
| Goals | Canonical root record uses the safe root title and `ambitions://tab/goals` fallback URL |
| Capture | Canonical root record uses the safe root title and `ambitions://tab/capture` fallback URL |
| Time | Canonical root record uses the safe root title and `ambitions://tab/time` fallback URL |
| You | Canonical root record uses the safe root title and `ambitions://tab/you` fallback URL |
| Continuation tokens | Carry only `kind`, `root`, safe IDs, metadata class, and redaction class |

## Privacy Boundary

- No raw goal text is present in canonical records, continuation tokens, or generated route URLs.
- No raw capture text is present in canonical records, continuation tokens, or generated route URLs.
- No schedule detail, proof body, receipt body, or note text is exported through the new metadata helpers.
- Receipt continuations fall back to the canonical root when an exact reopen identifier is missing.

## Validation Evidence

- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-016`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-016 --prompt prompts/batches/AFEP-016.md --batch-type source-changing`
- `xcodegen generate`
- `make xcode-build-for-testing BATCH=AFEP-016`
- `make xcode-focused-test BATCH=AFEP-016 TEST=AmbitionsTests/ExternalSurfaceActionPayloadTests`
- `make xcode-focused-test BATCH=AFEP-016 TEST=AmbitionsTests/ExternalRoutingTests`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-016 --prompt prompts/batches/AFEP-016.md --changed-from 62f1b386ceaed328ba7181737372feb30e68ef5f --batch-type source-changing`
- `git diff --check`

The unqualified focused-test filters `ExternalSurfaceActionPayloadTests` and `ExternalRoutingTests` were attempted during review and are not accepted as XCTest proof because the wrapper log showed Xcode rejected those filters. The qualified reruns above are the accepted focused-test evidence.

## Non-Claims

- No Spotlight index creation or refresh was exercised on-device.
- No Siri, Shortcuts, widget, Live Activity, or device-level invocation was proven here.
- No privacy/legal or release approval is implied.

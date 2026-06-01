# AFEP-014 Privacy and Provenance Packet

Batch: AFEP-014
Scope: Personal Vault, privacy labels, and provenance labels inside `You`

## Provenance Labels Implemented

- `SourceRecord-backed profile state`
- `SourceRecord / Receipt / ReplayTrace`
- `Receipt-backed provenance`
- `System authorization state`
- `SourceRecord / Receipt`

## Privacy Labels Implemented

- `Private by default`
- `Summaries first`
- `No silent writes`
- `No silent retention or export`

## Overclaim Boundaries

- The copy stays local-first and inspectable.
- The implementation does not claim protected-storage completion.
- The implementation does not claim legal or privacy review approval.
- The implementation does not claim release readiness.
- The implementation does not claim hidden inference or hidden learning.

## Source Evidence

- Personal Vault rows are built in `Native/Ambitions/Features/You/YouFeatureService.swift`.
- The row model is defined in `Native/Ambitions/Domain/YouModels.swift`.
- The row view tags are rendered in `Native/Ambitions/Features/You/YouScreen.swift`.
- The focused You service tests assert the labels and non-overclaim copy.

## Validation Evidence

- `make xcode-build-for-testing BATCH=AFEP-014`
- `make xcode-focused-test BATCH=AFEP-014 TEST=AmbitionsTests/You/YouFeatureServiceTests`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-014 --prompt prompts/batches/AFEP-014.md --changed-from 2e7f582ddcba413a62e6825e3b90b366009283e3 --batch-type source-changing --allow-yellow`

## Boundary Notes

- This packet is evidence of visible labels and test coverage, not a claim of completed privacy, legal, or protected-storage signoff.

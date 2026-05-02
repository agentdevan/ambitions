# PXOS Validation And Evidence Protocol

Status: Future Codex OS protocol; PXOS implementation not started
Date: 2026-05-02

PXOS evidence must separate canon, implementation, preview, simulator proof,
physical-device proof, accessibility proof, release proof, and platform proof.

## Required Evidence Fields

- command run
- timestamp/log path when available
- touched files
- proof scope
- what the proof does not claim
- product acceptance evidence
- accessibility/cognitive-load evidence when UI is touched
- copy review evidence when language is touched
- visual evidence when UI is touched
- ME/CS/AOS/REC gate results
- unresolved Yellow list
- Red stop classification if any

Docs-only PXOS batches should run doc/status scans and should not run app tests
unless app code changes, which is forbidden in docs-only batches.

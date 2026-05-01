# Swiftui State Contract Pack

Path: .codex/validation/swiftui-state-contract-pack.md
Status: Active validation pack

## Purpose
Check value-state, projector, view, privacy, accessibility, and compatibility boundaries.

## Required Checks
- git status and allowed/forbidden file diff review
- task width did not escalate
- build/focused tests for implementation work
- copy guard for touched visible strings
- privacy/trust review for touched projection or memory/receipt data
- accessibility identifier and label preservation for touched UI
- no runtime dependency additions
- no workflow edits
- report Green/Yellow/Red with evidence

## SwiftUI State Contract Checks
- run file size scan
- run responsibility scan
- check state/projector/view separation
- review compatibility helpers
- review user-facing copy location
- review privacy projection types
- preserve accessibility identifiers
- run behavior-preservation tests

## Output
Validation summary with verified, failed, not verified, and human/device follow-up separated.

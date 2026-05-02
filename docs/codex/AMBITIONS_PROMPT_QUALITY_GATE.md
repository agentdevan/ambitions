# Ambitions Prompt Quality Gate

Status: Active Codex OS protocol for future Ambitions batches

## Purpose

Prevent future Codex prompts from becoming vague, overbroad, or claim-inflating. This gate applies to AOS, ME, CS, Release Evidence Closure, Product Depth, repair trains, and any post-F30 batch prompt.

## Required Fields For Every Future Batch Prompt

- Batch ID and name
- Status, including whether it is future-only, active, complete, or historical
- Purpose and product problem
- Source truth files to read first
- Explicit allowed files
- Explicit forbidden files
- Exact ownership target or a discovery command plus decision-record requirement
- Required preflight checks
- Implementation boundary
- Non-goals
- Validation commands
- Evidence outputs
- Audit/report path
- Registry/context/run-state update requirement
- Green / Yellow / Red criteria
- Stop conditions
- Rollback or repair path
- What this batch must not claim
- What this batch does not prove
- Commit message recommendation
- Next safe prompt or next gate

## Executability Standard

A prompt is not executable if it only says `selected by manifest`, `update as needed`, `run tests`, `preserve behavior`, `follow canon`, or `validate` without naming owners, commands, evidence, gates, and stop conditions. If the exact owner file is known, name it. If the owner file must be discovered, name the discovery command and require a decision record before edits.

## Release And Platform Claim Standard

Prompts touching release, evidence, privacy, accessibility, performance, external surfaces, platform capability, or source-sensitive claims must state the proof required and the proof not available. Simulator proof never implies physical-device proof, public accessibility conformance, TestFlight readiness, App Store submission readiness, final RC lock, signed archive validation, App Store Connect validation, rendered widget/App Intent/Live Activity proof, or production model behavior.

## Scope Rejection Rules

Reject prompts that mix broad refactor with product behavior, mix release claims with implementation, touch more primitives than named, lack validation, lack file boundaries, lack stop conditions, ask Codex to polish everything, silently choose product direction, imply release readiness without evidence, or start AOS/ME/CS/Product Depth/Release Evidence Closure without explicit train activation.

## Boundary

This protocol does not implement app behavior, add dependencies, change workflows, or create release claims.

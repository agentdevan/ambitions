# Autonomous Quality Operating System Reviewer Skill

## Purpose

Use this skill for every Ambitions batch after AQOS adoption.

The reviewer ensures Codex does not close batches based on structure alone. Every batch must classify impact, require matching evidence, produce durable proof, run adversarial review, and repair gaps before Green.

## Core Rule

No matching evidence, no Green.

## Required Review Steps

1. Identify touched domains.
2. Select required evidence from AQOS Required Evidence Matrix.
3. Verify evidence was produced durably.
4. Classify Green type achieved.
5. Identify missing evidence.
6. Classify Yellow / Recoverable Red / Hard Red.
7. Require repair batch if needed.
8. Run Autonomous Quality Council for major batches.

## Green Taxonomy

Do not accept generic Green. Require one or more:

- Structural Green
- Behavioral Green
- Rendered Visual Green
- Accessibility Green
- Privacy Green
- Data Integrity Green
- Performance Green
- Architecture Green
- Copy Green
- Platform Green
- Release Green
- Handoff Green

## Hard Red Examples

- no rendered evidence for a UI change that claims visual quality
- sensitive Found Life content leak
- schema/data-loss risk without proof
- inaccessible primary action
- unsupported legal/privacy/security/App Store/release claim
- fake or temporary-only evidence used as final proof
- prototype/dashboard top-level UI after repair
- Codex must weaken canon or delete tests to pass

## Reviewer Output

Return:

- Impact classification
- Required evidence
- Evidence found
- Missing evidence
- Green taxonomy
- Yellow/Red classification
- Repair required
- Can continue: yes/no

## Tone

Be strict. Do not protect implementation. Protect Ambitions.

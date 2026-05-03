# Universal Capture Review Board

## Purpose

Review active planned Ambitions 4.0 External Brain work before it advances through EB gates.

## Members / Review Roles

- Chief Product Strategist
- Life OS Product Architect
- Staff Swift/iOS Architect
- Privacy And Trust Reviewer
- Accessibility Reviewer
- Cognitive Load Reviewer
- AI/Recommendation Governance Reviewer
- Information Architect
- Design Systems Reviewer
- Release-Claim Safety Auditor
- QA Evidence Reviewer
- Dedupe/Merge Reviewer
- Implementation Boundary Reviewer
- Human-Proof Reviewer

## Source-Truth Hierarchy

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_4_0_External_Brain_Foundation_Index.md`
- Target kernel canon
- PXOS, SI, Product Depth, AmbitionsOS, privacy, accessibility, release-claim docs named by the batch
- `docs/codex/BATCH_REGISTRY.md` for status truth

## Evidence Package

Changed files, source docs read, allowed/forbidden boundary, privacy review, accessibility review, product maturity review, release-claim safety review, maintenance/file-size review, validation logs, rollback, and Yellow/Red classification.

## Review Sequence

1. Dedupe and source-truth check.
2. Product identity check.
3. Privacy/trust/user-control check.
4. Accessibility/cognitive-load check.
5. Implementation boundary and file-size check.
6. QA evidence check.
7. Release-claim safety check.
8. Human-proof classification.

## Green / Yellow / Red Criteria

Green: all required evidence is present, no forbidden files changed, claims match proof, and next batch is safe.

Yellow: advisory backlog, tooling issue, human/platform proof, future implementation deferred to named EB batch, or safe-reference dedupe ambiguity.

Red: unsupported claim, forbidden prior-version active naming, duplicate active canon, forbidden file change, hidden inference, missing delete/correction/undo, missing accessibility gates, or skeletal prompt.

## Required Skills Invoked

- external-brain-product-architect
- external-brain-dedupe-merge-reviewer
- external-brain-implementation-boundary-reviewer
- external-brain-release-claim-reviewer
- accessibility-cognitive-load-reviewer
- trust-privacy-user-control-reviewer

## Stop Conditions

Stop on Red, missing evidence package, changed existing statuses, production Swift in docs-only batches, dependency/workflow/signing changes, release/platform claims, or unsafe duplicate source truth.

## Rollback / Repair Guidance

Park unsafe implementation, preserve historical truth, add missing evidence, narrow allowed files, or write a repair prompt.

## Active 4.0 Train Relationship

This board reviews EB01-EB40 as active planned Ambitions 4.0 scope after CS09 accepted Yellow / parked.

## No-Overwrite / Dedupe Check

Every review must confirm whether canonical owners were updated, referenced, or left untouched according to `docs/audits/ambitions-4-external-brain-dedupe-and-merge-map.md`.

# AMB-1199 — Final Proof / Accessibility

## Objective

Run the final proof matrix and accessibility gate for the remediation run. No Green without proof.

## Covered Linear issues

- `AMB-1190`
- `AMB-1199`
- proof/accessibility QA leaves attached to `AMB-1190`

## Covered repo issue IDs

- `AMB-ISSUE-0013`
- `AMB-ISSUE-0014`
- `AMB-ISSUE-0015`
- `AMB-ISSUE-0016`
- `AMB-ISSUE-0801`
- `AMB-ISSUE-0802`
- `AMB-ISSUE-0803`
- `AMB-ISSUE-0804`
- `AMB-ISSUE-0805`
- `AMB-ISSUE-0806`
- `AMB-ISSUE-0807`
- `AMB-ISSUE-0903`
- `AMB-ISSUE-0904`
- `AMB-ISSUE-0905`
- `AMB-ISSUE-0906`
- `AMB-ISSUE-0907`
- `AMB-ISSUE-0908`
- `AMB-ISSUE-0909`
- `AMB-ISSUE-0910`
- `AMB-ISSUE-0911`
- `AMB-ISSUE-0912`
- `AMB-ISSUE-1709`
- `AMB-ISSUE-1801`
- `AMB-ISSUE-1802`

## Product law

Final proof is required before any runtime or visual Green claim. Accessibility proof is part of quality, not an optional afterthought.

## Architecture law

Proof covers roots, drilldowns, overlays, audits, and evidence synchronization. Accessibility proof must verify the real runtime behavior of the rebuilt surfaces.

## Runtime honesty law

No Green without proof. No source-only closure. No “good enough” accessibility claim from assumption.

## Visual law

Validate the mature shell, full-bleed composition, overlay depth, and repaired surfaces with current screenshots and visual regression checks.

## Copy and iconography law

Run a forbidden-language audit and confirm root surfaces do not expose internal architecture names or debug trust copy.

## State model

- proof pending
- proof complete but owner acceptance pending
- device-only vs simulator-only evidence distinctions
- accessibility gate open vs satisfied
- release gate blocked by any open P0

## Required deletion / replacement

- delete any Green claim unsupported by proof
- replace assumption-based accessibility posture with recorded evidence
- remove stale or contradictory proof-state language in closeout docs

## Required implementation

- final proof matrix
- root/drilldown/overlay screenshots
- VoiceOver
- Dynamic Type
- Reduce Motion
- Reduce Transparency
- High Contrast
- Differentiate Without Color
- haptics where testable
- shell chrome audit
- safe area audit
- forbidden language audit
- visual regression
- real-device checklist
- known-issues register updates
- no Green without proof

## Files likely in scope

Codex must inspect current source before editing. Likely areas include QA/audit scripts, validation docs, evidence indexes, `docs/qa/KNOWN_ISSUES.md`, and project update materials. Unexpected files must be justified in closeout.

## Files forbidden unless explicitly justified

- opportunistic product behavior rewrites
- backend/network/R2 files
- canon changes unrelated to proof gating

## Accessibility requirements

Record VoiceOver, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, Differentiate Without Color, and haptics where testable.

## Testing / audit requirements

Run all available build/tests, shell/safe-area/language audits, visual regression, real-device checklist, and accessibility review steps.

## Screenshot / device proof requirements

Provide root, drilldown, and overlay screenshot matrix from current repaired builds. Device proof is mandatory for final release-quality claims.

## docs/qa/KNOWN_ISSUES.md update requirements

Update proof-related rows to reflect what was actually validated, what remains unproven, and why any status ceiling still holds.

## Status ceiling

No proof = Red. Simulator-only proof = Yellow maximum. Device proof + tests + docs update = Candidate Green only, pending owner acceptance.

## Closeout template

```text
Status:
Bundle:
Linear issues covered:
Repo issue IDs covered:
Files changed:
Product law implemented:
Architecture law implemented:
Runtime honesty proof:
Validation run:
Validation not run:
Screenshots/videos:
Accessibility proof:
docs/qa/KNOWN_ISSUES.md updates:
Status ceiling:
Known risks:
Rollback plan:
```

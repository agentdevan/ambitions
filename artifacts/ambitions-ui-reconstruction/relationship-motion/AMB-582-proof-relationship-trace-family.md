# AMB-582 Proof / Relationship / Trace Primitive Family

Verdict: Green for AMB-582 scoped implementation.

## Source Truth Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`

## Scope

AMB-582 installs a shared proof, relationship, receipt, and trace primitive family for active Goals and Motion proof paths. Today proof rows already use the closure / recovery primitive family, so no Today source patch was needed for this issue.

The runtime-affecting boundary stays tied to SourceRecord, Receipt, ReplayTrace, and You / What Ambitions knows inspection language so proof remains inspectable before any state change is implied.

## Changed Files

- `Sources/Components/ProofRelationshipTracePrimitiveFamily.swift`
- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift`
- `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`
- `Native/AmbitionsTests/App/ProofRelationshipTracePrimitiveFamilyTests.swift`
- `Native/AmbitionsTests/Motion/MotionCurrentScreenTests.swift`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `docs/codex/concept-lock-registry.yml`
- `docs/codex/existing-code-champion-coverage.yml`
- `artifacts/ambitions-ui-reconstruction/screenshots/proof-relationship-trace-family-amb-582.png`
- `artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-582-proof-relationship-trace-family.md`

## Implementation Notes

- Added `ProofRelationshipTracePrimitiveFamilyContract`, primitive roles, stage, line, and token views.
- Replaced Motion context trace chips, Motion field proof rows, lane trace tokens, lane source / proof / receipt rows, and the source / proof / receipt inspection section with the shared primitive family.
- Replaced Goals review-trail row internals and receipt row internals with the shared stage and line primitives while keeping the existing section ownership names.
- Kept proof rows anchored to source, receipt, replay trace, and user inspection semantics rather than detached visual labels.
- Registered the primitive family and added concept-lock plus champion coverage entries.
- Repaired Motion bottom-mask clearance after visual review showed the receipt line sitting under the mask. The repair keeps tab-bar clearance but reduces the opaque mask to the same height as the reserved bottom inset.

## Visual Evidence

- Screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/proof-relationship-trace-family-amb-582.png`
- Dimensions: `1206 x 2622`
- Launch command used for final screenshot:

```bash
SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process 8ACCD665-4807-4102-B526-5A1AE20686A8 com.ambitions.ios --args -AmbitionsInitialSurface motion -AmbitionsScreenshotMode YES -AmbitionsMotionRenderState proof
```

The final screenshot shows the Motion proof state with Source, Proof, and Receipt primitive lines visible above the bottom mask.

## Validation

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-582 --prompt artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-582-proof-relationship-trace-family.md` — Green.
- `python3 scripts/ambitions-champion-coverage-check.py` — Green before source edits.
- `make xcode-focused-test BATCH=AMB-582 TEST=AmbitionsTests/MotionCurrentScreenTests` — 11 tests passed after the bottom-mask repair.
- `make xcode-focused-test BATCH=AMB-582 TEST=AmbitionsTests/ProofRelationshipTracePrimitiveFamilyTests` — 4 tests passed after the bottom-mask repair.
- `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/proof-relationship-trace-family-amb-582.png --simulator 8ACCD665-4807-4102-B526-5A1AE20686A8 --retries 3` — screenshot written and visually inspected.

## Post-Change Validation

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-582 --prompt artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-582-proof-relationship-trace-family.md --changed-from 48d46c24751603e6b0af2ea609bfe60fa542e8d7` — Green.
- `python3 scripts/ambitions-unsupported-claim-scan.py --changed-from 48d46c24751603e6b0af2ea609bfe60fa542e8d7` — Green.
- `bash scripts/release-claim-safety-scan.sh` — Green.
- `bash scripts/codex-forbidden-claim-scan.sh ...` — no blocking hits.
- `python3 scripts/ambitions-champion-coverage-check.py` — Green; generated report outputs were restored before commit.
- `git diff --check` — clean.

## Proof Boundaries

- This is local simulator screenshot proof only.
- No real-device, TestFlight, App Store, public accessibility, performance, privacy, legal, CI, or release readiness proof is claimed.
- Accessibility semantics were covered by primitive identifiers and existing focused source tests, but manual VoiceOver, Dynamic Type, Reduce Motion, and contrast review remain outside this AMB-582 proof.

## Rollback

Revert this commit to remove the shared proof / relationship / trace primitive family, restore the previous Motion and Goals proof row internals, and remove the AMB-582 registry and coverage entries.

# Verification

## Exact automated and build checks

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/adaptive-skills-and-pathways
python3 scripts/ambitions-canon.py check
python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/source-atlas-no-private-graph-egress-audit.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
scripts/ambitions-xcode-test-focused.sh --batch PDL-ADAPTIVE-SKILLS-INTEGRATION --test AmbitionsTests/AdaptiveSkillsPathwaysIntegrationTests --test AmbitionsTests/AdaptiveSkillsPathwaysAuthorityBoundaryTests
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
make xcode-build-for-testing BATCH=PDL-ADAPTIVE-SKILLS-INTEGRATION
git diff --check
```

## Required evidence

- Automated: every REQ-001 through REQ-016 maps to owner/handoff, happy-path,
  degraded, forbidden-claim, correction/deletion, cancellation/race, and replay
  assertions; all child focused suites remain green.
- Build: generated-project determinism and build-for-testing cover every child
  module referenced by the integration harness.
- Runtime: the synthetic journey covers accepted activity, capability review,
  continuity/aspiration recommendation, adoption, route generation/comparison,
  placement preview/confirmation, correction, deletion influence, and pivot;
  each handoff is also tested missing, stale, conflicted, blocked, canceled, and
  interrupted.
- Accessibility: automated semantics plus physical-iPhone VoiceOver, Voice
  Control, Switch Control, keyboard, largest Dynamic Type, reflow/orientation,
  non-color meaning, reduced effects, focus restoration, announcements, and
  interruption recovery across existing child-owned surfaces.
- Privacy/security: network capture contains fixed public artifact IDs only;
  no private or derived-sensitive graph data leaves the device; permissions,
  minimization, no-score, no-hosted-inference, and no-umbrella-owner scans pass.
- Migration/replay: every participating child direct-upgrade fixture passes;
  empty/additive migration, backup/restore, crash/rerun, idempotency, and pre/post
  replay equivalence are proven. Integration owns no migration.
- Deletion/recovery: correction, suppression, archive, Trash, restore, evidence
  detach, source withdrawal, and deletion update future influence without
  rewriting truthful Goal, Proof, Receipt, or History records.
- Performance: measure bounded end-to-end latency, memory, energy, and storage,
  report each child stage separately, and establish thresholds before acceptance.
- Device: named physical-device rendered, interaction, interruption, and
  accessibility evidence is required after all child visual approvals. Real
  provider acceptance, external execution, release, App Store readiness, and
  broad production outcomes remain unproven.

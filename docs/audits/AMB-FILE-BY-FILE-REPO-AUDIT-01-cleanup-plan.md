# AMB-FILE-BY-FILE-REPO-AUDIT-01 Cleanup Plan

1. Resolve active-truth red drift first, especially any top-level IA or release claim conflicts.
2. Split oversized SwiftUI views and deduplicate embedded UI primitives.
3. Demote historical portals and audit-only material into classified support/history lanes.
4. Keep generated artifacts out of active source paths.

## Red Surfaces
- `docs/truth/CODEX_PROCESS_TRUTH.md`: File references forbidden architecture or dependency language in an active surface.
- `docs/truth/HISTORICAL_POLICY.md`: Active truth file contains legacy IA wording that conflicts with current top-level IA.
- `docs/truth/IMPLEMENTATION_TRUTH.md`: Active truth file contains legacy IA wording that conflicts with current top-level IA.
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`: Active truth file contains legacy IA wording that conflicts with current top-level IA.
- `docs/truth/PRODUCT_MOAT_TRUTH.md`: Active truth file contains legacy IA wording that conflicts with current top-level IA.
- `docs/truth/PRODUCT_UPGRADES_VISION.md`: File references forbidden architecture or dependency language in an active surface.
- `docs/truth/RELEASE_TRUTH.md`: Active truth file contains legacy IA wording that conflicts with current top-level IA.

## Yellow Surfaces
- `.codex/DEPARTMENT_REGISTRY.md`: Classified conservatively from path, content, and current authority boundaries.
- `.codex/GLOBAL_BATCH_TRAIN.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/OPERATING_SYSTEM.md`: Contains forbidden architecture language only in non-claim context.
- `.codex/REPO_INVENTORY.md`: Contains forbidden architecture language only in non-claim context.
- `.codex/REVIEW_BOARD.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/SESSION_BOOTSTRAP.md`: Contains forbidden architecture language only in non-claim context.
- `.codex/SKILL_GOVERNANCE.md`: Contains forbidden architecture language only in non-claim context.
- `.codex/TOOLING_AND_VALIDATION.md`: Contains forbidden architecture language only in non-claim context.
- `.codex/VALIDATION_HARNESS.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/evals/prompts/03-ios-extension-builder.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/evals/prompts/07-design-system-guard.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/evals/prompts/22-release-miss-refinement.md`: Contains release-style wording only in forbidden, proof-target, or historical context.
- `.codex/evals/skill-eval-matrix.md`: Contains forbidden architecture language only in non-claim context.
- `.codex/hooks/user_prompt_submit_guard.py`: Contains forbidden architecture language only in non-claim context.
- `.codex/manifests/repair-profiles.yml`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/manifests/skills-routing-map.yml`: Contains forbidden architecture language only in non-claim context.
- `.codex/manifests/visual-proof-map.yml`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/operations/manual-signoff-checklists.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/operations/release-claim-truth-protocol.md`: Contains release-style wording only in forbidden, proof-target, or historical context.
- `.codex/operations/task-classification.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/review-boards/ambitions-ui-primitive-review-board.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/review-boards/ambitionsos-product-review-board.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/review-boards/signature-experience-review-board.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/review-boards/signature-interface-review-board.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/review-boards/top-level-surface-review-board.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/routes/README.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/accepted-yellow-classifier.md`: Classified conservatively from path, content, and current authority boundaries.
- `.codex/skills/accessibility-cognitive-load-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/accessibility-privacy-performance-quality-reviewer.md`: Contains forbidden architecture language only in non-claim context.
- `.codex/skills/adaptive-screen-implementation-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/ambitions-canon-v2-reconciler/SKILL.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/ambitions-ios-surface-polisher/SKILL.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/ambitions-long-term-data-survival-reviewer.md`: Classified conservatively from path, content, and current authority boundaries.
- `.codex/skills/ambitions-v2-validation-closeout/SKILL.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/ambitions/privacy-claim-verifier.md`: Contains forbidden architecture language only in non-claim context.
- `.codex/skills/ambitions/swiftui-flagship-ui-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/analytics-privacy-reviewer.md`: Contains forbidden architecture language only in non-claim context.
- `.codex/skills/anti-agentic-slop-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/aos-fixture-architect.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/aos-invariant-enforcer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/aos-model-boundary-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/aos-performance-budget-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/aos-red-team-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/aos-release-claim-boundary-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/aos-schema-migration-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/aos-train-orchestrator.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/apple-design-award-visual-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/autonomous-quality-operating-system-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/capture-routing-classification-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/codex-prompt-quality-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/codex-repair-train-designer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/codex-train-integrity-lead.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/compatibility-migration-architect.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/conservative-futurism-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/conservative-futurism-visual-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/continuity-sync-archive-reviewer.md`: Classified conservatively from path, content, and current authority boundaries.
- `.codex/skills/deep-not-wide-product-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/design-system-guard/SKILL.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/dream-red-team-fixture-architect.md`: Classified conservatively from path, content, and current authority boundaries.
- `.codex/skills/dream-safety-legality-triage-reviewer.md`: Classified conservatively from path, content, and current authority boundaries.
- `.codex/skills/external-brain-dedupe-merge-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/external-brain-human-proof-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/external-brain-implementation-boundary-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/external-brain-integration-architect.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/external-brain-product-architect.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/external-brain-release-claim-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/external-brain-test-fixture-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/faang-frontend-implementation-lead.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/faang-frontend-implementation-team.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/faang-rendered-visual-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/faang-staff-ios-architect.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/flake-forensics-lead.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/founder-vision-and-handoff-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/human-made-codebase-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/ios-native-believability-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/large-file-extraction-architect.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/life-memory-graph-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/life-os-product-quality-reviewer.md`: Contains legacy naming that should stay compatibility-only or be rewritten.
- `.codex/skills/living-dream-architect.md`: Classified conservatively from path, content, and current authority boundaries.
- `.codex/skills/living-plan-recompiler-architect.md`: Classified conservatively from path, content, and current authority boundaries.

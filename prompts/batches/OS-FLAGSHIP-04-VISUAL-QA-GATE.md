<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# OS-FLAGSHIP-04-VISUAL-QA-GATE

## Purpose

Install and validate the visual QA gate for flagship Ambitions iPhone surfaces.

## Required Reads

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/os/AMB-CODEX-OS-VISUAL-QA-GATE.md`
- `.codex/skills/ambitions/swiftui-flagship-ui-reviewer.md`
- `.codex/skills/ambitions/accessibility-native-ios-reviewer.md`

## Scope

- Gate documentation, review routing, and proof requirements only.
- No visible UI implementation unless a later implementation batch explicitly owns it.

## Done

- The gate requires screenshot or preview proof, iPhone size coverage, Dynamic Type, Reduce Motion, empty/normal/dense/error/recovery states, one-primary-object review, and anti-dashboard review.
- Validation and rollback notes are recorded.

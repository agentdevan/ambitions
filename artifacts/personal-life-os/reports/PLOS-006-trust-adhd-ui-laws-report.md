# PLOS-006 Trust-Light UI And ADHD Cognitive Load Laws Report

Status: Green for AMB-642 / PLOS-006 law-install scope, pending commit/push/Linear closeout
Issue: AMB-642 / PLOS-006
Parent: AMB-608 / PLOS-M00
Date: 2026-06-12
Base SHA: `f33b3cf444c9f3ea362627bb826cb7d405f121e8`

## Summary

AMB-642 installed two supporting PLOS governance laws:

- `docs/codex/TRUST_UI_DISCLOSURE_LAW.md`
- `docs/codex/ADHD_COGNITIVE_LOAD_UI_LAW.md`

The laws define trust-light disclosure, top-level versus drill-down boundaries, source/receipt/consequence visibility, glyph and breadcrumb requirements, cognitive-load constraints, copy constraints, and future UI/accessibility Green enforcement.

## Existing-First Inspection

Required issue command:

```bash
rg -n "copy|tone|ADHD|cognitive|trust|breadcrumb|VoiceOver|Dynamic Type|Reduce Motion|dashboard|card|glyph|receipt|drill" docs Native Sources
```

Initial result:

- The required command found relevant source and docs hits and returned exit code `0`.
- Before AMB-642 edits, the required command produced `8057` output lines.
- After AMB-642 edits, the required command produced `8132` output lines with exit code `0`.
- A narrower docs/truth and docs/codex inspection identified existing UI and accessibility law owners.
- File discovery confirmed relevant existing primitives under `Sources/Components`.

Key inspected files and directories:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/ui-quality-firewall.md`
- `docs/codex/ambitions_ui_review_checklist.md`
- `docs/codex/ambitions_no_card_replacement_taxonomy.md`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `docs/architecture/decisions/ADR-009-accessibility-contracts-before-claims.md`
- `Sources/Components/TrustReceiptLayerPrimitives.swift`
- `Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift`
- `Sources/Components/QuietReflowPrimitiveFamily.swift`

Existing seams found:

- Product design truth already requires progressive disclosure, one primary object/action, compact trust/receipt/source paths, Dynamic Type, VoiceOver, Reduce Motion, Reduce Transparency, Increase Contrast, no dashboard/card-stack/chatbot posture, no shame, and no cloud AI confidence theater.
- UI quality firewall already blocks generic dashboards/cards, weak or clipped UI, missing trust/source/receipt, missing accessibility semantics, and false Green.
- UI review checklist already requires compact source/trust/receipt, active source path, Dynamic Type, Reduce Motion, Increase Contrast, banned-language checks, and honest status.
- No-card replacement taxonomy already blocks panel piles, metric grids, generic task rows, chat transcript panels, and calendar-copy cards.
- Primitive registry and source primitives already include trust strip, proof trace, quiet reflow, receipt, source, review, privacy, and accessibility-summary vocabulary.

## Files Changed

- `docs/codex/TRUST_UI_DISCLOSURE_LAW.md`
- `docs/codex/ADHD_COGNITIVE_LOAD_UI_LAW.md`
- `artifacts/personal-life-os/reports/PLOS-006-trust-adhd-ui-laws-report.md`
- `artifacts/plos-runtime/PLOS_GOAL.md`
- `artifacts/plos-runtime/PLOS-run-state.md`
- `artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.md`
- `artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json`
- `artifacts/plos-runtime/PLOS_PHASE_GATES.md`
- `artifacts/plos-runtime/PLOS_CHANGELOG.md`
- `artifacts/plos-runtime/PLOS_DECISIONS.md`
- `artifacts/plos-runtime/PLOS_RISK_REGISTER.md`
- `artifacts/proof-ledger/PROOF_LEDGER.md`
- `artifacts/proof-ledger/proof-index.json`
- `docs/codex-os/PROGRAM_REGISTRY.md`

## Acceptance Gate Check

| Gate | Result | Evidence |
|---|---|---|
| Trust-light disclosure law installed | Green | `TRUST_UI_DISCLOSURE_LAW.md` defines top-level decision line, trust strip, consequence line, receipt preview, drill-down trace, and blocker layers. |
| ADHD/cognitive-load law installed | Green | `ADHD_COGNITIVE_LOAD_UI_LAW.md` defines top-level cognitive-load rules, disclosure density, copy constraints, accessibility rules, and progressive disclosure rules. |
| Deep drill-down remains available | Green | Both laws require source, context, constraint, receipt, fallback, rollback, and replay/trust detail to remain inspectable outside default density. |
| Top-level UI remains quiet | Green | Both laws limit default top-level state to a primary object/action, short reason, compact trust/consequence path, and no dashboard/debug/source dump. |
| Material consequence cannot be hidden | Green | Trust law blocks false calm; cognitive-load law blocks hidden review-needed, confirm, warn, blocked, or impossible state. |
| Accessibility proof boundary preserved | Green | Both laws require Dynamic Type, VoiceOver, Reduce Motion, Reduce Transparency, Increase Contrast, safe-area, tap-target, and legibility proof for future UI claims, but make no accessibility claim here. |
| No UI implementation claim | Green | The report and laws state that AMB-642 is governance-only with no SwiftUI, screenshot, runtime, or app source changes. |

## Validation

Planned and/or run for AMB-642 closeout:

- `git status --short --branch`
- Required AMB-642 search over `docs Native Sources` returned `8132` lines with exit code `0`
- Focused file inspection over current design truth, UI firewall, review checklist, no-card taxonomy, primitive registry, accessibility ADR, and trust/accessibility/reflow primitives
- `rg -n "Trust UI|glyph|breadcrumb|ADHD|cognitive|VoiceOver|Dynamic Type|Reduce Motion|paragraph|dashboard" docs` returned `321` lines with exit code `0`
- `git diff --check`
- `python3 -m json.tool artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json`
- `python3 scripts/codex/plos-readiness-validate.py`
- `python3 scripts/codex/linear-closeout-validate.py --self-test`
- `scripts/codex/program-preflight.sh plos`
- `scripts/codex/program-phase-gate.sh plos M00`
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child`

## Proof Artifacts

- `docs/codex/TRUST_UI_DISCLOSURE_LAW.md`
- `docs/codex/ADHD_COGNITIVE_LOAD_UI_LAW.md`
- `artifacts/personal-life-os/reports/PLOS-006-trust-adhd-ui-laws-report.md`
- `artifacts/proof-ledger/PROOF_LEDGER.md`
- `artifacts/proof-ledger/proof-index.json`

## Runtime Path Proof

Not applicable. AMB-642 installs governance law only and does not prove trust strip behavior, drill-down behavior, UI copy, accessibility, screenshots, runtime reasoning UI, source disclosure UI, receipt UI, or app behavior.

## Privacy / Safety / Source Checks

- No app source changed.
- No runtime feature implemented.
- No UI redesign implemented.
- No screenshots added or updated.
- No source pack, R2 object, private user data, telemetry, analytics, hosted backend, cloud LLM dependency, or sharing transport introduced.
- The laws block false calm, hidden material consequences, unlabeled glyph-only trust state, and source/receipt overclaim.

## Accessibility Checks

No accessibility verification is claimed. The laws define future accessibility gates for UI claims, including Dynamic Type, VoiceOver, Reduce Motion, Reduce Transparency, Increase Contrast, safe areas, tap targets, glyph labels, and legibility.

## Performance Notes

Not applicable. No runtime or performance claim is made.

## Rollback / Failure Behavior

Revert the AMB-642 closeout commit to remove the two supporting law docs, report, and PLOS state/ledger updates. No app source, UI implementation, runtime feature, source pack, R2 object, screenshots, or user data is affected.

## Remaining Yellow / Red

Yellow:

- The laws define governance only; trust-light UI, deep drill-down, screenshot review, accessibility proof, and runtime reasoning UI remain owned by later PLOS phases.
- AMB-643 through AMB-645 still own remaining M00 privacy/safety, execution-contract, validation/reporting installs.

Red:

- None for AMB-642 scope.

## Linear Changes

- AMB-642 was live-resolved from Linear using actual `AMB-642`.
- AMB-642 moved to In Progress before edits using actual `AMB-642`.
- Final closeout comment/status update must use actual `AMB-642` after push.

## Next Issue To Run

`AMB-643` / `PLOS-007` after AMB-642 is committed, pushed, validated, and updated in Linear.

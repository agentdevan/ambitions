<!-- markdownlint-disable MD013 -->

# Codex Scorecard

Status: Active Codex execution-quality scorecard  
Date updated: 2026-05-10  
Authority: Subordinate to `docs/truth/*` and current validation evidence

This scorecard measures Codex execution quality. It is not app quality proof,
release proof, accessibility conformance, performance proof, or human approval.

## 1. Scoring Rule

Score only the work being closed out. Do not score uninspected repo areas.
Scores require evidence; otherwise mark `not scored`.

## 2. Metrics

| Metric | Green | Yellow | Red |
| --- | --- | --- | --- |
| Truth-first grounding | Required truth files read and conflicts resolved | Supporting docs partially inspected | Truth conflict or old authority used |
| Scope control | Only allowed paths touched | Safe extra docs/support files touched with reason | Source/runtime/CI/dependency touched outside scope |
| Validation fit | Required packs run or not-run reason recorded | Advisory findings remain with owner | Validation skipped, hidden, or contradicted |
| Claim discipline | Non-claims explicit and scanner clean/contextual | Review triggers explained | False release/implementation/accessibility/performance claim |
| Patch quality | Small owning seam, clear rollback | Larger docs diff but still coherent | Broad churn or unrelated edits |
| Review-board coverage | Required lanes pass/not applicable | Some lanes not run with safe reason | Required lane fails or is omitted |
| Visual proof discipline | Screenshot/proof present when visual claim made | Visual proof not run and no visual claim made | Visual claim without current proof |
| Accessibility/motion discipline | Gates run when UI changed | Not run and no UI/accessibility claim made | Accessibility/motion claim without proof |
| Performance discipline | Budget/measurement used when claimed | Not run and no performance claim made | Performance claim without measurement |
| Defect memory | Regression risk recorded when bug fixed | No defect touched | Recurrence risk ignored after defect repair |

## 3. Numeric Mapping

Use only for internal Codex improvement:

- Green: 2
- Yellow: 1
- Red: 0
- Not applicable: excluded
- Not scored: excluded

Do not convert score into user-facing product quality, release readiness, or
shipping approval.

## 4. Closeout Template

```text
Codex scorecard:
- Truth-first grounding:
- Scope control:
- Validation fit:
- Claim discipline:
- Patch quality:
- Review-board coverage:
- Visual proof discipline:
- Accessibility/motion discipline:
- Performance discipline:
- Defect memory:
Overall:
Evidence:
Not scored:
```

## 5. Update Rules

Update this file only when:

- a metric definition changes
- a new recurring quality failure appears
- a new validation pack or review lane is added
- an owner explicitly asks for a scorecard baseline update

Per-run scores belong in closeout reports, not in this definition file, unless
the owner asks for a persistent trend ledger.

## 6. Current Baseline

This setup pass creates the scorecard. It does not score all historical Codex
work or certify the repo’s overall quality.

## 7. Phase 10 Gate Result

Phase 10 result: Green.

Validation:

- docs-only scorecard artifact
- no app/source/runtime files touched
- no product quality, release, accessibility, performance, or implementation
  proof claimed


<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

FRONTEND-ARCHITECTURE-ATLAS-VISUAL-ENCYCLOPEDIA-001

# Objective

Create the complete Ambitions Front-End Architecture Atlas + Visual Encyclopedia as active repo canon.

This batch produces repo-owned product/design documentation for every visible Ambitions surface, visual object, hierarchy level, primitive, state, affordance, label pattern, chrome element, material, color, typography rule, spacing rule, wrapper, receipt, CTA, sheet, overlay, drill-down, and cross-surface behavior that can be derived from active repo source truth.

This is not a UI implementation batch and not a Codex implementation-guidelines document.

Active top-level IA is exactly Today / Goals / Capture / Time / You. Active primary objects are Today -> Reality Meridian, Goals -> Constellation Atlas, Capture -> Atmosphere Composer, Time -> LifeShape Field, You -> User System Profile.

Create docs/canon/frontend/**, validators under scripts/ambitions-frontend-*.py and scripts/ambitions-visual-*.py, and reports under build/reports/frontend-architecture-atlas-visual-encyclopedia-001.*. Do not touch production SwiftUI. Validators must check required files, registry fields, MRI/HBI handling, Plan top-level exclusion, accessibility fields, surface bible sections, primitive/behavior/trace coverage, and visual reference ledgers.

Required final report: Green/Yellow/Red, active IA confirmation, files created/modified, source truth inspected, MRI/HBI discovery, registry count, bible/matrix counts, obsolete references, unresolved gaps, validation commands/results, proof no production UI implementation occurred, and next batch.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->

# Codex Quality System Gate Matrix

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-66075429

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active CQS gate matrix
Date: 2026-05-05

| Gate | Applies to | Green | Accepted Yellow | Red / Hard Red |
| --- | --- | --- | --- | --- |
| Source Truth Gate | Every batch | Active canon and handoff docs read. | Advisory source gap is named and safe. | Source conflict would weaken canon. |
| Scope Gate | Every batch | Allowed/forbidden files are explicit. | Boundary gap is docs-only and owned. | Required edits have unknown boundary. |
| Senior Architecture Gate | Code batches | Dependencies flow Domain/Services/Features correctly. | Large-file advisory has owner. | Broad refactor or dependency inversion. |
| SwiftUI Composition Gate | UI batches | Native composition, state outside view body. | Existing large view touched narrowly. | Generic card stack or business logic in views. |
| Visual Quality Gate | User-facing UI | Premium native object identity with durable FVQ screenshot or rendered preview evidence, freshness proof, and visual score. | Existing FVQ evidence is inherited or an operator proof checklist owns missing rendered proof. | Generic/slop UI, surface drift, fake polish, or Green claimed from compile/tests/docs alone. |
| FVQ Rendered Proof Gate | UI-affecting batches | Surfaces touched, primary object, screenshots/previews, freshness proof, visual score, accessibility/readability, Reduce Motion, privacy rendering, drift result, and repair decision are recorded. | Tooling/device/external-surface gap is Accepted Yellow with explicit owner and no-claim boundary. | No rendered proof for a visible change, stale screenshot proof, primary-object visual drift, or material rendered regression. |
| Canon Drift Gate | Product/copy/UI | Tabs and product laws preserved. | Internal compatibility term is contained. | New tab, habit tracker, chatbot, calendar clone. |
| Accessibility Gate | UI/motion/copy | Labels, traversal, Dynamic Type, Reduce Motion considered. | Manual proof deferred. | Color-only or motion-only meaning. |
| Privacy/Legal/App Store Gate | Platform/copy/release | Claims evidence-bound. | Human/legal proof named as future. | Unsupported compliance/release claim. |
| Performance/Battery Gate | Runtime/UI/platform | Work is bounded and testable. | Instrument proof deferred. | Always-on costly behavior without budget. |
| Platform Surface Gate | Widgets/App Intents/notifications | Surface data minimized and reversible. | Device proof deferred. | Sensitive data exposure or unsupported platform claim. |
| StoreKit Gate | Monetization | Entitlements and restore/cancel paths clear. | Monetization deferred. | Dark pattern or App Review risk. |
| Schema/Sync/Migration Gate | Persistence/sync | Migration/conflict rules tested. | Strategy-only docs. | Data-loss or schema corruption risk. |
| Anti-Slop Gate | Every batch | Names, helpers, models, and docs are specific. | Existing smell inventoried. | Prompt-built residue introduced. |
| Validation Gate | Every batch | Strong/Adequate validation run. | Advisory backlog classified. | `git diff --check` fails or required validation missing. |
| Report Gate | Every batch | FAANG-style packet written. | Small report gap has owner. | Missing evidence or hidden failure. |

Hard Red always stops. Recoverable Red enters the CQS repair loop.

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

# Codex Quality System Gate Matrix
<!-- markdownlint-disable MD013 -->

Status: Active CQS gate matrix
Date: 2026-05-05

| Gate | Applies to | Green | Accepted Yellow | Red / Hard Red |
| --- | --- | --- | --- | --- |
| Source Truth Gate | Every batch | Active canon and handoff docs read. | Advisory source gap is named and safe. | Source conflict would weaken canon. |
| Scope Gate | Every batch | Allowed/forbidden files are explicit. | Boundary gap is docs-only and owned. | Required edits have unknown boundary. |
| Senior Architecture Gate | Code batches | Dependencies flow Domain/Services/Features correctly. | Large-file advisory has owner. | Broad refactor or dependency inversion. |
| SwiftUI Composition Gate | UI batches | Native composition, state outside view body. | Existing large view touched narrowly. | Generic card stack or business logic in views. |
| Visual Quality Gate | User-facing UI | Premium native object identity with durable FVQ screenshot or rendered preview evidence, freshness proof, and visual score. | Existing FVQ evidence is inherited or an operator proof checklist owns missing rendered proof. | Generic/slop UI, dashboard drift, fake polish, or Green claimed from compile/tests/docs alone. |
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

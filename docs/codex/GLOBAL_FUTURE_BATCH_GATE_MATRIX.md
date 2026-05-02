# Global Future Batch Gate Matrix

<!-- markdownlint-disable MD013 -->

Status: Global planning and Codex OS control; no future train started
Date: 2026-05-02

## Gate Result Contract

Every gate returns:

- Result: Green, Yellow, or Red.
- Rationale.
- Evidence used.
- Required repair if Red.
- Deferral owner if Yellow.
- Evidence required before continuation.

## Required Gates

| Gate | Applies when | Green | Yellow | Red | Owner/review skill |
| --- | --- | --- | --- | --- | --- |
| Source Truth Gate | Every batch | Required docs and batch prompt read; conflicts resolved by newest active canon. | Minor stale reference is documented and not safety-critical. | Missing owner doc or conflict affects implementation safety. | `source-truth-reconciler`, active canon review |
| Scope Boundary Gate | Every batch | Allowed/forbidden files and task width are explicit and respected. | Scope pressure is documented and still safe. | Forbidden files touched or scope expands into another batch. | `diff-scope-controller`, scope boundary review |
| Product Decision Lock Gate | Product/canon/UI/copy | Decisions are locked, open, or deferred in source truth/ledger. | Open decision deferred with owner. | Open decision implemented silently. | product decision lock review |
| REC Release Evidence Gate | REC/release/messaging | Claim has evidence and limitations. | Advisory evidence gap is named. | Unsupported readiness/platform claim. | release evidence reviewer |
| Release Claim Safety Gate | Release/product messaging | No App Store/TestFlight/device/release claim outruns proof. | Claim wording needs future human review but is not active. | Readiness claim without proof. | `release-claim-truth-enforcer` |
| PXOS Product Experience Gate | User-facing UI/copy/interaction | Surface, hierarchy, copy, visual, trust, recovery, accessibility rules are named. | Non-blocking PXOS detail deferred. | User-facing work without PXOS owner. | PXOS surface hierarchy reviewer |
| Top-Level Surface Composition Gate | Today/Goals/Capture/Plan/You top-level UI | Glance, one-primary-object, and drill-down discipline pass. | Minor hierarchy risk has owner. | Stacked-card/detail-container/dashboard top-level surface. | top-level composition reviewer |
| Product Depth Gate | PD01-PD18 or drill-down/depth work | Deepens existing surfaces and has PXOS + ME/CS prerequisites plus AOS blockers when runtime is touched. | PD train is formal but blocked by unresolved prerequisite; no implementation starts. | Widens app or starts Product Depth without approval. | `product-depth-strategist`, `deep-not-wide-product-reviewer` |
| ME Maintainability Gate | Code/extraction/large UI | Owner files checked, file sizes measured, tests selected. | Existing large-file debt tracked with near-term ME owner. | Expansion worsens giant file or mixes refactor/feature unsafely. | `large-file-extraction-architect` |
| File Size / Diff Size Gate | Code batches | Diff is narrow, file sizes stable/improved or justified. | Small increase documented with owner. | Unreviewable diff or large-file regression. | file-size/diff-size reviewer |
| CS Compatibility Gate | Routes/raw/external/import/export/persistence | Replacement map and compatibility proof exist before deletion. | Seam risk documented and not touched. | Compatibility break or deletion without proof. | `compatibility-migration-architect` |
| AOS Runtime/Intelligence Gate | Recommendation/source-truth/runtime | Typed contracts, fallback, privacy, source truth, and no overclaim. | Internal-only gap tracked before exposure. | User-facing intelligence without PXOS/AOS/trust gates. | `runtime-contract-reviewer` |
| Privacy/Trust/Receipt Gate | Trust, proof, memory, recommendations, receipts | Source labels, consent, correction, local-first, proof/receipt path clear. | Noncritical trust affordance deferred with owner. | Hidden meaningful change or private projection leak. | privacy/trust reviewer |
| Accessibility/Cognitive Load Gate | UI/copy/interactions | Dynamic Type, VoiceOver, Reduce Motion, visible alternatives, no color-only meaning. | Human review needed but no blocker. | Accessibility blocker or cognitive overload in primary flow. | `accessibility-cognitive-load-reviewer` |
| Copy/Language Gate | User-facing copy | Ambitions 3.0/PXOS language, no AI theater, no shame, no fake precision. | Minor copy debt owned. | Product identity drift or unsupported AI/model language. | `product-language-reviewer` |
| Visual Quality Gate | UI work | Premium native hierarchy, calm surface, visual orientation, no generic dashboard. | Screenshot/human polish pending but no blocker. | Generic task app/dashboard/card-stack drift. | `premium-ios-visual-reviewer` |
| Product Drift Gate | Every batch | Preserves Ambitions identity and five-tab IA. | Historical wording hit in negative examples only. | Task app, habit tracker, calendar clone, chatbot, dashboard, or new tab drift. | product strategy reviewer |
| Validation Evidence Gate | Every batch | Commands, logs, pass/fail, proof scope, and non-claims recorded. | Advisory command failure classified. | Required evidence missing or skipped without reason. | `evidence-gate-reporter` |
| Validation Strength Gate | Every batch | Strength is Strong or Adequate for batch type. | Weak/Missing only for docs-only or explicitly owned future validation. | Weak/Missing for implementation batch. | validation-evidence auditor |
| Test Strength Gate | Implementation/testing | Meaningful tests or closest available proof, no weakening. | Test gap has near-term owner and no Red risk. | Tests deleted/loosened to pass or no meaningful proof. | testability reviewer |
| Skills/Review Board Gate | Every batch | Required skills/boards invoked or equivalent protocol mapped. | Skill gap documented as safe Yellow. | Required review skipped for risky work. | skill-selection protocol |
| Handoff Gate | Every batch closeout | Report, files, validation, risks, next prompt, evidence ledger. | Minor handoff gap not affecting continuation. | No closeout evidence. | post-run closeout writer |
| Rollback Gate | Every batch closeout | Revert/rollback path documented. | Rollback is manual but clear. | No rollback path for risky change. | rollback protocol |
| Human Proof Gate | Release/platform/manual proof | Human-only proof is separated into operator checklist. | Human proof pending but no claim made. | Codex fakes or claims human-only proof. | `manual-verification-blocker` |
| Continuation Gate | Before next batch | Current batch committed, Green or accepted Yellow, clean branch, prerequisites satisfied. | Accepted Yellow documented and safe for next batch. | Unresolved Red, dirty unsafe branch, weak validation, or missing approval. | global continuation protocol |

## Batch-Type Gate Packs

- Docs/protocol: Source Truth, Scope Boundary, Product Decision Lock, Validation Evidence, Validation Strength, Handoff, Rollback, Product Drift.
- Evidence/release: Docs/protocol gates plus REC Release Evidence, Release Claim Safety, Human Proof.
- PXOS/user-facing: Docs/protocol gates plus PXOS Product Experience, Top-Level Composition, Product Depth when relevant, Accessibility, Copy, Visual, Trust/Proof.
- ME/code maintainability: Source Truth, Scope, ME, File Size, Test Strength, Validation Strength, Rollback.
- CS/compatibility: Source Truth, Scope, CS, Test Strength, Release Claim Safety if external, Rollback.
- AOS/intelligence: Source Truth, Scope, AOS Runtime/Intelligence, Privacy/Trust, Performance, Evaluation, PXOS expression before exposure.
- Product Depth: PXOS, Product Depth, Top-Level Composition, ME, CS, AOS when runtime/source-truth/proof logic is touched, Accessibility, Visual, Copy, Privacy/Trust, Validation Strength.

## Failure Handling

- Green: may close and commit. Continuation still requires the continuation protocol.
- Yellow: classify, assign owner, decide fix-now vs defer, document why continuation is safe.
- Red: stop forward progress and enter `GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL.md`.

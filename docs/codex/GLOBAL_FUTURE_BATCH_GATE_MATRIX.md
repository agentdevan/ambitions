# Ambitions 4.0 Global Future Batch Gate Matrix

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-39648739, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

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

Status: Ambitions 4.0 gate matrix; queued/blocked batches only; no queued train started
Date: 2026-05-02

## Gate Result Contract

This matrix governs the Ambitions 4.0 Execution Program. It does not make any queued batch started, implemented, shipped, or release-proven.

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
| PXEQ Product Experience Equivalence Gate | EB UI implementation, user-facing UI/copy/interaction, previews, living modules, motion, visual-system changes | Batch reads PXEQ docs, names the primary visual object/system, records living-state purpose, before/after product-experience impact, preview or no-UI evidence, Reduce Motion/Dynamic Type/VoiceOver/tap target/contrast/non-color proof, and anti-generic checks. | Existing UI debt or human polish need is documented with owner and no new generic/static/noisy experience is introduced. | Technically passing UI that feels generic, static, cluttered, unreadable, overbuilt, noisy, decorative, motion-heavy without meaning, or missing required PXEQ evidence. | `product-experience-equivalence-reviewer`, `living-interface-systems-reviewer`, PXEQ review board |
| FET Frontend Excellence Gate | FCP/AFI/DAV/PD/SI/FVQ/AOS UI/LDI UI/Source Atlas UI/PFC external-surface UI, shell, chrome, visual primitives, preview/screenshot, motion, accessibility presentation, or user-facing copy | FET applicability declared; screenshot/preview/rendered evidence exists for UI-touching work; first viewport, bottom chrome, top-level composition, primitive identity, copy compression, accessibility, motion, route compatibility, release claims, and scorecard pass. | Average score 80-89 with no hard Red and named owner, or docs-only UI governance makes no rendered UI claim. | Missing screenshots/previews for UI work, build/test substituted for visual proof, hard frontend Red, average below 80, unsupported premium/flagship/10/10 claim, stale/unmapped screenshot packet, or route/raw/persistence drift. | `faang-frontend-implementation-lead`, `ios-product-design-director`, `swiftui-senior-systems-engineer`, `screenshot-visual-qa-reviewer` |
| Top-Level Surface Composition Gate | Today/Goals/Capture/Plan/You top-level UI | Glance, one-primary-object, and drill-down discipline pass. | Minor hierarchy risk has owner. | Stacked-card/detail-container/dashboard top-level surface. | top-level composition reviewer |
| Product Depth Gate | PD01-PD18 or drill-down/depth work | Deepens existing surfaces and has PXOS + ME/CS/SI prerequisites plus AOS blockers when runtime is touched. | PD train is formal but blocked by unresolved prerequisite; no implementation starts. | Widens app or starts Product Depth without approval. | `product-depth-strategist`, `deep-not-wide-product-reviewer` |
| ME Maintainability Gate | Code/extraction/large UI | Owner files checked, file sizes measured, tests selected. | Existing large-file debt tracked with near-term ME owner. | Expansion worsens giant file or mixes refactor/feature unsafely. | `large-file-extraction-architect` |
| File Size / Diff Size Gate | Code batches | Diff is narrow, file sizes stable/improved or justified. | Small increase documented with owner. | Unreviewable diff or large-file regression. | file-size/diff-size reviewer |
| CS Compatibility Gate | Routes/raw/external/import/export/persistence | Replacement map and compatibility proof exist before deletion. | Seam risk documented and not touched. | Compatibility break or deletion without proof. | `compatibility-migration-architect` |
| Profile/You Compatibility Gate | CS02, You/Profile naming, shell, route/raw/default/accessibility seams | Visible `You` canon is preserved while `profile` raw/default/accessibility compatibility remains stable or is migrated with proof. | Internal `Profile` names remain intentionally with CS02C/CS10 owner and no user-facing regression. | Broad Profile-to-You rename, raw-value/default/accessibility break, duplicate destination, or retirement claim without proof. | `compatibility-migration-architect`, route/raw-value safety reviewer, accessibility identifier compatibility reviewer |
| Insights/Plan Compatibility Gate | CS03, Insights/Plan naming, shell, route/raw/default/external/accessibility/contextual-intelligence seams | Visible `Plan` canon is preserved while legacy `insights` raw/external/accessibility/contextual-intelligence compatibility remains stable or is migrated with proof. | Internal `Insights` names remain intentionally with CS03C/CS10/future PD/AOS owner and no user-facing regression; current repo maps legacy `insights` to You/Profile history support and this is documented. | Broad Insights-to-Plan rename, `InsightsRouteTarget` deletion without proof, raw-value/default/external/accessibility break, duplicate destination, contextual-intelligence semantic loss, or retirement claim without proof. | `compatibility-migration-architect`, route/raw-value safety reviewer, accessibility identifier compatibility reviewer, contextual-intelligence compatibility reviewer |
| Habits/Ritual/Plan Compatibility Gate | CS04, Habits/Ritual/Plan naming, shell, route/raw/default/external/accessibility/recurring-loop seams | Visible top-level IA remains `Today / Goals / Capture / Plan / You`; legacy `habits` raw/external/accessibility compatibility remains stable or is migrated with proof; Plan-owned Rituals support semantics remain intact. | Internal `Habits` names remain intentionally with CS04C/future SI/PD/AOS owner and no user-facing top-level Habits regression. | Broad Habits-to-Rituals or Habits-to-Plan rename, `PlanRouteTarget.habits` deletion without proof, raw-value/default/external/accessibility break, duplicate Habits/Rituals destination, recurring-loop semantic loss, or retirement claim without proof. | `compatibility-migration-architect`, route/raw-value safety reviewer, accessibility identifier compatibility reviewer, persistence/defaults reviewer |
| ActiveFocus/TodayFocus Compatibility Gate | CS05, activeFocus schema, TodayFocus state/service, `.focus` route, shell command, App Intent, and FocusNow widget seams | `activeFocus` external snapshot compatibility, `.focus` routes, quick-focus commands, App Intent URLs, and FocusNow widget values remain stable or are migrated with schema/route/widget proof; user-facing Today canon remains Step/Start-now oriented. | Internal `activeFocus`, `TodayFocus*`, `.focus`, `quick_focus`, `focusNow`, and FocusNow names remain intentionally with CS05C/future PD03/SI owner and no user-facing Focus-mode regression; CS05B focused proof is complete but does not retire the seam. | Broad Focus-to-Step-Session rename, external snapshot schema break, route/raw/App Intent/widget break, accessibility identifier mismatch, duplicate Focus/Step Session destination, Today state semantic loss, or retirement claim without proof. | `compatibility-migration-architect`, route/raw-value safety reviewer, Today state contract reviewer, accessibility identifier compatibility reviewer |
| AOS Runtime/Intelligence Gate | Recommendation/source-truth/runtime | Typed contracts, fallback, privacy, source truth, and no overclaim. | Internal-only gap tracked before exposure. | User-facing intelligence without PXOS/AOS/trust gates. | `runtime-contract-reviewer` |
| Privacy/Trust/Receipt Gate | Trust, proof, memory, recommendations, receipts | Source labels, consent, correction, local-first, proof/receipt path clear. | Noncritical trust affordance deferred with owner. | Hidden meaningful change or private projection leak. | privacy/trust reviewer |
| Accessibility/Cognitive Load Gate | UI/copy/interactions | Dynamic Type, VoiceOver, Reduce Motion, visible alternatives, no color-only meaning. | Human review needed but no blocker. | Accessibility blocker or cognitive overload in primary flow. | `accessibility-cognitive-load-reviewer` |
| Copy/Language Gate | User-facing copy | Ambitions 3.0/PXOS language, no AI theater, no shame, no fake precision. | Minor copy debt owned. | Product identity drift or unsupported AI/model language. | `product-language-reviewer` |
| Visual Quality Gate | UI work | Premium native hierarchy, calm surface, visual orientation, no generic surface. | Screenshot/human polish pending but no blocker. | Generic task app/dashboard/card-stack drift. | `premium-ios-visual-reviewer` |
| Signature Interface Creative Direction Gate | SI implementation and SI-facing UI | Primitive is Ambitions-native, invented-but-believable, useful, restrained, accessible, coherent, and maintainable. | Rubric has nonblocking concern with owner and no category below Red threshold. | Style-only card/panel, generic surface skin, or primitive fails rubric without repair/owner. | `signature-interface-creative-director`, Signature Interface review board |
| Anti-Generic UI Gate | SI/UI/top-level work | Anti-generic scan reviewed; no card-stack, surface, calendar clone, chatbot, notes, habit, or project-management drift. | Historical/negative example hits classified and safe. | Generic UI drift introduced or used as repair. | `ambitions-native-ui-primitive-reviewer` |
| Preview Coverage Gate | SI/UI implementation | Meaningful preview/component state evidence exists for touched primitives. | Preview gap has safe owner and no user-facing uncertainty. | UI-changing primitive lacks preview/state evidence without allowed reason. | `visual-qa-preview-fixture-reviewer` |
| Interaction/Motion/Haptics Gate | SI interaction/motion/haptics | Motion orients/confirms/reduces uncertainty; haptics are purposeful; interaction states are testable. | Minor motion polish deferred with owner. | Decorative/gamified motion or interaction increases cognitive load. | `interaction-motion-haptics-reviewer` |
| Reduce Motion Gate | SI/UI motion | Reduced Motion equivalent is defined and validated where motion matters. | Motion is noncritical and fallback owner named. | Required motion work lacks Reduce Motion equivalent. | `accessibility-adaptive-interface-reviewer` |
| SI File-Size/Component Boundary Gate | SI implementation | Components are small, named, reusable, previewable, and do not bloat owner files. | File-size increase is documented and owned by a near-term extraction/follow-up. | Giant one-off visual owner or unreviewable UI diff. | `si-file-size-component-boundary-reviewer` |
| LDI Living Dream Source Truth Gate | LDI batches and queued SI/PD/AOS hooks that touch Living Dream concepts | LDI canon is read, one primary handling lane is named where relevant, safety/privacy/source/professional-boundary boundaries are explicit, and no runtime claim outruns evidence. | Future fixture/human proof gap is named with owner and no unsupported claim is made. | Unsafe/professional advice path, user-data server, hosted AI, silent commitment mutation, unknown lane, or full runtime/release claim without proof. | `living-dream-architect`, LDI review board |
| Product Drift Gate | Every batch | Preserves Ambitions identity and five-tab IA. | Historical wording hit in negative examples only. | Task app, habit tracker, calendar clone, chatbot, surface, or new tab drift. | product strategy reviewer |
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
- PXOS/user-facing: Docs/protocol gates plus PXOS Product Experience, PXEQ Product Experience Equivalence, FET Frontend Excellence when visible UI/copy is touched, Top-Level Composition, Product Depth when relevant, Accessibility, Copy, Visual, Trust/Proof.
- EB UI implementation: Source Truth, Scope, EB dependency graph, PXEQ Product Experience Equivalence, PXOS Product Experience, Privacy/Trust/Receipt, Accessibility/Cognitive Load, Copy/Language, Visual Quality, Product Drift, Preview Coverage, Interaction/Motion/Haptics, Reduce Motion, Validation Evidence, Validation Strength, Handoff, Rollback. PXEQ must be Green before EB03, EB14, EB20, EB26, EB33, or any UI-heavy EB batch can pass Green.
- ME/code maintainability: Source Truth, Scope, ME, File Size, Test Strength, Validation Strength, Rollback.
- CS/compatibility: Source Truth, Scope, CS, Profile/You Compatibility when CS02 is active, Insights/Plan Compatibility when CS03 is active, Habits/Ritual/Plan Compatibility when CS04 is active, Test Strength, Release Claim Safety if external, Rollback.
- AOS/intelligence: Source Truth, Scope, AOS Runtime/Intelligence, Privacy/Trust, Performance, Evaluation, PXOS and PXEQ expression before exposure.
- LDI/Living Dream: Source Truth, Scope, LDI Living Dream Source Truth, Safety/Legality/Feasibility, Professional Boundary, Local-First Privacy, Source Claim/Pack Integrity, No Silent Mutation, Product Drift, Release Claim Safety, Evidence Manifest, Rollback.
- Product Depth: PXOS, Product Depth, FET Frontend Excellence when visible UI/copy is touched, Signature Interface, Top-Level Composition, ME, CS, AOS when runtime/source-truth/proof logic is touched, Accessibility, Visual, Copy, Privacy/Trust, Validation Strength.
- Signature Interface: Source Truth, Scope, FET Frontend Excellence, Signature Interface Creative Direction, Anti-Generic UI, Visual Quality, Accessibility/Cognitive Load, Interaction/Motion/Haptics, Reduce Motion, Preview Coverage, File Size/Diff Size, SI File-Size/Component Boundary, Release Claim Safety, Product Drift, Validation Strength, Handoff, Rollback. Add Top-Level Surface Composition and IA/Shell/Navigation review when shell, navigation, or top-level surfaces are touched.

## FET Frontend Excellence Inheritance

Future FCP, AFI, DAV, PD, SI, FVQ, AOS UI, LDI UI, Source Atlas UI, and PFC external-surface UI batches inherit `docs/codex/FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md` and `docs/codex/FRONTEND_EXCELLENCE_GATE_MATRIX.md`. FET does not replay completed history and does not claim current UI repair. It prevents future UI-touching Green closeout from relying on build/test success without rendered visual evidence.

FET01-FET12 additionally installs the concrete gate docs for screenshot evidence, first viewport budget, shell/bottom chrome ownership, top-level surface composition, primitive misuse/density, copy compression, accessibility/Dynamic Type/Reduce Motion, motion/haptics believability, visual QA scorecards, and UI regression stops. These gate docs are mandatory references for future UI-touching dry-runs.

## Failure Handling

- Green: may close and commit. Continuation still requires the continuation protocol.
- Yellow: classify, assign owner, decide fix-now vs defer, document why continuation is safe.
- Red: stop forward progress and enter `GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL.md`.


## LDI01-LDI22 Living Dream batch gate pack

LDI01-LDI22 use the LDI/Living Dream gate pack and remain queued after AOS30 by default.

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

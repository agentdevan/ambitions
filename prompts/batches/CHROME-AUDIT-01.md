<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# CHROME-AUDIT-01 — Chrome Authority Audit And Bounded Installation Plan

## Batch ID

CHROME-AUDIT-01

## Runner Command

```bash
scripts/ambitions-codex-train.sh CHROME-AUDIT-01 prompts/batches/CHROME-AUDIT-01.md
```

or:

```bash
make batch BATCH=CHROME-AUDIT-01 PROMPT=prompts/batches/CHROME-AUDIT-01.md
```

## Objective

Audit Ambitions' current app chrome against the newly installed chrome authority overlay and produce a bounded, proof-driven implementation plan for making the product shell feel like a top-tier native iPhone app without drifting into generic productivity, chatbot, calendar, surface, commerce, or motivational chrome.

This batch is primarily an audit and authority-alignment batch. It may update documentation, trace ledgers, inventories, and implementation prompts. It must not broadly rewrite SwiftUI source unless a later explicitly scoped implementation batch authorizes that work.

## Active Source Truth To Inspect

Inspect these first, in order:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`
9. `frontend/visual-encyclopedia/AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md`
10. `frontend/visual-encyclopedia/CHROME_ENRICHMENT_DOCTRINE.md`
11. `frontend/visual-encyclopedia/CHROME_PRIMITIVES.md`
12. `frontend/visual-encyclopedia/trace/CHROME_ENRICHMENT_INSTALL_LEDGER.md`
13. `frontend/visual-encyclopedia/recipes/shell/global_app_shell.md`
14. `frontend/visual-encyclopedia/recipes/today/today_reality_meridian_flagship_surface.md`
15. `frontend/visual-encyclopedia/recipes/today/today_start_here_region.md`
16. `frontend/visual-encyclopedia/recipes/today/today_current_context_header.md`
17. `frontend/visual-encyclopedia/recipes/today/closure_sheet.md`
18. `frontend/visual-encyclopedia/recipes/capture/capture_root_atmosphere_composer.md`
19. `frontend/visual-encyclopedia/recipes/time/time_root_lifeshape_field.md`
20. `frontend/visual-encyclopedia/recipes/goals/goals_root_constellation_atlas.md`
21. `frontend/visual-encyclopedia/recipes/you/you_root_user_system_profile.md`
22. `frontend/visual-encyclopedia/trace/FRONTEND_SOURCE_BINDINGS.yaml`
23. `frontend/visual-encyclopedia/trace/FRONTEND_IMPLEMENTATION_RECEIPT_SCHEMA.yaml`
24. `frontend/visual-encyclopedia/trace/FRONTEND_PROOF_CONTRACT_SCHEMA.yaml`
25. `Native/Ambitions/App/AppTab.swift`
26. `Native/Ambitions/App/AmbitionsRootView.swift`
27. `Native/Ambitions/Features/Today/*`
28. `Native/Ambitions/Features/Goals/*`
29. `Native/Ambitions/Features/Captures/*`
30. `Native/Ambitions/Features/Plan/*` as internal compatibility seam only
31. `Native/Ambitions/Features/Profile/*`
32. `Sources/Theme/AmbitionTheme.swift`
33. `Sources/Accessibility/AccessibilityNutrition.swift`
34. `Sources/Previews/*`

## Operating Model

Run as:

1. GPT-5.5 plan: inspect authority, classify risk, define audit approach.
2. GPT-5.3-Codex-Spark bounded patch: update only allowed documentation/control-plane artifacts.
3. GPT-5.5 review/repair/final commit: verify authority, terminology, scope, and proof honesty.

Do not bypass the runner unless the user explicitly says: `bypass the Ambitions runner`.

## Allowed Scope

Documentation and control-plane only:

- `frontend/visual-encyclopedia/**/*.md`
- `frontend/visual-encyclopedia/**/*.yaml`
- `docs/audits/**/*chrome*`
- `docs/canon/**/*chrome*` only if an existing canon path clearly requires it
- `build/reports/**/*chrome*`
- `prompts/batches/CHROME-*.md`

Allowed deliverables:

- chrome audit report
- active/supporting/historical/obsolete classification table
- primitive-to-surface mapping
- source-to-chrome gap ledger
- next implementation batch prompt
- validation matrix
- rollback plan
- authority index link corrections
- proof-honesty warnings

## Forbidden Scope

Do not modify unless a later implementation batch explicitly authorizes it:

- `Native/**/*.swift`
- `Sources/**/*.swift`
- `.github/workflows/**`
- package/project build configuration
- runtime persistence/data models
- test fixtures unrelated to chrome audit
- release docs claiming shipped behavior
- screenshots, visual proof, or simulator artifacts unless generated by an explicitly scoped later UI batch
- `.codex/runs/**` committed artifacts

Do not:

- promote `Plan` as a visible top-level destination
- introduce an AI/chatbot top-level destination
- replace Reality Meridian with a generic task list
- make Start Here a generic recommendation card
- add Start now, Start now, Recommended step, proof signal, proof thread, shame, or failure framing
- claim implementation, screenshot parity, accessibility conformance, or release readiness without proof
- silently delete historical material without classification and rollback notes

## Audit Work Required

### Phase 1 — Authority Read

Read the active truth files and frontend authority index. Confirm the installed chrome doctrine and primitives are subordinate to truth and compatible with active IA.

Output:

- authority summary
- any conflict with truth files
- whether chrome docs are correctly discoverable

### Phase 2 — Chrome Inventory

Inventory every current chrome artifact in docs and source:

- top context/header chrome
- bottom tab chrome
- Capture composer chrome
- Reality Meridian chrome
- Start Here chrome
- receipt/proof/source affordances
- closure/recovery sheets
- adjust/reflow/conflict sheets
- continuity/session state
- You/Profile trust chrome
- terminology and CTA language

Classify each as:

- active
- supporting
- historical
- obsolete
- archive-candidate
- delete-candidate

### Phase 3 — Primitive Mapping

Map installed primitives to each top-level destination:

- Today: `RealityMeridianRail`, `CurrentTimeGlow`, `StartHereSurface`, `ReceiptHandle`, `ReceiptDrawer`, `ClosureSheet`, `RecoverySheet`, `AdjustPlanSheet`, `ContinuityStrip`.
- Goals: `ObjectThreadRail`, `ProofSheet`, `ReceiptHandle`, `ReceiptDrawer`, `ContextTopEdge`.
- Capture: `AtmosphereComposer`, `ContextTopEdge`, `DestinationTabBar`, post-capture routing affordances.
- Time: `LifeShapeScopeChip`, `RealityMeridianRail` where day-specific, `ScheduleConflictSheet`, `AdjustPlanSheet`, `SourceQualityLine`.
- You: `TrustProfilePanel`, grouped navigation rows, receipt/proof/trust controls.

### Phase 4 — Gap And Risk Ledger

Identify:

- missing primitives
- duplicated chrome
- obsolete Plan-era chrome
- generic dashboard/card-stack risks
- chatbot drift risks
- local-proof claims without proof paths
- accessibility gaps
- Dynamic Type / Reduce Motion / VoiceOver gaps
- visual proof gaps
- source-binding gaps

### Phase 5 — Bounded Next Batch Plan

Create the next implementation-ready runner prompt, likely:

`CHROME-TODAY-01.md`

It must be scoped to Today chrome first and must include source files, forbidden scope, validation expectations, visual proof expectations, hard red stops, rollback expectations, and runner command.

## Required Output Files

Create or update only within allowed scope:

1. `docs/audits/CHROME_AUDIT_01.md`
2. `build/reports/chrome-audit-01.json`
3. `frontend/visual-encyclopedia/trace/CHROME_PRIMITIVE_SURFACE_MATRIX.md`
4. `frontend/visual-encyclopedia/trace/CHROME_GAP_AND_RISK_LEDGER.md`
5. `prompts/batches/CHROME-TODAY-01.md`

If any output path already exists, update it instead of duplicating.

## Validation Expectations

Before final commit, run every applicable local validation command available in the repo without requiring external paid services. At minimum, attempt:

```bash
git diff --check
python3 scripts/ambitions-surface-recipe-inventory-check.py .
```

If a command is unavailable, fails because of pre-existing repo conditions, or is out of scope, record that honestly in `docs/audits/CHROME_AUDIT_01.md` and `build/reports/chrome-audit-01.json`.

## Visual Proof Expectations

This audit batch does not need to produce simulator screenshots. It must define visual proof expectations for later implementation batches.

The later Today implementation batch must require screenshots or equivalent visual proof for:

- normal Today
- active step
- overrun/drift with exact current-time marker
- unresolved closure
- recovery needed
- no available free time
- protected block
- away/vacation day
- high-pressure day
- empty/new user day

## Hard Red Stop Conditions

Stop red and do not patch if:

- active truth files conflict with the chrome doctrine in a way that cannot be safely resolved
- required source paths are missing and cannot be confidently mapped
- planned changes would touch forbidden SwiftUI/source scope
- `.codex/runs/**` artifacts would be committed
- the batch would create release claims without proof
- the batch would remove historical docs without classification
- the batch would weaken the local-first moat or introduce external/cloud LLM dependency into core behavior

## Rollback Expectations

Rollback is path-scoped.

If this batch fails before commit, restore all touched files.
If it commits and later fails review, revert only the CHROME-AUDIT-01 documentation/control-plane changes unless a higher authority file requires correction.
Do not rollback truth files unless they were explicitly and incorrectly modified by this batch.

## Final Response Required From Codex

Return:

- Status: GREEN / YELLOW / RED
- Files changed
- Validation commands run and results
- Chrome risks found
- Next batch recommended
- Any skipped validation with reason
- Explicit statement that no SwiftUI implementation or release readiness was claimed

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

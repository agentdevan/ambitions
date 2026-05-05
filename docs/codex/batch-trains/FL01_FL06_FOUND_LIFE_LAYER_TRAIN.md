# FL01-FL06 Found Life Layer Train
<!-- markdownlint-disable MD013 -->

Status: Active-scope planning truth; FL01-FL03 complete Green, FL04 queued.
Date: 2026-05-05
Train code: FL

## Required Approval Phrase

`Start Found Life Layer Train`

The global full-stack order may also select FL batches when the user explicitly preauthorizes cross-train sequencing.

## Purpose

The Found Life Layer protects the real soul of Ambitions: helping ambitious, scattered, under-guided people become found in life without losing the joy of today.

It turns Ambitions from a goal execution app into a life visibility, searchable memory, promise-keeping, option-value, and future-building operating system.

Locked tagline:

> Find your life. Keep your promises. Build your future. Enjoy today.

## Relationship To Existing Trains

- FCP implements flagship product objects.
- PFC makes platform/framework/legal/build quality trustworthy.
- AOS builds the life intelligence runtime.
- LDI turns dreams into safe, sourced, feasible paths.
- FL gives all of those trains the deeper life-continuity purpose so they do not devolve into task management, dashboards, or generic AI memory.

FL is not a sixth tab. FL is a domain/canon layer expressed through Today, Goals, Capture, Plan, You, AOS, LDI, FCP, and PFC.

## Placement

FL01-FL06 should run after PFC12 App Groups / Shared Storage Boundary and before FCP17 Schedule / Availability / Defaults Center.

Reason:

- PFC foundations now clarify repo/build/schema/sync/storage boundaries.
- FCP core objects have not started yet.
- Found Life needs to shape Start Here, Reality Rail, Availability Center, Receipt Drawer, Memory Lens, AOS, and LDI before those implementation batches lock product assumptions.

## Global Stop Conditions

Stop on hard Red:

- new top-level tab
- dashboard/search-database/notes-app/life-feed drift
- generic productivity drift
- surveillance-feeling memory model
- sensitive life data exposed without privacy/source/freshness controls
- career/education/health/legal/financial claims that outrun source truth and legal boundaries
- unsupported AOS/LDI/runtime/memory/sync claim
- any production Swift edit in docs-only FL batches unless explicitly permitted

## Batch Order

### FL01 — Founder Backstory / Product Soul Lock

Status: Complete / Green on 2026-05-05 with accepted Yellow order-reconciliation note.

Type: Docs/canon.
Owner: Product soul / positioning.
Depends on: Found Life canon file.
Goal: Lock the founder backstory, sports-car-with-no-GPS metaphor, and tagline into canon without turning it into marketing fluff.
Allowed files: canon/docs/audits/order docs.
Required output: product soul source truth and no-drift rules.
Acceptance:

- The line `Find your life. Keep your promises. Build your future. Enjoy today.` is recorded as canonical tagline.
- The product is explicitly defined as life visibility and life continuity, not only goal execution.
- Found Life is not a new top-level tab.
- The source truth protects against dashboards, shame, surveillance, and generic memory chatbot drift.

Evidence:

- `docs/codex/batches/FL01_Founder_Backstory_Product_Soul_Lock_Prompt.md`
- `docs/audits/fl01-founder-backstory-product-soul-lock-report.md`

Accepted Yellow:

- The preferred order placed FL01-FL06 before FCP17, but FCP17 landed before FL
  because the Found Life remote source arrived after local FCP17 execution.
  FCP17 remains completed Green. FL now governs all further FCP/AOS/LDI/PFC
  work, and later FL batches may flag FCP17 for compatibility review if needed.

### FL02 — Life Inventory Object Model

Status: Complete / Green on 2026-05-05.

Type: Docs/domain contract.
Owner: AOS / Memory / You / Capture.
Depends on: FL01.
Goal: Define Life Inventory object model for life threads, roles, commitments, relationships, projects, errands, ideas, dreams, and parked loops.
Required output: domain object definitions, ownership map, privacy classification, and surface mapping.
Acceptance:

- Life threads have states, sources, freshness, privacy class, and owner surfaces.
- Life Inventory maps to Today, Capture, Goals, Plan, You, Memory Lens, AOS, and LDI.
- No dashboard or all-at-once life database is introduced.

Evidence:

- `docs/codex/batches/FL02_Life_Inventory_Object_Model_Prompt.md`
- `docs/audits/fl02-life-inventory-object-model-report.md`

### FL03 — Commitment Memory / Open Loop Registry

Status: Complete / Green on 2026-05-05.

Type: Docs/domain contract.
Owner: Memory / Capture / Today / You.
Depends on: FL02.
Goal: Define how Ambitions remembers promises, errands, follow-ups, birthdays, work threads, parked projects, abandoned ideas, waiting items, and blocked loops.
Required output: Commitment Memory and Open Loop Registry contracts.
Acceptance:

- Commitment states include active, parked, waiting, blocked, needs review, needs recovery, intentionally dropped, ready to revive, converted to goal, converted to one-off step.
- User-confirmed, inferred, imported, private, stale, and completed commitments are separate.
- Closure is non-shaming and receipt-backed.

Evidence:

- `docs/codex/batches/FL03_Commitment_Memory_Open_Loop_Registry_Prompt.md`
- `docs/audits/fl03-commitment-memory-open-loop-registry-report.md`

### FL04 — Searchable Life Recall Contract

Type: Docs/domain/trust contract.
Owner: Memory Lens / You / AOS.
Depends on: FL02-FL03.
Goal: Define what life recall/search can answer and what proof/source/privacy/freshness must be shown.
Required output: search contract, recall examples, forbidden hallucination rules, privacy and deletion/correction boundaries.
Acceptance:

- Recall never presents unsupported inference as fact.
- Every recall answer has source/freshness/privacy/review path.
- Sensitive content is private by default.
- Widgets/Live Activities/notifications cannot expose sensitive Found Life content by default.

### FL05 — Option Value / Pivot Preservation Model

Type: Docs/domain/intelligence contract.
Owner: Goals / AOS / LDI.
Depends on: FL02-FL04.
Goal: Define how prior proof still counts when the user pivots between dreams, careers, hobbies, and life directions.
Required output: option-value model, path-overlap contract, proof-transfer rules, source requirements, career/education safety boundaries.
Acceptance:

- Progress is preserved across pivots where source/requirements overlap.
- Adjacent paths expose requirements and uncertainty.
- Career/education recommendations are source-grounded and non-claimy.
- No legal/financial/medical/professional claim outruns source truth.

### FL06 — Weekly Life Sweep Ritual

Type: Docs/product ritual contract.
Owner: Today / Plan / You / AOS.
Depends on: FL01-FL05.
Goal: Define the weekly ritual that helps users become found again without shame.
Required output: Weekly Life Sweep object contract, prompts, state model, privacy/trust rules, and integration map.
Acceptance:

- Sweep includes forgotten commitments, promises, still matters, can drop, becoming real, noise, next income/career move, relationship/family attention, work risk, and future path evidence.
- The ritual is calm and short enough to complete.
- It feeds Start Here, Reality Rail, Life Inventory, Option Value, and Memory Lens.
- It never becomes a dashboard, scorecard, or shame ritual.

## Validation

Every FL batch must run or document inability to run:

- `git status --short`
- `git diff --check`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- Found Life drift scan if available
- release/legal/privacy/no-claim scan

FL docs-only batches must verify no production Swift, route/raw value, persistence/schema, sync/cloud, monetization, privacy/legal, release, workflow, signing, entitlement, CI, AI runtime, or LDI runtime behavior changed.

## Completion Standard

FL completes when FL01-FL06 are Green or accepted Yellow with owner and repair path, and global order points FCP/AOS/LDI/PFC work to Found Life source truth before implementing life visibility, recall, recommendation, proof, or path-pivot behavior.

<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# START-HERE-REALITY-RECOGNITION-01

## Batch ID

`START-HERE-REALITY-RECOGNITION-01`

## Runner Command

```bash
scripts/ambitions-codex-train.sh START-HERE-REALITY-RECOGNITION-01 prompts/batches/START-HERE-REALITY-RECOGNITION-01.md
```

or:

```bash
make batch BATCH=START-HERE-REALITY-RECOGNITION-01 PROMPT=prompts/batches/START-HERE-REALITY-RECOGNITION-01.md
```

## Objective

Install the mature Start Here reality-recognition model into Ambitions implementation planning and, where the active source scope supports safe bounded changes, into Today frontend behavior.

The core product rule is:

> Start Here recognizes scheduled reality before it recommends anything.

A scheduled step currently inside its time window must render as `Active step`, not `Recommended step` and never `best next step`. `Recommended step` is valid only when Ambitions selects from unscheduled possible work.

## Active Source Truth To Inspect First

Inspect these files before planning or patching:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`
- `frontend/visual-encyclopedia/CHROME_ENRICHMENT_DOCTRINE.md`
- `frontend/visual-encyclopedia/START_HERE_REALITY_RECOGNITION_DOCTRINE.md`
- `frontend/visual-encyclopedia/CHROME_PRIMITIVES.md`
- `frontend/visual-encyclopedia/recipes/today/README.md`
- `frontend/visual-encyclopedia/recipes/today/today_reality_meridian_flagship_surface.md`
- `frontend/visual-encyclopedia/recipes/today/today_start_here_region.md`
- `frontend/visual-encyclopedia/trace/CHROME_ENRICHMENT_INSTALL_LEDGER.md`
- `Native/Ambitions/Features/Today/*`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppTab.swift`
- `Sources/Theme/AmbitionTheme.swift`
- `Sources/Accessibility/AccessibilityNutrition.swift`
- `Sources/Previews/*`

## Allowed Scope

Docs/source may be changed only within this scope:

- Today Start Here resolver/state/copy source files, if present.
- Today Reality Meridian integration files, if present.
- Today previews/fixtures needed to prove state variants.
- Accessibility labels for Today Start Here and Reality Meridian.
- `frontend/visual-encyclopedia/*` only when needed to keep canon and implementation receipts aligned.
- `build/reports/*` only for generated proof reports/receipts.
- `prompts/batches/*` only for follow-up runner prompts if the current repo state requires splitting implementation.

Prefer the narrowest patch that gives Ambitions a resolver-derived Start Here state model without broad visual rewrites.

## Forbidden Scope

Do not:

- Rename the top-level `Time` tab back to `Plan`.
- Add an AI/chatbot top-level destination.
- Replace Reality Meridian with a generic task list.
- Convert Start Here into a detached recommendation card.
- Add shame language such as `Overdue`, `Failed`, or `Behind` as primary user-facing state.
- Use `best next step`, `next best move`, `optimal move`, `AI pick`, or `Suggested by AI`.
- Treat scheduled-current work as `Recommended step`.
- Collapse `Active step`, `In progress`, `Up next`, and `Recommended step` into a single state.
- Silently reflow plans without preview, receipt, and rollback/undo path.
- Depend on glow, color, or motion as the only state carrier.
- Make broad shell or design-system rewrites outside Today unless required by shared primitives and explicitly proven safe.
- Claim release readiness, simulator parity, screenshot parity, accessibility conformance, or shipped behavior without proof.

## Required Product Model

Implement or prepare the source architecture for these concepts:

- `StartHereMode`
- `StartHereAuthority`
- `TemporalRelation`
- `StartHereCTA`
- `ReceiptSource`
- `ReceiptSignal`

The resolver output must include:

- display label
- primary object/title
- explanation copy
- primary CTA
- secondary CTA
- receipt source
- receipt signals
- visual tone/state
- accessibility label

The UI must consume resolver output rather than infer user-facing labels ad hoc from task data.

## Required Resolver Precedence

1. Active session → `In progress` → `Resume`.
2. Hard current commitment/protected/away → `Current commitment`, `Protected time`, or `Away mode`.
3. Scheduled step inside current time window → `Active step` → `Start now`.
4. Overrunning scheduled step without closure → `Needs closure` → `Close loop`.
5. High-priority unresolved loop → `Needs closure`.
6. Upcoming scheduled step → `Up next` → `Open step`.
7. Open free window with unscheduled selected work → `Recommended step` → `Start now`.
8. Broken fit / plan drift → `Recovery` → `Recover plan`.
9. Missing context → `Set up today` → `Add schedule`.
10. Competing hard/scheduled items → `Schedule conflict` → `Resolve conflict`.

## Copy Rules

Use this label taxonomy exactly unless higher truth conflicts:

- `In progress`
- `Active step`
- `Current commitment`
- `Protected time`
- `Away mode`
- `Up next`
- `Recommended step`
- `Needs closure`
- `Recovery`
- `Set up today`
- `Schedule conflict`

Receipt source must match authority:

- `Active step` → `Scheduled step`
- `In progress` → `Active session`
- `Up next` → `Scheduled step`
- `Recommended step` → `Local recommendation`
- `Recovery` → `Reality change`
- `Needs closure` → `Open loop`
- `Protected time` → `Availability rule`
- `Away mode` → `Away setting`
- `Current commitment` → `Calendar / schedule source`
- `Schedule conflict` → `Conflict source`
- `Set up today` → `Missing context`

## Visual Proof Expectations

If UI source is changed, produce previews/screenshots or a generated proof report for at least these states, or explicitly explain why a state could not be generated from current source:

1. Active step
2. In progress
3. Up next
4. Recommended step
5. Needs closure
6. Recovery
7. Protected time
8. Current commitment
9. Away mode
10. Schedule conflict
11. Set up today
12. Overrunning step
13. Low-energy/reduced-choice variant, if supported
14. Dynamic Type
15. Reduce Motion
16. VoiceOver order notes

Proof must show that the Reality Meridian visually agrees with Start Here state. For `Active step`, the scheduled block remains at its actual time and the current-time marker sits at exact current time.

## Validation Expectations

Run the strongest available local validations for the touched scope. At minimum, inspect and report:

- Swift build/test feasibility for touched files.
- Any Today preview compilation or snapshot generation available in the repo.
- Terminology scan for forbidden copy.
- Accessibility labels for state, source, action, and receipt.
- Release-honesty wording in changed docs/reports.

If a validation command cannot be run in the environment, record it as `not_run` with the reason. Do not claim Green for unrun proof.

## Hard Red Stop Conditions

Stop and return Red if implementation would require:

- lying about shipped behavior or proof
- deleting active canon to make source pass
- broad unrelated rewrites
- introducing Plan as visible top-level destination
- removing local proof/receipt inspection
- turning Today into a generic list/calendar/dashboard
- bypassing the Ambitions runner
- touching secrets, CI credentials, or costed external services

## Rollback Expectations

Rollback must be path-scoped. If source changes fail validation, revert only this batch's touched implementation files and preserve the active docs unless the docs themselves caused the failure. Any rollback report must name:

- paths reverted
- validation that failed
- retained canon
- follow-up batch needed

## Required Output Receipt

Write a final batch report under `build/reports/` that includes:

- status: Green / Yellow / Red
- files changed
- resolver/model changes
- copy changes
- preview/proof status
- validations run
- validations not run
- known gaps
- rollback instructions
- next recommended batch

## Acceptance Bar

This batch is acceptable only when Ambitions cannot accidentally render a scheduled-current step as `Recommended step` in the Today Start Here surface without a test/proof failure or explicit Yellow/Red report.

# PLOS Goal

Status: Active Goal Mode program authority for PLOS
Program: Personal Life OS Runtime Master Build
Current allowed run type: AMB-713 / PLOS-092 Step context-fit validator
Current execution state: PLOS-M00 through PLOS-M08 complete in Linear. M09 is active after live Linear verification confirmed AMB-627 / PLOS-M09 is Backlog, AMB-711 and AMB-712 are Done, AMB-713 is In Progress, AMB-714 through AMB-717 are Backlog, and AMB-773 through AMB-779 are Duplicate/archived/canceled.

## Mission

Upgrade and run the PLOS control plane so the full Linear PLOS project can run through Goal Mode without synthetic issue drift, false Green, context churn, privacy/source/safety drift, or phase-order violations.

This file does not prove runtime implementation. It defines the governance, queue, validation, reviewer, and closeout rules that must stay Green while PLOS execution proceeds one `AMB-*` child issue at a time.

## Non-Goals

- Do not implement PLOS runtime features during documentation/planning children unless the active `AMB-*` child explicitly authorizes source implementation.
- Execute PLOS phases only in order, through the actual `AMB-*` parent and child identifiers, after the relevant phase gate passes.
- A parent phase closes only after all required children and the parent acceptance gate are Green or explicitly accepted Yellow with no-claim boundaries.
- Do not create branches or PRs for normal PLOS execution unless a future active issue changes branch policy.
- Do not introduce required cloud LLM, hosted planning, analytics, telemetry, or custom backend dependencies.
- Do not place private user data in R2, public Source Atlas objects, or external source packs.
- Do not claim release, TestFlight, device, accessibility, privacy, App Review, or performance readiness without matching proof.

## Authority

Read these before any PLOS source-changing run:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. `docs/codex/PERSONAL_LIFE_OS_RUNTIME_LAW.md` for PLOS runtime-law Green enforcement after AMB-637
10. `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md` for any-goal/source-needed/coverage-demand Green enforcement after AMB-638
11. `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md` for Source Atlas source authority, freshness, review, jurisdiction, eligibility, and share-boundary Green enforcement after AMB-639
12. `docs/codex/SEED_BASED_PLANNING_LAW.md` for reusable seed, seed-gap, composition, and hardcoded-Step Green enforcement after AMB-639
13. `docs/codex/STEP_ELASTICITY_RUNTIME_LAW.md` for Step Elasticity, shrink/replace/split/merge/recovery/momentum, and Vibe Signature Green enforcement after AMB-640
14. `docs/codex/LIFE_CONSEQUENCE_REFLOW_LAW.md` for cross-goal reflow, schedule mutation, Goal Treaty, severity, non-suppressible event, and receipt Green enforcement after AMB-641
15. `docs/codex/TRUST_UI_DISCLOSURE_LAW.md` for trust-light UI, source/receipt/replay disclosure, drill-down trace, breadcrumb, glyph, and false-calm Green enforcement after AMB-642
16. `docs/codex/ADHD_COGNITIVE_LOAD_UI_LAW.md` for low cognitive-load, ADHD-friendly, top-level copy/density, progressive disclosure, and accessibility-boundary Green enforcement after AMB-642
17. `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md` for local/iCloud/R2/data classification, privacy/source pack, export, sync, and cloud-boundary Green enforcement after AMB-643
18. `docs/codex/SHARING_AND_PROGRESS_STORY_LAW.md` for user-initiated/local/redacted/proof-bound sharing, progress stories, export, projection, and no-social-pressure Green enforcement after AMB-643
19. `docs/codex/HIGH_RISK_DOMAIN_SAFETY_LAW.md` for high-risk, jurisdiction, source authority, professional-boundary, blocked unsafe, crisis/safety, and high-risk sharing Green enforcement after AMB-643
20. `docs/codex/PROGRAM_EXECUTION_CONTRACT.md` for existing-first execution, source-changing guard, Codex Red/Yellow authority, non-waivable gates, Yellow continuation, closeout format, token optimization, and no-architecture-theater Green enforcement after AMB-644
21. `docs/codex/PLOS_GREEN_YELLOW_RED_REPORTING.md` for Green/Yellow/Red reporting, final report format, screenshot/accessibility proof boundaries, and issue-to-phase rollup enforcement after AMB-645
22. `docs/codex/PLOS_VALIDATION_REGISTRY.md` for known versus unknown validation commands, proof lanes, and no-invented-command enforcement after AMB-645
23. `docs/codex/PLOS_PROOF_ARTIFACT_CONTRACT.md` for report, validation, screenshot, accessibility, performance, reviewer, script-output, ledger, and rollup artifact paths after AMB-645
24. `artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.md`
25. `artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.md`
26. `artifacts/plos-runtime/PLOS-run-state.md`
27. `artifacts/plos-runtime/PLOS_PHASE_GATES.md`
28. `.agents/skills/plos-runtime-master-build/SKILL.md`
29. Relevant live source, tests, scripts, Linear issue, and proof artifacts for the active `AMB-*` issue

Truth files outrank this file. Linear issue content outranks stale local planning only after the issue has been resolved to the actual `AMB-*` identifier.

## Linear Binding Law

PLOS labels are aliases. Linear identifiers are `AMB-*`.

- `PLOS-M00` resolves to `AMB-608`.
- `PLOS-M01` resolves to `AMB-609`.
- Continue through `PLOS-M26` as declared in `PLOS_LINEAR_ISSUE_MAP.json`.
- Never fetch, comment, update, or close out Linear work using `PLOS-M##` or `PLOS-###`.
- If a child issue label is needed, resolve it to the live `AMB-*` child issue before work starts and record that binding in the active packet/run-state.
- Any unresolved PLOS label is Red for execution.

## Program Artifacts

Required readiness artifacts:

- `artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.md`
- `artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.json`
- `artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.md`
- `artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json`
- `artifacts/plos-runtime/PLOS_PHASE_GATES.md`
- `artifacts/plos-runtime/PLOS_RISK_REGISTER.md`
- `artifacts/plos-runtime/PLOS_AUTONOMOUS_READINESS_AUDIT.md`
- `.agents/skills/plos-runtime-master-build/SKILL.md`
- `.agents/skills/plos-runtime-master-build/references/plos-reviewer-prompts.md`
- `.agents/skills/plos-runtime-master-build/references/plos-closeout-template.md`
- `docs/codex/PLOS_GREEN_YELLOW_RED_REPORTING.md`
- `docs/codex/PLOS_VALIDATION_REGISTRY.md`
- `docs/codex/PLOS_PROOF_ARTIFACT_CONTRACT.md`
- `scripts/codex/plos-readiness-validate.py`
- `scripts/codex/program-preflight.sh`
- `scripts/codex/program-phase-gate.sh`
- `scripts/codex/linear-closeout-validate.py`

Supporting Source Atlas readiness artifacts:

- `artifacts/source-atlas-factory/SAF_HARDENING_PLAN.md`
- `scripts/codex/source-atlas-readiness-validate.py`
- `.agents/skills/source-atlas-factory/SKILL.md`

## Execution Sequence

1. Confirm branch is `main` and capture `BASE_SHA`.
2. Read active truth files and this PLOS goal packet.
3. Resolve the active phase label to its `AMB-*` Linear issue.
4. Resolve any child issue label to its `AMB-*` Linear issue before Linear access.
5. Run `scripts/codex/program-preflight.sh plos`.
6. Run `scripts/codex/program-phase-gate.sh plos <phase>`.
7. Inspect live source ownership before any source edit.
8. Keep the patch scoped to the active `AMB-*` issue.
9. Run focused validation and any required reviewer prompts.
10. Validate closeout text with `python3 scripts/codex/linear-closeout-validate.py --program plos`.
11. Commit and push only validated scoped work.
12. Update Linear with evidence-backed status using the `AMB-*` issue identifier.

## Phase Order

PLOS phases run strictly `M00` through `M26`, using the queue in `PLOS_EXECUTION_QUEUE.json`.

Broad runtime expansion is blocked until:

- M00 governance/law is Green or accepted Yellow.
- M01 live runtime truth map is Green or accepted Yellow.
- M02 through M09 foundations and safety gates are satisfied.
- M10 Golden Slice gate proves the vertical slice boundary before scaling.

## Green / Yellow / Red

Green means the scoped phase or readiness task is complete, AMB-bound, validated, and no proof claim exceeds evidence.

Yellow means the scoped work is structurally correct but a named validation, external proof, owner review, device check, or child-map refresh remains incomplete and owned.

Red means execution must stop. Red includes:

- PLOS label used as a Linear identifier.
- Synthetic issue drift.
- PLOS-M00 execution before owner review for this readiness packet.
- Runtime feature implementation during readiness hardening.
- Private user data in R2 or public Source Atlas material.
- Required cloud LLM/core server dependency.
- Missing receipt, source binding, rollback, or safety gate for source packs.
- Phase order violation.
- Release, accessibility, privacy, device, performance, or App Review claims without proof.

## Closeout Boundary

Every PLOS closeout must state:

- The actual `AMB-*` issue(s) covered.
- Whether PLOS-M00 or any runtime phase was executed.
- Whether app source changed.
- Whether runtime features were implemented.
- Validations run and failures.
- Linear update target and identifier.
- Yellow/Red limits and next eligible action.

For AMB-667 execution, correct closeout says: reports/validation/control-plane artifacts only; no app source changes; no runtime features; R2 API compatibility validation plan is documentation/planning only; no compatibility test implementation, Cloudflare/R2 configuration, credential provisioning, network call, production write path, runtime fetch, dependency change, scanner install, SDK change, production pack publication, release, privacy/legal, security certification, performance, accessibility, device, or runtime behavior changed; AMB-611 / PLOS-M03 parent acceptance is the next eligible action only after AMB-667 is committed, pushed to `main`, and updated in Linear.

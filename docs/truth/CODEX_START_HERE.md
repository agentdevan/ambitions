# CODEX_START_HERE.md

Status: Active Codex routing and consumption aid
Scope: Task routing, minimum read paths, proof expectations, and closeout discipline
Owner posture: Routing/digest only, subordinate to all substantive truth files

This file routes Codex; it does not replace truth files.

This file does not define product canon, moat strategy, product-experience behavior, implementation status, release proof, process law, or retention policy. If this file conflicts with a substantive truth file, the substantive truth file wins.

Docs and plans do not prove implementation. Truth files define authority and standards; current source, tests, logs, screenshots, device proof, accessibility proof, privacy proof, release evidence, and owner acceptance prove scoped claims.

## Purpose and authority

Use this file to reduce truth-tax before action:

- identify the task type
- read the required files for that task
- preserve the existing truth hierarchy
- select the right proof standard
- close with evidence-bounded status

Do not use this file to skip a file that the active user instruction, `AGENTS.md`, or a specific issue explicitly requires.

## Default read path

For non-trivial Ambitions work, read in this order:

1. `docs/truth/README.md`
2. `docs/truth/CODEX_START_HERE.md`
3. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
4. `docs/truth/PRODUCT_ORIGIN_TRUTH.md` if present
5. `docs/truth/PRODUCT_MOAT_TRUTH.md`
6. `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
7. `docs/truth/IMPLEMENTATION_TRUTH.md`
8. `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
9. `docs/truth/RELEASE_TRUTH.md`
10. `docs/truth/CODEX_PROCESS_TRUTH.md`
11. `docs/truth/HISTORICAL_POLICY.md`
12. `AGENTS.md`
13. `README.md`
14. `docs/README.md`
15. `project.yml`
16. `Package.swift`
17. Relevant source, tests, retained scripts, build docs, current logs, and current issue/proof artifacts

Use the task matrix below to choose a smaller safe read path only when the task is clearly bounded and no instruction requires the full path.

## Task-type routing matrix

| Task type | Required files |
|---|---|
| Product identity / IA / design law | `docs/truth/README.md`, `docs/truth/PRODUCT_ORIGIN_TRUTH.md` if present, `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `docs/truth/PRODUCT_MOAT_TRUTH.md`, `docs/truth/PRODUCT_EXPERIENCE_CANON.md` |
| Product-experience behavior | `docs/truth/README.md`, `docs/truth/PRODUCT_EXPERIENCE_CANON.md`, `docs/truth/PRODUCT_EXPERIENCE_ACTION_MAP.md`, `docs/qa/product-experience-scenario-gates.md` |
| Swift source/runtime | `docs/truth/README.md`, `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `docs/truth/PRODUCT_EXPERIENCE_CANON.md`, `docs/truth/IMPLEMENTATION_TRUTH.md`, `docs/truth/CODEX_PROCESS_TRUTH.md`, relevant source/tests |
| SwiftUI/frontend/visual | `docs/truth/README.md`, `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `docs/truth/PRODUCT_EXPERIENCE_CANON.md`, `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`, `docs/truth/RELEASE_TRUTH.md`, relevant source/tests/screenshots |
| Build/test/release | `docs/truth/README.md`, `docs/truth/IMPLEMENTATION_TRUTH.md`, `docs/truth/RELEASE_TRUTH.md`, `docs/truth/CODEX_PROCESS_TRUTH.md`, build docs/scripts |
| QA/risk/gates | `docs/truth/README.md`, `docs/truth/PRODUCT_EXPERIENCE_CANON.md`, `docs/truth/PRODUCT_EXPERIENCE_ACTION_MAP.md`, `docs/qa/product-experience-scenario-gates.md`, `docs/qa/product-experience-scenario-gates.yaml`, `docs/truth/RELEASE_TRUTH.md` |
| Docs cleanup/retention | `docs/truth/README.md`, `docs/truth/HISTORICAL_POLICY.md`, `docs/truth/CODEX_PROCESS_TRUTH.md` |
| Account/R2/Source Atlas | `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `docs/truth/PRODUCT_MOAT_TRUTH.md`, `docs/truth/PRODUCT_EXPERIENCE_CANON.md`, `docs/truth/IMPLEMENTATION_TRUTH.md`, `docs/truth/RELEASE_TRUTH.md` |
| Origin/problem framing | `docs/truth/PRODUCT_ORIGIN_TRUTH.md` if present, `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `docs/truth/PRODUCT_EXPERIENCE_CANON.md` |

## Required proof by task type

| Task type | Required proof |
|---|---|
| Docs/governance | Truth-file diff, authority relationship preserved, no new canon conflict, relevant script/check output, `git diff --check`. |
| Product behavior/gates | Scenario gate IDs, current status label, evidence paths or empty evidence list, future proof needed, no status upgrade without evidence. |
| Swift source/runtime | Canonical owner/source proof, focused tests or explicit not-run reason, current logs, no forbidden IA/runtime drift, rollback path. |
| SwiftUI/frontend/visual | Source/tests, screenshots or explicit not-run reason, accessibility proof notes, Dynamic Type/Reduce Motion/contrast/safe-area notes, no Visual Green self-certification. |
| Build/test/release | Exact commands, exit codes, branch, commit SHA, environment, logs/artifacts, unsupported claims listed as not supported. |
| Account/R2/Source Atlas | Offline no-account boundary, no private life graph backend, no R2 private user context, request/privacy proof before any implementation or release claim. |

## Allowed closeout statuses

Docs/governance closeout may use:

- Green
- Yellow
- Red

Implementation and release-adjacent closeout must use the split status model:

- Source Green
- Runtime Green
- Interaction Green
- Ready for Visual Review
- Visual Green only with independent visual review
- Release Green only with current release proof and required approvals
- Yellow
- Red

Do not use an unqualified Green for source, visual, runtime, accessibility, device, TestFlight, App Store, account, R2, privacy, or release claims.

## Hard Red triggers

Stop and report Red if the train:

- reintroduces any persistent surface outside Today / Goals / Time / You
- treats Capture as a tab or root destination
- treats Motion as a tab, root destination, activity feed, score, streak, XP layer, or dashboard
- weakens Trust as Proof / Source / Privacy / History / Receipts
- requires sign-in or network for offline core value
- creates or implies a hosted private life graph
- makes hosted AI/cloud LLMs core runtime dependencies
- forgets R2 is not a user-data backend
- sends private user context, goals, captures, schedule, proof, receipts, behavior, inferred priorities, or the private life graph to R2/Source Atlas
- creates Source Atlas marketplace browsing as product center
- adds productivity score, life score, XP, streak pressure, social feed, public profile, or AI-chatbot center
- upgrades scenario gate status without evidence
- treats docs, plans, source names, screenshot paths, or string scans as implementation/product/release proof
- self-certifies Visual Green or Release Green

## Minimal closeout checklist

- Baseline SHA and final SHA
- Files changed
- Task type and required truth files inspected
- Truth hierarchy preserved
- Product law preserved: Today / Goals / Time / You, Capture global composer, Motion behavior, Trust inspection
- Local-first/account/R2/AI boundaries preserved
- Proof produced and validation run
- Validation not run with reason
- Known risks and remaining sprawl risks
- Rollback plan

For source trains, also include canonical owners touched, files moved/created, old/non-canonical paths removed, compatibility shims left, and whether Final Architecture Tree was inspected.

## Scenario gates

Human-readable scenario gates live at:

- `docs/qa/product-experience-scenario-gates.md`

Machine-readable scenario gate index lives at:

- `docs/qa/product-experience-scenario-gates.yaml`

Validate the machine-readable index with:

```bash
python3 scripts/product-experience-gate-index-check.py
```

Future trains that touch product-experience behavior must update the relevant gate status as Existing, Partial, Missing, or Unknown and attach evidence paths only when current evidence exists.

## Future split note

`IMPLEMENTATION_TRUTH.md` contains stable implementation standards and mutable source snapshot sections. A future governance train may split mutable source inventory into a dedicated snapshot file if it can do so without weakening implementation truth or creating authority sprawl.

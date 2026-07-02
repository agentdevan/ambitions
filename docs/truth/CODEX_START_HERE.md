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
3. `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`
4. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
5. `docs/truth/PRODUCT_ORIGIN_TRUTH.md` if present
6. `docs/truth/PRODUCT_MOAT_TRUTH.md`
7. `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
8. `docs/truth/IMPLEMENTATION_TRUTH.md`
9. `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
10. `docs/truth/RELEASE_TRUTH.md`
11. `docs/truth/CODEX_PROCESS_TRUTH.md`
12. `docs/truth/HISTORICAL_POLICY.md`
13. `AGENTS.md`
14. `README.md`
15. `docs/README.md`
16. `project.yml`
17. `Package.swift`
18. Relevant source, tests, retained scripts, build docs, current logs, and current issue/proof artifacts

Use the task matrix below to choose a smaller safe read path only when the task is clearly bounded and no instruction requires the full path.

## Task-type routing matrix

| Task type | Required files |
|---|---|
| Product identity / IA / design law | `docs/truth/README.md`, `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`, `docs/truth/PRODUCT_ORIGIN_TRUTH.md` if present, `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `docs/truth/PRODUCT_MOAT_TRUTH.md`, `docs/truth/PRODUCT_EXPERIENCE_CANON.md` |
| Product-experience behavior | `docs/truth/README.md`, `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`, `docs/truth/PRODUCT_EXPERIENCE_CANON.md`, `docs/truth/PRODUCT_EXPERIENCE_ACTION_MAP.md`, `docs/qa/product-experience-scenario-gates.md` |
| Swift source/runtime | `docs/truth/README.md`, `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`, `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `docs/truth/PRODUCT_EXPERIENCE_CANON.md`, `docs/truth/IMPLEMENTATION_TRUTH.md`, `docs/truth/CODEX_PROCESS_TRUTH.md`, relevant source/tests |
| LocalRuntimeOS / backend runtime | `docs/truth/README.md`, `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`, `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `docs/truth/IMPLEMENTATION_TRUTH.md`, `docs/truth/CODEX_PROCESS_TRUTH.md`, `.agents/skills/ambitions-runtime-contract-engineering/SKILL.md`, Linear `AMB-1544` and the active leaf, relevant source/tests |
| SwiftUI/frontend/visual | `docs/truth/README.md`, `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`, `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `docs/truth/PRODUCT_EXPERIENCE_CANON.md`, `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`, `docs/truth/RELEASE_TRUTH.md`, `docs/truth/FIGMA_PRODUCTION_GATE_ADDENDUM.md` when screenshots/Figma/VSP/visual proof are in scope, `docs/skills/ui-north-star-production-gate/SKILL.md`, relevant source/tests/screenshots |
| Figma/VSP/marketing render | `docs/truth/README.md`, `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`, `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`, `docs/truth/RELEASE_TRUTH.md`, `docs/truth/FIGMA_PRODUCTION_GATE_ADDENDUM.md`, `docs/skills/figma-production-gate/SKILL.md`; add `docs/skills/ui-north-star-production-gate/SKILL.md` when SwiftUI plausibility, screenshots, accessibility, shell, or design-system implementation is in scope |
| Build/test/release | `docs/truth/README.md`, `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md` when product or release claims are in scope, `docs/truth/IMPLEMENTATION_TRUTH.md`, `docs/truth/RELEASE_TRUTH.md`, `docs/truth/CODEX_PROCESS_TRUTH.md`, build docs/scripts |
| QA/risk/gates | `docs/truth/README.md`, `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`, `docs/truth/PRODUCT_EXPERIENCE_CANON.md`, `docs/truth/PRODUCT_EXPERIENCE_ACTION_MAP.md`, `docs/qa/product-experience-scenario-gates.md`, `docs/qa/product-experience-scenario-gates.yaml`, `docs/truth/RELEASE_TRUTH.md` |
| Docs cleanup/retention | `docs/truth/README.md`, `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md` when product mission/canon is touched, `docs/truth/HISTORICAL_POLICY.md`, `docs/truth/CODEX_PROCESS_TRUTH.md` |
| Account/R2/Source Atlas | `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`, `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `docs/truth/PRODUCT_MOAT_TRUTH.md`, `docs/truth/PRODUCT_EXPERIENCE_CANON.md`, `docs/truth/IMPLEMENTATION_TRUTH.md`, `docs/truth/RELEASE_TRUTH.md` |
| Origin/problem framing | `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`, `docs/truth/PRODUCT_ORIGIN_TRUTH.md` if present, `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `docs/truth/PRODUCT_EXPERIENCE_CANON.md` |

## Required proof by task type

| Task type | Required proof |
|---|---|
| Docs/governance | Truth-file diff, authority relationship preserved, no new canon conflict, relevant script/check output, `git diff --check`. |
| Product behavior/gates | Scenario gate IDs, current status label, evidence paths or empty evidence list, future proof needed, no status upgrade without evidence. |
| Swift source/runtime | Canonical owner/source proof, focused tests or explicit not-run reason, current logs, no forbidden IA/runtime drift, rollback path. |
| LocalRuntimeOS / backend runtime | Proof that the scoped change preserves `Command -> Event -> Projection -> Receipt -> Replay`, exact owner under `Core/LocalRuntimeOS/` or explicit Yellow debt, focused runtime/storage/projection/replay tests or not-run reason, no implementation Green from canon alone. |
| SwiftUI/frontend/visual | Source/tests, screenshots or explicit not-run reason, accessibility proof notes, Dynamic Type/Reduce Motion/contrast/safe-area notes, no Visual Green self-certification. |
| Build/test/release | Exact commands, exit codes, branch, commit SHA, environment, logs/artifacts, unsupported claims listed as not supported. |
| Account/R2/Source Atlas | Offline no-account boundary, no private life graph backend, no R2 private user context, request/privacy proof before any implementation or release claim. |

Architecture remediation and cleanup trains must also run:

```bash
python3 scripts/ambitions-remediation-governance-check.py
python3 scripts/ambitions-accepted-yellow-misuse-audit.py
```

For branch or PR validation, pass the base ref:

```bash
python3 scripts/ambitions-remediation-governance-check.py --base origin/main
```

If the guard is not run, close Yellow and name the exact follow-up. Passing this
guard is not implementation, runtime, visual, accessibility, privacy, device,
TestFlight, App Store, or release proof.

Every nontrivial product, feature, Linear, Codex, architecture, QA, or release-facing work item must state how it preserves or improves:

```text
Intent -> Context -> Path -> Time Fit -> Reflow -> Action -> Proof -> Learning
```

Infrastructure-only work must name which part of the loop it protects or enables, except for narrow repo health, security, build, or cleanup work where the relationship is explicitly "does not affect product mission; preserves repo health."

## Truth Claim Status Taxonomy

Use these labels for truth-doc, Linear, closeout, and governance claims before touching source. These labels classify the claim being made; they do not replace the split implementation/release statuses below.

| Label | Meaning |
|---|---|
| Implemented Green | The exact claim has current linked evidence artifacts: source paths, focused tests or logs, proof packets, owner acceptance where required, and no broader unsupported claim. |
| Implemented Yellow | Some source, process, or proof exists, but evidence is incomplete, validation is stale/not run, owner acceptance is missing, or known debt remains. Name the missing proof and next follow-up. |
| Partial | A defined subset is implemented or proven, but the whole claim is not. List what is present, what is absent, and the evidence boundary. |
| Aspirational | Desired future direction, product law, or architecture target with no current implementation proof. Do not treat as source truth. |
| Deprecated | Historical, compatibility-only, or retired material. It must not drive new work unless a current issue explicitly scopes migration or deletion. |
| Blocked | The claim cannot be proven or advanced because a named dependency, artifact, environment, approval, or blocker is missing. |
| Unknown | Current evidence has not been inspected or no proof was found. Do not infer implementation from plans, names, memory, or old docs. |

No fake Green rule: Green requires linked current evidence artifacts for the exact claim. Truth files, plans, source names, screenshot paths, string scans, and generated reports can support context, but they do not by themselves prove implementation, runtime behavior, visual quality, accessibility, privacy/legal approval, device readiness, TestFlight readiness, App Store readiness, R2 production readiness, CloudKit readiness, or release readiness.

Context compaction guard: after resume, interruption, or context compaction,
the newest user-visible instruction wins over summaries, memory, stale tracker
state, and earlier task variants. Before editing, tracker mutation, commit, or
closeout, re-run `git status --short --branch`, inspect the current diff, run
the relevant local guard for the active task, and refresh tracker state for any
issue you will claim or mutate. Do not continue a superseded task from a
compacted summary.

## Allowed closeout statuses

Docs/governance closeout may use:

- Green
- Yellow
- Red

Remediation parent Feature closeouts may use Green, Yellow, or Red only for
the exact parent scope being closed. Parent Green requires linked current
evidence for every required validation and proof artifact in that parent scope.
Accepted Yellow is forbidden for incomplete required source/runtime/test
remediation scope. If the parent or leaf requires code, deletion/quarantine,
runtime enforcement, direct-write removal, command/rejection receipt behavior,
migration proof, projection safety, device/release proof, or executable tests,
documentation is not closure. Keep the issue `In Progress`, move it to
`Needs Repair`, or use `Ready For Review` only after implementation and proof
exist. A docs-only leaf may close within docs-only scope, but it cannot close a
source/runtime parent. Red means the parent cannot be closed without repair.

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
- adds new meaningful runtime mutation authority outside the LocalRuntimeOS command/event/projection/receipt/replay spine
- adds new architecture nouns without deleting, collapsing, or replacing duplicate authority
- adds new Source Atlas scope before an ADR allowlists the changed file and Source Atlas boundary audits pass for the changed scope
- adds new `+02`, `+03`, or `+04` split files
- adds new broad `Models.swift` files
- touches production Swift files above the hard line cap without scoped deletion, collapse, or extraction proof
- changes package boundaries as cleanup theater without a linked package decision record
- lets adapters mutate canonical state
- adds central `Projection/SurfaceLenses` files when feature-local projection can satisfy canon
- adds custom Stage/UIKit/rendering machinery where SwiftUI-native implementation can satisfy product law
- creates Source Atlas marketplace browsing as product center
- adds productivity score, life score, XP, streak pressure, social feed, public profile, or AI-chatbot center
- cannot explain its relationship to Private Life Orchestration unless it is narrow repo health, security, build, or cleanup work
- upgrades scenario gate status without evidence
- treats docs, plans, source names, screenshot paths, or string scans as implementation/product/release proof
- self-certifies Visual Green or Release Green

## Minimal closeout checklist

- Baseline SHA and final SHA
- Files changed
- Task type and required truth files inspected
- Truth hierarchy preserved
- Product law preserved: Today / Goals / Time / You, Capture global composer, Motion behavior, Trust inspection
- Private Life Orchestration preserved: Intent -> Context -> Path -> Time Fit -> Reflow -> Action -> Proof -> Learning
- Local-first/account/R2/AI boundaries preserved
- Proof produced and validation run
- Validation not run with reason
- Known risks and remaining sprawl risks
- Exact next Linear follow-up for any Yellow/Red gap
- Rollback plan

Every remediation parent Feature closeout must also list validation run,
validation not run, proof artifacts, known risks, follow-up, and rollback.
Do not report Yellow as Green. Do not report release, device, accessibility,
privacy/legal, TestFlight, App Store, account, R2, or production readiness
claims unless current artifacts and required approvals are linked.

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

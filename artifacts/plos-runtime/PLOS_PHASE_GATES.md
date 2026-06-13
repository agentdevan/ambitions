# PLOS Phase Gates

Status: Active PLOS Goal Mode phase-gate contract
Updated: 2026-06-12
Scope of current packet: AMB-609 / PLOS-M01 read-only proof and mapping; no PLOS runtime feature implementation

Every phase must satisfy the global gates plus its phase-specific gate before execution can be closed Green. A phase label is not a Linear identifier. Use the `AMB-*` issue in `PLOS_LINEAR_ISSUE_MAP.json`.

## Global Gates

Before any PLOS phase runs:

- Read active truth files and `AGENTS.md`.
- Confirm current branch policy from the active issue; default is `main`.
- Resolve the phase label to its `AMB-*` issue.
- Resolve every child label to an `AMB-*` issue before Linear access.
- After AMB-637, read `docs/codex/PERSONAL_LIFE_OS_RUNTIME_LAW.md` before any PLOS issue that claims runtime/product Green.
- After AMB-638, read `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md` before any PLOS issue that claims any-goal intake, source-needed, unsupported-goal, classifier, or coverage-demand Green.
- After AMB-639, read `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md` before any PLOS issue that claims Source Atlas authority, source-backed pathing, freshness, revocation, jurisdiction, review, runtime eligibility, or share eligibility Green.
- After AMB-639, read `docs/codex/SEED_BASED_PLANNING_LAW.md` before any PLOS issue that claims seed coverage, coverage-demand seed gaps, source-pack seed behavior, Step generation from Source Atlas, elasticity seeds, or hardcoded-Step safety Green.
- After AMB-640, read `docs/codex/STEP_ELASTICITY_RUNTIME_LAW.md` before any PLOS issue that claims Step elasticity, replacement, shrink, extension, split, merge, recovery-safe behavior, momentum-tail behavior, Vibe Signature ranking, Step reallocation, Step rescheduling, or elastic Step UI Green.
- After AMB-641, read `docs/codex/LIFE_CONSEQUENCE_REFLOW_LAW.md` before any PLOS issue that claims reflow, schedule install, goal mutation, Step mutation, deadline change, source-change adaptation, active-goal portfolio safety, Goal Treaty behavior, recovery routing, or cross-goal consequence Green.
- After AMB-642, read `docs/codex/TRUST_UI_DISCLOSURE_LAW.md` and `docs/codex/ADHD_COGNITIVE_LOAD_UI_LAW.md` before any PLOS issue that claims trust-light UI, runtime reasoning disclosure, source/receipt/replay disclosure, drill-down trace, breadcrumb, glyph state, low cognitive-load UI, ADHD-friendly UI, top-level copy/density, or accessibility-boundary Green.
- After AMB-643, read `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`, `docs/codex/SHARING_AND_PROGRESS_STORY_LAW.md`, and `docs/codex/HIGH_RISK_DOMAIN_SAFETY_LAW.md` before any PLOS issue that claims local data, iCloud/CloudKit, R2, source-pack distribution, privacy, export, sharing, progress story, high-risk safety, jurisdiction, professional-boundary, crisis/safety, or high-risk share Green.
- After AMB-644, read `docs/codex/PROGRAM_EXECUTION_CONTRACT.md` before any PLOS issue that claims process Green, Red/Yellow continuation, child/phase closeout readiness, source-changing authority, human review requirement, non-waivable gate status, issue splitting/resequencing, or proof/reporting Green.
- After AMB-645, read `docs/codex/PLOS_GREEN_YELLOW_RED_REPORTING.md`, `docs/codex/PLOS_VALIDATION_REGISTRY.md`, and `docs/codex/PLOS_PROOF_ARTIFACT_CONTRACT.md` before any PLOS issue that claims Green/Yellow/Red status, validation proof, report completeness, screenshot proof, accessibility proof, performance proof, privacy/source/safety proof, issue-to-phase rollup, or proof artifact Green.
- Run `scripts/codex/program-preflight.sh plos`.
- Run `scripts/codex/program-phase-gate.sh plos <phase>`.
- Confirm no dirty forbidden app/source/project paths unless the active issue explicitly authorizes source changes.
- Confirm no PLOS label is used for Linear fetch, comment, status update, or closeout.
- Preserve local-first, inspectable runtime authority.
- Preserve Source Atlas public-reference-only boundaries.
- Preserve proof boundaries: no release, privacy, accessibility, device, performance, or App Review claims without evidence.

## Green / Yellow / Red Gate

Green:

- The phase is AMB-bound, in order, scoped, validated, and proof-backed.
- Required reviewer prompts are run or explicitly not applicable with reason.
- Linear closeout uses the `AMB-*` issue identifier and evidence-backed status.

Yellow:

- The phase is structurally correct but a named external proof, owner review, device proof, or evidence refresh remains incomplete and owned.
- Yellow cannot authorize a release or broad runtime claim.

Red:

- Synthetic issue drift, PLOS label Linear access, phase-order violation, private user data in R2, required cloud LLM/core server dependency, silent user-data mutation, missing source/proof receipt, or unproven readiness/release claim.

## M00

Linear issue: `AMB-608`
Label: `PLOS-M00`
Purpose: Existing governance expansion and runtime laws.

Required before Green:

- Existing governance, truth files, Goal Mode policy, and current PLOS/Source Atlas artifacts have been audited.
- The Personal Life OS runtime law is installed, cross-linked to active truth, and available for future PLOS Green enforcement.
- The Any Goal Solution Loop law is installed, cross-linked to existing Source Atlas/GoalIntent anchors, and available for future any-goal intake and coverage-demand Green enforcement.
- The Source Atlas Authority law is installed, cross-linked to existing Source Atlas anchors, and available for future source authority, freshness, review, jurisdiction, runtime eligibility, and share-boundary Green enforcement.
- The Seed-Based Planning law is installed, cross-linked to existing Source Atlas seed/bridge anchors, and available for future seed coverage, coverage-demand, Step Quality Firewall, elasticity, and hardcoded-Step Green enforcement.
- The Step Elasticity Runtime law is installed, cross-linked to existing StepCandidate, replacement, recovery, proof, Source Atlas, Step Quality Firewall, and Life Consequence Reflow anchors, and available for future shrink/extend/replace/split/merge/recovery/momentum/Vibe Signature Green enforcement.
- The Life Consequence Reflow law is installed, cross-linked to existing goal, schedule, plan, reflow, timeline, receipt, consequence, proof, capacity, protected-time, Today, Time, Goals, Step Elasticity, and Source Atlas anchors, and available for future reflow/schedule/Goal Treaty/severity/non-suppressible/receipt Green enforcement.
- The Trust UI Disclosure law and ADHD Cognitive Load UI law are installed, cross-linked to existing design truth, UI firewall, UI review checklist, no-card taxonomy, primitive registry, trust/accessibility primitives, Source Atlas, and Life Consequence Reflow anchors, and available for future trust-light/source/receipt/replay/drill-down/breadcrumb/glyph/cognitive-load/accessibility-boundary Green enforcement.
- The Local Data Cloud Boundary, Sharing And Progress Story, and High Risk Domain Safety laws are installed, cross-linked to existing local-first truth, release truth, privacy manifest source, CloudKit continuity models, privacy/safety models, Source Atlas store/pack models, share extension source, and Source Atlas Factory hardening plan, and available for future local/iCloud/R2/privacy/sharing/high-risk/jurisdiction Green enforcement.
- The Program Execution Contract is installed, cross-linked to existing Codex process truth, Goal Mode policy, run-state/proof/script/closeout standards, PLOS artifacts, and PLOS skill, and available for future existing-first/source-changing/Codex authority/non-waivable gate/Yellow continuation/closeout/token-optimization/no-architecture-theater Green enforcement.
- The PLOS Green/Yellow/Red reporting standard, validation registry, and proof artifact contract are installed, cross-linked to existing Codex OS proof/closeout standards, Program Execution Contract, PLOS artifacts, PLOS skill, and closeout template, and available for future status reporting, validation lane, unknown-command, artifact-path, screenshot/accessibility/performance/privacy/source/safety proof, and issue-to-phase rollup Green enforcement.
- Runtime laws are installed as governance and validation authority, not as feature implementation.
- PLOS Linear phase map and execution queue are present and validator-clean.
- PLOS closeout/reviewer/Red escalation templates are concrete.
- Source Atlas Factory hardening plan exists and is validator-clean.
- No app source, runtime feature, or release claim is introduced by governance work.

Current M00 status: Green for `AMB-608` governance scope after parent acceptance. `AMB-636`, `AMB-637`, `AMB-638`, `AMB-639`, `AMB-640`, `AMB-641`, `AMB-642`, `AMB-643`, `AMB-644`, and `AMB-645` are Done. M01 is complete in Linear for `AMB-609`; owner accepted AMB-608 / PLOS-M00 and AMB-609 / PLOS-M01 as complete and authorized continuous AMB-610 / PLOS-M02 through AMB-635 / PLOS-M26 execution on 2026-06-12, subject to strict phase gates and one-child-at-a-time execution.

## M01

Linear issue: `AMB-609`
Label: `PLOS-M01`
Purpose: Live runtime truth map.

Required before Green:

- Active app runtime paths are mapped from live source.
- Surface ownership is mapped from live source.
- Source Atlas Factory runtime map is produced from live source and tooling.
- Runtime model ownership map identifies active, stale, duplicate, fixture, test, and script artifacts.
- Existing Linear projects/issues/docs are linked into the master control plane using `AMB-*` identifiers.
- No source migration or feature implementation is claimed unless source and validation prove it.

Current M01 status: Green for live runtime truth-map scope under `AMB-609`; `AMB-609` is Done in Linear. Live-resolved children are `AMB-646` / `PLOS-010`, `AMB-647` / `PLOS-011`, `AMB-648` / `PLOS-012`, `AMB-649` / `PLOS-013`, `AMB-650` / `PLOS-014`, `AMB-651` / `PLOS-015`, and `AMB-652` / `PLOS-016`. All live-resolved M01 children are Done in Linear. M02+ execution is authorized by the active owner objective, but each phase still requires the relevant phase gate and one-child-at-a-time closeout.

## M02

Linear issue: `AMB-610`
Label: `PLOS-M02`
Purpose: Local data, CloudKit, R2 boundary, and data lifecycle foundation.

Current M02 status: Green for scoped documentation/control-plane foundation after all live-resolved children `AMB-653` through `AMB-660` completed in Linear and the parent acceptance report was prepared. Parent issue `AMB-610` is pending commit/push and Linear closeout. M03 may not start until AMB-610 is pushed, moved to Done in Linear, and the M03 phase gate passes.

Current M02 closeout: `AMB-610` is Done in Linear as of 2026-06-12. M03 execution is authorized by the active owner objective, subject to M03 phase gate and one-child-at-a-time closeout.

Required before Green:

- Local data ownership, migration, deletion, export, CloudKit, and continuity boundaries are explicit.
- R2 is limited to public reference/source distribution. Private user data in R2 is Red.
- Privacy declarations are mapped to live source behavior.
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md` is read and preserved before local data, CloudKit/iCloud, R2, export, deletion, privacy, data lifecycle, or source-pack distribution Green.
- No custom backend or required cloud planning runtime is introduced.

## M03

Linear issue: `AMB-611`
Label: `PLOS-M03`
Purpose: Security and supply-chain foundation.

Current M03 status: Done in Linear. Green for scoped documentation/control-plane foundation after all canonical children `AMB-661` through `AMB-667` completed in Linear and parent acceptance was pushed at `539528484379f298dc1bd16ba555724235ad92e6`. Live Linear verification on 2026-06-12 America/New_York confirmed `AMB-727`, `AMB-728`, and `AMB-729` are Duplicate of canonical Done children, and `AMB-972` is Canceled/non-authoritative and not active PLOS scope.

Current M03 closeout boundary: no app source changes, no runtime feature implementation, no cryptography/key/R2/Cloudflare/dependency/scanner/SDK implementation, no live R2 writes, no security certification, and no release/privacy/legal/performance/accessibility/device proof.

Required before Green:

- Runtime dependency, signing, script, MCP, and supply-chain risks are classified.
- New dependencies, hosted CI, write-capable MCP, secret-reading tooling, signing automation, or production-affecting services require explicit separate approval.
- Security reviewer prompt has no unresolved Red.

Current M03 closeout: `AMB-611` is Done in Linear as of 2026-06-12 America/New_York. M04 execution is authorized by the active owner objective, subject to M04 phase gate and one-child-at-a-time closeout.

## M04

Linear issue: `AMB-612`
Label: `PLOS-M04`
Purpose: R2 Source Atlas distribution mesh.

Current M04 status: Done in Linear after parent acceptance closeout on 2026-06-12 America/New_York. Canonical children `AMB-668` / `PLOS-040` through `AMB-675` / `PLOS-047` are Done. Duplicate children `AMB-730` through `AMB-737` are marked Duplicate in Linear and point to canonical Done children; they were not executed and do not block parent acceptance. `AMB-971` is Canceled/non-authoritative and must not be executed or used as active PLOS scope. M05 is eligible after AMB-612 was pushed, closed in Linear, and the M05 phase gate passed.

Required before Green:

- R2 object contract is public-reference-only and excludes private user data.
- Source pack distribution has hash/signature, freshness, revocation, rollback, and receipt rules.
- Runtime eligibility is blocked until M05/M06 source authority gates are satisfied.
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md` is read and preserved before R2 distribution, source-pack publication, freshness, revocation, release receipt, or R2 fallback Green.
- Source Atlas validator is Green.
- Live R2 writes require an active AMB issue that explicitly owns the write scope and records account/bucket/action/result with no secrets and no private user data.

## M05

Linear issue: `AMB-613`
Label: `PLOS-M05`
Purpose: Source Atlas Pack / Seed Foundry.

Current M05 status: In progress under parent `AMB-613`. Live Linear verification on 2026-06-13 America/New_York found canonical design/control-plane children `AMB-676` / `PLOS-050` through `AMB-685` / `PLOS-059`; `AMB-676` through `AMB-683` are Done in Linear and `AMB-684` / `PLOS-058` is in progress for release receipt requirements. `AMB-973` / `PLOS-M05-R2` is the canonical live Cloudflare R2 staging activation owner and is Backlog. Duplicate children `AMB-738` through `AMB-747` are marked Duplicate of canonical M05 children, are not active scope, and must not be executed. AMB-613 / PLOS-M05 cannot close Green unless AMB-973 is Done, or explicitly Yellow/blocked with no-claim boundaries that prevent M06/M10 runtime eligibility/runtime consumption claims.

Required before Green:

- Pack and seed schema, source binding, freshness, review, jurisdiction, release receipt, and rollback are explicit.
- Existing Source Atlas tooling is reused or extended instead of duplicated.
- Any pack eligible for runtime use has release proof and revocation path.

## M06

Linear issue: `AMB-614`
Label: `PLOS-M06`
Purpose: Source Authority Mesh.

Required before Green:

- Source authority, source trust level, provenance, freshness, conflict handling, and deprecation are mapped.
- Runtime can distinguish public reference material from user-private context.
- Missing or stale source authority produces inspectable degradation, not hidden mutation.

## M07

Linear issue: `AMB-615`
Label: `PLOS-M07`
Purpose: Any Goal Solution Loop.

Required before Green:

- Goal solution behavior is bounded by local-first, inspectable, source-aware laws.
- Generated steps are specific, capacity-aware, and receipt-backed.
- No generic task-list, chatbot, dashboard, or shame/streak framing is introduced.

## M08

Linear issue: `AMB-616`
Label: `PLOS-M08`
Purpose: Native Context Mesh and permission explainers.

Required before Green:

- Calendar, reminders, files/photos/OCR, location, Health/Fitness, CloudKit, and permission state adapters are classified.
- Permission explainers are value-first, revocable, and local-first.
- No background ingestion or silent private-data expansion is introduced.

## M09

Linear issue: `AMB-627`
Label: `PLOS-M09`
Purpose: Step Quality Firewall.

Required before Green:

- Generic, unsafe, source-weak, context-mismatched, inaccessible, or uninspectable steps are blocked or degraded.
- Canonical user-facing language uses `Recommended step`, `Start now`, `Open step`, and `Step`.
- Accessibility and VoiceOver validation expectations are explicit.

## M10

Linear issue: `AMB-617`
Label: `PLOS-M10`
Purpose: Golden vertical slice.

Required before Green:

- One vertical slice proves the local-first Private Life Runtime moat end to end.
- Proof covers source, recommendation, schedule/capacity context, receipt, execution, closure/recovery, replay, and no hidden mutation.
- Broad runtime expansion remains blocked until this gate is Green or accepted Yellow with owner and no-claim boundary.

## M11

Linear issue: `AMB-618`
Label: `PLOS-M11`
Purpose: Onboarding and first-run activation.

Required before Green:

- First-run activation teaches Ambitions as Personal Life OS without generic app category collapse.
- Permission asks are contextual, optional where possible, revocable, and privacy-honest.
- No cloud AI theater or chatbot-first framing is introduced.

## M12

Linear issue: `AMB-619`
Label: `PLOS-M12`
Purpose: Multi-Path Lattice.

Required before Green:

- Runtime can represent multiple viable paths with inspectable tradeoffs.
- Path changes preserve proof, source authority, user constraints, and rollback.
- No hidden reranking or opaque score pressure is introduced.

## M13

Linear issue: `AMB-620`
Label: `PLOS-M13`
Purpose: Step Graph Compiler.

Required before Green:

- Step graph generation is deterministic, source-aware, receipt-backed, and locally inspectable.
- Compiler output can be tested for source, context, safety, and accessibility gates.
- Generic task-language fallback is Red unless explicitly degraded and explained.

## M14

Linear issue: `AMB-621`
Label: `PLOS-M14`
Purpose: Step Elasticity Engine.

Required before Green:

- Steps can shrink, extend, replace, defer, or split according to time and capacity reality.
- Elasticity is receipt-backed and avoids shame, score pressure, and silent mutation.
- Recovery paths remain inspectable.
- `docs/codex/STEP_ELASTICITY_RUNTIME_LAW.md` is read and preserved before Step Elasticity Engine Green.

## M15

Linear issue: `AMB-622`
Label: `PLOS-M15`
Purpose: Schedule Install Kernel.

Required before Green:

- Schedule installs are previewable, reversible, receipt-backed, and conflict-aware.
- Calendar-like behavior remains Ambitions-native and capacity-aware, not a calendar clone.
- Commit/cancel/rollback behavior is proven before Green.

## M16

Linear issue: `AMB-623`
Label: `PLOS-M16`
Purpose: Life Consequence / Cross-Goal Reflow Engine.

Required before Green:

- Cross-goal impacts are explicit, inspectable, and recovery-aware.
- Reflow preserves user constraints and proof.
- `docs/codex/LIFE_CONSEQUENCE_REFLOW_LAW.md` is read and preserved before Life Consequence / Cross-Goal Reflow Engine Green.
- No hidden productivity scoring or guilt mechanics are introduced.

## M17

Linear issue: `AMB-624`
Label: `PLOS-M17`
Purpose: Trust-light UI and deep drill-down.

Required before Green:

- UI surfaces reveal runtime reasoning without dashboard/admin/debug anatomy.
- Drill-down explains source, context, constraints, receipt, and fallback.
- `docs/codex/TRUST_UI_DISCLOSURE_LAW.md` and `docs/codex/ADHD_COGNITIVE_LOAD_UI_LAW.md` are read and preserved before Trust-light UI, deep drill-down, source/receipt/replay disclosure, breadcrumb, low cognitive-load, or accessibility-boundary Green.
- Visual/accessibility proof is required for UI claims.

## M18

Linear issue: `AMB-625`
Label: `PLOS-M18`
Purpose: High-risk safety, legality, and jurisdiction.

Required before Green:

- High-risk domains, legal/medical/financial safety boundaries, and jurisdiction handling are explicit.
- Unsafe or unsupported advice degrades safely and inspectably.
- `docs/codex/HIGH_RISK_DOMAIN_SAFETY_LAW.md` is read and preserved before high-risk safety, legality, jurisdiction, professional-boundary, crisis/safety, regulated goods, cannabis, minors/student data, or high-risk source/share Green.
- No high-risk autopilot or unreviewed external source behavior is introduced.

## M19

Linear issue: `AMB-628`
Label: `PLOS-M19`
Purpose: Performance Runtime hardening.

Required before Green:

- Performance budgets, replay cost, source-pack cost, storage cost, and UI responsiveness are measured where claimed.
- No performance claim is made without current evidence.
- Local-first behavior remains viable under realistic device constraints.

## M20

Linear issue: `AMB-629`
Label: `PLOS-M20`
Purpose: Sharing and Progress Story System.

Required before Green:

- Sharing is opt-in, redacted, privacy-honest, and reversible.
- Progress story framing avoids social pressure, shame, and fake productivity scoring.
- `docs/codex/SHARING_AND_PROGRESS_STORY_LAW.md` and `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md` are read and preserved before sharing, progress story, export, share extension, proof projection, redaction, or hosted/share transport Green.
- Visual proof is required for share surfaces.

## M21

Linear issue: `AMB-630`
Label: `PLOS-M21`
Purpose: Year in Ambitions.

Required before Green:

- Recap behavior is calm, source-backed, locally derived, and user-owned.
- The year-end narrative avoids shame, scores, hidden inference, and social feed drift.
- Export/delete/privacy behavior remains clear.

## M22

Linear issue: `AMB-631`
Label: `PLOS-M22`
Purpose: Local compounding and paid local recommendations.

Required before Green:

- Paid/local recommendation behavior is local-first, inspectable, and non-deceptive.
- No cloud AI dependency, tracking, dark pattern, or external monetization SDK is introduced without separate approval.
- User value and privacy proof are explicit.

## M23

Linear issue: `AMB-632`
Label: `PLOS-M23`
Purpose: CloudKit/iCloud sync hardening.

Required before Green:

- Sync, conflict, migration, offline, and replay behavior are tested or explicitly Yellow.
- iCloud continuity remains Apple-native before custom server infrastructure.
- Privacy manifest and data lifecycle claims match source.

## M24

Linear issue: `AMB-633`
Label: `PLOS-M24`
Purpose: Observability, support, diagnostics, and data export.

Required before Green:

- Diagnostics are local-first, user-owned, and free of tracking/analytics drift.
- Export/delete/support receipts are explicit.
- No telemetry SDK, crash SDK, or hosted support dependency is added without policy gates.

## M25

Linear issue: `AMB-634`
Label: `PLOS-M25`
Purpose: App Review / compliance readiness.

Required before Green:

- App Review, privacy label, permission copy, high-risk safety, and data lifecycle evidence are current.
- No App Store/TestFlight/readiness claim is made without matching release proof.
- Human/device/legal follow-up is explicitly separated from local validation.

## M26

Linear issue: `AMB-635`
Label: `PLOS-M26`
Purpose: Full certification gauntlets.

Required before Green:

- Full certification gauntlets cover runtime, source authority, privacy, safety, accessibility, performance, onboarding, sharing, sync, and golden slice proof.
- All remaining Yellow items have owner, scope, no-claim boundary, and next action.
- Final Green cannot be claimed without current evidence for every required proof domain.

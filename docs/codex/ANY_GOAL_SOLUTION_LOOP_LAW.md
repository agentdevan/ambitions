# Any Goal Solution Loop Law

Status: Active PLOS M00 governance law
Issue: AMB-638 / PLOS-002
Parent: AMB-608 / PLOS-M00
Authority posture: Supporting PLOS law subordinate to `docs/truth/*`
Runtime implementation proof: none

This law defines how "any goal" enters Ambitions without false certainty. It operationalizes existing product truth, the Personal Life OS runtime law, and current Source Atlas / GoalIntent model boundaries. It does not implement a classifier, create R2 objects, add source packs, or prove source-backed pathing.

## Core Promise

Any goal can enter Ambitions.

Every goal receives the correct operating mode.

If full pathing is unavailable, Ambitions creates a solution loop.

The promise is intake and safe routing, not instant full authority. Ambitions must preserve the user's private goal locally, classify the operating mode honestly, and avoid fake source-backed paths when coverage, source freshness, jurisdiction, safety, or clarification is missing.

## Existing Model Anchors

AMB-638 inspected current source before installing this law. Existing seams include:

- `Native/Ambitions/Domain/SourceAtlasIntentMatchModels.swift`
  - `SourceAtlasIntentMatcher`
  - `SourceAtlasIntentMatch`
  - `SourceAtlasPackSelection`
  - `source-needed`, `unsupported`, `runtime-blocked`, `high-risk`, and `review-required` rejection reasons
  - `canDriveRuntime`
  - `requiredUserReview`
  - fallback `normalizedGoalIntent: "goal-scaffold"`
- `Native/Ambitions/Domain/GoalEngine/GoalIntentCompilerModels.swift`
  - `GoalIntent`
  - `GoalPrivacyClass.localOnly`
  - `GoalSourceState.rawInput`, `draft`, `path`, `plan`, and `blocked`
  - clarification, blocked reason, capacity envelope, compiled Step, and receipt models
- `Native/Ambitions/Runtime/SourceAtlasRuntimeBridgeReplay.swift`
  - unsupported-goal fallback receipt behavior
  - replay summaries and local-only receipt fields
- `Native/Ambitions/Domain/SourceAtlasCoverageRuntimeFixtureModels.swift`
  - coverage fixture privacy/local-only validation boundaries
- `Native/AmbitionsTests/Runtime/SourceAtlasRuntimeBridgeCoverageGauntletTests.swift`
  - coverage permutations, unsupported scenario coverage, runtime-blocked selection checks, raw-goal redaction checks

These seams are not implementation approval for AMB-638. They are the existing-first source anchors later runtime work must inspect before changing behavior.

## Operating Modes

Every goal intake must resolve to one of these modes before it claims source-backed pathing:

| Mode | Meaning | Allowed behavior | Green blocker |
|---|---|---|---|
| Fully source-backed path | Current, reviewed, applicable Source Atlas coverage can drive runtime. | Compile path options and Steps with source, reason, receipt, and replay proof. | Missing source/freshness/review proof. |
| Partial source-backed path | Some current source coverage exists but gaps remain. | Use covered parts, mark missing pieces, ask clarification or create coverage demand. | Pretending the partial path is complete. |
| Starter-only path | A safe local starter Step is possible without full source authority. | Offer a low-risk first Step with explicit non-source-backed boundary. | Calling it source-backed. |
| Clarification-needed path | User intent is too ambiguous to route safely. | Ask for the smallest needed clarification or hold as local draft. | Guessing intent as authoritative. |
| Source-needed path | The goal family is understood but source/pathing data is absent, stale, contradicted, revoked, or unknown. | Preserve local draft, explain source need, create local coverage gap. | Generating fake authoritative Steps. |
| Coverage-demand path | The system lacks reusable seed coverage for this goal family/capability/proof/replacement path. | Record an abstract local coverage gap and optionally request anonymous coverage with explicit consent. | Uploading raw private goal text by default. |
| Jurisdiction-needed path | Legal, medical, financial, school, travel, age, location, or rule context controls safe pathing. | Ask for jurisdiction/source context or route to guarded/high-risk mode. | Treating jurisdiction as normal unsupported coverage. |
| High-risk guarded path | The goal may involve safety, legality, health, financial, or irreversible consequences. | Guard, narrow, warn, require review, or refuse unsafe pathing as appropriate. | Routing high-risk content as ordinary local-only draft. |
| Local-only draft path | The user can keep the goal locally without runtime pathing. | Store local draft, clarify later, preserve privacy and receipts. | Implying source-backed execution exists. |
| Unsupported-but-captured path | Ambitions cannot safely or currently path the goal, but can preserve it locally. | Capture, label unsupported coverage honestly, keep recovery route open. | Dead-ending with "Ambitions cannot help." |
| Unsafe-blocked path | The goal or requested path is unsafe, disallowed, or cannot be supported. | Block the unsafe path, preserve only safe local context when appropriate, and avoid procedural help. | Downgrading unsafe to unsupported-but-captured. |

## Coverage Demand Queue Law

Coverage demand exists to improve reusable source and seed coverage without leaking private life data.

Rules:

- Raw private goal text remains local.
- Abstract coverage gaps may be recorded locally.
- Optional anonymous coverage requests require explicit user consent.
- A coverage request asks for reusable seed gaps, not exact hardcoded Steps for a private user.
- Future public-reference coverage, including R2-hosted reference packs when authorized by later phases, may unlock "Fresh pathing is now available."
- R2 or public Source Atlas objects must never contain private goals, captures, calendar data, behavior, receipts, proof, profile, inferred priorities, or personal context.
- Coverage demand must leave a receipt when it changes user-visible behavior or future recommendation eligibility.

Coverage demand is not a promise that a future pack will exist. It is a safe loop: preserve the user's goal locally, record the missing reusable seed class, and return when source/pathing coverage becomes available.

## Seed Gap Types

Coverage demand must classify gaps as reusable seed needs:

- goal family seed gap
- capability seed gap
- starter seed gap
- elasticity seed gap
- jurisdiction seed gap
- proof seed gap
- replacement seed gap

Seed gaps must be abstract enough to be reusable and privacy-safe. They must not encode a user's raw private goal, exact schedule, private context, protected trait, or personal proof trail.

## User-Facing Behavior

Never say:

- "Ambitions cannot help."
- "This goal is fully source-backed" when coverage is partial, stale, unavailable, high-risk, or blocked.
- "Here is the exact plan" when the path is source-needed or coverage-demand.

Allowed law examples:

- "This needs source/pathing coverage before Ambitions treats it as source-backed."
- "Ambitions can keep this goal locally and help you choose a safe starter step while coverage is missing."
- "This needs jurisdiction or safety review before Ambitions can suggest a path."
- "Fresh pathing is now available" only when a later validated source/freshness gate proves it.

These examples are law examples, not shipped copy.

## Unsafe And High-Risk Routing

Unsafe and high-risk goals are not ordinary unsupported goals.

If a goal requires legal, medical, financial, safety, age, school, travel, jurisdiction, or irreversible-consequence review, the system must route to jurisdiction-needed, high-risk guarded, or unsafe-blocked mode. It must not:

- create a local-only draft that looks actionable
- generate procedural steps for unsafe action
- imply source-backed authority without reviewed source
- request external coverage using raw private text
- let a coverage-demand path bypass safety

## Source Atlas And Seed Planning Cross-Link

This law depends on Source Atlas authority and seed-based planning, but AMB-638 does not install that next law. Until AMB-639 installs the Source Atlas Authority and Seed-Based Planning law, use these existing anchors:

- `artifacts/source-atlas-factory/SAF_HARDENING_PLAN.md`
- `artifacts/source-atlas-factory/SAF-run-state.md`
- `artifacts/source-atlas-factory/SAF_GOAL.md`
- `Native/Ambitions/Domain/SourceAtlasIntentMatchModels.swift`
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/GoalEngine/GoalIntentCompilerModels.swift`
- `Native/Ambitions/Runtime/SourceAtlasRuntimeBridgeReplay.swift`
- `Native/AmbitionsTests/Runtime/SourceAtlasRuntimeBridgeCoverageGauntletTests.swift`

Forward cross-link:

- AMB-639 / PLOS-003 must install the Source Atlas Authority and Seed-Based Planning law and link back to this file.

## Green Enforcement

Any goal intake, classifier, Source Atlas matching, unsupported-goal, source-needed, or coverage-demand issue must reference this law before claiming Green.

Green requires:

- a live `AMB-*` issue identifier
- an explicit operating mode
- local privacy boundary proof
- source/freshness/review/risk status when source-backed behavior is claimed
- coverage-demand behavior when coverage is missing
- no raw private goal text in coverage requests by default
- reusable seed-gap framing, not hardcoded private Steps
- unsafe/high-risk routing separated from ordinary unsupported goals
- no runtime implementation claim without source and validation proof

Yellow is allowed when a scoped law/report is correct but future Source Atlas authority, pack proof, or implementation proof remains owned. Red is required for false source-backed claims, dead-end unsupported goals, raw private goal leakage, hardcoded coverage Steps, unsafe local-only routing, phase-order violation, or Linear access by PLOS labels.

## Non-Claims

This file does not prove:

- any classifier implementation
- source pack creation
- R2 object creation
- coverage request transport
- source-backed path availability
- app runtime behavior
- app source migration
- release readiness
- privacy/legal approval
- accessibility, device, build, or performance validation
- owner approval

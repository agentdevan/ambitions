# Step Elasticity Runtime Law

Status: Active PLOS M00 governance law
Issue: AMB-640 / PLOS-004
Parent: AMB-608 / PLOS-M00
Authority posture: Supporting PLOS law subordinate to `docs/truth/*`
Runtime implementation proof: none

This law defines Step Elasticity as a non-optional runtime requirement for PLOS execution. It does not implement Elastic Step models, add UI controls, change generated Steps, alter Today, or claim Step Elasticity Engine behavior.

## Core Law

A Step is not a fixed task.

A Step is the current best expression of a goal path under the user's present time, energy, resources, source state, deadline, proof, and other active goals.

Step Elasticity is a runtime law, not a UI convenience. Ambitions must adapt Steps around real life without making the user fail a rigid app-authored task. Any shrink, extend, replace, split, merge, defer, proof-only, recovery-safe, or momentum-tail change must preserve inspectability, receipts, source authority, proof value, and cross-goal consequences.

## Existing Model Anchors

AMB-640 inspected current source before installing this law. Existing seams include:

- `Native/Ambitions/Domain/GoalEngine/StepCandidateFieldModels.swift`
  - `StepCandidateKind` already includes `lighter`, `shorter`, `lowerEnergy`, `locationCompatible`, `noEquipment`, `recoverySafe`, `proofGathering`, `substitution`, `parallelPath`, and `fallback`.
  - `CandidateRiskLevel`, `CandidateValidity`, rejection reasons, source traces, deadline contribution, proof references, access requirements, and future-pressure fields provide existing inspection anchors.
- `Native/Ambitions/Runtime/StepCandidateFieldGenerator.swift`
  - candidate variants are generated, deduplicated, ranked, rejected, and traced with source provenance, factors, replay references, Source Atlas expansion traces, deadline contribution, and future pressure.
- `Native/Ambitions/Domain/GoalEngine/GoalEngineStepRewriter.swift`
  - vague Step copy is rewritten toward concrete session/action/evidence/fallback micro-step structure.
- `Native/Ambitions/Runtime/StepReallocationRuntimeBridge.swift`
  - approved step reallocation decisions and events already bridge into replayable runtime decision traces.
- `Native/Ambitions/Domain/Reschedule/RescheduleEngine.swift`
  - delay, skip, stuck, and ask-for-smaller-step triggers already carry smaller-step, recovery posture, waiting-state, rationale, confidence, and defer concepts.
- `Native/Ambitions/Features/Today/TodayStepReplacementSheet.swift`
  - replacement UI seams exist and must not become the only elasticity mode.
- `Native/AmbitionsTests/**/StepCandidate*.swift`, `Native/AmbitionsTests/**/StepReallocation*.swift`, and related tests
  - existing test coverage names provide future ownership hints, but AMB-640 does not change or validate runtime behavior.

These anchors are existing-first context only. They do not prove Elastic Step implementation.

## Required Step Forms

Every future runtime implementation that claims Step Elasticity Green must be able to reason about these forms:

| Form | Runtime meaning | Green blocker |
|---|---|---|
| minimum viable version | The smallest useful expression that preserves safety, proof, and source constraints. | Shrinking into meaningless busywork. |
| standard version | The default balanced expression for current time, energy, source state, and goal path. | Treating standard as the only true Step. |
| extended version | More work when the user has extra capacity and the added work is still goal-aligned. | Expanding without checking other active goals. |
| deep-work version | Focused, higher-load expression that requires an appropriate protected context. | Offering deep work in fragmented or low-energy conditions. |
| low-energy version | A lower-energy expression that protects continuity without shame. | Silently erasing required proof or deadline value. |
| no-resource version | A version that works without unavailable equipment, access, money, transport, or tools. | Pretending unavailable resources are optional when they are required. |
| location-compatible version | A version that fits the user's current or selected environment. | Using private location context without correct local/privacy handling. |
| proof-only version | A proof, receipt, or evidence action when execution cannot safely progress. | Treating proof-only as full execution completion. |
| recovery-safe version | A gentle route after delay, interruption, stuck state, or changed reality. | Shame framing or hidden penalty. |
| deadline-protecting version | A version that preserves a deadline, checkpoint, or expiring source condition. | Reducing deadline value without a receipt. |
| momentum-tail version | Optional follow-through after completion or extra capacity. | Turning momentum into streak, score, guilt, or goal cannibalization. |
| split version | A Step decomposed across time, proof, or dependency boundaries. | Splitting without preserving traceability and receipts. |
| merge version | Compatible Steps combined when it lowers overhead without losing meaning. | Merging unrelated goals or hiding consequence. |
| replacement set | A set of alternatives when the current Step no longer fits. | Treating replacement as the only adaptation mode. |

## Top-Level Controls

Top-level Step controls must stay simple at rest:

- Start now
- Shrink
- Keep momentum
- Replace
- Open step

These controls are product semantics, not a claim that UI exists. Future UI work must still prove native iPhone quality, accessibility, source/receipt clarity, and no task-app/category collapse.

## Advanced Drill-Down Controls

Advanced controls may be available only when the user asks for more control or when a consequence requires inspection:

- Make shorter
- Make easier
- Use no equipment
- Do proof instead
- Split this
- Extend this
- Pull next Step forward
- Protect tomorrow
- Show all alternatives

Advanced controls must not overwhelm the default surface. They exist to preserve agency and inspectability without forcing the user into a planning console.

## Vibe Signature

Vibe Signature is runtime-relevant. It is not decorative copy, visual flavor, or a mood badge.

Future Step ranking, filtering, replacement, shrink, extension, schedule install, and recovery behavior must treat Vibe Signature as an input when it changes fit:

| Dimension | Values | Runtime use |
|---|---|---|
| mode | creative, admin, physical, recovery, proof, learning, review | Match the Step's work type to current context and available path. |
| energy | low, medium, high | Avoid assigning high-energy work to low-energy states and preserve recovery. |
| load | fragmented, focused, deep | Match Step scale to attention shape and protected time. |
| environment | home, desk, gym, studio, outside, phone | Filter or transform resource, location, and access requirements. |
| tone | calm, decisive, exploratory, restorative | Shape the default posture without shame, urgency theater, or AI wrapper copy. |

Vibe Signature may not override safety, source authority, deadline physics, proof requirements, or Life Consequence Reflow. It can influence ranking only inside the allowed envelope.

## Mutation Requirements

Every shrink, extend, replace, split, merge, defer, proof-only conversion, recovery-safe conversion, or momentum-tail action must calculate and receipt these impacts before it can claim Green:

- deadline impact
- density impact
- proof impact
- downstream dependency impact
- recovery impact
- affected active goals
- schedule changes
- source-validity impact

The calculation may be simple in an early implementation, but it must be explicit. Silent mutation is Red.

## User Agency

Ambitions recommends the least destructive default.

The user can inspect and choose alternatives.

Ambitions must not force one rigid app-authored version of the user's life.

User choice does not waive safety, source authority, privacy, proof, or consequence requirements. If a chosen alternative weakens a deadline, proof value, source validity, recovery posture, or another active goal, Ambitions must show the consequence and preserve a receipt.

## Integration Points

Step Elasticity binds these PLOS laws and future phases:

- Personal Life OS Runtime Law: Elastic Steps are required because Ambitions makes execution fit the user's life, not the reverse.
- Any Goal Solution Loop: source-needed, coverage-demand, starter-only, high-risk, and unsupported modes can only offer elastic behavior inside their authority envelope.
- Source Atlas Authority: shrink, replace, proof-only, deadline-protecting, and location-compatible behavior must respect freshness, revocation, contradiction, jurisdiction, review, and eligibility states.
- Seed-Based Planning: elasticity seeds define reusable shrink, extend, defer, split, merge, replacement, resource-light, location-compatible, deadline-protecting, recovery, and momentum-tail behavior.
- Step Quality Firewall: generic, unsafe, source-weak, proof-erasing, inaccessible, or uninspectable elastic variants must be rejected or degraded before they reach the user.
- Life Consequence Reflow: every Step mutation that changes time, density, proof, deadline, dependencies, recovery, source validity, or other active goals must trigger reflow/simulation impact before Green.
- Schedule Install Kernel: elastic Step changes that affect schedule must be previewable, reversible, and receipt-backed.
- Trust-light UI: top-level controls must stay simple at rest while preserving drill-down for consequence inspection.

Forward law cross-links:

- AMB-641 / PLOS-005 installs the Life Consequence Reflow law and links back to this file.
- AMB-627 / PLOS-M09 must install or prove the Step Quality Firewall contract and link back to this file before Step Quality Firewall Green.
- AMB-621 / PLOS-M14 must use this law as the governance gate for any Step Elasticity Engine implementation.

Until those later laws and runtime phases are installed, this file is governance authority only and does not prove implementation.

## Green Enforcement

Any future PLOS issue that claims Step elasticity, replacement, shrink, extension, split, merge, recovery-safe behavior, momentum-tail behavior, Vibe Signature ranking, Step reallocation, Step rescheduling, or elastic Step UI must reference this law before Green.

Green requires:

- a live `AMB-*` issue identifier
- existing-first inspection of Step, StepCandidate, replacement, recovery, proof, source, and schedule ownership
- explicit Step form coverage or a named not-in-scope boundary
- clear top-level versus advanced control exposure when UI is in scope
- Vibe Signature treated as runtime-relevant, not decorative
- mutation impact calculations for deadline, density, proof, downstream dependencies, recovery, affected goals, schedule, and source validity
- Step Quality Firewall relationship
- Life Consequence Reflow relationship
- no runtime implementation claim without source and validation proof

Yellow is allowed when this law/report is correct but future runtime models, UI, Step Quality Firewall proof, or Life Consequence Reflow proof remains owned. Red is required for UI-convenience framing, replacement-only adaptation, silent proof/deadline degradation, hidden goal cannibalization, decorative Vibe Signature, PLOS label Linear access, or phase-order violation.

## Cross-Links

Primary authority:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `AGENTS.md`

PLOS law authority:

- `docs/codex/PERSONAL_LIFE_OS_RUNTIME_LAW.md`
- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`
- `docs/codex/SEED_BASED_PLANNING_LAW.md`
- `artifacts/plos-runtime/PLOS_PHASE_GATES.md`
- `artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.md`

Forward PLOS law/phase authority:

- AMB-641 / PLOS-005 Life Consequence Reflow law
- AMB-627 / PLOS-M09 Step Quality Firewall
- AMB-621 / PLOS-M14 Step Elasticity Engine

Proof for this law installation:

- `artifacts/personal-life-os/reports/PLOS-004-step-elasticity-law-report.md`

## Non-Claims

This file does not prove:

- Elastic Step model implementation
- Step Elasticity Engine implementation
- Vibe Signature runtime implementation
- Step Quality Firewall implementation
- Life Consequence Reflow implementation
- Step UI control implementation
- app source behavior
- source migration completion
- release readiness
- TestFlight or App Store readiness
- accessibility verification
- privacy or legal approval
- performance validation
- device validation
- owner approval

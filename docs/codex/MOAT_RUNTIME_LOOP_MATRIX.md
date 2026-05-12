# Moat Runtime Loop Matrix

Status: active control-plane overlay  
Batch: MRI00-MOAT-RUNTIME-GAP-LOCK

## Purpose

This matrix maps Ambitions' end-game product loops to current and future implementation work. It prevents component-only batch completion from being mistaken for product-loop completion.

## Loop Matrix

| Loop | End-Game User Outcome | Existing Coverage | MRI Coverage | Acceptance Proof |
|---|---|---|---|---|
| Capture-to-meaning | A raw capture becomes the correct durable object: proof, source, constraint, commitment, reflection, held item, goal seed, or ready-to-place action. | PK capture services, SA import/review plans, Capture visual canon | MRI14, MRI28, MRI37 | Capture examples route correctly, can be corrected, and create receipts. |
| Source-to-recommendation | A source/claim/freshness state can explain or constrain a recommendation. | SA07-SA32, PK33 recommendation evidence, PK34 quarantine | MRI09, MRI10, MRI11, MRI39 | Why This? shows source, claim state, freshness, reason, uncertainty, controls. |
| Start Here execution | Today recommends a step that fits actual reality and closes with proof or recovery. | PK Today service extraction, recommendation evidence, visual Today lane | MRI17-MRI24, MRI26, MRI36 | Start Here can explain fit, start step, close action, record receipt, reflow if needed. |
| Goal-to-life-direction | Goals belong to Ambition Graph hierarchy, not only standalone task containers. | Goals source, LDI/AOS plans, moat truth | MRI01-MRI08, MRI27 | Identity Direction -> Ambition -> Commitment -> Step -> Proof is visible and navigable. |
| Reality Fit / LifeShape | Time shows realistic capacity/pressure and affects recommended work. | PK cache/performance, Time visual canon, AOS planning | MRI17-MRI24, MRI29 | Protected/open time and pressure visibly affect Start Here and reflow. |
| Recovery and re-entry | Ambitions restarts from the last honest point without shame. | Closure states, recovery copy, moat truth | MRI03-MRI06, MRI20, MRI38 | Broken day creates Still Counts/Needs Recovery path with proof preservation. |
| Personal Runtime trust/control | User can inspect, reset, disable, delete, or correct local learning inputs. | PK data controls/privacy, You/Profile controls | MRI12, MRI13, MRI15, MRI30, MRI43 | You shows what Ambitions learned/used and supports reset/delete receipts. |
| Native Apple surfaces with receipts | Widgets/App Intents/Share/Notifications preserve command, policy, receipt, and trust boundaries. | PK side-effect ledgers, PFC plans | MRI31, MRI47 | External action creates guarded command/receipt and does not bypass local policy. |
| Visual runtime acceptance | Top-level surfaces feel like Ambitions, not generic productivity UI. | Visual canon/moat control-plane docs | MRI25-MRI34, MRI40, MRI45 | Screens pass anti-generic, object-first, native iPhone, accessibility-aware review. |
| Final proof/release gates | Readiness claims are made only after current proof. | RELEASE_TRUTH.md, PFC/RHC plans | MRI41-MRI44, MRI46-MRI50 | Build/test/device/accessibility/performance/privacy/release proof packets exist. |

## Gap Rules

If a batch contributes to a loop but does not close it, its report must state:

- the loop it supports,
- what artifact it adds,
- what loop behavior remains open,
- which later MRI/SA/AOS/FCP/PFC batch closes the behavior.

## Loop Completion Rule

A loop is complete only when the user-facing behavior, local runtime data flow, trust/receipt path, accessibility path, and validation proof all exist.
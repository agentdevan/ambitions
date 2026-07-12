+++
schema_version = 1
conflict_id = "CONFLICT-CALENDAR-REPLACEMENT-BAR"
status = "unresolved"
severity = "P0_BLOCKER"
priority = "P0"
concepts = ["linear.decision.save-types", "product.replacement-level-planning-product", "product.time-018-calendar-grade-acceptance"]
scopes = ["active product and engineering authority migration", "linear v3 decision 31; owner-evidence-backed migration topology"]
recommendation = "compose"
recommendation_rationale = "Keep first-class personal calendar replacement as target law and bind any readiness claim to the complete acceptance bar and current evidence."
stronger_composition = "Separate product target, launch obligation, external-organizer limitations, implementation state, and release proof into linked requirements."
proposed_canonical_law = "Time MUST target first-class replacement of ordinary personal calendar planning, but Ambitions MUST NOT claim replacement or deprecate external fallback until every calendar-grade behavior, accessibility, privacy, migration, performance, and proof obligation is current and satisfied."
artifacts_to_supersede = ["LINEAR-CANON-V3:decision:31", "REPO-43E0D80464B2869224C805D8:line:1432", "REPO-AA88FA58EEA6FBA9BAB10270:line:161"]
target_requirement_status = "planned_uncreated"
target_requirement_id = ""
owner_decision = ""
allowed_resolutions = ["keep_a", "keep_b", "compose", "reject_both"]
affected_task_scopes = ["surface.time", "system.scheduling-capacity"]
nonclaims = "No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made."
claim_ceiling = "Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization."

[[claims]]
claim_id = "CLAIM-LFT-0031"
source_id = "LINEAR-CANON-V3"
source_location = "decision:31"
concept = "linear.decision.save-types"
scope = "linear v3 decision 31; owner-evidence-backed migration topology"
modality = "MUST"
normalized_value = "time must replace ordinary daily apple calendar use at first-class quality. it uses familiar day / week / month / year / list calendar behavior, enriched by protected time, fixed commitments, flexible work, suggested placement, capacity, recovery, goal movement, proof, transition, reflow, and conflict semantics. all time is not treated equally."
evidence_sha256 = "4ec6446caf5f71eb4be01208806138b5399ca883e28bfe97d8a4f93d1ea8e4da"
owner_approval = "linear-comment:630b2575-4cb0-4d70-9ea5-39799d470946:decision:31"
owner_evidence_text_sha256 = "5d2dd57e45b00339d8d0b4f83f572e78bfea82894e8d77ca653589768988d539"
owner_evidence_rationale_sha256 = "7d8af6073b9bbe342077a7a2426700efdae6810fab1bdcfc24f79d1512cf730d"

[[claims]]
claim_id = "CLAIM-STB-0135"
source_id = "REPO-43E0D80464B2869224C805D8"
source_location = "line:1432"
concept = "product.time-018-calendar-grade-acceptance"
scope = "active product and engineering authority migration"
modality = "INFORMATIONAL"
normalized_value = "time is not accepted until it proves:"
evidence_sha256 = "64413fd0d0f55c3ace1e224d045fe00b871982520d09dfb24e5526cd1db0866b"
owner_approval = "active-repo-authority:docs/truth/PRODUCT_DESIGN_TRUTH.md"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-STB-0471"
source_id = "REPO-AA88FA58EEA6FBA9BAB10270"
source_location = "line:161"
concept = "product.replacement-level-planning-product"
scope = "active product and engineering authority migration"
modality = "SHOULD"
normalized_value = "ambitions should eventually replace apple reminders and apple calendar for the user’s personal planning experience."
evidence_sha256 = "9ab6be52cecda281b3fcd7076659229430dde2e590ba2d356b00de8e8757b02f"
owner_approval = "active-repo-authority:docs/truth/PRODUCT_EXPERIENCE_CANON.md"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[impacts]]
dimension = "repo"
analysis = "Product Design acceptance, Product Experience aspiration, Implementation Truth, and future Time/system specs need scoped ownership."

[[impacts]]
dimension = "linear"
analysis = "Decision 31 must reference target and acceptance requirements separately."

[[impacts]]
dimension = "figma"
analysis = "Time visual authority must cover Day/Week/Month/Year/List and stress/accessibility states; current explorations are not final proof."

[[impacts]]
dimension = "production_source"
analysis = "TimeSurface and LifeShapeField are source-present; EventKit/import/recurrence paths do not establish the complete bar."

[[impacts]]
dimension = "tests"
analysis = "Later require views, recurrence exceptions, time zones, import/export, reflow, search, direct manipulation alternatives, offline/degraded, performance, and device tests."

[[impacts]]
dimension = "proof"
analysis = "Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven."

[[impacts]]
dimension = "privacy"
analysis = "Calendar permissions, invite/attendee/location content, provenance, import, and external writes require minimization and review."

[[impacts]]
dimension = "accessibility"
analysis = "Every view and direct manipulation needs VoiceOver, keyboard/switch alternatives, Dynamic Type, Reduce Motion/Transparency, and non-color semantics."

[[impacts]]
dimension = "migration_rollback"
analysis = "Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag."
+++

# CONFLICT-CALENDAR-REPLACEMENT-BAR

> Shadow migration decision docket. It is non-authoritative and remains unresolved until the owner records a decision.

## Competing conceptual claims

| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `CLAIM-LFT-0031` | time must replace ordinary daily apple calendar use at first-class quality. it uses familiar day / week / month / year / list calendar behavior, enriched by protected time, fixed commitments, flexible work, suggested placement, capacity, recovery, goal movement, proof, transition, reflow, and conflict semantics. all time is not treated equally. | `MUST` | linear v3 decision 31; owner-evidence-backed migration topology | `LINEAR-CANON-V3:decision:31` | `4ec6446caf5f71eb4be01208806138b5399ca883e28bfe97d8a4f93d1ea8e4da` |
| `CLAIM-STB-0135` | time is not accepted until it proves: | `INFORMATIONAL` | active product and engineering authority migration | `REPO-43E0D80464B2869224C805D8:line:1432` | `64413fd0d0f55c3ace1e224d045fe00b871982520d09dfb24e5526cd1db0866b` |
| `CLAIM-STB-0471` | ambitions should eventually replace apple reminders and apple calendar for the user’s personal planning experience. | `SHOULD` | active product and engineering authority migration | `REPO-AA88FA58EEA6FBA9BAB10270:line:161` | `9ab6be52cecda281b3fcd7076659229430dde2e590ba2d356b00de8e8757b02f` |

## User consequences

Ambitions may claim replacement too early, hide external tools before first-class behavior exists, or treat a launch requirement as indefinite aspiration.

## Compatibility analysis

Target law, acceptance bar, implementation posture, and proof are distinct. Current Time/LifeShapeField source and tests do not prove calendar-grade acceptance or calendar replacement.

## Recommendation

**Compose A and B with explicit scopes.** Keep first-class personal calendar replacement as target law and bind any readiness claim to the complete acceptance bar and current evidence.

This is a recommendation for Gate A, not an owner decision.

## Stronger composition option

Separate product target, launch obligation, external-organizer limitations, implementation state, and release proof into linked requirements.

## Proposed canonical law

Time MUST target first-class replacement of ordinary personal calendar planning, but Ambitions MUST NOT claim replacement or deprecate external fallback until every calendar-grade behavior, accessibility, privacy, migration, performance, and proof obligation is current and satisfied.

## Impact analysis

| Dimension | Impact |
| --- | --- |
| repo | Product Design acceptance, Product Experience aspiration, Implementation Truth, and future Time/system specs need scoped ownership. |
| Linear | Decision 31 must reference target and acceptance requirements separately. |
| Figma | Time visual authority must cover Day/Week/Month/Year/List and stress/accessibility states; current explorations are not final proof. |
| production source | TimeSurface and LifeShapeField are source-present; EventKit/import/recurrence paths do not establish the complete bar. |
| tests | Later require views, recurrence exceptions, time zones, import/export, reflow, search, direct manipulation alternatives, offline/degraded, performance, and device tests. |
| proof | Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven. |
| privacy | Calendar permissions, invite/attendee/location content, provenance, import, and external writes require minimization and review. |
| accessibility | Every view and direct manipulation needs VoiceOver, keyboard/switch alternatives, Dynamic Type, Reduce Motion/Transparency, and non-color semantics. |
| migration / rollback | Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag. |

## Artifacts to supersede

- `LINEAR-CANON-V3:decision:31`
- `REPO-43E0D80464B2869224C805D8:line:1432`
- `REPO-AA88FA58EEA6FBA9BAB10270:line:161`

## Target requirement

- Status: `planned_uncreated`
- Requirement ID: not created; it becomes mandatory only after owner resolution.

## Owner decision

- Status: unresolved
- Decision: blank
- Allowed values: `keep_a`, `keep_b`, `compose`, `reject_both`

## Explicit nonclaims and claim ceiling

- Nonclaims: No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made.
- Claim ceiling: Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization.

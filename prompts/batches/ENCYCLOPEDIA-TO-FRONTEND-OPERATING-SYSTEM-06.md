<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Ambitions Batch Prompt: ENCYCLOPEDIA-TO-FRONTEND-OPERATING-SYSTEM-06
## Batch ID
`ENCYCLOPEDIA-TO-FRONTEND-OPERATING-SYSTEM-06`
## Runner Command
```bash
scripts/ambitions-codex-train.sh ENCYCLOPEDIA-TO-FRONTEND-OPERATING-SYSTEM-06 prompts/batches/ENCYCLOPEDIA-TO-FRONTEND-OPERATING-SYSTEM-06.md
```
Equivalent:
```bash
make batch BATCH=ENCYCLOPEDIA-TO-FRONTEND-OPERATING-SYSTEM-06 PROMPT=prompts/batches/ENCYCLOPEDIA-TO-FRONTEND-OPERATING-SYSTEM-06.md
```
## Model Path
Use the Ambitions runner with this model path:
1. GPT-5.5 planning.
2. GPT-5.4-mini bounded patch.
3. GPT-5.5 review, repair, and final readiness.
Do not use Spark terminology in this batch, reports, generated prompts, docs, validators, or commit messages.
## Objective
Convert the Ambitions Visual Encyclopedia from a completed authority dataset into the operational frontend control plane for Codex implementation.
The encyclopedia is no longer being expanded for its own sake. It must now become the required interface between:
- intended canon
- Codex frontend prompts
- SwiftUI source files
- design tokens
- component contracts
- scenario/interaction proof
- visual drift detection
- implementation receipts
- implementation sequencing
- future UI batches
The output of this batch must make the encyclopedia directly usable for coding the entire frontend.
After this batch, future frontend work should not start from vague repo browsing. It should start from an encyclopedia-generated surface packet, preflight gate, implementation prompt, source binding, proof contract, and implementation receipt.
## Core Operating Principle
The encyclopedia is the source of visual/product intent.
This batch installs the operational loop:
```text
Encyclopedia surface
↓
Authority packet
↓
Codex implementation prompt
↓
SwiftUI source binding
↓
Preview/scenario/accessibility proof
↓
Implementation receipt
↓
Drift checker
↓
Frontend implementation dashboard
↓
Next surface queue
```
Do not create another broad documentation layer. Create tools, schemas, generated reports, and enforcement paths that make the existing encyclopedia practical during implementation.
## Product Truth
Ambitions is a premium native iPhone-first, local-first external brain and personal life operating system.
Active top-level IA is exactly:
- Today
- Goals
- Capture
- Time
- You
Active primary objects are exactly:
- Today -> Reality Meridian
- Goals -> Constellation Atlas
- Capture -> Atmosphere Composer
- Time -> LifeShape Field
- You -> User System Profile
Visual/product direction:
- 70% Apple quiet luxury
- 20% living on-device intelligence
- 10% executive command clarity
- graphite / warm dark luxury
- restrained celestial orientation
- QuietGlass
- GraphiteRecess
- LuminousTrace
- CelestialField
- Trust Seam
- source/proof/receipt clarity
- local-first runtime trust
- non-shaming recovery
- object-first native iPhone surfaces
Hard exclusions:
- no Plan top-level tab
- no chatbot UI
- no generic productivity app
- no generic dashboard/card stack
- no task-list clone
- no calendar clone
- no habit tracker
- no streaks, rings, scores, shame, or productivity-bro tone
- no sportsbook/gambling/urgency mechanics
- no cloud/external LLM dependency in core product
- no false implementation proof
- no release/TestFlight/App Store/device/accessibility conformance claim
## Current State To Verify
Do not assume this summary is true. Verify from source first.
The prior repair lane likely established:
- `VISUAL-DESIGN-FINAL-FORM-LOCK-REPAIR-05`
- 159 mature surface universe entries
- 159 source/provenance/batch linkage rows
- residue zero
- dashboard conflict repaired
- final gate Green
- implementation proof not claimed
Verify these from:
- `build/reports/visual-design-final-form-lock-repair-05.md`
- `build/reports/visual-design-lock-repair-05-final-gate.json`
- `build/reports/mature-app-surface-universe-complete.json`
- `build/reports/source-provenance-batch-linkage-complete.json`
- `build/reports/active-authority-residue-zero.json`
- `build/reports/dashboard-conflict-authority.json`
- `docs/canon/frontend/MATURE_APP_SURFACE_UNIVERSE.yaml`
- `docs/canon/frontend/VISUAL_SOURCE_PROVENANCE_AND_BATCH_LINKAGE.yaml`
If any of those are missing or Red, stop and report Red. Do not install operational tooling on top of an unsafe authority base.
## Active Source Truth To Inspect
Inspect in this order:
1. `docs/truth/**`
2. `docs/canon/frontend/MATURE_APP_SURFACE_UNIVERSE.yaml`
3. `docs/canon/frontend/VISUAL_SOURCE_PROVENANCE_AND_BATCH_LINKAGE.yaml`
4. `docs/canon/frontend/SURFACE_RECIPE_INVENTORY.yaml`
5. `docs/canon/frontend/VISUAL_ITEM_REGISTRY.yaml`
6. `docs/canon/frontend/VISUAL_SOURCE_LINKS.yaml`
7. `docs/canon/frontend/recipes/**`
8. `docs/canon/frontend/surfaces/**`
9. `docs/canon/frontend/contracts/**`
10. `docs/canon/frontend/primitives/**`
11. `docs/canon/frontend/behavior/**`
12. `docs/canon/frontend/trace/**`
13. `DesignTokens/**`
14. `Sources/Theme/*.swift`
15. current SwiftUI implementation:
    - `Native/**`
    - `Sources/**`
    - `AppUI/Sources/**`
16. `prompts/batches/**`
17. `docs/codex/**`
18. `build/reports/**`
19. `scripts/**`
20. `Makefile`
21. root `README.md`
22. `docs/canon/frontend/README.md`
23. `docs/canon/frontend/FRONTEND_AUTHORITY_INDEX.md`
## Source Precedence
Use this precedence order:
1. `docs/truth/**`
2. Mature App Store Surface Universe
3. source/provenance/batch linkage manifest
4. active surface recipes
5. surface bibles
6. design token source under `DesignTokens/**`
7. component/accessibility/state/behavior contracts
8. current final-form repair reports
9. planned batch prompts
10. current SwiftUI source
11. generated reports
12. historical/supporting material
13. obsolete/archive-candidate material
Generated reports do not outrank source truth. SwiftUI source is implementation reality, not visual intent authority.
## Allowed Scope
May create/update:
### Operational authority docs
- `docs/canon/frontend/ENCYCLOPEDIA_TO_FRONTEND_OS.md`
- `docs/canon/frontend/FRONTEND_AUTHORITY_INDEX.md`
- `docs/canon/frontend/README.md`
- root `README.md`, only for navigation/routing
- `docs/canon/frontend/trace/ENCYCLOPEDIA_TO_FRONTEND_OS_STATUS.md`
- `docs/canon/frontend/trace/FRONTEND_SOURCE_BINDINGS.yaml`
- `docs/canon/frontend/trace/FRONTEND_IMPLEMENTATION_RECEIPT_SCHEMA.yaml`
- `docs/canon/frontend/trace/FRONTEND_PROOF_CONTRACT_SCHEMA.yaml`
### Generated output directories
- `build/reports/frontend-authority-packets/**`
- `build/reports/frontend-implementation-prompts/**`
- `build/reports/frontend-implementation-receipts/**`
- `build/reports/frontend-implementation-dashboard.json`
- `build/reports/frontend-implementation-dashboard.md`
- `build/reports/frontend-next-surface-queue.json`
- `build/reports/frontend-next-surface-queue.md`
- `build/reports/frontend-source-bindings.json`
- `build/reports/frontend-drift-check.json`
- `build/reports/encyclopedia-to-frontend-operating-system-06.json`
- `build/reports/encyclopedia-to-frontend-operating-system-06.md`
### Scripts
May create:
- `scripts/ambitions-frontend-authority-packet.py`
- `scripts/ambitions-frontend-authority-preflight.py`
- `scripts/ambitions-frontend-implementation-prompt.py`
- `scripts/ambitions-frontend-source-bindings.py`
- `scripts/ambitions-frontend-drift-check.py`
- `scripts/ambitions-frontend-implementation-dashboard.py`
- `scripts/ambitions-frontend-next-surface-queue.py`
- `scripts/ambitions-frontend-receipt-check.py`
- `scripts/ambitions-frontend-proof-contract-check.py`
- `scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py`
- shared helpers if needed:
  - `scripts/ambitions_frontend_authority_common.py`
### Generated Swift authority bindings
May create generated, non-UI Swift files if Swift source layout supports it:
- `Sources/Theme/AmbitionsSurfaceID.generated.swift`
- `Sources/Theme/AmbitionsRecipeID.generated.swift`
- `Sources/Theme/AmbitionsFrontendAuthority.generated.swift`
or a better existing generated-source location if source truth indicates one.
These generated files must not implement UI. They may define identifiers, static metadata, and compile-safe strings used by future implementation.
### Makefile
May add targets:
- `frontend-authority-packet`
- `frontend-authority-packets-p0`
- `frontend-authority-packets-all`
- `frontend-authority-preflight`
- `frontend-implementation-prompt`
- `frontend-source-bindings`
- `frontend-drift-check`
- `frontend-implementation-dashboard`
- `frontend-next-surface-queue`
- `frontend-receipt-check`
- `frontend-proof-contract-check`
- `encyclopedia-to-frontend-os-final-gate`
- `encyclopedia-to-frontend-os-all`
## Forbidden Scope
Do not:
- implement production SwiftUI UI
- redesign screens
- generate screenshots
- activate hosted CI
- add `.github/workflows/**`
- change app routing
- change persistence/data model
- claim implementation proof
- claim accessibility conformance
- claim device proof
- claim App Store/TestFlight/release readiness
- rewrite the whole encyclopedia
- add another broad canon layer
- create duplicate authority paths
- downgrade the 159-surface universe
- hide planned/candidate/intended-only surfaces
- invent batch IDs
- mark intended-only surfaces as implemented
- mark source candidates as proof
- weaken existing validators to pass Green
- require all 159 surfaces to be implemented before the tooling becomes useful
- make future implementation depend on manual repo spelunking
## Required Deliverable Concept
This batch must create a working frontend authority interface.
A future Codex batch should be able to run:
```bash
make frontend-authority-packet SURFACE=today_root_reality_meridian
make frontend-authority-preflight SURFACE=today_root_reality_meridian
make frontend-implementation-prompt SURFACE=today_root_reality_meridian BATCH=TODAY-REALITY-MERIDIAN-FLAGSHIP-IMPLEMENTATION-01
make frontend-drift-check
make frontend-implementation-dashboard
make frontend-next-surface-queue
```
and receive a complete implementation contract derived from the encyclopedia.
## Phase 0 — Baseline Verification
Run and record:
```bash
git status --short
git diff --stat
cat build/reports/visual-design-final-form-lock-repair-05.md || true
cat build/reports/visual-design-lock-repair-05-final-gate.json || true
cat build/reports/mature-app-surface-universe-complete.json || true
cat build/reports/source-provenance-batch-linkage-complete.json || true
cat build/reports/active-authority-residue-zero.json || true
cat build/reports/dashboard-conflict-authority.json || true
```
Verify:
- active IA is Today / Goals / Capture / Time / You
- mature universe exists
- provenance manifest exists
- inventory count is 159
- provenance row count is 159
- residue is zero
- dashboard conflict is resolved
- implementation proof remains not claimed
If this base is unsafe, stop Red.
## Phase 1 — Install Frontend Authority OS Manifest
Create:
`docs/canon/frontend/ENCYCLOPEDIA_TO_FRONTEND_OS.md`
This should be concise and operational, not a giant new canon doc.
It must define:
- the encyclopedia is the source of frontend intent
- implementation must start from surface IDs
- surface packets are generated views, not source truth
- generated prompts are implementation contracts
- receipts are implementation proof records
- drift checks compare source against authority
- dashboards show implementation status
- source truth remains in existing canon files
Create or update:
`docs/canon/frontend/FRONTEND_AUTHORITY_INDEX.md`
It must become the human front door for frontend work.
It must include:
```text
For frontend/UI/design implementation work:
1. Pick a surface ID from MATURE_APP_SURFACE_UNIVERSE.yaml.
2. Generate the surface packet.
3. Run frontend preflight.
4. Generate the implementation prompt.
5. Implement only within declared source scope.
6. Produce proof and receipt.
7. Run drift check and dashboard.
```
Update root `README.md` and `docs/canon/frontend/README.md` only enough to point to the frontend authority workflow. Do not create a verbose README rewrite unless current README is actively misleading.
## Phase 2 — Surface Authority Packet Generator
Create:
`scripts/ambitions-frontend-authority-packet.py`
Required CLI:
```bash
python3 scripts/ambitions-frontend-authority-packet.py --surface today_root_reality_meridian
python3 scripts/ambitions-frontend-authority-packet.py --surface today_root_reality_meridian --format json
python3 scripts/ambitions-frontend-authority-packet.py --all
python3 scripts/ambitions-frontend-authority-packet.py --tier P0
```
Required outputs:
- single-surface Markdown packet:
  - `build/reports/frontend-authority-packets/<surface_id>.md`
- single-surface JSON packet:
  - `build/reports/frontend-authority-packets/<surface_id>.json`
- packet index:
  - `build/reports/frontend-authority-packets/index.json`
  - `build/reports/frontend-authority-packets/index.md`
Each packet must include:
- surface ID
- surface name
- destination
- primary object
- maturity tier
- recipe path
- surface bible path, if available
- universe row
- provenance row
- source candidates
- planned implementation batch
- patch target batch
- source relationship
- implementation proof status
- tokens
- contracts
- state/scenario requirements
- interaction grammar requirements
- accessibility/ADHD requirements
- privacy/local-first requirements
- proof/source/receipt requirements
- performance/preview requirements
- forbidden drift
- allowed scope
- forbidden scope
- required validation
- required proof
- known gaps
- receipt requirements
The packet must be clear enough that a Codex implementation batch can use it as the contract without reading the entire encyclopedia.
Hard requirement:
- Generating a packet for any of the 159 surface IDs must not fail.
- P0 packets must be generated during this batch.
- The index must include all 159 surfaces.
## Phase 3 — Frontend Authority Preflight
Create:
`scripts/ambitions-frontend-authority-preflight.py`
Required CLI:
```bash
python3 scripts/ambitions-frontend-authority-preflight.py --surface today_root_reality_meridian
python3 scripts/ambitions-frontend-authority-preflight.py --surface today_root_reality_meridian --source Native/Ambitions/Today/TodayRootView.swift
python3 scripts/ambitions-frontend-authority-preflight.py --batch TODAY-REALITY-MERIDIAN-FLAGSHIP-IMPLEMENTATION-01 --surface today_root_reality_meridian
```
It must verify:
- surface exists in mature universe
- surface has recipe/provenance row
- source relationship is explicit
- source candidates are known or gap is explicit
- tokens/contracts are known
- proof requirements are known
- implementation status is not falsely claimed
- active IA is valid
- Plan is not active top-level IA
- if source targets are supplied, they are allowed or require explicit extension reason
- generated packet exists or can be generated
- surface is not obsolete/superseded
- required proof contract can be generated
The preflight should output:
- `build/reports/frontend-authority-preflight/<surface_id>.json`
- `build/reports/frontend-authority-preflight/<surface_id>.md`
Hard requirement:
- future implementation prompts generated by this batch must require preflight.
## Phase 4 — Frontend Implementation Prompt Generator
Create:
`scripts/ambitions-frontend-implementation-prompt.py`
Required CLI:
```bash
python3 scripts/ambitions-frontend-implementation-prompt.py \
  --surface today_root_reality_meridian \
  --batch TODAY-REALITY-MERIDIAN-FLAGSHIP-IMPLEMENTATION-01
```
Output:
- `prompts/generated/frontend/<BATCH_ID>.md`
- `build/reports/frontend-implementation-prompts/<BATCH_ID>.json`
The generated prompt must be Ambitions-runner-compatible and include the required header:
```md
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
```
The generated prompt must include:
- batch ID
- surface ID
- objective
- packet path
- active source truth to inspect
- allowed source targets
- forbidden scope
- source binding requirements
- token/contract requirements
- scenario proof requirements
- interaction grammar requirements
- accessibility requirements
- visual proof requirements
- implementation receipt requirements
- drift check requirements
- validation commands
- hard Red conditions
- rollback expectations
- final response format
The generated prompt must forbid Codex from:
- inventing layout outside the packet
- using unregistered visual patterns
- using hardcoded colors/radii/spacing when tokens exist
- claiming implementation proof without previews/screenshots/tests
- touching unrelated surfaces
- reintroducing Plan top-level IA
- adding chatbot UI
This turns the encyclopedia into a prompt factory.
## Phase 5 — Frontend Source Binding System
Create or update:
`docs/canon/frontend/trace/FRONTEND_SOURCE_BINDINGS.yaml`
This must bind encyclopedia surfaces to source candidates and future implementation status.
Schema:
```yaml
schema_version: 1
generated_from_batch: ENCYCLOPEDIA-TO-FRONTEND-OPERATING-SYSTEM-06
bindings:
  - surface_id:
    recipe_id:
    destination:
    primary_object:
    source_relationship:
    source_candidates:
    declared_implementation_files:
    generated_swift_identifier:
    preview_targets:
    test_targets:
    implementation_status:
      one_of:
        - canon_only_pending_lock
        - planned
        - source_approximation_present
        - partially_implemented
        - implemented_unproven
        - proven
    proof_status:
      one_of:
        - not_in_scope
        - required_missing
        - partial
        - proven
    last_receipt:
    known_gaps:
```
Create:
`scripts/ambitions-frontend-source-bindings.py`
It must generate/update:
- `docs/canon/frontend/trace/FRONTEND_SOURCE_BINDINGS.yaml`
- `build/reports/frontend-source-bindings.json`
- `build/reports/frontend-source-bindings.md`
It must not mark any surface implemented without receipt/proof.
## Phase 6 — Generated Swift Authority IDs
If Swift source layout supports it, create generated Swift authority ID files.
Preferred files:
- `Sources/Theme/AmbitionsSurfaceID.generated.swift`
- `Sources/Theme/AmbitionsRecipeID.generated.swift`
- `Sources/Theme/AmbitionsFrontendAuthority.generated.swift`
These must be generated from:
- `MATURE_APP_SURFACE_UNIVERSE.yaml`
- `VISUAL_SOURCE_PROVENANCE_AND_BATCH_LINKAGE.yaml`
They may include:
- `enum AmbitionsSurfaceID: String, CaseIterable`
- `enum AmbitionsRecipeID: String, CaseIterable`
- `enum AmbitionsDestinationID: String, CaseIterable`
- static metadata lookup for destination/tier/status
- no UI implementation
If the repo has an existing generated token/source pattern, follow it.
If Swift generated source cannot be safely added, create a Red or Yellow note only if this blocks the OS install. Otherwise generate a non-Swift JSON binding and mark Swift binding as planned.
Do not modify production SwiftUI views in this batch.
## Phase 7 — Implementation Receipt and Proof Contract
Create:
`docs/canon/frontend/trace/FRONTEND_IMPLEMENTATION_RECEIPT_SCHEMA.yaml`
Schema:
```yaml
receipt_schema_version: 1
required_fields:
  batch_id:
  surface_ids:
  recipe_ids:
  source_files_changed:
  generated_packet_paths:
  tokens_used:
  contracts_used:
  scenario_proof:
  interaction_proof:
  accessibility_proof:
  dynamic_type_proof:
  reduce_motion_proof:
  visual_proof:
  preview_targets:
  screenshots:
  tests_run:
  drift_check_result:
  known_gaps:
  implementation_status:
  proof_status:
  rollback_notes:
```
Create:
`docs/canon/frontend/trace/FRONTEND_PROOF_CONTRACT_SCHEMA.yaml`
This must define proof requirements by surface tier:
- P0:
  - preview coverage required
  - scenario proof required for relevant states
  - Dynamic Type proof required
  - Reduce Motion proof required when motion exists
  - accessibility/VoiceOver proof required
  - screenshot or preview image proof expected when UI changes
  - implementation receipt required
- P1:
  - preview or targeted proof required
  - receipt required
- P2/candidate:
  - proof requirement determined by implementation scope
  - receipt required if code changes
Create:
`scripts/ambitions-frontend-receipt-check.py`
It must validate receipts under:
`build/reports/frontend-implementation-receipts/**`
Create:
`scripts/ambitions-frontend-proof-contract-check.py`
It must verify generated prompts include the proof contract.
## Phase 8 — Frontend Drift Checker
Create:
`scripts/ambitions-frontend-drift-check.py`
Required CLI:
```bash
python3 scripts/ambitions-frontend-drift-check.py
python3 scripts/ambitions-frontend-drift-check.py --surface today_root_reality_meridian
python3 scripts/ambitions-frontend-drift-check.py --strict
```
It must check:
- active IA labels remain Today / Goals / Capture / Time / You
- no Plan top-level IA leakage
- no chatbot/assistant UI language in core UX
- no generic dashboard/card/task-list language in active UI source/canon
- no hardcoded visual values in frontend source where tokens should be used, unless existing baseline/debt is explicit
- no unregistered surface IDs in generated Swift identifiers
- no recipe ID referenced in code that is absent from the encyclopedia
- no source file claims to implement a surface without binding
- no implementation receipt claims proof for absent files
- no preview target claims a surface absent from authority
- no generated prompt lacks required header
- no source/provenance row marks implementation proven without receipt
Output:
- `build/reports/frontend-drift-check.json`
- `build/reports/frontend-drift-check.md`
Important:
- For current pre-implementation source, baseline existing debt instead of blocking the install unless it violates active IA or proof honesty.
- In strict mode, fail on all new drift.
## Phase 9 — Frontend Implementation Dashboard
Create:
`scripts/ambitions-frontend-implementation-dashboard.py`
Output:
- `build/reports/frontend-implementation-dashboard.json`
- `build/reports/frontend-implementation-dashboard.md`
Dashboard must answer:
- total mature surfaces
- surfaces by destination
- surfaces by maturity tier
- surfaces by implementation status
- surfaces by proof status
- source-linked surfaces
- canon-only pending lock surfaces
- source-approximation surfaces
- implemented-unproven surfaces
- proven surfaces
- surfaces with receipts
- surfaces missing receipts
- P0 surfaces ready for implementation
- P0 surfaces blocked by missing source binding
- top drift findings
- next recommended surfaces
- proof gaps
- active IA status
- dashboard status Green / Yellow / Red
Do not claim app implementation just because canon exists.
## Phase 10 — Next Surface Queue Generator
Create:
`scripts/ambitions-frontend-next-surface-queue.py`
Output:
- `build/reports/frontend-next-surface-queue.json`
- `build/reports/frontend-next-surface-queue.md`
It must rank surfaces for implementation using:
- maturity tier
- user-visible value
- dependency depth
- source linkage readiness
- token/contract readiness
- proof readiness
- implementation risk
- object importance
- whether the surface unlocks many child surfaces
- whether surface is foundation/shared shell
- whether it is required before Today/Time/Capture/Goals/You can become real
The queue should likely prioritize:
1. generated identifiers / source binding
2. primitive/token consumption layer
3. app shell / destination chrome
4. Today root / Reality Meridian
5. Today Start Here region
6. Today Reality Meridian rail
7. Step Detail / Step Session
8. receipts / proof/source primitives
9. Time root / LifeShape Field
10. Capture root / Atmosphere Composer
11. Goals root / Constellation Atlas
12. You root / User System Profile
Do not hardcode that sequence if the source data indicates a better dependency order. Use source evidence.
## Phase 11 — Makefile Targets
Add targets:
```makefile
frontend-authority-packet
frontend-authority-packets-p0
frontend-authority-packets-all
frontend-authority-preflight
frontend-implementation-prompt
frontend-source-bindings
frontend-drift-check
frontend-implementation-dashboard
frontend-next-surface-queue
frontend-receipt-check
frontend-proof-contract-check
encyclopedia-to-frontend-os-final-gate
encyclopedia-to-frontend-os-all
```
Expected behavior:
```bash
make frontend-authority-packet SURFACE=today_root_reality_meridian
make frontend-authority-preflight SURFACE=today_root_reality_meridian
make frontend-implementation-prompt SURFACE=today_root_reality_meridian BATCH=TODAY-REALITY-MERIDIAN-FLAGSHIP-IMPLEMENTATION-01
make frontend-drift-check
make frontend-implementation-dashboard
make frontend-next-surface-queue
make encyclopedia-to-frontend-os-all
```
If Makefile variable forwarding is awkward, document exact direct Python alternatives in the target comments and final report.
## Phase 12 — OS Final Gate
Create:
`scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py`
Output:
- `build/reports/encyclopedia-to-frontend-os-final-gate.json`
The final gate must assert:
- Repair 05 final gate exists and is Green
- mature universe exists
- provenance manifest exists
- all 159 surfaces can generate packets
- packet index includes all 159 surfaces
- P0 packets are generated
- sample packets for Today, Goals, Capture, Time, You exist
- preflight passes for at least:
  - `today_root_reality_meridian`
  - `goals_root_constellation_atlas`
  - `capture_root_atmosphere_composer`
  - `time_root_lifeshape_field`
  - `you_root_user_system_profile`
- implementation prompt generator creates a runner-compatible prompt with required headers
- source bindings report exists
- generated Swift authority IDs exist or documented as safely deferred
- receipt schema exists
- proof contract schema exists
- drift checker report exists
- implementation dashboard exists
- next-surface queue exists
- Make targets exist
- root/frontend README routing exists
- no implementation proof is claimed
- no UI implementation changed
- no release/device/accessibility proof is claimed
Red if any of the above is missing.
## Validation Expectations
Run:
```bash
git diff --check
python3 -m py_compile \
  scripts/ambitions_frontend_authority_common.py \
  scripts/ambitions-frontend-authority-packet.py \
  scripts/ambitions-frontend-authority-preflight.py \
  scripts/ambitions-frontend-implementation-prompt.py \
  scripts/ambitions-frontend-source-bindings.py \
  scripts/ambitions-frontend-drift-check.py \
  scripts/ambitions-frontend-implementation-dashboard.py \
  scripts/ambitions-frontend-next-surface-queue.py \
  scripts/ambitions-frontend-receipt-check.py \
  scripts/ambitions-frontend-proof-contract-check.py \
  scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py
python3 scripts/ambitions-frontend-authority-packet.py --tier P0
python3 scripts/ambitions-frontend-authority-packet.py --surface today_root_reality_meridian
python3 scripts/ambitions-frontend-authority-packet.py --surface goals_root_constellation_atlas
python3 scripts/ambitions-frontend-authority-packet.py --surface capture_root_atmosphere_composer
python3 scripts/ambitions-frontend-authority-packet.py --surface time_root_lifeshape_field
python3 scripts/ambitions-frontend-authority-packet.py --surface you_root_user_system_profile
python3 scripts/ambitions-frontend-authority-preflight.py --surface today_root_reality_meridian
python3 scripts/ambitions-frontend-implementation-prompt.py --surface today_root_reality_meridian --batch TODAY-REALITY-MERIDIAN-FLAGSHIP-IMPLEMENTATION-01
python3 scripts/ambitions-frontend-source-bindings.py
python3 scripts/ambitions-frontend-drift-check.py
python3 scripts/ambitions-frontend-implementation-dashboard.py
python3 scripts/ambitions-frontend-next-surface-queue.py
python3 scripts/ambitions-frontend-receipt-check.py
python3 scripts/ambitions-frontend-proof-contract-check.py
python3 scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py
make encyclopedia-to-frontend-os-all
```
If relevant existing gates are available, also run:
```bash
make visual-all
make visual-100-all
make design-system-15-all
make visual-design-final-form-all
make visual-design-lock-repair-05-all
```
If Swift generated IDs are added and a Swift build target exists, run the appropriate Swift compile/build check. If unavailable, document why.
## Visual Proof Expectations
This is an operating-system tooling batch, not a UI implementation batch.
Required proof:
- generated authority packets
- generated implementation prompt
- preflight reports
- source binding report
- drift check report
- implementation dashboard
- next-surface queue
- final gate report
- validation command log
Not required:
- screenshots
- device proof
- visual regression images
- App Store screenshots
Do not claim UI implementation proof.
## Hard Red Conditions
Return Red if:
- Repair 05 authority base is missing or not Green.
- Mature universe is missing.
- Provenance manifest is missing.
- Packet generation does not work.
- Any of the 159 surface IDs cannot generate a packet.
- P0 packet generation fails.
- Preflight fails for root surfaces without explicit source-truth reason.
- Generated implementation prompt lacks Ambitions runner headers.
- Generated implementation prompt allows direct Codex execution.
- Generated implementation prompt allows generic UI invention.
- Source bindings are missing.
- Drift checker is missing.
- Implementation dashboard is missing.
- Next-surface queue is missing.
- Receipt schema is missing.
- Proof contract schema is missing.
- Final gate is missing or fails.
- README/frontend README do not tell the operator how to use the encyclopedia for implementation.
- Generated Swift authority IDs are claimed but absent.
- Swift generated files break build when build is available.
- Production SwiftUI UI is modified.
- Release/device/accessibility/App Store proof is claimed.
- Plan appears as active top-level IA.
- Chatbot UI is introduced.
- Any validator is weakened merely to pass Green.
## Success Criteria
Green means:
- the encyclopedia is queryable by surface ID
- all 159 surfaces are packet-generatable
- P0 packets are generated
- root destination preflights pass
- implementation prompt generator works
- generated prompt is runner-compatible
- source bindings exist
- proof/receipt schemas exist
- drift checker exists and runs
- implementation dashboard exists
- next-surface queue exists
- Make targets work
- final gate passes
- proof honesty preserved
- no production UI implementation occurred
Yellow means:
- core OS is installed and usable
- all hard Red conditions are avoided
- but Swift generated IDs or some optional source binding details are safely deferred with explicit evidence
Red means:
- the encyclopedia remains non-operational for Codex coding
- packet/preflight/prompt generation does not work
- required artifacts are missing
- final gate fails
## Final Report
Create:
- `build/reports/encyclopedia-to-frontend-operating-system-06.md`
- `build/reports/encyclopedia-to-frontend-operating-system-06.json`
The final report must include:
```text
STATUS: GREEN|YELLOW|RED
Batch: ENCYCLOPEDIA-TO-FRONTEND-OPERATING-SYSTEM-06
Model path: GPT-5.5 plan -> GPT-5.4-mini bounded patch -> GPT-5.5 review
Summary:
Files changed:
Authority base:
Surface packet generator:
P0 packets:
Preflight gate:
Implementation prompt generator:
Source bindings:
Generated Swift authority IDs:
Receipt schema:
Proof contract schema:
Drift checker:
Implementation dashboard:
Next-surface queue:
Make targets:
Validation run:
Final gate:
Remaining gaps:
Implementation proof:
Release/device/accessibility proof:
Rollback notes:
Commit:
```
Do not market the result. Be proof-based.

# Frontend Authority Packet: Today Root / Reality Meridian

Batch: `ENCYCLOPEDIA-TO-FRONTEND-OPERATING-SYSTEM-06`
Surface ID: `today_root_reality_meridian`
Destination: `Today`
Primary object: `Reality Meridian`
Maturity tier: `P0`
Recipe path: `frontend/visual-encyclopedia/recipes/today/today_root_reality_meridian.md`
Surface bible: `frontend/visual-encyclopedia/surfaces/TODAY_REALITY_MERIDIAN_BIBLE.md`
Source relationship: `implemented_source_present`
Implementation status: `implemented_unproven`
Proof status: `no_proof_required`

## Signature Visual Instrument
- instrument id: `reality_meridian_instrument`
- instrument name: `Reality Meridian Instrument`
- instrument required: `True`
- implementation status: `intended_authority_pending_source_proof`
- doctrine: `frontend/visual-encyclopedia/SIGNATURE_VISUAL_INSTRUMENTS.md`
- matrix: `frontend/visual-encyclopedia/trace/SIGNATURE_VISUAL_INSTRUMENTS_MATRIX.yaml`
- guidance: Use or create a dedicated visual-object SwiftUI component rather than burying this instrument inside a root screen file.

### Shared Instrument Primitives
- LivingBackground
- LiveTelemetryPanel
- ContextualDrilldownHeader
- MetricInstrumentChart

### Future Visual Object Source Files
- Native/Ambitions/Features/Today/RealityMeridianSurface.swift
- Native/Ambitions/Features/Today/RealityMeridianLiveStatePanel.swift
- Native/Ambitions/Features/Today/RealityMeridianContinuitySpine.swift

### Native SwiftUI Technique Candidates
- Canvas
- Shape
- Path
- GeometryReader
- TimelineView
- matchedGeometryEffect

### Forbidden Visual Regressions
- generic task list
- generic dashboard
- disconnected card stack
- shame language
- opaque model-certainty language

## Source Candidates
- Native/Ambitions/Features/Today/TodayScreen.swift
- Native/Ambitions/Features/Today/TodayViewModel.swift
- Native/Ambitions/Features/Today/TodayExecutionViewState.swift
- Native/Ambitions/Features/Today/TodayDayRailPanels.swift

## Tokens
- Sources/Theme/AmbitionObjectTokens.generated.swift
- Sources/Theme/AmbitionStateTokens.generated.swift
- frontend/visual-encyclopedia/primitives/RECEIPT_PRIMITIVES.md

## Contracts
- frontend/visual-encyclopedia/contracts/PROOF_CHIP_CONTRACT.md
- frontend/visual-encyclopedia/contracts/RECEIPT_CONTRACT.md
- frontend/visual-encyclopedia/contracts/TRUST_SEAM_CONTRACT.md

## State and Scenario Requirements
- visible_regions:
  - orientation
  - primary object
  - source/proof line
  - action or disclosure
  - state recovery
- forbidden_patterns:
  - generic dashboard
  - card-stack fallback
  - task-list clone
  - calendar clone
  - chatbot UI
  - AI confidence or model jargon
  - sportsbook or gambling language
  - color-only state meaning
  - shame language
- state_machine_relationship:
  - frontend/visual-encyclopedia/behavior/STATE_TRANSITIONS.md
  - frontend/visual-encyclopedia/trace/STATE_TO_VISUAL_ENCODING_MATRIX.md
  - frontend/visual-encyclopedia/trace/SURFACE_SCENARIO_COVERAGE_MATRIX.yaml
- preview_matrix_relationship:
  - frontend/visual-encyclopedia/trace/PREVIEW_MATRIX.yaml
  - frontend/visual-encyclopedia/trace/SCREEN_TO_DRILLDOWN_MATRIX.md
- state_coverage_status: documented
- scenarios:
  - {'state': 'blocked', 'status': 'covered', 'definition': 'Today Root / Reality Meridian distinguishes blocked work from failure and offers unblock, defer, or recovery actions with receipt-safe language.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'differentiate_without_color', 'status': 'covered', 'definition': 'Today Root / Reality Meridian pairs color with text, glyph, position, or line treatment for every meaningful state.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'dynamic_type', 'status': 'covered', 'definition': 'Today Root / Reality Meridian supports Dynamic Type by collapsing dense rows into stacked labels while preserving action order.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'empty', 'status': 'covered', 'definition': 'Today Root / Reality Meridian uses first-use or empty copy that names what can appear here without shame, scoring, or fake certainty.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'error', 'status': 'covered', 'definition': 'Today Root / Reality Meridian names the recoverable issue, keeps existing local state visible where possible, and offers a safe retry or repair path.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'first_use', 'status': 'covered', 'definition': 'Today Root / Reality Meridian orients the first-time user around Today and Reality Meridian without onboarding permission prompts outside the owning surface.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'increased_contrast', 'status': 'covered', 'definition': 'Today Root / Reality Meridian elevates labels, strokes, and glyphs so state is never communicated by subtle color alone.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'loading', 'status': 'covered', 'definition': 'Today Root / Reality Meridian uses quiet skeleton/progress treatment and preserves layout stability while local data resolves.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'local_runtime_unavailable', 'status': 'covered', 'definition': 'Today Root / Reality Meridian names local-runtime unavailability as a temporary capability gap and keeps non-runtime content inspectable.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'normal', 'status': 'covered', 'definition': "Today Root / Reality Meridian shows the user's current Reality Meridian state with calm hierarchy, source context, and a clear next action.", 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'offline_local_only', 'status': 'covered', 'definition': 'Today Root / Reality Meridian remains usable from local state and makes any unavailable external source explicit without blocking core review.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'overloaded', 'status': 'covered', 'definition': 'Today Root / Reality Meridian compresses density, prioritizes the highest-value object, and avoids piling on more work when the user is overloaded.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'permission_missing', 'status': 'covered', 'definition': 'Today Root / Reality Meridian explains the missing permission in context and routes the user to a visible alternative instead of requesting surprise access.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'privacy_sensitive_data', 'status': 'covered', 'definition': 'Today Root / Reality Meridian treats personal data as private by default and avoids exposing sensitive details without explicit context.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'proof_missing', 'status': 'covered', 'definition': 'Today Root / Reality Meridian marks missing proof plainly and routes to proof capture or acknowledgement without inventing evidence.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'receipt_created', 'status': 'covered', 'definition': 'Today Root / Reality Meridian confirms receipt creation with source/action context and a visible way to inspect or correct it.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'recovery', 'status': 'covered', 'definition': 'Today Root / Reality Meridian presents recovery as a normal continuation path, preserving proof/source/receipt continuity.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'reduced_motion', 'status': 'covered', 'definition': 'Today Root / Reality Meridian replaces expressive transitions with static emphasis, opacity-safe state changes, and no required motion comprehension.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'reduced_transparency', 'status': 'covered', 'definition': 'Today Root / Reality Meridian uses solid fallback surfaces and borders so meaning remains legible without translucent material.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'source_conflict', 'status': 'covered', 'definition': 'Today Root / Reality Meridian surfaces source conflict as reviewable evidence with correction or choice paths, not as hidden resolution.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'stale_source', 'status': 'covered', 'definition': 'Today Root / Reality Meridian displays stale-source language, freshness metadata, and an update/review path when source evidence is out of date.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'undo_reversal', 'status': 'covered', 'definition': 'Today Root / Reality Meridian exposes visible undo or reversal behavior for user-affecting changes and avoids silent mutation.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'voiceover', 'status': 'covered', 'definition': 'Today Root / Reality Meridian defines a VoiceOver order that starts with identity, then state, source/proof context, and available actions.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'waiting', 'status': 'covered', 'definition': 'Today Root / Reality Meridian shows waiting state as a legitimate holding pattern with owner/source context and no productivity-shaming language.', 'evidence': 'defined_by_final_form_matrix'}

## Interaction Grammar Requirements
- surface_family: today
- surface_kind: top_level_surface
- supporting_objects:
  - Receipt System
  - Source Freshness Badge
  - Why This Sheet
  - Closure System
- user_perception: None
- forbidden_patterns:
  - generic dashboard
  - card-stack fallback
  - task-list clone
  - calendar clone
  - chatbot UI
  - AI confidence or model jargon
  - sportsbook or gambling language
  - color-only state meaning
  - shame language

## Accessibility and ADHD Requirements
- accessibility_status: documented
- adhd_status: documented
- dynamic_type: required
- voiceover: required
- reduce_motion: required
- contrast: required
- tap_targets: 44pt minimum

## Privacy and Local-First Requirements
- privacy_local_first_status: documented
- local_first: required
- source_freshness_visible: True
- hosted_backend: forbidden

## Proof, Source, and Receipt Requirements
- proof_source_receipt_status: documented
- proof_status: no_proof_required
- implementation_proof_status: not_in_scope
- receipt_expected_for_code_changes: True

## Performance and Preview Requirements
- performance_budget_status: documented
- preview_matrix_relationship:
  - frontend/visual-encyclopedia/trace/PREVIEW_MATRIX.yaml
  - frontend/visual-encyclopedia/trace/SCREEN_TO_DRILLDOWN_MATRIX.md
- preview_targets:
  - None
- no_release_claims: True

## Forbidden Drift
- forbidden_patterns:
  - generic dashboard
  - card-stack fallback
  - task-list clone
  - calendar clone
  - chatbot UI
  - AI confidence or model jargon
  - sportsbook or gambling language
  - color-only state meaning
  - shame language
- hard_red:
  - Plan as a top-level destination
  - chatbot UI
  - generic dashboard
  - card-stack fallback
  - task-list clone
  - release/device/accessibility proof claims

## Allowed Scope
- source_targets:
  - Native/Ambitions/Features/Today/TodayScreen.swift
  - Native/Ambitions/Features/Today/TodayViewModel.swift
  - Native/Ambitions/Features/Today/TodayExecutionViewState.swift
- docs:
  - frontend/visual-encyclopedia/ENCYCLOPEDIA_TO_FRONTEND_OS.md
  - frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md
  - frontend/visual-encyclopedia/trace/FRONTEND_IMPLEMENTATION_RECEIPT_SCHEMA.yaml
  - frontend/visual-encyclopedia/trace/FRONTEND_PROOF_CONTRACT_SCHEMA.yaml
- generated_artifacts:
  - build/reports/frontend-authority-packets/today_root_reality_meridian.md
  - build/reports/frontend-authority-packets/today_root_reality_meridian.json

## Forbidden Scope
- native_swiftui_ui: forbidden
- routing_changes: forbidden
- persistence_changes: forbidden
- ui_claims: forbidden
- release_claims: forbidden

## Required Validation
- git diff --check
- python3 -m py_compile scripts/ambitions_frontend_authority_common.py scripts/ambitions-frontend-authority-packet.py scripts/ambitions-frontend-authority-preflight.py scripts/ambitions-frontend-implementation-prompt.py scripts/ambitions-frontend-source-bindings.py scripts/ambitions-frontend-drift-check.py scripts/ambitions-frontend-implementation-dashboard.py scripts/ambitions-frontend-next-surface-queue.py scripts/ambitions-frontend-receipt-check.py scripts/ambitions-frontend-proof-contract-check.py scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py
- python3 scripts/ambitions-frontend-authority-packet.py --tier P0
- python3 scripts/ambitions-frontend-authority-preflight.py --surface today_root_reality_meridian
- python3 scripts/ambitions-frontend-implementation-prompt.py --surface today_root_reality_meridian --batch FRONTEND-SURFACE-RECIPE-ENCYCLOPEDIA-001
- python3 scripts/ambitions-frontend-source-bindings.py
- python3 scripts/ambitions-frontend-drift-check.py
- python3 scripts/ambitions-frontend-implementation-dashboard.py
- python3 scripts/ambitions-frontend-next-surface-queue.py
- python3 scripts/ambitions-frontend-receipt-check.py
- python3 scripts/ambitions-frontend-proof-contract-check.py
- python3 scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py

## Required Proof
- generated authority packets
- generated implementation prompt
- preflight report
- source bindings report
- drift check report
- implementation dashboard
- next-surface queue
- final gate report
- validation command log

## Known Gaps
- no active gap in the mature universe
- not_in_scope
- proof status is no_proof_required

## Receipt Requirements
- batch_id
- surface_ids
- recipe_ids
- source_files_changed
- generated_packet_paths
- tokens_used
- contracts_used
- scenario_proof
- interaction_proof
- accessibility_proof
- dynamic_type_proof
- reduce_motion_proof
- visual_proof
- preview_targets
- screenshots
- tests_run
- drift_check_result
- known_gaps
- implementation_status
- proof_status
- rollback_notes

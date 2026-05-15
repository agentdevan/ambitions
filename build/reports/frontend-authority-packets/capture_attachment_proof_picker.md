# Frontend Authority Packet: Capture Attachment / Proof Picker

Batch: `ENCYCLOPEDIA-TO-FRONTEND-OPERATING-SYSTEM-06`
Surface ID: `capture_attachment_proof_picker`
Destination: `Capture`
Primary object: `Atmosphere Composer`
Maturity tier: `candidate`
Recipe path: `frontend/visual-encyclopedia/recipes/capture/capture_attachment_proof_picker.md`
Surface bible: `frontend/visual-encyclopedia/surfaces/CAPTURE_ATMOSPHERE_COMPOSER_BIBLE.md`
Source relationship: `planned_source_target`
Implementation status: `planned`
Proof status: `no_proof_required`

## Source Candidates
- None

## Tokens
- Sources/Theme/AmbitionObjectTokens.generated.swift
- frontend/visual-encyclopedia/contracts/PRIMARY_CTA_CONTRACT.md
- frontend/visual-encyclopedia/primitives/RECEIPT_PRIMITIVES.md

## Contracts
- frontend/visual-encyclopedia/contracts/PRIMARY_CTA_CONTRACT.md
- frontend/visual-encyclopedia/contracts/RECEIPT_CONTRACT.md

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
  - frontend/visual-encyclopedia/trace/PREVIEW_MATRIX.yaml
- preview_matrix_relationship:
  - frontend/visual-encyclopedia/trace/PREVIEW_MATRIX.yaml
- state_coverage_status: candidate
- scenarios:
  - None

## Interaction Grammar Requirements
- surface_family: capture
- surface_kind: drill_down
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
- accessibility_status: candidate
- adhd_status: candidate
- dynamic_type: required
- voiceover: required
- reduce_motion: required
- contrast: required
- tap_targets: 44pt minimum

## Privacy and Local-First Requirements
- privacy_local_first_status: candidate
- local_first: required
- source_freshness_visible: True
- hosted_backend: forbidden

## Proof, Source, and Receipt Requirements
- proof_source_receipt_status: candidate
- proof_status: no_proof_required
- implementation_proof_status: not_in_scope
- receipt_expected_for_code_changes: True

## Performance and Preview Requirements
- performance_budget_status: candidate
- preview_matrix_relationship:
  - frontend/visual-encyclopedia/trace/PREVIEW_MATRIX.yaml
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
  - None
- docs:
  - frontend/visual-encyclopedia/ENCYCLOPEDIA_TO_FRONTEND_OS.md
  - frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md
  - frontend/visual-encyclopedia/trace/FRONTEND_IMPLEMENTATION_RECEIPT_SCHEMA.yaml
  - frontend/visual-encyclopedia/trace/FRONTEND_PROOF_CONTRACT_SCHEMA.yaml
- generated_artifacts:
  - build/reports/frontend-authority-packets/capture_attachment_proof_picker.md
  - build/reports/frontend-authority-packets/capture_attachment_proof_picker.json

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
- python3 scripts/ambitions-frontend-authority-preflight.py --surface capture_attachment_proof_picker
- python3 scripts/ambitions-frontend-implementation-prompt.py --surface capture_attachment_proof_picker --batch FRONTEND-SURFACE-RECIPE-ENCYCLOPEDIA-001
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
- planned canon retained as explicit future surface
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

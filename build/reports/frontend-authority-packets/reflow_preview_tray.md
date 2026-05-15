# Frontend Authority Packet: Reflow Preview Tray

Batch: `ENCYCLOPEDIA-TO-FRONTEND-OPERATING-SYSTEM-06`
Surface ID: `reflow_preview_tray`
Destination: `Cross-surface`
Primary object: `Reflow Preview Tray`
Maturity tier: `P0`
Recipe path: `frontend/visual-encyclopedia/recipes/cross_surface/reflow_preview_tray.md`
Surface bible: `frontend/visual-encyclopedia/surfaces/GLOBAL_SHELL_AND_CHROME_BIBLE.md`
Source relationship: `planned_source_target`
Implementation status: `planned`
Proof status: `no_proof_required`

## Source Candidates
- None

## Tokens
- Sources/Theme/AmbitionTokens.generated.swift
- frontend/visual-encyclopedia/primitives/COLOR_AND_STATE_TOKENS.md
- frontend/visual-encyclopedia/primitives/TRUST_SEAM.md

## Contracts
- frontend/visual-encyclopedia/contracts/TRUST_SEAM_CONTRACT.md
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
  - frontend/visual-encyclopedia/behavior/CROSS_SURFACE_STATE_GRAMMAR.md
  - frontend/visual-encyclopedia/trace/SURFACE_SCENARIO_COVERAGE_MATRIX.yaml
- preview_matrix_relationship:
  - frontend/visual-encyclopedia/trace/PREVIEW_MATRIX.yaml
  - frontend/visual-encyclopedia/trace/SCREENSHOT_PROOF_MATRIX.md
- state_coverage_status: candidate
- scenarios:
  - {'state': 'blocked', 'status': 'covered', 'definition': 'Reflow Preview Tray distinguishes blocked work from failure and offers unblock, defer, or recovery actions with receipt-safe language.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'differentiate_without_color', 'status': 'covered', 'definition': 'Reflow Preview Tray pairs color with text, glyph, position, or line treatment for every meaningful state.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'dynamic_type', 'status': 'covered', 'definition': 'Reflow Preview Tray supports Dynamic Type by collapsing dense rows into stacked labels while preserving action order.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'empty', 'status': 'covered', 'definition': 'Reflow Preview Tray uses first-use or empty copy that names what can appear here without shame, scoring, or fake certainty.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'error', 'status': 'covered', 'definition': 'Reflow Preview Tray names the recoverable issue, keeps existing local state visible where possible, and offers a safe retry or repair path.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'first_use', 'status': 'covered', 'definition': 'Reflow Preview Tray orients the first-time user around Time and LifeShape Field without onboarding permission prompts outside the owning surface.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'increased_contrast', 'status': 'covered', 'definition': 'Reflow Preview Tray elevates labels, strokes, and glyphs so state is never communicated by subtle color alone.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'loading', 'status': 'covered', 'definition': 'Reflow Preview Tray uses quiet skeleton/progress treatment and preserves layout stability while local data resolves.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'local_runtime_unavailable', 'status': 'covered', 'definition': 'Reflow Preview Tray names local-runtime unavailability as a temporary capability gap and keeps non-runtime content inspectable.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'normal', 'status': 'covered', 'definition': "Reflow Preview Tray shows the user's current LifeShape Field state with calm hierarchy, source context, and a clear next action.", 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'offline_local_only', 'status': 'covered', 'definition': 'Reflow Preview Tray remains usable from local state and makes any unavailable external source explicit without blocking core review.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'overloaded', 'status': 'covered', 'definition': 'Reflow Preview Tray compresses density, prioritizes the highest-value object, and avoids piling on more work when the user is overloaded.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'permission_missing', 'status': 'covered', 'definition': 'Reflow Preview Tray explains the missing permission in context and routes the user to a visible alternative instead of requesting surprise access.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'privacy_sensitive_data', 'status': 'covered', 'definition': 'Reflow Preview Tray treats personal data as private by default and avoids exposing sensitive details without explicit context.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'proof_missing', 'status': 'covered', 'definition': 'Reflow Preview Tray marks missing proof plainly and routes to proof capture or acknowledgement without inventing evidence.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'receipt_created', 'status': 'covered', 'definition': 'Reflow Preview Tray confirms receipt creation with source/action context and a visible way to inspect or correct it.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'recovery', 'status': 'covered', 'definition': 'Reflow Preview Tray presents recovery as a normal continuation path, preserving proof/source/receipt continuity.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'reduced_motion', 'status': 'covered', 'definition': 'Reflow Preview Tray replaces expressive transitions with static emphasis, opacity-safe state changes, and no required motion comprehension.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'reduced_transparency', 'status': 'covered', 'definition': 'Reflow Preview Tray uses solid fallback surfaces and borders so meaning remains legible without translucent material.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'source_conflict', 'status': 'covered', 'definition': 'Reflow Preview Tray surfaces source conflict as reviewable evidence with correction or choice paths, not as hidden resolution.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'stale_source', 'status': 'covered', 'definition': 'Reflow Preview Tray displays stale-source language, freshness metadata, and an update/review path when source evidence is out of date.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'undo_reversal', 'status': 'covered', 'definition': 'Reflow Preview Tray exposes visible undo or reversal behavior for user-affecting changes and avoids silent mutation.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'voiceover', 'status': 'covered', 'definition': 'Reflow Preview Tray defines a VoiceOver order that starts with identity, then state, source/proof context, and available actions.', 'evidence': 'defined_by_final_form_matrix'}
  - {'state': 'waiting', 'status': 'covered', 'definition': 'Reflow Preview Tray shows waiting state as a legitimate holding pattern with owner/source context and no productivity-shaming language.', 'evidence': 'defined_by_final_form_matrix'}

## Interaction Grammar Requirements
- surface_family: shared-shell
- surface_kind: tray
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
  - frontend/visual-encyclopedia/trace/SCREENSHOT_PROOF_MATRIX.md
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
  - build/reports/frontend-authority-packets/reflow_preview_tray.md
  - build/reports/frontend-authority-packets/reflow_preview_tray.json

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
- python3 scripts/ambitions-frontend-authority-preflight.py --surface reflow_preview_tray
- python3 scripts/ambitions-frontend-implementation-prompt.py --surface reflow_preview_tray --batch FRONTEND-SURFACE-RECIPE-ENCYCLOPEDIA-001
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

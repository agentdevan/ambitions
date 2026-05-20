# AMB_PROJECTION_CONTRACT_REGISTRY

This registry is the contract authority for all projection packets.

## Shared contract template

Each contract must define:
- owner, consumer, schema_maturity
- required_fields, forbidden_fields
- runtime_identity, projection_identity
- generatedAt
- freshness semantics
- proof semantics
- not_chosen semantics
- privacy semantics
- unavailable_stale_conflict states
- fixture names
- preview requirements
- test expectations
- migration/versioning expectations
- rollback considerations

Contract ownership rule:
- `runtime_identity` names the authoritative runtime owner of the packet or state being projected.
- `projection_identity` names the renderer only; it must not imply selection or mutation authority.

## Contract: StartHereDecisionPacket
- owner: Private Life Runtime
- consumer: Start Here UI + Step Detail
- schema_maturity: L2
- required_fields: [id, generatedAt, candidates, selected_candidate, ranking_ledger_id, source_freshness, trust_receipts, closure_contract_id]
- forbidden_fields: [ui_ranking_override, ai_confidence_score]
- runtime_identity: PrivateLifeRuntime
- projection_identity: RealityMeridianProjection
- freshness_semantics: every packet carries source_freshness state and stale severity
- proof_semantics: trust_receipt_ids + unavailable_reason
- not_chosen_semantics: reason_ids + excluded_candidate_ids + alternatives_count
- privacy_semantics: redaction_flags and redaction_version
- unavailable_stale_conflict_states: [runtime_unavailable, stale_source, partial_conflict]
- fixtures: [start_here_normal.json, start_here_stale.json]
- preview_requirements: normal and stale states required
- test_expectations: one decision packet always includes selection + not-chosen set
- migration/versioning: backwards compatible bump on schema field changes
- rollback_considerations: fall back to last_valid_packet

## Contract: RealityMeridianProjection
- owner: Frontend
- consumer: Today root destination
- schema_maturity: L2
- required_fields: [packet_id, decision_summary, evidence_snippet, next_step_id]
- forbidden_fields: [opaque_ai_reasoning, raw_model_confidence]
- runtime_identity: PrivateLifeRuntime
- projection_identity: TodaySurfaceRenderer
- freshness_semantics: shows source freshness badge and degraded states
- proof_semantics: proof_links + receipt_summary
- not_chosen_semantics: compact_not_chosen_preview
- privacy_semantics: redacted_user_text and masked_intake
- unavailable_stale_conflict_states: [runtime_unavailable, stale_source, partial_conflict]
- fixtures: [rm_normal.json, rm_unavailable.json, rm_recovery.json]
- preview_requirements: VoiceOver summary per state
- test_expectations: all mandatory states must render
- migration/versioning: additive field-only policy preferred
- rollback_considerations: stale projection fallback

## Contract: LifeShapeProjection
- owner: Runtime + frontend
- consumer: Time surface
- schema_maturity: L1
- required_fields: [week_windows, protected_time, capacity_windows]
- forbidden_fields: [calendar_clone_fields]
- runtime_identity: PrivateLifeRuntime
- projection_identity: LifeShapeSurfaceRenderer
- freshness_semantics: protected_time_refresh_state
- proof_semantics: source_freshness + continuity_state
- not_chosen_semantics: protected_time_block_reasons
- privacy_semantics: local_visibility_controls
- unavailable_stale_conflict_states: [runtime_unavailable, source_stale, conflict_detected]
- fixtures: [lsf_normal.json, lsf_conflict.json]
- preview_requirements: normal + protected-time conflict
- test_expectations: no claim of sync completion without continuity proof
- migration/versioning: preserve old payload keys when renamed
- rollback_considerations: read-only fallback model

## Contract: GoalConstellationProjection
- owner: Runtime + frontend
- consumer: Goals surface
- schema_maturity: L1
- required_fields: [goal_threads, mission_context, blockers]
- forbidden_fields: [calendar_like_grid_clone]
- runtime_identity: PrivateLifeRuntime
- projection_identity: GoalAtlasRenderer
- freshness_semantics: goal_snapshot_stamp
- proof_semantics: mission_receipt_ids
- not_chosen_semantics: blocked_goal_reasons
- privacy_semantics: memory_visibility_controls
- unavailable_stale_conflict_states: [runtime_unavailable, stale_source]
- fixtures: [goals_normal.json, goals_blocked.json]
- preview_requirements: blocked and momentum scenarios
- test_expectations: deterministic ordering by runtime ranking
- migration/versioning: append-only preferred
- rollback_considerations: safe to suppress updates and retain last snapshot

## Contract: CaptureAtmosphereProjection
- owner: Frontend
- consumer: Capture surface
- schema_maturity: L1
- required_fields: [entry_modes, refined_object, clarification_state]
- forbidden_fields: [silent_mutation]
- runtime_identity: PrivateLifeRuntime
- projection_identity: AtmosphereRenderer
- freshness_semantics: intake_snapshot_version
- proof_semantics: command_trace_id
- not_chosen_semantics: omitted_capture_paths
- privacy_semantics: redaction_preview
- unavailable_stale_conflict_states: [runtime_unavailable, offline_mode]
- fixtures: [capture_raw.json, capture_clarified.json]
- preview_requirements: raw thought and clarified states
- test_expectations: always deterministic for same input
- migration/versioning: staged migration with compatibility aliasing
- rollback_considerations: retain raw capture for user recovery

## Contract: ClosurePromptProjection
- owner: Runtime
- consumer: Start now flow
- schema_maturity: L2
- required_fields: [closure_id, selected_step_id, outcome, evidence_map]
- forbidden_fields: [silent_mutation_without_receipt]
- runtime_identity: ClosureEngine
- projection_identity: ClosureSurfaceRenderer
- freshness_semantics: closure_freshness
- proof_semantics: closure_receipt + replay_id
- not_chosen_semantics: rejection_reason
- privacy_semantics: resettable_local_state
- unavailable_stale_conflict_states: [runtime_unavailable, source_stale]
- fixtures: [closure_normal.json, closure_blocked.json]
- preview_requirements: closure ritual and recovery states
- test_expectations: reversibility surfaced per policy
- migration/versioning: receipt schema migration supported
- rollback_considerations: explicit undo/restore path

## Contract: ProofTrailProjection
- owner: Frontend
- consumer: Proof trail surface
- schema_maturity: L2
- required_fields: [items, why_this, why_now, replay_link]
- forbidden_fields: [unexplained_scores]
- runtime_identity: RealitySignature
- projection_identity: ProofTrailRenderer
- freshness_semantics: proof_timestamp, stale_mark
- proof_semantics: receipt_ids + continuity_ids
- not_chosen_semantics: not_chosen_bundle
- privacy_semantics: reveal_optional_controls
- unavailable_stale_conflict_states: [proof_unavailable, runtime_unavailable]
- fixtures: [proof_ready.json, proof_unavailable.json]
- preview_requirements: one normal and one unavailable scenario
- test_expectations: no fake proof claims allowed
- migration/versioning: preserve existing proof ids
- rollback_considerations: hide unavailable evidence until refreshed

## Contract: TrustReceiptProjection
- owner: Trust runtime
- consumer: You / Trust console
- schema_maturity: L2
- required_fields: [trust_mode, offline_state, claims_state]
- forbidden_fields: [mandatory_cloud_switch]
- runtime_identity: TrustReceipt
- projection_identity: TrustConsoleRenderer
- freshness_semantics: last_verified_at
- proof_semantics: trust_manifest_ref, evidence_ref
- not_chosen_semantics: denied_request_paths
- privacy_semantics: redact_controls
- unavailable_stale_conflict_states: [runtime_unavailable, network_unavailable]
- fixtures: [trust_local.json, trust_redacted.json]
- preview_requirements: local-only and redacted states
- test_expectations: all trust controls deterministic
- migration/versioning: explicit manifest versioning
- rollback_considerations: conservative local-only mode

## Contract: SourceFreshnessProjection
- owner: Runtime
- consumer: all surfaces
- schema_maturity: L1
- required_fields: [source_version, freshness_state, degraded_fields]
- forbidden_fields: [undefined_freshness]
- runtime_identity: SourceFreshness
- projection_identity: SourceFreshnessBadge
- freshness_semantics: always present
- proof_semantics: source_fingerprint
- not_chosen_semantics: excluded_items_stale
- privacy_semantics: no hidden source details
- unavailable_stale_conflict_states: [source_unavailable, stale_source]
- fixtures: [source_fresh.json, source_stale.json]
- preview_requirements: normal and stale states
- test_expectations: freshness displayed on surfaces
- migration/versioning: monotonic version fields
- rollback_considerations: fallback to last_verified_snapshot

## Contract: DiagnosticsProjection
- owner: Runtime + Frontend QA
- consumer: debug surfaces
- schema_maturity: L0
- required_fields: [diagnostic_code, severity, repair_hint]
- forbidden_fields: [raw_stack_traces]
- runtime_identity: RuntimeDiagnostics
- projection_identity: DiagnosticsRenderer
- freshness_semantics: diagnostic_timestamp
- proof_semantics: repair_status
- not_chosen_semantics: skipped_checks
- privacy_semantics: scrubbed_details
- unavailable_stale_conflict_states: [diagnostics_unavailable]
- fixtures: [diag_normal.json, diag_recovery.json]
- preview_requirements: debug and recovery states
- test_expectations: no crash due missing diagnostics
- migration/versioning: keep old severity codes
- rollback_considerations: hide advanced diagnostics

## Contract: UserSystemProjection
- owner: Frontend
- consumer: You surface
- schema_maturity: L1
- required_fields: [user_profile_summary, settings, memory_controls]
- forbidden_fields: [social_guilt_terms]
- runtime_identity: LocalMemoryControls
- projection_identity: UserSystemRenderer
- freshness_semantics: profile_snapshot_timestamp
- proof_semantics: profile_change_receipt
- not_chosen_semantics: rejected_profile_mutations
- privacy_semantics: profile_visibility_state
- unavailable_stale_conflict_states: [local_state_unavailable]
- fixtures: [you_normal.json, you_memory_disabled.json]
- preview_requirements: local-first status and delete/reset
- test_expectations: deterministic settings restoration
- migration/versioning: explicit settings schema version
- rollback_considerations: reset to defaults safely

## Contract: ContinuityProjection
- owner: Continuity runtime
- consumer: Continuity surface
- schema_maturity: L1
- required_fields: [continuity_state, conflict_state, restore_checkpoint_id]
- forbidden_fields: [false_complete_claim]
- runtime_identity: ContinuityReceipt
- projection_identity: ContinuityRenderer
- freshness_semantics: restore_freshness
- proof_semantics: conflict_receipt + migration_receipt
- not_chosen_semantics: skipped_restore_paths
- privacy_semantics: local_state_restore_only
- unavailable_stale_conflict_states: [continuity_unknown, conflict_detected, partial_restore]
- fixtures: [cont_enabled.json, cont_conflict.json]
- preview_requirements: partial restore and conflict states
- test_expectations: no restore claim without receipts
- migration/versioning: schema version and idempotent migrations
- rollback_considerations: rollback checkpoint retention

## Contract: AccessibilitySemanticProjection
- owner: Accessibility runtime
- consumer: screen-reader surfaces
- schema_maturity: L1
- required_fields: [semantic_summary, controls_order, privacy_safe_text]
- forbidden_fields: [color_only_meaning]
- runtime_identity: AccessibilityContract
- projection_identity: AccessibilityRenderer
- freshness_semantics: semantic_snapshot_version
- proof_semantics: accessibility_validation_id
- not_chosen_semantics: omitted_semantic_fields
- privacy_semantics: protected_labeling
- unavailable_stale_conflict_states: [accessibility_unavailable]
- fixtures: [a11y_normal.json, a11y_reduced.json]
- preview_requirements: VoiceOver state coverage
- test_expectations: required labels and hints for each control
- migration/versioning: maintain semantic ids
- rollback_considerations: conservative defaults

## Contract: ScreenshotCandidateProjection
- owner: Visual runtime
- consumer: release and QA surfaces
- schema_maturity: L1
- required_fields: [screenshot_id, surface, projection_contract, fixture, validation_command]
- forbidden_fields: [unlinked_candidate]
- runtime_identity: VisualProofRuntime
- projection_identity: ScreenshotRegistry
- freshness_semantics: capture_timestamp
- proof_semantics: source_proof_ref
- not_chosen_semantics: unselected_scenes
- privacy_semantics: redaction_state
- unavailable_stale_conflict_states: [capture_unavailable]
- fixtures: [screenshot_registry_examples]
- preview_requirements: at least required states in table
- test_expectations: all required scenes have command+state metadata
- migration/versioning: scene_id stable across cycles
- rollback_considerations: candidate invalidation and re-capture

## Contract: MemoryLensProjection
- owner: Trust runtime + frontend
- consumer: You / Memory Lens
- schema_maturity: L1
- required_fields: [memory_pressure, operating_curve, fricton_map]
- forbidden_fields: [opaque_model_store]
- runtime_identity: PersonalOperatingCurve
- projection_identity: MemoryLensRenderer
- freshness_semantics: memory_snapshot_time
- proof_semantics: memory_control_receipts
- not_chosen_semantics: pruned_learning_paths
- privacy_semantics: opt_out_redacted_fields
- unavailable_stale_conflict_states: [memory_readonly]
- fixtures: [memorylens_normal.json, memorylens_reset_pending.json]
- preview_requirements: reset and control scenarios
- test_expectations: memory controls deterministic
- migration/versioning: memory schema version
- rollback_considerations: restore previous control profile

## Contract: LocalControlKnobsProjection
- owner: Trust runtime
- consumer: You surface
- schema_maturity: L1
- required_fields: [local_only_toggle, memory_control, network_toggle]
- forbidden_fields: [forced_cloud_mode]
- runtime_identity: LocalMemoryControls
- projection_identity: LocalControlKnobsRenderer
- freshness_semantics: control_sync_state
- proof_semantics: control_receipt_ids
- not_chosen_semantics: rejected_control_requests
- privacy_semantics: explicit permission wording
- unavailable_stale_conflict_states: [controls_unavailable]
- fixtures: [controls_normal.json, controls_disabled.json]
- preview_requirements: controls in normal and restricted modes
- test_expectations: control changes produce closure-safe events
- migration/versioning: backward-compatible defaults
- rollback_considerations: reset to safe profile

## Contract: NotChosenReasonsProjection
- owner: Proof runtime
- consumer: Proof surfaces
- schema_maturity: L1
- required_fields: [candidate_id, reason_code, reason_text, alternatives_count]
- forbidden_fields: [humiliating_language]
- runtime_identity: NotChosenReason
- projection_identity: NotChosenReasonsRenderer
- freshness_semantics: reason_snapshot_at
- proof_semantics: ranking_ledger_ref
- not_chosen_semantics: explicit and compact
- privacy_semantics: redact_sensitive_context
- unavailable_stale_conflict_states: [reasons_unavailable]
- fixtures: [not_chosen_normal.json, not_chosen_compact.json]
- preview_requirements: compact and full modes
- test_expectations: no missing reason for non-selected candidates
- migration/versioning: preserve historical reason codes
- rollback_considerations: hide reasons on unavailable state

## Contract: DecisionReplayProjection
- owner: Runtime
- consumer: Decision replay viewer
- schema_maturity: L2
- required_fields: [replay_id, seed, state_sequence, outcome]
- forbidden_fields: [mutated_trace]
- runtime_identity: DecisionReplayContract
- projection_identity: DecisionReplayRenderer
- freshness_semantics: replay_stamp
- proof_semantics: replay_hash + receipt_ref
- not_chosen_semantics: excluded_candidates_in_replay
- privacy_semantics: redacted_payload_mode
- unavailable_stale_conflict_states: [replay_unavailable]
- fixtures: [replay_available.json, replay_unavailable.json]
- preview_requirements: replay object and failure states
- test_expectations: replay identity stable
- migration/versioning: replay schema migration with replay_id stability
- rollback_considerations: no replay mutation after publish

## Contract: PrivacyRedactionProjection
- owner: Trust runtime
- consumer: all surfaces
- schema_maturity: L1
- required_fields: [redaction_state, redaction_rules, redaction_scope]
- forbidden_fields: [silent_redaction_without_notice]
- runtime_identity: LocalMemoryControls
- projection_identity: RedactionRenderer
- freshness_semantics: redaction_version
- proof_semantics: redaction_receipt
- not_chosen_semantics: redacted_reasons
- privacy_semantics: all required
- unavailable_stale_conflict_states: [redaction_unavailable]
- fixtures: [redaction_enabled.json, redaction_disabled.json]
- preview_requirements: privacy mode scenes
- test_expectations: redaction visible in UI hints
- migration/versioning: explicit redaction schema
- rollback_considerations: disable_redaction only with explicit receipt

# Ambitions 3.0 — Data Event Taxonomy

Status: Active Ambitions 3.0 analytics/data canon  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Last updated: 2026-04-30

---

## Purpose

This document defines internal product events for Ambitions 3.0.

Events are for product quality and debugging. They must not become user-facing scores.

---

## Event Principles

- Event names are plain and stable.
- Events should map to the Golden Launch Loop.
- Events should not collect unnecessary sensitive content.
- Events should distinguish action from outcome.
- Events should not imply judgment.

---

## Core Event Families

### Capture / Place

- `capture_created`
- `placement_suggested`
- `placement_confirmed`
- `placement_changed`
- `needs_a_place_saved`
- `grow_into_goal_started`
- `capture_saved_as_proof`
- `capture_saved_as_waiting`
- `capture_saved_as_decision`

### Plan

- `plan_scope_opened`
- `day_shape_opened`
- `week_shape_opened`
- `life_shape_opened`
- `capacity_viewed`
- `commitments_viewed`
- `decision_deck_opened`
- `reflow_previewed`
- `reflow_approved`
- `reflow_cancelled`
- `recovery_contract_started`

### Today / Step

- `recommended_step_shown`
- `why_this_opened`
- `step_detail_opened`
- `step_started`
- `step_paused`
- `step_resumed`
- `make_smaller_selected`
- `recommended_step_rejected`

### Closure / Proof / Receipts

- `closure_prompt_shown`
- `closure_recorded`
- `still_counts_selected`
- `proof_saved`
- `receipt_created`
- `receipt_peek_opened`
- `receipt_history_opened`

### Goals / Reviews

- `goal_created`
- `goal_detail_opened`
- `goal_next_step_selected`
- `goal_parked`
- `goal_archived`
- `review_opened`
- `review_to_plan_action_created`

### Trust / Memory

- `memory_candidate_shown`
- `memory_confirmed`
- `memory_changed`
- `memory_paused`
- `memory_deleted`
- `automation_level_changed`
- `trust_receipt_created`

### Shell / Navigation

- `destination_opened`
- `capture_aperture_opened`
- `active_step_capsule_opened`
- `meridian_destination_selected`

---

## Required Event Properties

Use only when relevant:

- `source_surface`
- `destination_surface`
- `object_type`
- `privacy_level`
- `source_label`
- `duration_source`
- `closure_outcome`
- `recommendation_type`
- `memory_status`
- `automation_level`
- `plan_scope`
- `is_sensitive_projection`

Do not include raw private content in analytics events.

---

## User-Facing Prohibition

Internal events must not become:

- productivity score
- health score
- streak
- ranking
- guilt metric
- balance grade

---

## Acceptance Criteria

An event is acceptable when:

- it maps to a product action or outcome
- it avoids private raw text
- it supports quality evaluation
- it has stable naming
- it does not create user-facing scoring pressure

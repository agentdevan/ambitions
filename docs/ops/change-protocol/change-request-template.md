# Canon Change Request Template

Status: Active template
Owner: CHANGE-PROTOCOL-001
Linear issue: AMB-34
Purpose: Standardize how a ChatGPT workshop decision becomes repo truth, conflict-aware implementation work, proof, and Linear status.

## When to use this template

Use this template after a ChatGPT workshop accepts a product, canon, IA, language, runtime, visual, monetization, privacy, proof, release, or process decision that may affect Ambitions source-of-truth files, active implementation work, batch prompts, train manifests, proof posture, or Linear status.

Do not use this template for casual brainstorming that has not been accepted as a change decision.

## Authority

Repo truth wins.

Required read order before filling this template:

1. docs/truth/README.md
2. docs/truth/PRODUCT_DESIGN_TRUTH.md
3. docs/truth/PRODUCT_MOAT_TRUTH.md
4. docs/truth/IMPLEMENTATION_TRUTH.md
5. docs/truth/RELEASE_TRUTH.md
6. docs/truth/CODEX_PROCESS_TRUTH.md
7. docs/truth/HISTORICAL_POLICY.md
8. docs/codex/GLOBAL_BATCH_SEQUENCE.md
9. docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json
10. docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml
11. docs/ops/batch-ledger/batch-ledger.json
12. docs/ops/batch-ledger/conflict-report.json
13. docs/ops/batch-ledger/conflict-action-workflow.md

## Hard gates

A change request is not ready for implementation until:

- the decision is explicit
- the source-of-truth tag is named
- the owning canon file is named
- the required canon edit is described
- affected surfaces and systems are listed
- affected active batches/prompts/trains are listed or explicitly marked none
- conflict checks are run before implementation work begins
- any retire / expedite / merge / rewrite / finish-proof action is recorded
- required implementation prompt or batch is named
- required proof is named
- Linear project and issue links are present
- no release/readiness claim is introduced without proof

## Required fields

### 1. Decision summary

Write the accepted decision in one paragraph.

Required:
- What changed
- Why it changed
- Whether the decision is product, canon, implementation, proof, release, process, or Linear-control-plane related

Example:

    Decision: Capture will become a global composer proposal, not active installed IA, until Product Design Truth is explicitly migrated.

### 2. Source-of-truth tag affected

Use stable tags so change impact can be queried.

Required format:

    source_of_truth_tag:

Allowed starting examples:

- product-design-truth
- product-moat-truth
- implementation-truth
- release-truth
- codex-process-truth
- historical-policy
- ios26-sequence-authority
- batch-ledger
- linear-control-plane
- change-protocol
- monetization-canon
- ia-canon
- runtime-canon
- visual-canon
- proof-canon

### 3. Owning canon file

Name the exact repo path that owns the decision.

Required format:

    owning_canon_file:

Allowed examples:

- docs/truth/PRODUCT_DESIGN_TRUTH.md
- docs/truth/PRODUCT_MOAT_TRUTH.md
- docs/truth/IMPLEMENTATION_TRUTH.md
- docs/truth/RELEASE_TRUTH.md
- docs/truth/CODEX_PROCESS_TRUTH.md
- docs/truth/HISTORICAL_POLICY.md
- docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json
- docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml
- docs/ops/batch-ledger/batch-ledger.json
- docs/ops/batch-ledger/conflict-action-workflow.md
- docs/ops/change-protocol/change-request-template.md

If the owning file does not exist yet, the request must say:

    owning_canon_file_status: proposed_new_file

### 4. Required canon edit

Describe the smallest truthful canon edit.

Required:

- exact file path
- section to change or add
- old wording, if replacing
- new wording, if known
- whether the edit is additive, replacement, migration, or deprecation
- whether historical material should be preserved, moved, or left unchanged

Template:

    canon_edit_type:
    canon_file:
    section:
    old_wording:
    new_wording:
    historical_handling:

### 5. Affected surfaces

List all affected Ambitions surfaces.

Allowed values:

- Today
- Goals
- Capture
- Time
- You
- Pulse
- Global
- None
- Unknown

Template:

    affected_surfaces:
    -

If Unknown, implementation is blocked until the uncertainty is resolved or explicitly accepted.

### 6. Affected systems

List all affected systems.

Allowed examples:

- IA
- chrome
- shell
- frontend
- runtime
- persistence
- privacy
- accessibility
- monetization
- branding
- proof
- release
- Linear
- Codex
- repo hygiene
- None
- Unknown

Template:

    affected_systems:
    -

If Unknown, implementation is blocked until the uncertainty is resolved or explicitly accepted.

### 7. Affected active batches / prompts / trains

Use the batch ledger and conflict reports before implementation.

Required checks:

    make batch-ledger-conflict-report
    make batch-ledger-conflict-action-workflow-validate

Required fields:

    affected_active_batches:
    -
    affected_active_prompts:
    -
    affected_active_trains:
    -
    affected_ledger_paths:
    -

If none are affected:

    affected_active_batches: none_detected
    affected_active_prompts: none_detected
    affected_active_trains: none_detected

Do not write none_detected unless the batch ledger was checked.

### 8. Conflict check result

Conflict checks must happen before implementation work begins.

Required fields:

    conflict_check_command:
    conflict_check_output:
    conflicts_found:
    recommended_conflict_actions:

Recommended action vocabulary must match docs/ops/batch-ledger/conflict-action-workflow.md:

- Retire
- Expedite
- Merge
- Rewrite
- Finish proof
- Cancel
- Keep planned

If conflicts are found, do not proceed to implementation until each conflict has a named action.

### 9. Required implementation prompt or batch

Every accepted canon change must either produce implementation work or explicitly say why implementation is not required.

Required fields:

    implementation_required: yes/no
    implementation_prompt_or_batch:
    implementation_scope:
    implementation_out_of_scope:
    codex_required: yes/no
    manual_script_allowed: yes/no

Rules:

- If source code must change, name the implementation prompt/batch.
- If only docs change, say implementation_required: no.
- If Codex is required, say why.
- If a manual script is sufficient, say why.

### 10. Required proof

Name the proof required to close the change.

Allowed proof classes:

- docs-only validation
- claim scan
- obsolete authority scan
- batch ledger regeneration
- conflict report regeneration
- unit test
- UI test
- build log
- screenshot
- accessibility proof
- performance proof
- privacy proof
- release proof
- accepted yellow with reason

Template:

    required_proof:
    -
    proof_commands:
    -
    proof_artifacts:
    -
    accepted_yellow_allowed: yes/no
    accepted_yellow_reason:

Do not claim proof exists until exact artifacts exist.

### 11. Linear project and issue links

Required fields:

    linear_project:
    linear_issue:
    related_linear_issues:
    blocked_by:
    blocks:

Rules:

- Linear is control plane, not repo truth.
- Linear Done does not prove implementation.
- Linear status must reflect repo proof, not replace it.

### 12. No-claim boundary

Every change request must include this section.

Required text:

    No-claim boundary:
    - This change request does not prove implementation.
    - This change request does not prove build success.
    - This change request does not prove test success.
    - This change request does not prove accessibility validation.
    - This change request does not prove performance validation.
    - This change request does not prove device validation.
    - This change request does not prove privacy/legal approval.
    - This change request does not prove TestFlight readiness.
    - This change request does not prove App Store readiness.
    - This change request does not prove release readiness.
    - Linear status is not repo truth.

### 13. Approval and closure

Required fields:

    owner_decision:
    approved_by:
    approval_date:
    closure_status:
    closure_proof:

Allowed closure statuses:

- proposed
- accepted
- rejected
- installed_docs_only
- implementation_ready
- implementation_in_progress
- proof_pending
- accepted_yellow
- green
- canceled
- superseded

## Blank template

Copy this block for future change requests.

    change_request_id:
    date:
    linear_project:
    linear_issue:

    decision_summary:

    source_of_truth_tag:
    owning_canon_file:
    owning_canon_file_status:

    canon_edit_type:
    canon_file:
    section:
    old_wording:
    new_wording:
    historical_handling:

    affected_surfaces:
      - Unknown

    affected_systems:
      - Unknown

    affected_active_batches:
      - unchecked
    affected_active_prompts:
      - unchecked
    affected_active_trains:
      - unchecked
    affected_ledger_paths:
      - unchecked

    conflict_check_command:
      - make batch-ledger-conflict-report
      - make batch-ledger-conflict-action-workflow-validate
    conflict_check_output:
    conflicts_found:
    recommended_conflict_actions:
      - unchecked

    implementation_required:
    implementation_prompt_or_batch:
    implementation_scope:
    implementation_out_of_scope:
    codex_required:
    manual_script_allowed:

    required_proof:
      - docs-only validation
    proof_commands:
      - git diff --check
    proof_artifacts:
    accepted_yellow_allowed:
    accepted_yellow_reason:

    related_linear_issues:
    blocked_by:
    blocks:

    no_claim_boundary:
      - This change request does not prove implementation.
      - This change request does not prove build success.
      - This change request does not prove test success.
      - This change request does not prove accessibility validation.
      - This change request does not prove performance validation.
      - This change request does not prove device validation.
      - This change request does not prove privacy/legal approval.
      - This change request does not prove TestFlight readiness.
      - This change request does not prove App Store readiness.
      - This change request does not prove release readiness.
      - Linear status is not repo truth.

    owner_decision:
    approved_by:
    approval_date:
    closure_status: proposed
    closure_proof:

## AMB-34 Green criteria

AMB-34 is Green when:

- this template exists at docs/ops/change-protocol/change-request-template.md
- every future canon change starts from this template
- the template points to current source files only
- the template requires conflict checks before implementation work begins
- the template includes all required fields from AMB-34
- no implementation/build/test/release claim is introduced

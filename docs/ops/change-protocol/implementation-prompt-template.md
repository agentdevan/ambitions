# Implementation Prompt Template

Status: Active template
Owner: CHANGE-PROTOCOL-001
Linear issue: AMB-36
Purpose: Standardize every implementation prompt, batch, or train before Codex or any local script changes Ambitions source files.

## When to use this template

Use this template before installing or running any new implementation prompt, Codex batch, train, repair pass, source refactor, UI migration, runtime change, persistence change, proof repair, or release-supporting change.

Do not use broad repo lore as canon. Do not reference old chat history, vague direction, generic product assumptions, or stale batch language as authority. Exact repo paths are required.

## Authority rule

Repo truth wins.

The implementation prompt must cite exact source-of-truth files. If the prompt cannot name the governing truth files, it is not ready.

Required minimum authority set:

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
11. docs/ops/change-protocol/change-request-template.md
12. docs/ops/change-protocol/change-impact-check.md
13. docs/ops/batch-ledger/batch-ledger.json
14. docs/ops/batch-ledger/conflict-report.json
15. docs/ops/batch-ledger/conflict-action-workflow.md

## Required preflight before implementation

Run or attach output from:

    make change-request-template-validate
    make batch-ledger-conflict-action-workflow-validate
    make change-impact-check

If the change impact check is RED because no inputs were provided, rerun it with the real change request, source-of-truth tags, affected surfaces, affected systems, affected files, batch path, and Linear issue.

Example input form:

    CHANGE_REQUEST=docs/ops/change-protocol/change-request-template.md
    SOURCE_OF_TRUTH_TAGS=change-protocol
    AFFECTED_SURFACES=Global
    AFFECTED_SYSTEMS=Codex,Linear,repo hygiene
    AFFECTED_FILES=docs/ops/change-protocol/implementation-prompt-template.md
    LINEAR_ISSUE=AMB-36
    make change-impact-check

Implementation cannot start until impact output is present and any blocking conflicts have named actions.

## Required sections

Every implementation prompt must include all sections below.

---

## 1. Source-of-truth tags

Required field:

    source_of_truth_tags:
      -

Allowed examples:

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

Rules:

- At least one tag is required.
- Unknown is not acceptable for implementation.
- Tags must resolve to exact canon files.
- Source-of-truth tags must match the change request and impact check.

---

## 2. Canon files to read first

Required field:

    canon_files_to_read_first:
      -

Rules:

- Every listed file must be an exact repo path.
- The prompt must not say read repo lore, old chats, broad context, or all docs as authority.
- The prompt may reference historical docs only when docs/truth/HISTORICAL_POLICY.md says they are relevant.
- The prompt must name the owning canon file for the change.

Minimum required files:

    docs/truth/README.md
    docs/truth/PRODUCT_DESIGN_TRUTH.md
    docs/truth/PRODUCT_MOAT_TRUTH.md
    docs/truth/IMPLEMENTATION_TRUTH.md
    docs/truth/RELEASE_TRUTH.md
    docs/truth/CODEX_PROCESS_TRUTH.md
    docs/truth/HISTORICAL_POLICY.md
    docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json
    docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml
    docs/ops/change-protocol/change-request-template.md
    docs/ops/change-protocol/change-impact-check.md
    docs/ops/batch-ledger/batch-ledger.json
    docs/ops/batch-ledger/conflict-report.json
    docs/ops/batch-ledger/conflict-action-workflow.md

---

## 3. Linear control plane

Required fields:

    linear_project:
    linear_issue:
    related_linear_issues:
      -
    blocked_by:
      -
    blocks:
      -

Rules:

- Linear is the control plane, not repo truth.
- Linear Done does not prove source implementation.
- Linear status must be updated only after repo artifacts and proof exist.
- If implementation creates new conflicts or proof gaps, Linear must show them as Yellow or follow-up work.

---

## 4. Change request link

Required fields:

    change_request_path:
    change_request_id:
    owner_decision:
    approved_by:
    approval_date:

Rules:

- The implementation prompt must be tied to an accepted change request.
- If there is no change request, create one from docs/ops/change-protocol/change-request-template.md before implementation.
- If the change request is proposed or unresolved, implementation is blocked.

---

## 5. Impact check output

Required fields:

    impact_check_command:
    impact_check_report:
    impact_check_json:
    implementation_blocked:
    required_conflict_actions:
      -

Required artifact paths:

    docs/ops/change-protocol/change-impact-check.md
    docs/ops/change-protocol/change-impact-check.json

Rules:

- New batches cannot be installed without impact output.
- Conflicting active batches/prompts/trains must be listed before implementation starts.
- Output must link affected canon files and ledger items.
- If implementation_blocked is true, implementation cannot start until conflicts are actioned or accepted with reason.

---

## 6. Scope

Required fields:

    implementation_scope:
      -
    implementation_out_of_scope:
      -

Scope must include:

- exact source files allowed to change
- exact docs allowed to change
- exact scripts allowed to change
- exact proof artifacts expected
- affected surfaces
- affected systems

Out-of-scope must include:

- source files not allowed to change
- product truth not allowed to change
- release claims not allowed
- unrelated cleanup not allowed
- broad refactors not allowed unless explicitly scoped

---

## 7. Affected ledger items

Required fields:

    affected_ledger_items:
      -
    affected_active_batches:
      -
    affected_active_prompts:
      -
    affected_active_trains:
      -
    affected_conflict_ids:
      -

Rules:

- Use docs/ops/batch-ledger/batch-ledger.json and docs/ops/batch-ledger/conflict-report.json.
- If none are affected, say none_detected and provide the impact-check artifact that proves it.
- Do not assume no impact without running the impact check.

---

## 8. Conflicts to retire, update, merge, rewrite, expedite, or finish first

Required fields:

    conflicts_to_action_first:
      -
    conflict_action_policy:
    conflict_action_owner:
    conflict_action_status:

Allowed actions:

- Retire
- Expedite
- Merge
- Rewrite
- Finish proof
- Cancel
- Keep planned

Rules:

- Follow docs/ops/batch-ledger/conflict-action-workflow.md.
- No conflict is silently auto-resolved.
- No one-issue-per-conflict generation by default.
- Active prompts are updated or removed only through owner-approved work.
- Source-only or partial implementation cannot be treated as complete.

---

## 9. Required source changes

Required fields:

    required_source_changes:
      -
    required_doc_changes:
      -
    required_script_changes:
      -
    required_test_changes:
      -
    prohibited_changes:
      -

Rules:

- Every required change must name exact repo paths or say new_file.
- If a path is unknown, the prompt is not implementation-ready.
- Implementation must stay inside scope.
- No broad repo cleanup unless explicitly scoped.
- No release/readiness claim unless proof exists.

---

## 10. Required proof artifacts

Required fields:

    proof_required:
      -
    proof_commands:
      -
    proof_artifacts:
      -
    proof_owner:
    accepted_yellow_allowed:
    accepted_yellow_reason:

Allowed proof classes:

- docs-only validation
- git diff check
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

Rules:

- Source-only is not implementation proof.
- Audit-only is not current test/build/release proof.
- If Xcode/source changes happen, proof must include the narrowest runnable build/test command or an explicit accepted-yellow reason.
- Proof artifacts must be exact repo paths.
- Linear status must link to proof paths.

---

## 11. Rollback and failure behavior

Required fields:

    rollback_plan:
      -
    failure_modes:
      -
    red_behavior:
    yellow_behavior:
    partial_behavior:

Rules:

- Red means stop and report the blocker.
- Yellow means record accepted gap and exact next repair.
- Partial implementation must stay visible in ledger and Linear.
- Do not edit reports from Red/Yellow to Green without new evidence.
- Do not hide failed validation output.
- Do not delete proof artifacts to make status cleaner.
- Rollback must preserve repo truth and historical traceability.

---

## 12. Linear sync steps

Required fields:

    linear_update_required:
    linear_update_scope:
    linear_status_after_proof:
    linear_links_to_add:
      -

Rules:

- Linear update happens after proof artifacts exist.
- Linear must not be used as the source of truth.
- For summary/control-plane work, update bounded summary records only.
- For source implementation work, update the implementation issue with proof links.
- Do not create bulk issue spam.
- Do not create one issue per ledger row or conflict by default.

---

## 13. No-claim boundary

Every implementation prompt must include this exact boundary:

    No-claim boundary:
    - This prompt does not prove implementation.
    - This prompt does not prove build success.
    - This prompt does not prove test success.
    - This prompt does not prove accessibility validation.
    - This prompt does not prove performance validation.
    - This prompt does not prove device validation.
    - This prompt does not prove privacy/legal approval.
    - This prompt does not prove TestFlight readiness.
    - This prompt does not prove App Store readiness.
    - This prompt does not prove release readiness.
    - Linear status is not repo truth.

---

## Blank implementation prompt template

    implementation_prompt_id:
    date:
    owner:
    linear_project:
    linear_issue:

    source_of_truth_tags:
      -

    canon_files_to_read_first:
      - docs/truth/README.md
      - docs/truth/PRODUCT_DESIGN_TRUTH.md
      - docs/truth/PRODUCT_MOAT_TRUTH.md
      - docs/truth/IMPLEMENTATION_TRUTH.md
      - docs/truth/RELEASE_TRUTH.md
      - docs/truth/CODEX_PROCESS_TRUTH.md
      - docs/truth/HISTORICAL_POLICY.md
      - docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json
      - docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml
      - docs/ops/change-protocol/change-request-template.md
      - docs/ops/change-protocol/change-impact-check.md
      - docs/ops/batch-ledger/batch-ledger.json
      - docs/ops/batch-ledger/conflict-report.json
      - docs/ops/batch-ledger/conflict-action-workflow.md

    related_linear_issues:
      -
    blocked_by:
      -
    blocks:
      -

    change_request_path:
    change_request_id:
    owner_decision:
    approved_by:
    approval_date:

    impact_check_command:
      - make change-impact-check
    impact_check_report:
      - docs/ops/change-protocol/change-impact-check.md
    impact_check_json:
      - docs/ops/change-protocol/change-impact-check.json
    implementation_blocked:
    required_conflict_actions:
      -

    implementation_scope:
      -
    implementation_out_of_scope:
      -

    affected_ledger_items:
      -
    affected_active_batches:
      -
    affected_active_prompts:
      -
    affected_active_trains:
      -
    affected_conflict_ids:
      -

    conflicts_to_action_first:
      -
    conflict_action_policy:
      - docs/ops/batch-ledger/conflict-action-workflow.md
    conflict_action_owner:
    conflict_action_status:

    required_source_changes:
      -
    required_doc_changes:
      -
    required_script_changes:
      -
    required_test_changes:
      -
    prohibited_changes:
      -

    proof_required:
      -
    proof_commands:
      -
    proof_artifacts:
      -
    proof_owner:
    accepted_yellow_allowed:
    accepted_yellow_reason:

    rollback_plan:
      -
    failure_modes:
      -
    red_behavior:
    yellow_behavior:
    partial_behavior:

    linear_update_required:
    linear_update_scope:
    linear_status_after_proof:
    linear_links_to_add:
      -

    no_claim_boundary:
      - This prompt does not prove implementation.
      - This prompt does not prove build success.
      - This prompt does not prove test success.
      - This prompt does not prove accessibility validation.
      - This prompt does not prove performance validation.
      - This prompt does not prove device validation.
      - This prompt does not prove privacy/legal approval.
      - This prompt does not prove TestFlight readiness.
      - This prompt does not prove App Store readiness.
      - This prompt does not prove release readiness.
      - Linear status is not repo truth.

## AMB-36 Green criteria

AMB-36 is Green when:

- this template exists at docs/ops/change-protocol/implementation-prompt-template.md
- the template requires source-of-truth tags
- the template requires exact canon files to read first
- the template includes scope and out-of-scope
- the template includes affected ledger items
- the template includes conflicts to retire/update/merge/rewrite/expedite/finish first
- the template includes required source changes
- the template includes required proof artifacts
- the template includes Linear project/issue links
- the template includes rollback and failure behavior
- the template cannot reference broad repo lore as canon
- the template requires proof and Linear sync steps

# Post-Implementation Proof and Linear Reconciliation

Status: Active protocol
Owner: CHANGE-PROTOCOL-001
Linear issue: AMB-38
Purpose: Define the required closure step after Codex, a local script, or a human implementation pass changes Ambitions source, docs, scripts, tests, prompts, trains, proof artifacts, or Linear control-plane state.

## Core rule

Implementation is not complete when code lands.

Implementation is complete only when the repo has proof or a documented partial state, and Linear reflects the actual repo-backed status.

Linear is the control plane, not repo truth.

## Required inputs

Every post-implementation reconciliation must start with these inputs:

    implementation_issue:
    implementation_prompt_or_batch:
    implementation_commit_or_branch:
    changed_paths:
      -
    expected_scope:
      -
    out_of_scope:
      -
    source_of_truth_tags:
      -
    canon_files_read:
      -
    proof_required:
      -
    proof_commands:
      -
    proof_artifacts:
      -
    linear_project:
    linear_issue:
    related_linear_issues:
      -

## Required authority files

Read these before declaring any implementation complete:

1. docs/truth/README.md
2. docs/truth/PRODUCT_DESIGN_TRUTH.md
3. docs/truth/PRODUCT_MOAT_TRUTH.md
4. docs/truth/IMPLEMENTATION_TRUTH.md
5. docs/truth/RELEASE_TRUTH.md
6. docs/truth/CODEX_PROCESS_TRUTH.md
7. docs/truth/HISTORICAL_POLICY.md
8. docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json
9. docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml
10. docs/ops/change-protocol/change-request-template.md
11. docs/ops/change-protocol/change-impact-check.md
12. docs/ops/change-protocol/implementation-prompt-template.md
13. docs/ops/batch-ledger/batch-ledger.json
14. docs/ops/batch-ledger/conflict-report.json
15. docs/ops/batch-ledger/conflict-action-workflow.md

## Required final sequence

Run this sequence after implementation work:

1. Capture changed paths.
2. Compare changed paths against scope.
3. Run the required validation/proof commands.
4. Save exact proof artifacts.
5. Classify result as Green, Accepted Yellow, Red, or Partial.
6. Regenerate batch ledger artifacts when batch/prompt/train/proof status changed.
7. Regenerate conflict reports when changed paths affect canon, ledger items, prompts, trains, or active surfaces.
8. Update touched source-of-truth tags only when the implementation legitimately changes canon authority.
9. Update Linear issue status and proof links.
10. Create bounded follow-up issues or summary records for unresolved Red/Yellow items.
11. Commit proof artifacts and reconciliation outputs.
12. Do not claim release/build/test/device/accessibility/privacy success unless exact proof exists.

## Required commands

Minimum docs/process-only closeout:

    git status --short
    git diff --check
    make change-request-template-validate
    make change-impact-check
    make implementation-prompt-template-validate
    make post-implementation-reconciliation-validate

Minimum batch-ledger-impact closeout:

    make batch-ledger-inventory
    make batch-ledger-detect-touchpoints
    make batch-ledger-classify-status
    make batch-ledger-conflict-report
    make post-implementation-reconciliation-validate

Minimum source-code closeout:

    git status --short
    git diff --check
    make change-impact-check
    make implementation-prompt-template-validate
    make batch-ledger-conflict-report
    run the narrowest applicable build/test command
    save the exact build/test/proof artifact path
    make post-implementation-reconciliation-validate

If Xcode validation is required, use the narrowest applicable lane available in the repo, for example:

    make xcode-focused-test BATCH=<batch-id> TEST=<test-name>
    make xcode-build-for-testing BATCH=<batch-id>
    make xcode-test-plan BATCH=<batch-id> TEST_PLAN=<plan-name>

If Xcode cannot run, the result cannot be Green unless the scoped claim is docs-only or the gap is explicitly accepted as Yellow.

## Status taxonomy

### Green

Green means:

- implementation stayed in scope
- required commands passed
- proof artifacts exist
- no Red conflicts remain for the scoped change
- source-only work is not being treated as complete
- Linear links to exact proof
- no unsupported release/readiness claim was introduced

### Accepted Yellow

Accepted Yellow means:

- implementation is useful but proof is incomplete or a bounded gap remains
- the gap is named
- the blocker is named
- the next repair is named
- Linear reflects Yellow/partial status
- the batch ledger reflects partial or accepted-yellow state
- no Green claim is made

### Red

Red means:

- implementation failed validation
- changed paths exceeded scope
- proof is missing for required source changes
- stale canon or retired terminology leaked into active work
- release/build/test/accessibility/device/privacy claims were made without proof
- Linear would misrepresent repo status if marked Done

Red behavior:

- stop
- preserve logs
- write the blocker
- do not hide or delete the failing proof artifact
- do not mark Linear Done
- create a bounded follow-up or keep the issue In Progress

### Partial

Partial means:

- source landed but proof is incomplete
- source-only or audit-only evidence exists
- some expected work landed but closure proof is missing
- implementation cannot be considered complete

Partial behavior:

- mark source-only implementation as partial, not complete
- keep proof gap visible
- update Linear with partial status
- update batch ledger or proof status when applicable
- create bounded follow-up only when owner-useful

## Source-only rule

Source-only implementation is never complete.

If source files changed but current proof is missing, stale, audit-only, or unavailable, classify as Partial or Accepted Yellow.

Do not mark source-only work Done unless the issue scope was explicitly source-only documentation and no implementation claim is made.

## Batch ledger update rules

Update or regenerate batch ledger artifacts when any of these changed:

- batch prompt
- train manifest
- proof artifact
- conflict status
- source-of-truth reference
- implementation/proof status
- active/historical/superseded state
- touched surface/system/file/canon source

Relevant commands:

    make batch-ledger-inventory
    make batch-ledger-detect-touchpoints
    make batch-ledger-classify-status
    make batch-ledger-conflict-report

Required outputs when applicable:

    docs/ops/batch-ledger/batch-ledger.json
    docs/ops/batch-ledger/batch-ledger.md
    docs/ops/batch-ledger/touchpoint-report.md
    docs/ops/batch-ledger/implementation-proof-status-report.md
    docs/ops/batch-ledger/conflict-report.md
    docs/ops/batch-ledger/conflict-report.json

## Source-of-truth tag update rules

Touched source-of-truth tags must be updated only when the implementation changes actual authority.

Allowed:

- add or revise canon authority when owner-approved
- update current tag references after canon file changes
- link implementation prompt to exact source-of-truth tags
- update ledger/canon references to prevent drift

Not allowed:

- changing truth files only to make an implementation look valid
- adding broad source-of-truth tags without exact canon paths
- treating historical docs as active truth unless HISTORICAL_POLICY allows it
- using Linear status as source-of-truth

## Linear reconciliation rules

Linear must reflect repo-backed reality.

Required Linear update fields or comment content:

    implementation_status:
    proof_status:
    proof_artifacts:
      -
    validation_commands:
      -
    changed_paths:
      -
    source_of_truth_tags:
      -
    batch_ledger_updated: yes/no/not_applicable
    conflicts_remaining:
      -
    follow_up_required: yes/no
    no_claim_boundary:
      -

Allowed Linear states:

- Done only when proof supports completion
- In Progress when implementation or proof is still active
- In Review when human review is required
- Todo or Backlog for future follow-up
- Canceled when owner-approved and repo artifacts explain why

Required Linear proof links:

- exact repo artifact paths
- exact report paths
- exact build/test log paths when applicable
- exact screenshot/proof paths when applicable

Not allowed:

- marking Done from source-only evidence
- marking Done because a script ran without checking output
- creating one issue per conflict by default
- creating one issue per ledger row by default
- hiding Yellow/Red by closing the issue without proof

## Follow-up issue policy for unresolved Red/Yellow items

Create follow-up issues only when bounded and owner-useful.

Allowed:

- one issue for a coherent Red repair bundle
- one issue for a proof-finish bundle
- one issue for a rewrite or retire bundle
- one issue for a merge/reconciliation bundle
- one issue for a validation environment blocker

Not allowed:

- one issue per ledger row
- one issue per conflict by default
- proof spam
- duplicate generated issues without stable sync keys
- issue creation that exceeds workspace limits

Every follow-up must include:

    source_issue:
    source_conflict_or_proof_id:
    affected_paths:
      -
    required_action:
    proof_required:
    no_claim_boundary:
    stable_sync_key:

## Required reconciliation artifact

Every implementation closeout should produce or update a reconciliation note.

Recommended path pattern:

    docs/ops/change-protocol/reconciliation/<issue-or-batch-id>.md

Required fields:

    reconciliation_id:
    generated_utc:
    implementation_issue:
    implementation_prompt_or_batch:
    changed_paths:
      -
    in_scope_changes:
      -
    out_of_scope_changes:
      -
    validation_commands:
      -
    validation_results:
      -
    proof_artifacts:
      -
    batch_ledger_updates:
      -
    source_of_truth_tag_updates:
      -
    linear_updates:
      -
    final_status:
    accepted_yellow_reason:
    red_blocker:
    follow_up_issues:
      -
    no_claim_boundary:
      -

## Rollback and failure behavior

Rollback must preserve traceability.

If implementation fails:

- keep the failing output
- record the failing command
- record the exact blocker
- do not delete proof artifacts to make status cleaner
- do not edit Red/Yellow reports into Green without new evidence
- revert source changes only when rollback is safer than repair
- keep docs/proof reports honest about the failure
- update Linear to reflect the failure or partial state

Rollback must not:

- erase historical evidence
- rewrite truth to hide implementation failure
- remove batch ledger records to make status look clean
- claim release readiness

## No-claim boundary

Every reconciliation must include:

    No-claim boundary:
    - This reconciliation does not prove implementation unless exact proof artifacts are listed.
    - This reconciliation does not prove build success unless exact build logs are listed.
    - This reconciliation does not prove test success unless exact test logs are listed.
    - This reconciliation does not prove accessibility validation unless exact accessibility proof is listed.
    - This reconciliation does not prove performance validation unless exact performance proof is listed.
    - This reconciliation does not prove device validation unless exact device proof is listed.
    - This reconciliation does not prove privacy/legal approval unless exact approval proof is listed.
    - This reconciliation does not prove TestFlight readiness.
    - This reconciliation does not prove App Store readiness.
    - This reconciliation does not prove release readiness.
    - Linear status is not repo truth.

## Blank reconciliation template

    reconciliation_id:
    generated_utc:
    owner:
    linear_project:
    linear_issue:
    implementation_issue:
    implementation_prompt_or_batch:
    implementation_commit_or_branch:

    changed_paths:
      -

    expected_scope:
      -
    out_of_scope:
      -

    in_scope_changes:
      -
    out_of_scope_changes:
      -

    source_of_truth_tags:
      -
    canon_files_read:
      -

    validation_commands:
      -
    validation_results:
      -

    proof_required:
      -
    proof_artifacts:
      -

    batch_ledger_updated:
    batch_ledger_updates:
      -

    source_of_truth_tags_updated:
    source_of_truth_tag_updates:
      -

    conflicts_remaining:
      -
    red_items:
      -
    yellow_items:
      -
    partial_items:
      -

    linear_updates:
      -
    linear_status_after_proof:
    linear_links_added:
      -

    follow_up_required:
    follow_up_issues:
      -

    final_status:
    accepted_yellow_reason:
    red_blocker:

    no_claim_boundary:
      - This reconciliation does not prove implementation unless exact proof artifacts are listed.
      - This reconciliation does not prove build success unless exact build logs are listed.
      - This reconciliation does not prove test success unless exact test logs are listed.
      - This reconciliation does not prove accessibility validation unless exact accessibility proof is listed.
      - This reconciliation does not prove performance validation unless exact performance proof is listed.
      - This reconciliation does not prove device validation unless exact device proof is listed.
      - This reconciliation does not prove privacy/legal approval unless exact approval proof is listed.
      - This reconciliation does not prove TestFlight readiness.
      - This reconciliation does not prove App Store readiness.
      - This reconciliation does not prove release readiness.
      - Linear status is not repo truth.

## AMB-38 Green criteria

AMB-38 is Green when:

- this protocol exists at docs/ops/change-protocol/post-implementation-proof-reconciliation.md
- every implementation PR or source-changing batch must produce proof or documented partial state
- Linear reflects actual implementation/proof state
- batch ledger and proof reports stay synchronized when relevant
- source-only implementation is marked partial, not complete
- Red/Yellow behavior is explicit
- follow-up issue creation is bounded and not spammy
- no implementation/build/test/release claim is introduced without proof

# Batch Lane Classification Policy

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, rewrite-authority-before-proof
> Dispositions: rewrite-authority-before-proof, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

This policy defines deterministic lane behavior for the throughput factory.

## Classes

### critical_serial_write
- **Purpose:** Canonical implementation lane for child batch execution through the
  official runner path.
- **Allowed model tier:** GPT-5.5 only (runner path), with `batch-no-commit` when needed.
- **Allowed actions:** `make batch`, review summary, ledger/status update, commit gating.
- **Forbidden actions:** direct execution bypasses, app behavior ownership without bounds,
  proof claim inflation, nested runner calls.
- **Proof requirements:** existing queue/registry truth, focused validation, and final `xcode` proof
  where implementation touched non-doc files.
- **Continuation rule:** continue only after accepted evidence and clean continuation gate outcome.
- **Escalation rule:** escalate to senior if branching, cleanup posture, or final-commit disputes appear.

### parallel_readonly_prep
- **Purpose:** Preflight, docs-only prep, candidate mapping, and deterministic routing.
- **Allowed model tier:** GPT-5.4-mini / unknown tier after runner authorization.
- **Allowed actions:** read-only prep notes, queue classification, test-router lookup, lane mapping.
- **Forbidden actions:** implementation, source mutation, architecture/canon rewrites, claims ownership of commit.
- **Proof requirements:** file read-only audit trail and deterministic script output.
- **Continuation rule:** may run in parallel for multiple queued candidates.
- **Escalation rule:** escalate to GPT-5.5 on any conflict with active truth or stale state.

### gpt_5_4_mini_bounded_patch_candidate
- **Purpose:** GPT-5.4-mini-safe implementation patch scope when explicitly approved by Phase01 / runner.
- **Allowed model tier:** GPT-5.4-mini with parent-approved boundary and no architecture or canon ownership.
- **Allowed actions:** modify only approved files in the patch boundary, run required local checks.
- **Forbidden actions:** production Swift source, route/raw-value edits, dependency/signing/workflow edits,
  release/readiness claims.
- **Proof requirements:** required validation set from batch prompt + local checks.
- **Continuation rule:** one bounded patch attempt; stop for unresolved blockers.
- **Escalation rule:** unresolved risk, proof conflict, or scope ambiguity escalates to GPT-5.5 repair lane.

### senior_judgment_required
- **Purpose:** Decisions that affect source truth, claims, commit eligibility, cleanup posture, or
  lane ownership.
- **Allowed model tier:** GPT-5.5 only.
- **Allowed actions:** final validation judgment, truth-order enforcement, gate interpretation.
- **Forbidden actions:** GPT-5.4-mini/unknown-tier deciding acceptance, final-status semantics, or
  queue reorder without evidence.
- **Proof requirements:** source truth and state evidence with explicit no-claim boundaries.
- **Continuation rule:** only GPT-5.5 may authorize resume/continue.
- **Escalation rule:** always escalates to senior desk by default for architecture, proof posture, or policy conflict.

### repair_or_finalize_required
- **Purpose:** repair, finalize, and formal closeout routing after non-green outcomes.
- **Allowed model tier:** GPT-5.5 planning/review and repair owner.
- **Allowed actions:** repair prompt generation, focused proof review, bounded retry only if allowed.
- **Forbidden actions:** direct rerun loops, nested child attempts, rerunning already accepted work.
- **Proof requirements:** run artifact review and gap-to-risk diff.
- **Continuation rule:** no forward batch execution while unresolved repair/finalization is active.
- **Escalation rule:** unresolved repair must be documented and escalated through repair prompt path.

### blocked_hard_red
- **Purpose:** immediate hard stop for prohibited or unsafe actions.
- **Allowed model tier:** detection model/runner checks by any tier; closure/decision by GPT-5.5.
- **Allowed actions:** classify and report blockers, preserve evidence.
- **Forbidden actions:** any file mutation or continuation command while blocked.
- **Proof requirements:** hard-block evidence plus rollback command.
- **Continuation rule:** halt batch execution until explicit owner unblock.
- **Escalation rule:** route directly to GPT-5.5 with hard-red record in report.

### defer_with_ledger
- **Purpose:** track known yellow/repeated, non-blocking risks outside the current child batch.
- **Allowed model tier:** GPT-5.4-mini/unknown-tier may log and propose quarantine entries.
- **Allowed actions:** classify and route known caveats to ledger; avoid repeat investigation.
- **Forbidden actions:** declaring resolved status without proof or masking unresolved caveats.
- **Proof requirements:** ledger + next-batch relevance check.
- **Continuation rule:** continue focused batches unless the caveat blocks the current lane.
- **Escalation rule:** move unresolved caveats into explicit no-claim boundaries or escalation list.

## Governance constraints

- GPT-5.4-mini/unknown-tier models may prepare, classify, summarize, map tests, and execute bounded patches
  only after runner authorization.
- GPT-5.4-mini/unknown-tier models may not decide source truth, architecture, privacy/legal posture,
  release posture, cleanup authority, deletion strategy, or final commit eligibility.
- GPT-5.5 is required for senior-only gates and any final commit path decisions.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->

> Supporting note: This file supports current Ambitions work but does not override `docs/truth/`.

# Codex Self-Healing Execution Authority

Status: Active supporting process policy
Owner: Codex process governance
Authority: `docs/truth/CODEX_PROCESS_TRUTH.md`
Scope: Repo-OS/process/metadata repair only

## Purpose

Codex may repair bounded Yellow-safe process blockers and continue in the same run when the repair is local, minimal, validated, and does not weaken guardrails.

This policy exists for repairable process failures before or around issue execution, such as stale prompt wording, stale runner metadata, stale active-batch metadata, or missing guard metadata when the correct owner is already established by current repo authority.

This policy does not prove app behavior, build success, test success, accessibility, performance, privacy/legal approval, release readiness, TestFlight readiness, or App Store readiness.

## Yellow-Safe Classes

- Stale prompt text causing a guard false positive before source files are touched.
- Stale issue text conflicting with active `docs/truth/*`.
- Missing or stale runner skill/process metadata.
- Stale active-batch metadata.
- Stale guard registry, canonical-owner, concept-lock, or coverage metadata.
- Missing owner/coverage metadata when the correct owner is already known from current audits or active registries.
- Validation command selection problems.
- Missing proof artifact shell when repo convention is clear.
- Old wording in process/supporting files that is clearly superseded by active truth files.
- Direct-main metadata drift when direct main was explicitly authorized.

## Red-Class Stops

- Guard weakening would be required.
- Product canon is ambiguous or would require product/design/moat truth changes.
- App source or app tests would change outside the issue scope.
- Locked concept source changes need owner authorization.
- Privacy, security, legal, release-readiness, signing, hosted CI, dependency, or external-service implications appear.
- Build/test failures are caused by the patch and are not fixable inside issue scope.
- Repo state is unsafe, direct-main conflicts, or user changes would be overwritten.
- The repair would change app behavior outside the current issue.
- The same blocker repeats after the bounded repair attempt.

## Allowed Boundaries

- `.codex/**`
- `scripts/ambitions-codex-train.sh`
- `scripts/ambitions-*guard*.py`
- `scripts/ambitions-*coverage*.py`
- `docs/codex/**`
- runner, skill, and process docs
- active-batch metadata
- guard, owner, concept-lock, and coverage registries
- `docs/truth/CODEX_PROCESS_TRUTH.md` only when process authority must be recorded
- `AGENTS.md` only when agent-facing exposure is required

## Disallowed Boundaries

- `Native/**`
- `Sources/**`
- `AppUI/**`
- app source
- app tests
- `project.yml`
- `Package.swift`
- privacy manifests
- entitlements
- product truth
- design truth
- moat truth
- release readiness truth, except explicit no-readiness non-claim wording when required
- user data
- signing
- hosted CI
- runtime dependencies
- external AI/backend paths
- app behavior outside the current issue scope

## Required Behavior

1. Classify the blocker as Yellow-safe or Red-class before repair.
2. Repair only the smallest safe repo-OS/process/metadata issue.
3. Validate the repair with the relevant guard, script, syntax, registry check, or targeted prompt retry.
4. Retry the original issue in the same run only if the retry remains inside the original issue scope and all fail-closed guards remain active.
5. Report both the self-heal result and the original issue result.
6. Commit directly to main only when the human explicitly authorized direct main and all acceptance gates pass.
7. Update Linear with self-heal evidence and the issue result, or produce paste-ready Linear evidence when Linear writes are unavailable.

## Guard Preservation

- Canonical owner coverage remains active.
- Parallel implementation guard remains active.
- Concept-lock protections remain active.
- Post-change guard remains blocking for real source boundary violations.
- Self-heal cannot authorize locked source changes.
- Guards must not be skipped, disabled, broadened, or made permissive to turn Red into Green.

## Direct Main

Direct-main execution is allowed only when the human explicitly authorizes it. If direct-main status, push access, or repo cleanliness is unsafe, stop Yellow before changes or before publication, whichever boundary is encountered.

## Reporting

Self-heal reporting must include:

- Green / Yellow / Red status
- files changed
- blocker classification
- self-heal summary
- validation commands and results
- guard reports
- retry result
- rollback command
- no-readiness-claim boundary

Linear updates must not mark the original implementation issue Done unless that issue itself was completed and validated. A self-heal issue may close only when this policy install or repair scope passes its own acceptance gates.

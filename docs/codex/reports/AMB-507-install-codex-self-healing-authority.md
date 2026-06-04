# AMB-507 Install Codex Self-Healing Authority

Status: Green
Date: 2026-06-04
Branch: main

## Scope

Repo-OS/process-governance repair only. No app source, app tests, project files, package manifests, privacy manifests, entitlements, product truth, design truth, moat truth, release truth, or app behavior were changed.

## Policy Installed

Bounded Codex self-healing authority is now recorded in `docs/truth/CODEX_PROCESS_TRUTH.md`, exposed to agents in `AGENTS.md`, summarized in `.codex/os/AMBITIONS_OPERATING_CONTEXT.md`, and expanded in `docs/codex/CODEX_SELF_HEALING_EXECUTION_AUTHORITY.md`.

The runner context in `scripts/ambitions-codex-train.sh` now tells child phases to classify Yellow-safe repo-OS/process/metadata blockers, repair only the smallest allowed process surface, validate, and retry only when fail-closed guards remain active.

## Yellow-Safe Classes

- Stale prompt text causing guard false positives before source files are touched.
- Stale issue text conflicting with current truth files.
- Missing or stale runner skill/process metadata.
- Stale active-batch metadata.
- Stale guard registry, canonical-owner, concept-lock, or coverage metadata.
- Missing owner/coverage metadata when the correct owner is already known from current audits or active registries.
- Validation command selection problems.
- Missing proof artifact shell when repo convention is clear.
- Old wording in process/supporting files that is clearly superseded by active truth files.
- Direct-main metadata drift when the human explicitly authorized direct main.

## Red-Class Stops

- Guard weakening would be required.
- Product canon is ambiguous or would require product/design/moat truth changes.
- App source or app tests would change outside the issue scope.
- Locked concept source changes need owner authorization.
- Privacy, security, legal, release-readiness, signing, hosted CI, dependency, or external-service implications appear.
- Build/test failures are caused by the patch and are not fixable inside scope.
- Repo state is unsafe, direct-main conflicts, or user changes would be overwritten.
- The repair would change app behavior outside the current issue.
- The same blocker repeats after the bounded repair attempt.

## Guard Protections Preserved

- Canonical owner coverage remains active.
- Parallel implementation guard remains active.
- Concept-lock protections remain active.
- Post-change guard remains blocking for real source boundary violations.
- Self-heal cannot authorize locked source changes.
- Guards must not be skipped, disabled, broadened, or made permissive to turn Red into Green.

## AMB-477 Retry Readiness

Champion coverage:

```text
python3 scripts/ambitions-champion-coverage-check.py --batch AMB-477
STATUS: GREEN
```

Clean pre-guard retry:

```text
python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-477 --prompt <clean-temp-amb-477-prompt> --batch-type source-changing
Status: GREEN
Concepts detected: Capture, Motion, Time, Today, You
Old-term violations: 0
Locked concepts touched: none
Blocked concept violations: 0
Required next action: continue
```

The first cleaned prompt attempt intentionally demonstrated the false-positive class: references to old forbidden wording and locked support paths caused a Red pre-guard before files were touched. The successful retry removed stale prompt wording and locked-path text without changing guard code.

## Validation

- `git branch --show-current`: `main`
- `git status --short`: changed files were limited to repo-OS/process docs and runner context during validation.
- `git log --oneline -12`: inspected current direct-main history.
- `git diff --check`: passed.
- `git diff --name-only`: confirmed no app source/test/project/package/privacy/entitlement paths changed.
- `git diff --stat`: inspected.
- `bash -n scripts/ambitions-codex-train.sh`: passed.
- `python3 -m py_compile scripts/ambitions-champion-coverage-check.py scripts/ambitions-parallel-implementation-guard.py`: passed.
- `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-477`: Green.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-477 --prompt <clean-temp-amb-477-prompt> --batch-type source-changing`: Green.
- `rg -n "self-heal|self healing|Yellow-safe|Red-class|direct main|direct-main|guard weakening|locked concept|human authorization|AMB-477" .codex scripts docs AGENTS.md 2>/dev/null`: policy discoverable.

## Missing Supporting Files

The user-requested audit references were checked, but these paths do not exist in the current checkout:

- `docs/codex/POST_BATCH_GATE_REGISTRY.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`

Current active-batch metadata instead points to newer sequence authority files that were inspected where present.

## Proof Boundaries

This is process proof only. It does not prove app build success, app test success, accessibility validation, performance validation, device validation, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, AMB-477 implementation, AMB-478 readiness, or app behavior changes.

## Rollback

After commit, rollback with:

```bash
git revert <AMB-507-commit-sha>
```

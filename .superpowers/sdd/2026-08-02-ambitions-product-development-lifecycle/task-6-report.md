# Task 6 report — lifecycle creation and state transitions

## Status

Completed. Task 6 adds deterministic lifecycle creation, sealing, dual review,
stale/reopen, and supersession transitions. The implementation is Python
standard library only and remains bounded to the requested transition module,
focused tests, and this report.

## TDD evidence

### RED

`test_transitions.py` was created before production code. The required focused
command failed at import because the transition module did not exist:

```text
ModuleNotFoundError: No module named 'product_docs.transitions'
Ran 1 test in 0.000s
FAILED (errors=1)
```

The tests name observable contract breaks across real temporary Git
repositories: unstable identity, overwrite, missing upstream authority,
untracked or dirty sealing inputs, non-atomic failure, invalid review bindings,
invalid blocker semantics, duplicate review IDs, uncommitted reviewed bytes,
incorrect revision increments, lost history, and authority-body mutation during
supersession.

### GREEN

After the minimal transition implementation and one test-only correction for
macOS `/var` versus `/private/var` path aliases, the focused suite passed:

```text
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_transitions.py' -v
Ran 12 tests in 8.409s
OK
```

## Implementation

- Normalizes initiative names through Unicode decomposition to lowercase ASCII
  kebab case and derives stable `PD-YYYY-MM-UPPERCASE-SLUG` initiative and
  phase document IDs. Explicit IDs must match the derived identity exactly.
- Creates revision-one drafts at the canonical path from the immutable active
  template without overwrite, recording exact committed active package,
  template, and `HEAD` baseline identity.
- Requires Scope and Design to bind the exact committed, valid, passed upstream
  lifecycle document, including revision, contract hash, commit, and historical
  package verification. Reduced entry instead requires a strict JSON object
  containing nonempty rationale and validated typed authority records.
- Exposes `is_committed_exact()` as a byte-for-byte `HEAD:path` comparison used
  by downstream creation and review handoff guards.
- Seals only tracked drafts. It rejects dirty operational package, evidence,
  inputs, dependencies, and declared owner paths; verifies active and historical
  package/template identity; validates complete document structure; derives the
  non-weakenable freshness set; clears both review lanes; computes the contract
  hash; appends a seal event; and performs one atomic target replacement only
  after every check succeeds.
- Parses review JSON with an exact field allowlist, typed lanes/verdicts, stable
  IDs, UTC timestamps, exact revision/hash binding, five formal finding arrays,
  next-phase output, and path/impact/rationale drift assessments. Content and
  consumer lanes advance only through their legal states; failure requires
  blockers, while pass forbids them.
- Appends review history in fixed field order and refuses duplicate review IDs.
  Reviews require target bytes committed exactly at `HEAD`.
- Persists `passed -> stale`, and permits only `needs-revision` or `stale` to
  reopen. Reopen increments revision exactly once, clears the seal, freshness,
  and both review lanes, optionally validates replacement baseline/input
  bindings, and preserves append-only history.
- Supersession records replacement, reason, and timestamp only in excluded
  history while changing status metadata; authority-bearing body sections are
  byte-preserved.

## Files

- `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py`
- `.agents/skills/ambitions-product-development-lifecycle/tests/test_transitions.py`
- `.superpowers/sdd/2026-08-02-ambitions-product-development-lifecycle/task-6-report.md`

## Validation

```text
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_transitions.py' -v
Ran 12 tests ... OK

python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -v
Ran 67 tests ... OK

ruff check <transition implementation and tests>
All checks passed!

ruff format --check <transition implementation and tests>
2 files already formatted

python3 -m py_compile .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/*.py
success

git diff --check
success
```

## Scope and concerns

No workflows, repository gates, approval receipts, product canon, or unrelated
source were changed. Task 7 still owns repository drift consumption and the
consumer PASS semantic-assessment integration; Task 8 still owns CLI parsing,
exit codes, and JSON command envelopes. This task establishes transition-domain
behavior only and makes no implementation, merge, visual, device, accessibility,
or release-readiness claim.

## Fix round 1 — upstream identity and phase-aware authority

All three Important review findings are corrected without widening Task 6.

### Corrections

1. Standard upstream binding now proves all parts of the adjacent-phase
   contract: the upstream file must use the canonical path for the target
   initiative, carry the same `initiative_id`, and carry the exact expected
   adjacent-phase `document_id`. A valid passed Research from another initiative
   can no longer create Scope, and an alias path cannot substitute for the
   canonical Research path. The valid same-initiative path remains covered.
2. Reduced-entry typed authority validation now receives the target document
   phase. `approved-design` is permitted only for reduced Design entry and is
   rejected for Scope. Research reopen explicitly rejects both lifecycle input
   and reduced-authority rebinding instead of falling through to Scope-upstream
   handling.
3. Active package identity now returns the manifest's exact `skill_version`.
   Creation writes that value into document metadata, while seal rejects any
   document metadata mismatch before mutation; `999.0.0` is covered and leaves
   target bytes unchanged.

The Minor observation about clean-package checks scanning test-only files is
deferred exactly as requested. No workflow file changed.

### Fix-round TDD evidence

The four new focused regressions were written and run before production edits.
RED was the expected four behavioral failures:

```text
test_new_scope_binds_only_same_initiative_canonical_research ... FAIL
  AssertionError: ProductDocsError not raised
test_reduced_scope_rejects_approved_design_authority ... FAIL
  AssertionError: ProductDocsError not raised
test_research_reopen_rejects_input_rebinding ... FAIL
  AssertionError: 'upstream-not-passed' != 'invalid-entry-authority'
test_seal_refuses_document_skill_version_mismatch ... FAIL
  AssertionError: ProductDocsError not raised

Ran 16 tests in 12.452s
FAILED (failures=4)
```

After the bounded transition changes, focused GREEN was:

```text
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_transitions.py' -v
Ran 16 tests in 12.255s
OK
```

### Fix-round validation

```text
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -v
Ran 71 tests in 13.884s
OK

ruff check <transition implementation and tests>
All checks passed!

ruff format --check <transition implementation and tests>
2 files already formatted

python3 -m py_compile .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/*.py
success

git diff --check
success
```

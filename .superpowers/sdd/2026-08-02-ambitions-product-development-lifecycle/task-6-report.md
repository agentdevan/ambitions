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

# Task 7 report — committed freshness and Codex consumption

## Status

Completed. Task 7 adds read-only committed repository consumption, stable
diagnostics and drift classification, and consumer-PASS enforcement against the
current `HEAD`. The implementation remains Python standard library only and
does not add workflows, gates, receipts, or product/canon changes.

## TDD evidence

### RED 1

The first focused test was written before `consume_document()`. The focused
command failed at import because the consumer API did not exist:

```text
ImportError: cannot import name 'consume_document' from 'product_docs.validation'
Ran 1 test in 0.000s
FAILED (errors=1)
```

The minimal committed-exact implementation made that one test green.

### RED 2

The remaining committed-input, historical binding, drift, and consumer review
tests were then added before their production behavior. The expanded focused
suite produced the expected missing-behavior failures: package/evidence and
historical blockers were absent, `ConsumptionReport` had no relevant-path
fields, current upstream drift was not checked, and invalid consumer
assessments were accepted. The run reported six failures and three errors.

### GREEN

After the bounded implementation and test-fixture corrections for macOS
`/var` versus `/private/var` aliases, focused GREEN was:

```text
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_consume.py' -v
Ran 8 tests in 13.818s
OK
```

## Implementation

- Adds `GitRepository.is_committed_exact()` for regular, tracked, byte-exact
  `HEAD:path` checks without shell command construction.
- Adds additive `ConsumptionReport` fields for ordered diagnostics and sorted
  relevant/unrelated changed paths while preserving the existing report API.
- Implements `consume_document()` in the required order: canonical identity,
  committed target, clean committed package, structure/hash/review state,
  reachable historical package and current compatibility, current and bound
  typed inputs, current/baseline evidence hashes, and baseline-to-HEAD drift.
- Requires lifecycle and approved-design upstreams to be valid passed documents
  at their exact bound commit, revision, contract hash, and authority ID; their
  current committed revision/hash/status must still match.
- Treats exact freshness paths and descendants using the conservative
  `freshness + "/"` prefix rule. Relevant and unrelated paths retain Git's
  sorted stable order. Unrelated drift is reported without semantic review;
  relevant drift emits only `semantic-review-required` after deterministic
  validation.
- Reuses existing source, authority-class, canon-delta, source-owner, and
  traceability validation. Version-one source recheck triggers remain required
  free-text semantic inputs; no unsupported expiry grammar is invented.
- Consumer PASS reruns consumption against current `HEAD`, rejects every
  deterministic blocker, requires exactly one assessment per relevant path,
  rejects duplicates/extras/material impact, and appends accepted nonmaterial
  assessments in sorted path order.
- The written PASS remains intentionally uncommitted. Existing
  committed-exact checks therefore prevent downstream creation or consumption
  until that reviewed state is committed.

## Files

- `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/models.py`
- `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/repository.py`
- `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py`
- `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py`
- `.agents/skills/ambitions-product-development-lifecycle/tests/test_consume.py`
- `.superpowers/sdd/2026-08-02-ambitions-product-development-lifecycle/task-7-report.md`

## Validation

```text
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_consume.py' -v
Ran 8 tests ... OK

python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -v
Ran 79 tests ... OK

ruff check <Task 7 implementation and tests>
All checks passed!

ruff format --check <Task 7 implementation and tests>
5 files already formatted

python3 -m py_compile .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/*.py
success

git diff --check
success
```

## Scope and concerns

No workflow, repository gate, approval receipt, product canon, application
source, or generated Xcode state changed. The only file beyond the brief's
listed implementation modules is `models.py`, changed additively because the
predeclared report lacked the required relevant/unrelated path outputs. Task 8
still owns CLI parsing, JSON envelopes, and `--as-of` input validation.

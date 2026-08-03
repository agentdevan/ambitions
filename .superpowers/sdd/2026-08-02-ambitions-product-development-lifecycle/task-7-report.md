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
  traceability validation. Version-one source recheck triggers retain their
  review prose while explicit dates and access-date-relative day durations are
  evaluated deterministically.
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
still owns CLI parsing, JSON envelopes, and the `--as-of` command-line surface.

## Fix round 1 — Important review findings

All four Important findings are corrected without widening Task 7.

### Corrections

1. Consumption now validates `as_of` and external Source-ledger access dates.
   Explicit `After N days` triggers expire relative to the recorded access date;
   explicit ISO trigger dates fire on or after that date. Both blockers retain
   exact `Source ledger` section and `SRC-*` identifier context.
2. Current lifecycle and approved-design upstreams now run full
   `validate_document(..., repository_root=...)` validation. A committed body
   tamper with unchanged stored revision/hash/status is rejected as
   `contract-hash-mismatch` plus `current-upstream-invalid`; binding mismatch is
   still reported independently when revision or hash also differs.
3. Canonical path spelling and committed-exact repository handoff are checked
   before TOML parsing. Malformed untracked canonical bytes report
   `document-not-committed-exact`; malformed committed noncanonical bytes report
   `noncanonical-document-path`, with metadata-free stable reports rather than
   parser leakage.
4. Consumption retains original `Diagnostic` objects, including path, section,
   identifier, and remediation. Consumer PASS now raises those exact diagnostics
   instead of collapsing them into a generic code/message wrapper.

### Fix-round TDD evidence

The five new focused regressions were written and run before production edits.
RED was the expected three behavioral failures and one parser-order error:

```text
test_consume_blocks_expired_and_triggered_external_sources ... FAIL
test_consume_checks_handoff_before_parsing_untracked_malformed_target ... ERROR
test_consume_revalidates_committed_current_upstream_body ... FAIL
test_consumer_pass_preserves_consumption_diagnostic_context ... FAIL

Ran 12 tests in 20.453s
FAILED (failures=3, errors=1)
```

After the bounded corrections and one pre-existing expectation adjustment so
full upstream invalidity and revision mismatch are both reported, focused GREEN
was:

```text
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_consume.py' -v
Ran 12 tests in 21.249s
OK
```

The complementary committed-noncanonical pre-parse regression and a final
red/green case proving malformed explicit trigger dates produce a stable
`invalid-source-recheck-date` diagnostic bring the final focused count to 14.

### Fix-round validation

```text
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -v
Ran 85 tests in 38.299s
OK

ruff check <Task 7 implementation and tests>
All checks passed!

ruff format --check <Task 7 implementation and tests>
3 files already formatted
```

The deferred Minor observations remain deferred exactly as requested: package
cleanliness still includes test paths, and downstream committed-PASS behavior
continues to rely on the existing committed-exact guard. No workflow changed.

## Fix-round re-review — NEEDS REVISION

### Important finding

1. `approved-design` inputs cannot pass consumption. The reduced Design-entry
   contract accepts `approved-design` as an external committed authority record
   with its own revision and contract hash (see `transitions.py:247-305`), not
   as a lifecycle document. `consume_document()` nevertheless routes it through
   `parse_document()` and requires lifecycle `PASSED` metadata
   (`validation.py:1151-1175`). A valid committed approved-design Markdown
   authority will therefore deterministically produce
   `upstream-not-passed-at-bound-commit`, preventing every reduced-Design
   handoff from receiving Consumer PASS. Validate this input against its
   declared external-authority contract and current committed bytes/revision/
   hash, or restrict the input kind if lifecycle-document semantics are truly
   required; add an end-to-end passing reduced-Design consumption regression.

### Verified corrections

- External source expiry/recheck checks use `as_of`, retain Source-ledger
  section and source ID context, and consumer PASS rethrows the original
  diagnostics.
- Canonical-path and exact-HEAD checks occur before parsing.
- Current lifecycle upstreams receive full repository validation.

### Re-review validation

```text
test_consume.py: 14 tests passed
full lifecycle suite: 85 tests passed
ruff check: passed
ruff format --check: passed
git diff --check (review range): passed
```

## Fix round 2 — approved-design authority consumption

The remaining Important finding is corrected without changing lifecycle-document
semantics or widening Task 7.

### Correction

`consume_document()` now branches typed inputs before document parsing:

- `approved-design` validates a nonempty exact authority ID, positive integer
  revision, lowercase prefixed contract hash, reachable bound commit, committed
  current file, and byte equality between the bound commit and current `HEAD`;
- a malformed binding reports `invalid-approved-design-binding`;
- committed authority drift reports
  `current-approved-design-binding-mismatch` and still appears in freshness
  drift;
- only `lifecycle-document` inputs are parsed as lifecycle documents and
  required to be valid `passed` revisions.

The declared approved-design revision/hash/authority tuple remains sealed by the
target Design contract hash. The external Markdown authority is not assigned
unsupported lifecycle metadata or status requirements.

### Fix-round TDD evidence

The valid and invalid reduced-Design tests were written before the typed branch.
After correcting one missing test import, RED was the expected two behavioral
failures:

```text
test_reduced_design_approved_authority_consumes_and_consumer_passes ... FAIL
  ('upstream-not-passed-at-bound-commit',) != ()
test_reduced_design_rejects_invalid_approved_authority_binding ... FAIL
  current-approved-design-binding-mismatch not found

Ran 2 tests in 3.107s
FAILED (failures=2)
```

Focused GREEN after the minimal branch was:

```text
python3 -m unittest -v \
  test_consume.ConsumptionTests.test_reduced_design_approved_authority_consumes_and_consumer_passes \
  test_consume.ConsumptionTests.test_reduced_design_rejects_invalid_approved_authority_binding
Ran 2 tests in 4.121s
OK
```

The passing end-to-end case creates a reduced-entry Design from committed
approved Markdown, completes/seals/commits/content-reviews it, receives a clean
consumption report, and records Consumer PASS. The invalid case proves both
committed authority-byte drift and a zero revision are rejected.

### Fix-round validation

```text
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_consume.py' -v
Ran 16 tests in 26.543s
OK

python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -v
Ran 87 tests in 41.669s
OK

ruff check <Task 7 implementation and tests>
All checks passed!

ruff format --check <Task 7 implementation and tests>
2 files already formatted
```

No workflow or gate changed. The previously deferred Minor observations remain
deferred.

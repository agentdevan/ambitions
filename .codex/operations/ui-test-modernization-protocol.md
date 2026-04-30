# UI Test Modernization Protocol

## When To Use

Use for Ambitions UI test failures, F-series UI batches, accessibility
identifier changes, or redesigns that affect smoke tests.

## Required Inputs

- `docs/canon/Ambitions_3_0_UI_Test_Contract.md`
- Failing test name and log excerpt.
- Owning primitive/surface docs.
- Current accessibility identifiers in source.

## Exact Steps

1. Classify the test class.
2. Identify user promise, owning canon, primitive, and surface.
3. Classify the failure reason before editing.
4. Prefer fixture or expectation updates when canon changed.
5. Preserve stable accessibility identifiers unless contract migration is
   explicitly approved.
6. Do not delete a test without replacement or retirement note.
7. Rerun focused UI test before broader suite.

## Output Artifacts

- UI test classification.
- Updated test or retirement note.
- Focused validation result.

## Stop Conditions

- Failure might be product bug and no owner doc is clear.
- Fix would require product redesign beyond the batch.
- Simulator/environment failure prevents classification.

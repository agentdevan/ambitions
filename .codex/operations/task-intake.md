# Task Intake

For safe Ambitions work requests, capture:

- desired outcome
- target repo area or feature surface
- whether the task is plan-only, plan-plus-implement, validate-only, docs reconciliation, or release-hardening
- constraints to preserve
- requested stop conditions if partial support is acceptable
- expected validation level

For active-batch transformation work, also capture:

- active batch number and name
- batch archetype from `transformation-validation-matrix.md`
- whether the pass is `plan`, `implement`, or `closeout`
- the required touch budget
- whether human/manual signoff is acceptable if a bounded combined UI flake remains
- whether the fixed frontend regression pack must be rerun in full or only the affected slice

## Ambitions Examples

- `Implement notification-originated capture support in the existing capture domain, but stop if runtime ingestion would require a new seam.`
- `Plan and wire a Share Extension through XcodeGen, then report what remains unverified.`
- `Do a release-hardening pass on this branch and tell me what still blocks merge.`
- `Run the Batch 46 plan pass only. Reconcile control truth first, define the touch budget, and do not start implementation.`
- `Run the Batch 47 closeout pass only. Use the Goal Detail checklist, the focused regression pack, and stop if only a known flake remains.`

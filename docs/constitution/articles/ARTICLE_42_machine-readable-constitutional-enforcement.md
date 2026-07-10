# Article 42 — Machine-readable constitutional enforcement

## ENFORCEMENT-001 — Normative registries

The following are normative annexes when present and valid:

```text
docs/constitution/opportunity-register.json
docs/constitution/laws.json
docs/constitution/law-source-map.json
docs/constitution/law-test-map.json
docs/constitution/scenarios.json
docs/constitution/performance-budgets.json
docs/constitution/data-classification.json
docs/constitution/dependency-graph.json
```

They may add implementation specificity but may not weaken the parent Constitution or this annex.

## ENFORCEMENT-002 — Registry integrity

Every launch-required opportunity has:

- unique stable ID,
- priority,
- law mapping,
- Linear owner,
- source owner,
- dependency mapping,
- required tests,
- proof obligations,
- status,
- claim ceiling.

## ENFORCEMENT-003 — Automated audit

The constitutional audit fails on duplicate IDs, missing dependencies, orphan law/source/test mappings, incorrect P0/P1 counts, missing required fields, or invalid launch-gate status.

## ENFORCEMENT-004 — PR compliance manifest

Every substantive PR reports laws and opportunities touched, source owners, migrations, data classifications, tests run/not run, proof, residual risks, rollback, and exact claim ceiling.

---

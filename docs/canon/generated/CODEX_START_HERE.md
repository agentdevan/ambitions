# Codex Start Here

> Generated navigation for Ambitions product canon. Do not edit by hand.

- Canon revision: `2`
- Documents: `66`
- Requirements: `466`

Canon defines product and engineering direction. It does not authorize
repository work and creates no task, pack, signature, approval, attestation,
or merge ceremony.

## Fast route

1. Read [the Constitution](../CONSTITUTION.md) for product mission, IA,
   object/runtime invariants, privacy, accessibility, and native-platform law.
2. Use the compiler query command to locate the exact owning specification,
   requirement, concept, dependencies, and source-owner hints.
3. Read that owning specification plus current source and tests; canon does not
   establish current implementation state.
4. Implement the smallest coherent change and run changed-scope engineering
   validation.

```sh
python3 scripts/ambitions-canon.py query --id LAW-LOCAL-AUTHORITY-001
python3 scripts/ambitions-canon.py query --concept surface.today.first-viewport
python3 scripts/ambitions-canon.py query --spec SURFACE-TODAY
python3 scripts/ambitions-canon.py query "migration replay integrity"
```

## Product and design entry points

- [Full canon index](INDEX.md)
- [Canon README and reading order](../README.md)
- [Visual System R1](../design/VISUAL_SYSTEM_R1.md)
- [Wave 1 Foundation Closure](../design/VC_WAVE_1_FOUNDATION_CLOSURE.md)
- [Wave 2 Surface and Journey Closure](../design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md)
- [Wave 3 Accessibility and Content Stress Closure](../design/VC_WAVE_3_ACCESSIBILITY_STRESS_CLOSURE.md)
- [Canonical UX Blueprint](../migration/UX_BLUEPRINT.md)
- [Object Boundary Matrix](object-boundary-matrix.md)
- [Requirement graph](requirement-graph.json)
- [Machine index](canon-index.json)

## Compiler maintenance

```sh
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py check
```

`build` writes deterministic navigation outputs. `check` detects concrete
parse, identity, dependency, concept, link, structured-data, and generated
drift defects. Neither command performs authorization or process enforcement.

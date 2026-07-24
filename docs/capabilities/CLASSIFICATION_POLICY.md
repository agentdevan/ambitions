# Capability Candidate Classification Policy

Status: **non-normative program control**

This policy governs Phase B separation of repository-derived candidate hints. It does not alter product canon, approve capabilities, or infer implementation status.

## Purpose

Repository archaeology intentionally harvests broadly. The raw inventory therefore contains product promises alongside requirements, behaviors, objects, surfaces, systems, implementation mechanisms, design expression, projects, and evidence. Classification prevents those categories from being silently promoted into the Capability Atlas.

## Allowed classifications

| Classification | Meaning | Capability treatment |
|---|---|---|
| `capability` | Durable person-facing product promise that may remain meaningful across implementation changes | Qualified for taxonomy and reconciliation |
| `behavior` | Bounded interaction, mutation, transition, or state response | Preserved as supporting behavior |
| `requirement` | Normative law, invariant, acceptance rule, or constraint | Preserved as supporting requirement |
| `object` | Canonical domain object or object identity | Preserved as supporting object |
| `surface` | Root, global presentation facility, depth, or presentation owner | Preserved as supporting surface |
| `system` | Runtime, service, engine, persistence, scheduling, synchronization, or other enabling subsystem | Preserved as supporting system |
| `implementation` | Code, API, schema, module, framework, or platform mechanism | Preserved as implementation evidence |
| `design_language` | Visual, material, layout, typography, motion, or interaction expression | Preserved as design expression |
| `project` | Plan, task, campaign, remediation program, review package, or delivery container | Preserved as program provenance |
| `evidence` | Test, audit, command, artifact, proof, traceability, or source pointer | Preserved as evidence |
| `ambiguous` | Insufficient evidence for safe promotion or exclusion | Preserved for manual reconciliation |

## Qualification statuses

### `qualified`

The record may proceed into taxonomy, deduplication, and product-promise reconciliation. It is still non-normative and is not approved merely because it qualified.

### `supporting`

The record is not itself a capability. It remains available for Product Genome links, source traceability, requirements, architecture, surfaces, tests, and proof.

### `ambiguous`

The record cannot be safely classified by deterministic rules. It must not be silently deleted or promoted. Manual semantic reconciliation is required.

## Deterministic precedence

Classification follows ordered rules so identical repository state produces identical results:

1. Preserve direct owner seeds as qualified capability candidates without canonizing them.
2. Classify commands, paths, structured-data fields, and proof pointers as evidence.
3. Classify tasks, phases, remediation, gates, and review containers as projects.
4. Treat tests as verification evidence and production source as implementation evidence.
5. Detect canonical objects, surfaces, explicit requirement identities, and enabling systems from source ownership and terminology.
6. Separate visual or interaction expression from product promise.
7. Qualify durable person-facing promises and capability-oriented headings only after the preceding exclusions.
8. Preserve all unresolved records as ambiguous.

## Authority protections

- Production code cannot independently establish a capability.
- Tests cannot independently establish a capability.
- Visual direction cannot independently establish a capability.
- Historical material cannot independently establish current authority.
- A normative requirement can support a capability without being identical to it.
- A direct owner seed qualifies for reconciliation but still requires an explicit owner decision before canonization.
- Classification confidence is a rule-confidence signal, not product confidence or implementation confidence.

## Output contract

Every classified record retains:

- stable candidate ID;
- exact terminology;
- normalized name hint;
- source family, path, and line range;
- authority class;
- evidence fingerprint;
- classification;
- qualification status;
- deterministic reason code;
- rationale;
- confidence;
- preservation disposition.

The classifier never emits a deletion disposition.

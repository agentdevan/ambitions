> Supporting note: This file supports Ambitions primitive promotion governance. It does not override `docs/truth/*`, live source, current validation logs, or release proof.

# Ambitions Primitive Promotion Protocol

Status: Active supporting governance
Scope: Moving a primitive from proposal or prototype into reusable Ambitions UI infrastructure
Owner posture: Process protocol, not source or release proof

## Promotion States

| State | Meaning |
|---|---|
| Proposed | Documented need exists, no source promotion approved. |
| Prototype | Narrow source experiment exists inside one owner surface. |
| Candidate | Prototype has proof and is ready for reuse review. |
| Promoted | Primitive is accepted into shared UI infrastructure with proof and fallback coverage. |
| Rejected | Primitive failed product, source, accessibility, proof, or anti-drift gates. |
| Retired | Primitive was superseded and has a rollback/extraction record. |

## Promotion Sequence

1. Register the primitive in `docs/codex/ambitions_primitive_invention_registry.md`.
2. Inspect existing owners in `Sources/Components/`, `Sources/Theme/`, `AppUI/Sources/`, and active feature source before adding code.
3. Classify the issue as docs-only, source-changing prototype, or promotion.
4. For source-changing work, run the required owner/parallel-implementation guard path when applicable.
5. Prove the primitive serves a named product object and state transition.
6. Record accessibility fallbacks before promotion.
7. Record validation or explain why no focused validation exists.
8. Update the registry status and owner paths.
9. Commit only scoped source/docs/proof artifacts.

## Promotion Evidence

Promotion requires evidence appropriate to the primitive:

- Source path and owning module.
- Before/after rationale or replacement taxonomy entry.
- Accessibility fallback details.
- Focused test, preview, screenshot, or manual proof when available.
- Performance caveat for Canvas, blur, material, shader, animation, or heavy layout primitives.
- Rollback path.

## Shared Infrastructure Targets

Promoted primitives should usually live in one of these areas:

- `Sources/Components/`
- `Sources/Theme/`
- `AppUI/Sources/`
- Existing feature-owner primitive files when reuse is not yet justified

Do not add shared primitives to unrelated feature files just to make reuse convenient.

## Promotion Closeout

Every promotion issue must include:

- Previous state
- New state
- Registry row updated
- Owner source path
- Reuse boundary
- Accessibility fallback
- Validation command/result or not-available reason
- Proof artifact path
- Rollback note

# Ambitions Unified Maximum Polish Frontend Program

Status: active. The repository is in transition mode. Component dispositions
remain gated by UFP-4, and zero-legacy cutover is not yet established.

This program produces one canonical Apple-native frontend without preserving
pre-Owner-Taste visual authority or treating existing shared code as approved
merely because it exists. Current source is inventory evidence until its UFP-4
disposition is recorded. Owner-approved output directions remain bounded design
evidence; they do not by themselves promote repository components, authorize
runtime integration, or prove device/release readiness.

## Program sequence

| Phase | Contract |
| --- | --- |
| UFP-0 | Consolidate authority, program inputs, and proof ceilings. |
| UFP-1 | Select primary frontend directions under current Owner Taste. |
| UFP-2 | Close the 47-screen coverage model. |
| UFP-3 | Resolve the unified design system and cross-root grammar. |
| UFP-4 | Assign every component source one final disposition. |
| UFP-5 | Complete fixture-driven frontend approval. |
| UFP-6 | Integrate the canonical frontend with runtime contracts. |
| UFP-7 | Perform the atomic cutover and prove zero legacy. |
| UFP-8 | Close production, device, accessibility, performance, and release proof. |

## Source and dependency law

The canonical presentation package has four roles:

```text
AmbitionsNativeVisualFoundry (fixture and proof harness)
    -> AmbitionsFlagshipUI
        -> AmbitionsPresentationContracts
        -> AmbitionsFlagshipFoundation
```

`AmbitionsPresentationContracts` and `AmbitionsFlagshipFoundation` are leaves.
Canonical `AmbitionsFlagshipUI` may depend only on those leaves and platform
frameworks. It must not import the Foundry, `AmbitionsRuntime*` implementation
modules, or `AmbitionsDesignSystem`. Runtime adaptation belongs outside the
canonical UI. The production app must link the three canonical products and
must not link the Foundry product.

## Component registry

[`COMPONENT_REGISTRY.json`](COMPONENT_REGISTRY.json) is the machine-readable
inventory contract. While `gate_status` is `pending_ufp_4`, `pending` is the
only honest disposition for current families not yet decided at UFP-4. UFP-4
must replace every pending value with exactly one accepted disposition:

- `promote`: move or retain as canonical production source after review.
- `rebuild`: replace the behavior in canonical source; do not transplant the
  current implementation as authority.
- `fixture-only`: retain only in the Foundry/proof harness; never ship it in the
  production dependency graph.
- `historical`: retain only as non-building historical evidence.
- `delete`: remove without a retained executable copy.

Directory entries classify all matching Swift files. A narrower file entry may
be used when UFP-4 needs a different disposition from its containing family.
Every Swift file under a configured frontend root must be classified; new files
fail the scanner when no registry entry covers them.

Every final row also requires a source owner, replacement, dependency-edge
inventory, nonempty proof requirements, removal condition, and explicit
`production_legacy` classification. All current production frontend source is
legacy in full: a `rebuild` row creates canonical replacement elsewhere, while
the original legacy source still must be deleted. No production-legacy row may
be promoted or survive final mode merely because the deletion manifest missed
its path.

The census includes the app, Share and Widget extension UI, production UI/UI
unit tests, the presentation-package tests, the Native Foundry host, and its UI
proof tests. Extension targets may survive only with rebuilt canonical UI
source; their current frontend files are legacy. Foundry test trees remain
proof-harness candidates, while UFP-4 must split any broad production-test row
until old UI tests and retained runtime tests have distinct dispositions.

## Legacy deletion contract

[`LEGACY_DELETION_MANIFEST.json`](LEGACY_DELETION_MANIFEST.json) records the
known transition surfaces that cannot survive UFP-7. Its presence is not an
instruction to delete them early and is not an accepted UFP-4 component
disposition. UFP-6 may use bounded adapters while runtime integration is being
proved. UFP-7 final mode fails if any configured legacy path, package product,
project target/dependency, import, renderer flag, wrapper, asset, production UI
test, or independently classified production-legacy source remains.

Transition validation checks schema, vocabulary, inventory coverage, manifest
shape, and canonical import direction while allowing inventoried legacy source
to remain:

```sh
python3 scripts/verify_unified_frontend_boundaries.py --mode transition
```

Final validation is intentionally red before the atomic cutover. It additionally
requires completed UFP-4 dispositions, the exact canonical package/project
direction, and zero configured legacy artifacts:

```sh
python3 scripts/verify_unified_frontend_boundaries.py --mode final
```

Neither mode establishes visual acceptance, runtime correctness, Simulator or
physical-device proof, accessibility conformance, performance, release
readiness, or production authorization.

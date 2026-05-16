# Frontend UI Decisions

Status: Active frontend decision control plane  
Authority: subordinate to `docs/truth/*` and upstream of generated frontend implementation prompts

This directory records UI/design decisions as first-class repo objects. A UI decision is the smallest durable unit of frontend intent that can be traced from product/design truth into the visual encyclopedia, AmbitionsDesignSystem primitive expectations, implementation scope, proof requirements, and rollback.

## Purpose

Use this system when a frontend decision should be easy to apply consistently, such as:

- changing a surface composition rule
- locking a visual object behavior
- changing canonical UI copy
- introducing or retiring a design-system primitive
- updating top-level chrome, navigation, receipt, source, trust, closure, or recovery treatment

Do not use this directory as implementation proof. A decision records intent and control-plane propagation only.

## Operating loop

1. Create or update one decision under `frontend/visual-encyclopedia/decisions/active/`.
2. Run `python3 scripts/ambitions-ui-decision-check.py`.
3. Run `python3 scripts/ambitions-ui-decision-sync.py`.
4. Generate an implementation prompt with `python3 scripts/ambitions-ui-decision-implementation-prompt.py --decision <decision-id>`.
5. Execute the generated prompt through the Ambitions runner.
6. Commit code changes only after proof and a receipt exist.

## Commands

Create a new decision:

```bash
python3 scripts/ambitions-ui-decision-new.py --id UID-2026-05-15-example --decision "Describe the UI decision" --surface today_root_reality_meridian
```

Validate all decisions:

```bash
python3 scripts/ambitions-ui-decision-check.py
```

Sync one decision into generated reports:

```bash
python3 scripts/ambitions-ui-decision-sync.py --decision UID-2026-05-15-example
```

Generate a runner-compatible implementation prompt:

```bash
python3 scripts/ambitions-ui-decision-implementation-prompt.py --decision UID-2026-05-15-example
```

Run the generated prompt:

```bash
scripts/ambitions-codex-train.sh UID-2026-05-15-example-IMPLEMENTATION-01 build/reports/ui-decisions/UID-2026-05-15-example/generated-implementation-prompt.md
```

## Required decision fields

Each active decision must declare:

- `id`
- `status`
- `decision_type`
- `decision`
- `reason`
- `owner_surface_ids`
- `affected_encyclopedia_files`
- `affected_design_system_primitives`
- `affected_swift_candidates`
- `proof_required`
- `hard_reds`
- `rollback_expectations`
- `implementation_proof_status`

## Proof boundary

UI decision files, matrices, and generated reports do not prove:

- SwiftUI implementation
- screenshot parity
- device behavior
- accessibility conformance
- hosted CI success
- release readiness
- App Store readiness

Those claims require implementation receipts and current evidence after code changes land.

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-52180060, AMB28-same_source_file_targeted_by_multiple_active_batches-12391598, AMB28-same_source_file_targeted_by_multiple_active_batches-15674448, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-28403787, AMB28-same_source_file_targeted_by_multiple_active_batches-40232383, AMB28-same_source_file_targeted_by_multiple_active_batches-76775145, AMB28-same_source_file_targeted_by_multiple_active_batches-83843232, AMB28-same_source_file_targeted_by_multiple_active_batches-88403236

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, terminology-quarantine
> Dispositions: merge-before-proof, merge-or-sequence-file-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Ambitions Batch Prompt: SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07

## Batch ID

`SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07`

## Runner Command

```bash
scripts/ambitions-codex-train.sh SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07 prompts/batches/SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07.md
```

Equivalent:

```bash
make batch BATCH=SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07 PROMPT=prompts/batches/SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07.md
```

## Model Path

Use the Ambitions runner with this model path:

1. GPT-5.5 planning.
2. GPT-5.4-mini bounded patch.
3. GPT-5.5 review, repair, and final readiness.

## Objective

Make the Signature Visual Instruments doctrine operational across the Visual Encyclopedia and Encyclopedia Frontend OS.

This batch must make future frontend packets, generated implementation prompts, source bindings, drift checks, dashboards, and next-surface queues understand that Ambitions is built around custom living visual instruments, not generic lists or static cards.

This is a control-plane and encyclopedia integration batch. Do not implement production SwiftUI UI in this batch.

## Active Source Truth To Inspect

Inspect first:

- `frontend/visual-encyclopedia/SIGNATURE_VISUAL_INSTRUMENTS.md`
- `frontend/visual-encyclopedia/trace/SIGNATURE_VISUAL_INSTRUMENTS_MATRIX.yaml`
- `frontend/visual-encyclopedia/ENCYCLOPEDIA_TO_FRONTEND_OS.md`
- `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`
- `frontend/visual-encyclopedia/MATURE_APP_SURFACE_UNIVERSE.yaml`
- `frontend/visual-encyclopedia/VISUAL_SOURCE_PROVENANCE_AND_BATCH_LINKAGE.yaml`
- `build/reports/frontend-authority-packets/index.json`
- `build/reports/frontend-implementation-dashboard.json`
- `scripts/ambitions-frontend-authority-packet.py`
- `scripts/ambitions-frontend-implementation-prompt.py`
- `scripts/ambitions-frontend-source-bindings.py`
- `scripts/ambitions-frontend-drift-check.py`
- `scripts/ambitions-frontend-implementation-dashboard.py`
- `scripts/ambitions-frontend-next-surface-queue.py`

## Required Integration

### Packet Generator

Update `scripts/ambitions-frontend-authority-packet.py` so packets include instrument data from `SIGNATURE_VISUAL_INSTRUMENTS_MATRIX.yaml`.

Each top-level destination packet must include:

- owning signature instrument
- shared instrument primitives
- likely source files
- future dedicated visual-object file guidance
- native SwiftUI technique candidates
- forbidden reference-copy behavior
- proof expectations

Major drill-down packets must include either an owning signature instrument or the shared instrument primitive that governs the surface.

### Implementation Prompt Generator

Update `scripts/ambitions-frontend-implementation-prompt.py` so generated prompts require:

- dedicated visual-object SwiftUI components when a surface owns a signature instrument
- typed ViewState backing
- AmbitionTheme and generated token usage
- preview scenarios for relevant states
- implementation receipt and drift-check proof
- no generic list/card-only replacement for instrument-owned surfaces
- no external app layout copying

### Source Bindings

Update `scripts/ambitions-frontend-source-bindings.py` and generated source bindings so relevant rows include:

- `signature_instrument_id`
- `shared_instrument_primitives`
- `visual_object_source_file`
- `future_visual_object_source_file`
- `instrument_implementation_status`

Do not mark an instrument implemented unless source and proof evidence exists.

### Drift Check

Update `scripts/ambitions-frontend-drift-check.py` so it can detect:

- top-level destination surfaces without instrument ownership
- generated packets missing instrument sections
- UI work that substitutes generic card/list structure for an instrument-owned surface
- decorative atmosphere without semantic state
- direct copying of external app language or mechanics

Also fix false-positive scanning where forbidden-pattern declarations inside generated packets are reported as drift warnings.

### surface And Queue

Update `scripts/ambitions-frontend-implementation-dashboard.py` so it reports:

- surfaces by signature instrument
- top-level surfaces missing instrument ownership
- instrument implementation status
- visual-object source readiness
- instrument proof status
- next recommended instrument implementation

Update `scripts/ambitions-frontend-next-surface-queue.py` so it:

- scores instrument-owned P0 surfaces higher
- treats shared instrument primitives as unlockers
- does not duplicate surface IDs
- recommends a real implementation sequence instead of only source-linked roots

## Required Validator

Create:

- `scripts/ambitions-signature-visual-instruments-check.py`

Create reports:

- `build/reports/signature-visual-instruments-check.json`
- `build/reports/signature-visual-instruments-check.md`

The validator must fail if:

- doctrine missing
- matrix missing
- root destination packets omit instrument ownership
- surface lacks instrument status
- next-surface queue duplicates surface IDs
- generated implementation prompt omits instrument requirements
- packet generator ignores the matrix

## Makefile

Add target:

```makefile
signature-visual-instruments-check
```

Ensure `encyclopedia-to-frontend-os-all` runs this target.

## Validation Expectations

Run:

```bash
git diff --check
python3 -m py_compile \
  scripts/ambitions-frontend-authority-packet.py \
  scripts/ambitions-frontend-implementation-prompt.py \
  scripts/ambitions-frontend-source-bindings.py \
  scripts/ambitions-frontend-drift-check.py \
  scripts/ambitions-frontend-implementation-dashboard.py \
  scripts/ambitions-frontend-next-surface-queue.py \
  scripts/ambitions-signature-visual-instruments-check.py \
  scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py

python3 scripts/ambitions-signature-visual-instruments-check.py
make frontend-authority-packets-p0
make frontend-implementation-dashboard
make frontend-next-surface-queue
make encyclopedia-to-frontend-os-final-gate
make encyclopedia-to-frontend-os-all
```

## Hard Red Conditions

Return Red if:

- doctrine or matrix is missing
- root packets omit instrument ownership
- generated implementation prompts omit instrument requirements
- source bindings omit instrument fields for relevant surfaces
- surface lacks instrument status
- next queue duplicates surface IDs
- drift checker still treats packet rule text as live UI drift
- production SwiftUI UI is modified
- implementation, release, device, or public accessibility proof is claimed

## Final Report

Create:

- `build/reports/signature-visual-instruments-encyclopedia-07.md`
- `build/reports/signature-visual-instruments-encyclopedia-07.json`

Final response format:

```text
STATUS: GREEN|YELLOW|RED
Batch: SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07
Summary:
Files changed:
Instrument doctrine:
Instrument matrix:
Packet generator integration:
Implementation prompt integration:
Source binding integration:
Drift checker integration:
surface integration:
Next queue integration:
Validation run:
Remaining gaps:
Implementation proof:
Rollback notes:
Commit:
```

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->

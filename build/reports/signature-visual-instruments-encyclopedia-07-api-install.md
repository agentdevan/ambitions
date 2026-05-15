# Signature Visual Instruments Encyclopedia 07 API Install Report

Status: API_INSTALL_IN_PROGRESS

Batch: `SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07`

## Summary

This report records the direct GitHub API installation of the operational Signature Visual Instruments layer.

The original runner batch prompt remains available at:

- `prompts/batches/SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07.md`

This API installation is applying the same intended repo changes directly through GitHub rather than through the local Ambitions runner process.

## Installed / Updated So Far

- `frontend/visual-encyclopedia/SIGNATURE_VISUAL_INSTRUMENTS.md`
- `frontend/visual-encyclopedia/trace/SIGNATURE_VISUAL_INSTRUMENTS_MATRIX.yaml`
- `scripts/ambitions_signature_visual_instruments.py`
- `scripts/ambitions-frontend-authority-packet.py`
- `scripts/ambitions-frontend-implementation-prompt.py`
- `scripts/ambitions-frontend-source-bindings.py`
- `scripts/ambitions-frontend-implementation-dashboard.py`
- `scripts/ambitions-frontend-next-surface-queue.py`
- `scripts/ambitions-frontend-drift-check.py`
- `scripts/ambitions-signature-visual-instruments-check.py`

## Proof Boundary

This direct GitHub API install cannot execute the local Ambitions runner or local Make targets from inside ChatGPT.

No production SwiftUI UI implementation proof, screenshot proof, device proof, public accessibility conformance proof, TestFlight proof, App Store proof, or release proof is claimed by this report.

## Required Local / CI Validation

After pulling `main`, run:

```bash
python3 -m py_compile \
  scripts/ambitions_signature_visual_instruments.py \
  scripts/ambitions-frontend-authority-packet.py \
  scripts/ambitions-frontend-implementation-prompt.py \
  scripts/ambitions-frontend-source-bindings.py \
  scripts/ambitions-frontend-drift-check.py \
  scripts/ambitions-frontend-implementation-dashboard.py \
  scripts/ambitions-frontend-next-surface-queue.py \
  scripts/ambitions-signature-visual-instruments-check.py

python3 scripts/ambitions-frontend-authority-packet.py --tier P0
python3 scripts/ambitions-frontend-implementation-prompt.py --surface today_root_reality_meridian --batch TODAY-REALITY-MERIDIAN-FLAGSHIP-IMPLEMENTATION-01
python3 scripts/ambitions-frontend-source-bindings.py
python3 scripts/ambitions-frontend-drift-check.py
python3 scripts/ambitions-frontend-implementation-dashboard.py
python3 scripts/ambitions-frontend-next-surface-queue.py
python3 scripts/ambitions-signature-visual-instruments-check.py
```

Expected final state after validation:

- root packets include `Signature Visual Instrument` sections
- generated implementation prompt includes instrument requirements
- source bindings include `signature_instrument_id` and instrument status fields
- dashboard includes signature instrument counts and status
- queue includes instrument scoring and duplicate-surface protection
- drift checker distinguishes forbidden-rule declarations from live UI drift

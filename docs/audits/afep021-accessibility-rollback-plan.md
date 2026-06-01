# AFEP-021 Accessibility Rollback Plan

## Primary Rollback

Restore the AFEP-021 source/test scaffold to the approved baseline while keeping the AFRI-034 accessibility proof matrix and the AFRI-005 shell screenshot proof path available.

## Exact Fallback Paths

- `docs/proof/afri/afri-034-accessibility-proof-matrix.md`
- `docs/proof/afri/afri-005-shell-preview-screenshot-proof.md`

## Source Rollback Targets

- `Native/Ambitions/PreviewSupport/ShellPreviewMatrix.swift`
- `Native/AmbitionsTests/App/ShellPreviewMatrixTests.swift`
- `Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift`

## Rollback Steps

1. Revert the AFEP-021 source scaffold additions.
2. Revert the AFEP-021 test additions.
3. Keep the AFRI-034 accessibility proof matrix as the current proof baseline.
4. Keep the AFRI-005 shell screenshot proof path as the rendered-proof fallback.
5. Re-run the focused accessibility tests and the claim-boundary scan before closing the batch.

## Safety Boundary

Rollback does not change production runtime behavior, persistence, sync, or privacy posture. It only removes the AFEP-021 source/test scaffold and restores the prior proof boundary.

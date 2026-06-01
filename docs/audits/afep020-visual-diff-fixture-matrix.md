# AFEP-020 Visual Diff Fixture Matrix

## Canonical Surfaces

| Tab | Surface Title | Primary Object | Fixture Key |
|---|---|---|---|
| Today | Today | Reality Meridian | `today-reality-meridian` |
| Goals | Goals | Constellation Atlas | `goals-constellation-atlas` |
| Capture | Capture | Atmosphere Composer | `capture-atmosphere-composer` |
| Time | Time | LifeShape Field | `time-lifeshape-field` |
| You | You | User System Profile | `you-user-system-profile` |

## Variant Dimensions

| Variant | Scenario | Accessibility Flag |
|---|---|---|
| Baseline | `baseline` | none |
| Loading | `loading` | none |
| Empty | `empty` | none |
| Private Source Review | `private_source_review` | none |
| Blocked Recovery | `blocked_recovery` | none |
| Overloaded | `overloaded` | none |
| Reduce Motion | `reduce_motion` | Reduce Motion |
| Increase Contrast | `increase_contrast` | Increase Contrast |
| Dynamic Type | `dynamic_type` | Dynamic Type |

## Deterministic Inputs

- Surface deterministic seed names are stable and path-safe.
- Variant deterministic seed names are stable and path-safe.
- Projection input names are stable and path-safe.
- Artifact stems are lowercased and use hyphen-separated names only.

## Artifact Bundle

- Bundle name: `AFEP-020 Visual Diff Lab`
- Bundle directory: `afep-020-visual-diff-lab`
- Artifact prefix: `afep020-visual-diff`
- Report filename: `afep020-visual-diff-lab-report.md`
- Fixture matrix filename: `afep020-visual-diff-fixture-matrix.md`
- Proof boundary filename: `afep020-visual-proof-claim-boundary.md`

## Provenance

The fixture matrix carries local-only provenance labels for:

- `SourceRecord`
- `Receipt`
- `ReplayTrace`
- `You / What Ambitions knows`

These labels support future proof work without implying current rendered screenshots.

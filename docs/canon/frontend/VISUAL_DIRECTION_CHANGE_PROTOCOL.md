# Visual Direction Change Protocol

Status: Active definition of done for visual direction changes

Every future visual-direction change must update this encyclopedia before it can be considered complete.

Required updates:

- New visible item: add a `VISUAL_ITEM_REGISTRY.yaml` entry.
- Renamed visual item: update `TERM_ALIAS_AND_DEPRECATION_REGISTRY.md` and affected registry entries.
- Removed visual item: move it to `OBSOLETE_AND_EXCLUDED_VISUAL_REFERENCE_LEDGER.md` or mark obsolete/archive/delete candidate.
- New screen: update `ACTIVE_IA_AND_SURFACE_MAP.md` and `trace/SCREEN_TO_DRILLDOWN_MATRIX.md`.
- New drill-down: update the owning surface bible and drill-down matrix.
- New primitive: update the primitive bible and object-to-primitive matrix.
- New state: update `trace/STATE_TO_VISUAL_ENCODING_MATRIX.md`.
- New reference image: update `VISUAL_REFERENCE_LEDGER.md`.
- Obsolete reference: classify it in the obsolete/excluded ledger.
- New visual decision: add a decision record to `VISUAL_DECISION_RECORDS.md`.
- MRI/HBI source-family extraction: update `trace/VISUAL_DIRECTION_SOURCE_FAMILY_EXTRACTION_LEDGER.md` and the source-family integration map.
- Every change must state affected areas: Today, Goals, Capture, Time, You, shell, primitives, behavior, accessibility, MRI, HBI.
- Visual updates must include accessibility and ADHD review notes.
- Visual updates must not revive Plan as a top-level tab.
- Celestial visuals must be semantic: orientation, continuity, state, proof, source freshness, or object meaning.

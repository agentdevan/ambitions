# UI Studio Tokens and Materials Review

Status: Active control-plane review ledger
Batch: `UI-STUDIO-02-TOKENS-AND-MATERIALS-REVIEW`

## Source Truth Reviewed

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`
- `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md`
- `frontend/visual-encyclopedia/VISUAL_VOCABULARY_BOUNDARY.md`
- `frontend/visual-encyclopedia/trace/DESIGN_TOKEN_COMPLETENESS_MATRIX.yaml`
- `frontend/visual-encyclopedia/trace/TOKEN_SOURCE_AUTHORITY_LEDGER.md`
- `frontend/visual-encyclopedia/trace/DESIGN_SYSTEM_AUTHORITY_LEDGER.md`

## Review Summary

| Area | Finding | Evidence / Boundaries |
| --- | --- | --- |
| Source-backed tokens | The active token set is already source-backed and complete. | `DESIGN_TOKEN_COMPLETENESS_MATRIX.yaml` reports `status: green`, `token_count: 51`, and `missing_tokens: []`. |
| Material primitives | The active material names are semantic, not decorative. | `VISUAL_VOCABULARY_BOUNDARY.md` classifies `QuietGlass`, `GraphiteRecess`, `LuminousTrace`, and `CelestialField` as internal canon only. |
| Shared values | Foundation color, semantic surface meaning, component shapes, motion, haptics, accessibility fallbacks, object tokens, and state tokens are shared across surfaces. | `DESIGN_SYSTEM_AUTHORITY_LEDGER.md` and the token matrix both point to shared control-plane use rather than bespoke one-off styling. |
| Generic / web-like risks | The main failure modes remain dashboard drift, card-stack shells, ornamental gradients/glass, color-only state, chatbot chrome, and calendar-clone treatment. | `PRODUCT_DESIGN_TRUTH.md`, `VISUAL_VOCABULARY_BOUNDARY.md`, and the UI Studio operating system all block those patterns. |
| Decorative materials | No new decorative material layer is authorized by current truth. | The current materials exist as semantic primitives, not visual garnish. |

## Token Provenance Notes

- `DesignTokens/*.tokens.json` remains the source truth for token generation.
- `Sources/Theme/AmbitionTokens.generated.swift`, `Sources/Theme/AmbitionObjectTokens.generated.swift`, and `Sources/Theme/AmbitionStateTokens.generated.swift` remain generated outputs.
- `Sources/Theme/AmbitionTheme.swift` remains the implementation truth seam.
- This review does not add a duplicate token system or a parallel material authority.

## Unresolved Proof Gaps

- Implementation proof is out of scope for this batch.
- Accessibility conformance proof is out of scope for this batch.
- Performance proof is out of scope for this batch.
- Device / simulator / release proof is out of scope for this batch.
- No token gap is currently exposed by the reviewed traces.

## Material Usage Guardrail

- `GraphiteRecess` stays the default semantic ground.
- `QuietGlass` stays inspectable and transient, not ornamental.
- `LuminousTrace` stays reserved for source, state, receipt, or attachment visibility.
- `CelestialField` stays an orientation layer, not a starfield or fantasy background.
- Any future surface work that cannot explain its material semantics should treat the material choice as unresolved rather than inventing a new layer.

## Validation

- Phase 04 repair pass reran `make prompt-audit`.
- Phase 04 repair pass reran `git diff --check`.
- Phase 04 repair pass reran `python3 scripts/ambitions-repo-authority-validate.py`.
- No source, token, generated Swift, project, package, or app implementation changes were made in this batch.

## Review Conclusion

The token and material layer is already coherent enough for the next flagship UI batch, provided later implementation work keeps using the existing semantic primitives instead of introducing decorative chrome or a second design system.

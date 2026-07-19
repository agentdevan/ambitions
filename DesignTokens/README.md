# Design Tokens

Status: Active token source tree scaffold

DesignTokens is the formal token source tree for the design-system install.

    ## Source Truth

    - `docs/truth/PRODUCT_DESIGN_TRUTH.md`
    - `Sources/Theme/AmbitionTheme.swift`
    - `frontend/visual-encyclopedia/primitives/*`

    ## Rule

    Tokens encode Ambitions product meaning. They are not a color dump.

    ## Current Architecture

    The token tree is intentionally bucketed rather than generic:

    - foundation: named surface/material colors such as graphite, quiet glass, and trace accents
    - semantic: product-specific meaning colors such as Today, Capture, proof, source freshness, and trust
    - component: spacing, radius, and panel geometry for reusable surface treatment
    - motion / haptics / accessibility: interaction and fallback contracts
    - objects / states: Reality Meridian, Start Here-adjacent surface behavior, closure, proof, recovery, and freshness semantics

    Quiet Glass and Graphite Recess remain named material/surface concepts. Reality Meridian remains the Today flagship object. Start Here remains a Today-facing command concept. The live theme is the implementation truth for typography, spacing, and material rendering; DesignTokens keeps those meanings inspectable without creating a second authority root.

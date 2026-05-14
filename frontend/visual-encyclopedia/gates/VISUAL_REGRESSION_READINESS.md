        # Visual Regression Readiness

        Status: Active frontend contract scaffold

        ## Definition

        This gate defines readiness criteria for future visual regression tests. It is readiness scaffolding only.

        ## Allowed Use

        - Use to describe future snapshot coverage.
- Use to track debt by surface and state.

        ## Forbidden Use

        - Do not claim snapshot implementation exists.
- Do not claim current screenshot proof.

        ## Required Tokens

        - AmbitionsVisualSnapshotTests
- AmbitionsAccessibilitySnapshotTests
- AmbitionsDynamicTypeSnapshotTests
- AmbitionsReduceMotionSnapshotTests

        ## Accessibility Requirements

        - The gate requires test-target names, state coverage, and an explicit debt note.

        ## State Variants

        - planned
- missing
- debt
- future proof

        ## Proof And Receipt

        The gate remains a readiness contract until snapshot tests are actually implemented.

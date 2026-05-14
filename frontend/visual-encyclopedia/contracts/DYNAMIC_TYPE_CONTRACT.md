        # Dynamic Type Contract

        Status: Active frontend contract scaffold

        ## Definition

        Dynamic Type must be supported for all P0 object surfaces, including collapse behavior and readable labels.

        ## Allowed Use

        - Use for any surface with text, CTA, or receipt content.
- Use to document collapse rules.

        ## Forbidden Use

        - Do not claim fixed-size UI is sufficient.
- Do not hide critical content at larger sizes.

        ## Required Tokens

        - textScaleFloor
- minimumTapTarget

        ## Accessibility Requirements

        - The contract requires readable content at larger sizes.
- The contract requires visible fallback paths.

        ## State Variants

        - small
- large
- accessibility extra large

        ## Proof And Receipt

        No accessibility conformance claim is made here; this file only states requirements.

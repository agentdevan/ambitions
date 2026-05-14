        # Local Runtime Trust Service

        Status: Active frontend contract scaffold

        ## Definition

        local-only trust ladder

        ## Allowed Use

        - Use as a boundary between view code and logic-heavy code.
- Use for feature-level responsibility reviews.

        ## Forbidden Use

        - Do not use as a justification for sprawling view logic.
- Do not use to claim runtime implementation.

        ## Required Tokens

        - inspectable
- reset
- forget preview

        ## Accessibility Requirements

        - Services must keep correction visible and accessible.
- Labels must be explicit and local.

        ## State Variants

        - scaffold
- contract
- future implementation

        ## Proof And Receipt

        No external/cloud LLM core dependency is introduced.

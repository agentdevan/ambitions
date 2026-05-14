        # Proof Ledger Service

        Status: Active frontend contract scaffold

        ## Definition

        proof and receipt recording

        ## Allowed Use

        - Use as a boundary between view code and logic-heavy code.
- Use for feature-level responsibility reviews.

        ## Forbidden Use

        - Do not use as a justification for sprawling view logic.
- Do not use to claim runtime implementation.

        ## Required Tokens

        - proof
- receipt
- correction

        ## Accessibility Requirements

        - Services must keep correction visible and accessible.
- Labels must be explicit and local.

        ## State Variants

        - scaffold
- contract
- future implementation

        ## Proof And Receipt

        Proof ledger stays local and inspectable.

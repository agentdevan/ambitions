        # Receipt Contract

        Status: Active frontend contract scaffold

        ## Definition

        The receipt contract captures what changed, what source it came from, and how the user can review or correct it later.

        ## Allowed Use

        - Use for closures, pivots, and recoveries.
- Use in the trust seam and history surfaces.

        ## Forbidden Use

        - Do not turn receipts into social feed items or metrics.
- Do not bury correction or delete actions.

        ## Required Tokens

        - proofReceipt
- luminousTrace

        ## Accessibility Requirements

        - Receipts need a clear reading order and an accessible summary.
- Expandable details need visible affordances.

        ## State Variants

        - created
- reviewed
- corrected
- forgotten

        ## Proof And Receipt

        Receipts are local and inspectable; they do not imply release proof.

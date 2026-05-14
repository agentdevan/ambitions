        # Proof Chip Contract

        Status: Active frontend contract scaffold

        ## Definition

        The proof chip summarizes that something happened, what source produced it, and whether correction remains available.

        ## Allowed Use

        - Use next to completion, receipt, or closure events.
- Use for proof summaries inside object surfaces.

        ## Forbidden Use

        - Do not use as a vanity badge or scoreboard.
- Do not hide the correction path.

        ## Required Tokens

        - proofReceipt
- luminousTrace

        ## Accessibility Requirements

        - The chip must be readable without color.
- The label must not rely on icon-only meaning.

        ## State Variants

        - attached
- partial
- missing
- correction offered

        ## Proof And Receipt

        A proof chip is a source-linked contract artifact, not proof by itself.

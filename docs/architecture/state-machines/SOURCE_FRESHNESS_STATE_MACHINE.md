        # Source Freshness State Machine

        Status: Active frontend contract scaffold

        ## Definition

        freshness and staleness transitions

        ## Allowed Use

        - Use as architecture guidance for the relevant object flow.
- Use to constrain future implementation reviews.

        ## Forbidden Use

        - Do not treat as proof of runtime implementation.
- Do not widen the scope beyond the named flow.

        ## Required Tokens

        - sourceFreshness
- proofReceipt
- youTrust

        ## Accessibility Requirements

        - The machine must keep source, proof, and correction visible.
- Accessibility and recovery are explicit gates.

        ## State Variants

        - fresh
- stale
- missing
- refreshing
- repaired

        ## Proof And Receipt

        No live freshness service is claimed.

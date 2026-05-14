        # Capture Route State Machine

        Status: Active frontend contract scaffold

        ## Definition

        capture entry and route reveal

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

        - idle
- typing
- route reveal
- held
- proof attached

        ## Proof And Receipt

        Do not claim a route engine exists just because the contract exists.

        # Source Proof Receipt Coverage Gate

        Status: Active frontend contract scaffold

        ## Definition

        This gate requires P0 surfaces to define source, proof, receipt, correction, stale/missing source, and local-only behavior.

        ## Allowed Use

        - Use for Today, Goals, Capture, Time, and You contracts.
- Use to confirm a complete control-plane definition.

        ## Forbidden Use

        - Do not use to claim runtime implementation.
- Do not use to claim release proof.

        ## Required Tokens

        - sourceFreshness
- proofReceipt
- youTrust

        ## Accessibility Requirements

        - Every surface must expose a correction path and a visible stale/missing state.
- Local-only behavior must remain explicit.

        ## State Variants

        - source present
- proof attached
- receipt attached
- correction
- stale
- missing

        ## Proof And Receipt

        The gate is a contract and does not by itself prove the runtime state.

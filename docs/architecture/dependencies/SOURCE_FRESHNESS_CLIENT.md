        # Source Freshness Client

        Status: Active frontend contract scaffold

        ## Definition

        freshness and staleness check boundary

        ## Allowed Use

        - Use as an interface boundary in future implementation work.
- Use to constrain feature service calls.

        ## Forbidden Use

        - Do not use these boundaries to justify hosted AI or generic frameworks.
- Do not treat the doc as implementation proof.

        ## Required Tokens

        - fresh
- stale
- missing
- refresh

        ## Accessibility Requirements

        - Each client must keep source and correction visible.
- No hidden state transitions.

        ## State Variants

        - contract
- scaffold
- future implementation

        ## Proof And Receipt

        Source freshness remains inspectable and local.

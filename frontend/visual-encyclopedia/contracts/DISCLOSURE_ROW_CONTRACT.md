        # Disclosure Row Contract

        Status: Active frontend contract scaffold

        ## Definition

        The disclosure row reveals deeper source, proof, or correction detail without becoming a dashboard row.

        ## Allowed Use

        - Use for source/proof drill-downs.
- Use for inspectable local controls.

        ## Forbidden Use

        - Do not use as a generic list-row fallback.
- Do not use as a hidden menu substitute.

        ## Required Tokens

        - disclosureRow
- sourceFreshness

        ## Accessibility Requirements

        - Rows must have a visible label and a meaningful accessory.
- VoiceOver must read the disclosure intent.

        ## State Variants

        - collapsed
- expanded
- stale
- correctable

        ## Proof And Receipt

        Disclosure rows are a control-plane primitive, not a generic app row.

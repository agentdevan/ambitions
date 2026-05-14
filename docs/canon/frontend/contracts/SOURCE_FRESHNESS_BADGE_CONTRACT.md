        # Source Freshness Badge Contract

        Status: Active frontend contract scaffold

        ## Definition

        The source freshness badge tells the user whether a recommendation, schedule, or summary is fresh, stale, or missing.

        ## Allowed Use

        - Use in Today, Time, and You whenever freshness matters.
- Use with explicit refresh or correction actions.

        ## Forbidden Use

        - Do not use as a silent health score.
- Do not imply real-time sync when none exists.

        ## Required Tokens

        - sourceFreshness
- recoveryMint

        ## Accessibility Requirements

        - Badge text must say fresh or stale in words.
- Color must not be the only signal.

        ## State Variants

        - fresh
- stale
- missing
- refreshing

        ## Proof And Receipt

        This badge is a state label; it does not prove data provenance alone.

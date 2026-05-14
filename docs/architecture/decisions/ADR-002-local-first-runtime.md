        # ADR-002 Local First Runtime

        Status: Active architecture decision record

        ## Context

        This ADR is dated 2026-05-14 and applies only to the control-plane install batch.

        ## Decision

        Core runtime behavior remains local-first and inspectable, with no external/cloud LLM core dependency.

        ## Consequences

        - Matches product truth.
- Prevents hosted dependency drift.

        ## Status

        Accepted

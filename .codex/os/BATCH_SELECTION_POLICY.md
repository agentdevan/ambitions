Status: ACTIVE
Owner: Governance OS
Authority Tier: active
Supersedes: none
Superseded By: none
Proof Expectation: docs-only
Cleanup Destination: none
Expected Lifetime: permanent

# Batch Selection Policy

Batch selection must be conservative.

Selection order:

1. Governance Reds.
2. Missing generated outputs.
3. Canon propagation work after canon changes.
4. Sequencing repairs.
5. Safest executable batch from the live queue.
6. Idle when no executable batch is safe.

Selection rules:

- Never pick historical complete-do-not-run entries.
- Never outrun active batch state or blocking prerequisites.
- Prefer the currently active batch when it is still authoritative and unblocked.
- Return the exact prompt file if known.
- Return preflight and postflight commands with every selection.

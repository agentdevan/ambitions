Status: ACTIVE
Owner: Governance OS
Authority Tier: active
Supersedes: none
Superseded By: none
Proof Expectation: docs-only
Cleanup Destination: none
Expected Lifetime: permanent

# Tool Use Policy

Codex OS tools in Ambitions must be local, deterministic, and stdlib-only unless a truth file explicitly permits more.

Tool rules:

- Prefer repo-local scripts over ad hoc shell fragments.
- Read real repo files, not memory, when deciding what to do next.
- Keep new scripts executable and predictable.
- Do not add network, secrets, paid services, or write-capable MCP tooling without explicit approval.
- Use the authorized batch wrapper for batch execution closeout.
- Use the next-action resolver as the canonical Codex command entrypoint.

When a tool only reports state, treat it as advisory unless a truth file makes it authoritative.

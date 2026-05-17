Status: ACTIVE
Owner: Governance OS
Authority Tier: active
Supersedes: none
Superseded By: none
Proof Expectation: docs-only
Cleanup Destination: none
Expected Lifetime: permanent

# Codex Decision Policy

Codex decisions in Ambitions must be bounded, deterministic, and evidence-driven.

Decision order:

1. Check active truth and the current repo state.
2. Check generated governance outputs.
3. Check for governance Reds, missing outputs, stale overlays, and orphan prompts.
4. Repair governance before selecting implementation work.
5. Select the safest next batch only when governance is clear.

Decision rules:

- Governance Red blocks feature expansion.
- Missing generated outputs require regeneration before batch selection.
- Canon changes require canon installer and follow-on regeneration.
- Report the exact command, not a vague intention.
- When no safe batch exists, report idle rather than inventing work.

Codex must not infer release readiness, App Store readiness, or device proof from governance state alone.

# Skill Deduplication Audit

## Purpose
This audit tracks the presence of duplicated boilerplate and global canon across `.agents/skills/*` to prevent redundant token consumption in future runs.

## Repeated Blocks Found
- Many skill files contain repeated root global context rules (e.g., repeating the full Ambitions identity, product moat, or runner rules) instead of focusing solely on the skill's specific mechanics.
- Boilerplate headers or standard iOS quality gate language is duplicated instead of being referenced from `AGENTS.md` or a central canon file.

## Recommended Consolidation Target
- Move global repo behavior and identity rules strictly to `AGENTS.md`.
- Skill files should only define:
  1. Trigger conditions (when to use)
  2. Required inputs/arguments
  3. Step-by-step execution procedure
  4. Specific validation required for the skill
  5. Allowed/forbidden actions specific to the skill

## Files Affected
- All files under `.agents/skills/*` (e.g., `ambitions-ios-quality-gate`, `ambitions-release-proof-honesty`, `ambitions-visual-product-quality`, etc.)

## Safe Future Migration Plan
1. Create a `docs/codex/SKILL_AUTHORING_GUIDE.md` outlining the lean skill format.
2. In a dedicated bounded batch, refactor 1-2 skills as a proof of concept.
3. Verify that removing global canon from the skill file does not cause agents to forget the rules (since `AGENTS.md` is hot context).
4. Roll out the lean format to the remaining skills.

## Risk Notes
- **Context Loss**: Aggressively stripping context from skills before verifying that `AGENTS.md` provides sufficient coverage could lead to agents violating global rules when executing specific skills.
- **Divergence**: If a skill relies on a highly specific interpretation of global canon, abstracting it away might break the skill's effectiveness.

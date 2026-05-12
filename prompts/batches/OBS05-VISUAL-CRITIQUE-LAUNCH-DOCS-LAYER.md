<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

OBS05-VISUAL-CRITIQUE-LAUNCH-DOCS-LAYER

# Allowed Scope

- `docs/codex/VISUAL_CRITIQUE_LAYER.md`
- `docs/codex/LAUNCH_DOCUMENTATION_LAYER.md`
- `tools/openai/visual_critique/README.md`
- `tools/openai/visual_critique/rubrics/ambitions_visual_canon.json`
- `tools/openai/visual_critique/critique_visual_packet.py`
- `tools/openai/launch_docs/README.md`
- `tools/openai/launch_docs/generate_launch_packet.py`

# Forbidden Scope

- screenshot uploads
- visual acceptance claims

# Objective

Finalize local visual-dimension and launch-draft tooling without runtime network calls.

# Validation

- `python3 tools/openai/visual_critique/critique_visual_packet.py --rubric tools/openai/visual_critique/rubrics/ambitions_visual_canon.json --dry-run`
- `python3 tools/openai/launch_docs/generate_launch_packet.py --dry-run`

# Rollback

`git restore --staged -- docs/codex/VISUAL_CRITIQUE_LAYER.md docs/codex/LAUNCH_DOCUMENTATION_LAYER.md tools/openai/visual_critique tools/openai/launch_docs`

# No-Claim Policy

No visual readiness or launch readiness claims are set.

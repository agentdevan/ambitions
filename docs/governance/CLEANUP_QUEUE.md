# Ambitions Cleanup Queue

Status: ACTIVE

| Path | Problem | Owner | Action | Priority | Blocks Execution? |
|---|---|---|---|---|---|
| docs/codex/BATCH_REGISTRY.md | append-only operational accumulation | governance | normalize + historical extraction | CRITICAL | YES |
| prompts/batches/ | potential orphan/superseded prompts | governance | reconcile lineage | HIGH | YES |
| docs/governance/generated/ | generated outputs may drift | governance | regenerate on closeout | HIGH | YES |
| .codex/runs/ | historical operational noise | codex-os | classify/archive/prune | MEDIUM | NO |
| docs/canon/ | duplicate overlay risk | canon | supersession reconciliation | HIGH | YES |

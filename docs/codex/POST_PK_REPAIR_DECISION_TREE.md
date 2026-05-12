# Post-PK Repair Decision Tree

Status: active repair-routing policy after PK41

## Classification

Use:

```bash
python3 scripts/ambitions-repair-classifier.py <log-or-final-message>
```

## Actions

| Classification | Action |
| --- | --- |
| `permission_or_local_wrapper` | Use `ACCESS_MODE=bypass`; direct native git only after scoped proof passes |
| `stale_state` | Run `ambitions-advance-batch-state.py` and `ambitions-state-advance-validate.py` |
| `missing_prompt` | Materialize prompt from template/live queue; do not run implementation until prompt exists |
| `broad_scanner_noise` | Narrow scan to changed/current files during install; keep broad scan for final gate |
| `focused_test_failure` | Repair touched owner seam once; rerun focused owner tests |
| `compile_failure` | Repair compile error in owning seam; do not advance without proof or documented Accepted Yellow |
| `simulator_environment` | Accepted Yellow only if focused source proof is otherwise clean |
| `git_push_failure` | Pull fast-forward, then direct `/usr/bin/git push --no-verify origin HEAD:main` if commit is eligible |
| `unsupported_claim` | Repair claim text/no-claim boundary; do not weaken scanner globally |
| `hard_red` | Stop and report exact blocker/rollback |
| `unknown` | Stop for manual triage |

## Repair Limit

Default repair pass count remains one. Do not convert unknown failure into broad cleanup.

# Post-PK Repair Operator — Codex Desktop

Use when a post-PK batch blocks.

1. Inspect the latest run output.
2. Classify the failure:

```bash
python3 scripts/ambitions-repair-classifier.py <latest-final-or-log-file>
```

3. Apply only the smallest repair:

- stale state -> `scripts/ambitions-advance-batch-state.py` + `scripts/ambitions-state-advance-validate.py`
- missing prompt -> materialize prompt from live queue/template
- broad scanner noise -> narrow scanner to changed/current files for install only
- focused test failure -> one owner-seam repair and focused rerun
- simulator/environment -> accepted Yellow only with clean owner proof
- git push failure -> `git pull --ff-only`, then `/usr/bin/git push --no-verify origin HEAD:main` if commit is eligible
- hard Red/unknown -> stop and report

4. Commit/push repair if eligible.
5. Continue with post-PK speed train.

Do not broaden scope, do not run global cleanup, and do not claim proof that was not run.

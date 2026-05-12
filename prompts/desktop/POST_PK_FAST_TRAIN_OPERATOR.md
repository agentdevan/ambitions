# Post-PK Fast Train Operator — Codex Desktop

Use after PK41 completes unless the operator explicitly allows PK use.

You are operating inside `/Users/devan/Documents/GitHub/ambitions` in Codex Desktop with full local permission.

Goal: run remaining non-PK batches as fast as possible using install/review/commit/advance, pushing to `main` after each batch.

Rules:

- Do not use `make speed-train`.
- Use the post-PK speed wrapper.
- Do not ask for routine command/git/push approval.
- Do not run full Xcode suites unless terminal gate owns it.
- Use focused proof by batch lane.
- Close each batch in one commit when practical: implementation + report + state advancement.
- Do not claim release, device, accessibility, performance, privacy/legal, visual completion, or global completion without proof.
- Do not touch `Native/Ambitions/**` unless the active non-PK batch explicitly owns that source seam.

Start:

```bash
cd /Users/devan/Documents/GitHub/ambitions
git pull --ff-only
make -f Makefile.post-pk-speed post-pk-speed-status
MAX_BATCHES=10 make -f Makefile.post-pk-speed post-pk-speed-train
```

If blocked, classify using:

```bash
python3 scripts/ambitions-repair-classifier.py <latest-final-or-log-file>
```

Repair once within the owning seam, then continue.

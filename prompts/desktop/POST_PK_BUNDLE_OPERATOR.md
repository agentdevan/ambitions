# Post-PK Bundle Operator — Codex Desktop

Use this to keep context warm across a related post-PK bundle while still committing each batch independently.

1. Inspect current bundle:

```bash
cd /Users/devan/Documents/GitHub/ambitions
python3 scripts/ambitions-bundle-next-batches.py --next
python3 scripts/ambitions-post-pk-speed-router.py
```

2. Run the post-PK speed train:

```bash
MAX_BATCHES=10 make -f Makefile.post-pk-speed post-pk-speed-train
```

3. For each batch:

- install only the current batch seam,
- run focused/proof-light checks by lane,
- close report and state in the same commit when practical,
- push to `main`,
- continue.

Do not merge batch IDs. The bundle is context only.

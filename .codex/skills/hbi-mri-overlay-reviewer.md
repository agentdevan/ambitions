# HBI / MRI Overlay Reviewer Skill

Status: Active speed skill  
Purpose: Classify whether the current batch must apply HBI, MRI, both, or neither before implementation begins.

## Use when

Use this skill for every autonomous-train batch transition and for any batch touching source import, runtime objects, recommendations, proof receipts, or cross-surface wiring.

## Fast commands

```bash
python3 scripts/ambitions-next-batch-router.py --dry-run --prefer-hbi
python3 scripts/ambitions-historical-baseline-train-guard.py
make -f Makefile.mri help || true
python3 scripts/ambitions-mri-autonomous-router.py --help || true
```

## HBI required when the batch touches

```text
source records
evidence
candidate claims
review queues
current state
runtime inspection
recommendation influence
source confidence
staleness
contradictions
export/delete/restore
local simulation
monetization gates
final proof
```

## MRI required when the batch touches

```text
runtime objects
moat loops
object graph
cross-surface routing
recommendation runtime
proof receipts
autonomous routing
Object OS overlays
```

## Output

Return one of:

```text
HBI required / MRI required / HBI + MRI required / neither required / stop Red for routing conflict
```

## Rules

- Do not bypass canonical queue truth.
- Do not treat HBI or MRI as optional when their scope applies.
- If MRI routing conflicts with canonical queue and no active authority resolves it, stop Red.
- If HBI guard fails, stop Red.

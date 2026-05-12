# Moat Runtime Autonomous Routing Policy

Status: active control-plane routing policy  
Date: 2026-05-12  
Authority: subordinate to `docs/truth/*`, current queue state, and live source/proof evidence

## Purpose

MRI is now an autonomous sidecar train. It is not appended blindly to the canonical global queue. It runs when milestone triggers indicate that the normal global train needs moat/runtime integration before continuing safely.

## Router

Primary router:

```bash
python3 scripts/ambitions-mri-autonomous-router.py --status
python3 scripts/ambitions-mri-autonomous-router.py --next
python3 scripts/ambitions-mri-autonomous-router.py --json
```

Primary wrapper:

```bash
make -f Makefile.mri mri-autonomous-status
make -f Makefile.mri mri-autonomous-next
make -f Makefile.mri mri-autonomous-once
MAX_BATCHES=10 make -f Makefile.mri mri-autonomous-train
```

## Behavior

- If no MRI intervention is due, the wrapper delegates to `scripts/ambitions-post-pk-speed-train.sh`.
- If an MRI intervention is due, the wrapper materializes MRI prompts, runs the next MRI sidecar batch through the canonical runner, marks it complete in `.codex/state/mri-autonomous-state.json`, pushes the state marker, then resumes.
- MRI completion state is tracked separately from the canonical global queue so MRI does not pollute or reorder active SA/AOS/LDI/FCP/PFC/RHC execution.

## Milestone Triggers

| Milestone | Trigger next batch | MRI bundle |
| --- | --- | --- |
| after-source-atlas-core | SA11 | MRI01-MRI08 |
| after-source-atlas-runtime | SA17 | MRI09-MRI16 |
| after-source-atlas-importers | SA25 | MRI17-MRI24 |
| after-source-atlas-complete | AOS24/AOS25/LDI17/FCP27/PFC31/RHC01 | MRI25-MRI34 |
| before-terminal-assurance | RHC01/RHC02/DPTG01/FINAL01/PFC37-PFC40 | MRI35-MRI44 |
| final-moat-integration | FINAL01/DPTG01/RELEASE01 | MRI45-MRI50 |

## Rule

MRI runs when it protects product-loop completeness. The normal global queue still owns implementation order.

## Non-Claims

This routing policy does not claim MRI implementation completion, visual runtime completion, release readiness, TestFlight readiness, App Store readiness, device proof, public accessibility conformance, performance validation, privacy/legal approval, or global train completion.

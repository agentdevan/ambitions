# MRI Autonomous Routing Install Report

Status: GitHub-side control-plane install complete. Local validation was not run in this chat.  
Date: 2026-05-12

## Objective

Make MRI run autonomously through the global train when milestone triggers indicate moat/runtime integration is needed.

MRI remains a sidecar overlay. It is not blindly appended to the canonical queue and does not replace the active SA/global train.

## Files Installed / Updated

- `scripts/ambitions-mri-autonomous-router.py`
- `scripts/ambitions-mri-autonomous-train.sh`
- `Makefile.mri`
- `docs/codex/MOAT_RUNTIME_AUTONOMOUS_ROUTING_POLICY.md`
- `docs/audits/mri-autonomous-routing-install-report.md`

## Behavior

The autonomous wrapper:

1. checks the current global queue next batch,
2. checks MRI milestone triggers,
3. materializes MRI prompts when needed,
4. runs the next MRI sidecar batch through the canonical runner when due,
5. marks MRI sidecar completion in `.codex/state/mri-autonomous-state.json`,
6. pushes that state marker,
7. otherwise delegates to post-PK speed train.

## Commands

```bash
make -f Makefile.mri mri-autonomous-status
make -f Makefile.mri mri-autonomous-next
make -f Makefile.mri mri-autonomous-once
MAX_BATCHES=10 make -f Makefile.mri mri-autonomous-train
```

## Milestone Triggers

- `SA11` triggers MRI01-MRI08.
- `SA17` triggers MRI09-MRI16.
- `SA25` triggers MRI17-MRI24.
- `AOS24`, `AOS25`, `LDI17`, `FCP27`, `PFC31`, or `RHC01` trigger MRI25-MRI34.
- `RHC01`, `RHC02`, `DPTG01`, `FINAL01`, or `PFC37`-`PFC40` trigger MRI35-MRI44.
- `FINAL01`, `DPTG01`, or `RELEASE01` trigger MRI45-MRI50.

## Recommended Local Validation

```bash
git pull --ff-only
python3 -m py_compile scripts/ambitions-mri-autonomous-router.py scripts/ambitions-mri-materialize-prompts.py
bash -n scripts/ambitions-mri-autonomous-train.sh
make -f Makefile.mri mri-status
make -f Makefile.mri mri-router-json
make -f Makefile.mri mri-autonomous-status
make -f Makefile.mri mri-autonomous-next
```

## Boundaries

No app runtime source, tests, package/project files, release automation, signing, entitlements, hosted backend, telemetry, analytics, or app runtime OpenAI integration were intentionally changed.

## Claims Not Made

This install does not claim MRI implementation complete, app runtime changed, visual runtime implemented, release readiness, TestFlight readiness, App Store readiness, physical-device validation, public accessibility conformance, performance validation, privacy/legal approval, or global train completion.

## Recommended Next Action

For future autonomous execution where MRI should self-insert at milestones, use:

```bash
MAX_BATCHES=10 make -f Makefile.mri mri-autonomous-train
```

instead of direct `post-pk-speed-train`.

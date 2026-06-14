# Ambitions Master Build Green / Yellow / Red Reporting

Status: Active reporting standard for `amb-master`
Authority posture: Supporting process standard subordinate to `docs/truth/*`, live source, current validation logs, and Linear `AMB-*` issue state

## Green

Green is allowed only when the scoped train is complete, AMB-bound, source-owner-safe, validated, proof-backed, and no claim exceeds evidence.

For source-changing trains, Green also requires focused tests or validators that cover the changed behavior, plus owner/parallel-implementation guard evidence where applicable.

## Yellow

Yellow is allowed for bounded, named gaps that do not invalidate the scoped change:

- human/device/manual proof unavailable
- external credential/signing/platform proof unavailable
- non-blocking pre-existing drift not caused by the patch
- future certification proof not required for this train

Every Yellow must name owner, safety reason, no-claim boundary, and retirement condition.

## Red

Red requires stop or repair before push when present:

- missing `AMB-*` binding
- train label used as Linear identifier
- source owner ambiguity for source-changing work
- privacy leak or private data in public/R2 paths
- required cloud LLM/core backend dependency
- data loss, migration failure, sync corruption, purchase break, route dead end, runtime crash, unsafe high-risk recommendation, inaccessible destructive flow, stale IA regression, invalid source trust
- validation failure caused by the patch
- readiness, release, accessibility, privacy/legal, performance, device, App Review, TestFlight, App Store, or full-project claims without current proof

## Closeout Sections

Every report must include:

- Linear issue and train label
- files changed and why
- source ownership proof
- validation commands/results/artifacts
- reviewer passes or why not applicable
- Green/Yellow/Red status
- Red blockers
- Yellow limits
- proof/claim boundaries
- rollback
- next train

# LocalRuntimeProof

Status: active runtime-proof gate
Owner: Private Life Runtime / LocalRuntimeOS
Current artifact: `current-local-runtime-proof.md` and `current-local-runtime-proof.json`

`LocalRuntimeProof` is the app-wide proof gate for the runtime law:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

This gate is stricter than LocalRuntimeOS source-present inventory. Source parity
can pass while LocalRuntimeProof remains Red if meaningful mutations still bypass
the Commands pipeline, side effects can execute without durable outbox proof, event
replay/projection consumption is not app-wide, or truth files still contain
explicit no-claim gaps.

Run:

```bash
python3 scripts/ambitions-local-runtime-proof.py
```

Generate the current audit artifacts:

```bash
python3 scripts/ambitions-local-runtime-proof.py --audit-only --write-json docs/qa/local-runtime-proof/current-local-runtime-proof.json --write-markdown docs/qa/local-runtime-proof/current-local-runtime-proof.md
```

Green is available only when the script exits Green and current focused runtime
tests support the same claim. This gate does not prove Visual Green, Release
Green, privacy/legal approval, TestFlight readiness, App Store readiness,
production CloudKit continuity, or production R2 readiness.

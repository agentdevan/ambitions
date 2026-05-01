# F21.5 UI Flake / Reliability Hardening Prompt

Status: Conditional

Run only if UI tests pass individually but fail in suite, timeouts or hangs occur, `scripts/test-local.sh` is unreliable, or simulator boot issues cause repeated ambiguity.

Scope:

- improve waits
- improve helper contracts
- add wrapper timeout/heartbeat if needed
- no product behavior changes

Green requires reliable rerun evidence and no weakened product-contract tests.

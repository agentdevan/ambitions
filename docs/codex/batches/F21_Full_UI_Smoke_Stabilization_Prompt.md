# F21 Full UI Smoke Stabilization Prompt

Status: Queued after F20 Green

Known pre-existing UI smoke failures may be worked in this batch.

Run:

```bash
scripts/test-local.sh || true
```

Scope:

- stabilize full UI smoke suite
- classify remaining failures
- modernize tests according to UI Test Contract
- replace brittle waits with product contract waits
- preserve product promises
- do not weaken tests to pass
- do not delete tests without replacement or retirement evidence

Green requires full UI smoke passing, or every remaining failure retired, replaced, or classified with accepted contract evidence.

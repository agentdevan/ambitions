# AMB-CODEX-OS-PROOF-LEDGER

Supporting note: This ledger supports current Ambitions Codex work but does not override `docs/truth/`.

## Purpose

Every batch should be able to answer:

- What claim is being made?
- What evidence supports it?
- What file or log proves it?
- What validation command ran?
- What is still missing?
- What proof type is this: source, test, visual, doc, or report?

## Rule

No proof means no `GREEN`.

## Recommended entry shape

```text
claim
evidence
path
command
status
gap
proof type
```

## Routes to existing support

- `proof-receipt-ledger-builder`
- `evidence-gate-reporter`
- `release-claim-safety-auditor`

## Non-claims

This ledger does not replace current raw logs or current source evidence.

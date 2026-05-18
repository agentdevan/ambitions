---
name: proof-ledger-writer
description: Record claims, evidence, validation commands, proof types, and gaps for Ambitions batches.
---

# Proof Ledger Writer

Use this wrapper when closing a batch or documenting validation evidence.

## Route to existing skills

- `proof-receipt-ledger-builder`
- `evidence-gate-reporter`
- `batch-closeout-editor`

## Minimum check

1. Record the claim.
2. Record the evidence path.
3. Record the command or proof source.
4. Record the remaining gap if not Green.

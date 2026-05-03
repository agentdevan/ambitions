# Codex OS Batch Atomicity And Commit Protocol

Status: Active protocol.
Date: 2026-05-03

Use one logical batch per commit. Use separate commits for Codex OS upgrades, proof/evidence repairs, stop-state reports, and implementation batches. Do not squash away audit truth or Yellow/Red repair history. Dirty tree handling is conservative: known run-state dirt may be classified; unknown dirt is Red. Commit names should use imperative verbs and batch identity where applicable.

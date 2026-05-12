# Batch Report Layer

## Purpose

Parse closeout reports and produce operator-friendly summaries and classifications.

## Components

- `tools/openai/batch_report/summarize_batch_report.py`: extracts status, changed files, and validation commands.
- `tools/openai/batch_report/classify_batch_result.py`: emits status classification.

## Requirements

- Must surface missing rollback and no-claim markers.
- Must keep output machine-readable JSON.
- Must not imply release or accessibility proof.

# Codex Proof Cache Protocol

Status: Active local proof-cache protocol.  
Date: 2026-05-08  
Scope: Local validation reuse without committing raw logs.

## Purpose

The proof cache lets Codex avoid rerunning equivalent validation for the same commit while preserving raw-log paths and hashes locally.

## Location

```text
.codex/state/proof-cache.json
```

This file is ignored by git. Use `scripts/ai/acx_sanitized_evidence.py` to create a committed sanitized packet when needed.

## Entry Fields

- timestamp
- commit
- profile
- exit
- raw_log
- raw_log_sha256

## Use Rules

- Reuse proof only when commit and relevant changed files match.
- Do not reuse proof after touching related files.
- Do not use cached proof for build/test/device/accessibility/release claims unless the profile and raw log actually prove those claims.
- Sanitized packets may cite raw local log path and SHA256, not raw sensitive output.

## Commands

```bash
python3 scripts/ai/acx_sanitized_evidence.py
python3 scripts/ai/acx_sanitized_evidence.py --write docs/audits/<packet>.md
```

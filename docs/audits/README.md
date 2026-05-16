# Audit Receipts

Status: Active audit-routing index  
Authority: Subordinate to `docs/truth/*`, `docs/status/README.md`, and current source/proof evidence.

Audit files are evidence and traceability receipts. They are not active product truth, implementation proof, release proof, visual proof, accessibility proof, or current execution instructions unless the file explicitly ties its claim to current source, commit SHA, command output, and release-truth boundaries.

## How to read this directory

- Start with `docs/truth/README.md` before using any audit.
- Use `docs/truth/RELEASE_TRUTH.md` for release/proof claim boundaries.
- Use `docs/status/release-evidence-packet.md` for current release evidence posture.
- Use `docs/status/cleanup-decision-register.md` for current cleanup decisions.
- Treat old FAANG, PX, SI, DAV, EB, and Ambitions 3.0 / 4.0 audit files as historical/supporting unless refreshed.

## Required fields for new audit receipts

New audit receipts should state:

- status;
- date;
- commit SHA or ref inspected;
- scope;
- files or commands inspected;
- validation performed;
- claims allowed;
- claims not allowed;
- next owner;
- archive/delete recommendation where applicable.

## Hard stops

- Do not use an audit receipt as release readiness proof by itself.
- Do not use old screenshot/demo reports as current visual proof.
- Do not use old accessibility reports as public accessibility conformance proof.
- Do not treat batch Green status as current source proof without current evidence.
- Do not delete audits until durable decisions are extracted and inbound references are checked.

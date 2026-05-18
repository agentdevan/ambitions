# Current Run State

Date: 2026-05-18
Active train: Manifest-faithful rerun reconciliation
Current batch: SA29 Hash / Signature / Revocation Tooling
Next eligible batch: SA30 Freshness Broker Manifest Contract

FCP27 is blocked.

Read first:

```text
docs/codex/SA28_LDI15_AOS24_MANIFEST_RERUN_DIRECTIVE.md
```

SA28-SA32, LDI15-LDI22, and AOS24-AOS30 must be rerun or truthfully reclassified against their manifests before FCP27 or later global queue work can proceed.

Existing commits are retained as historical/supporting evidence. They are not reverted by default and are not sufficient Green proof unless the manifest criteria are satisfied.
SA29 rerun validation is now Green after the repair pass proved last-known-good pack availability for invalid, corrupt, and revoked replacement failures. The next eligible batch is SA30 Freshness Broker Manifest Contract.

Frontend-touching rerun work must inherit the frontend encyclopedia from `frontend/README.md`.

No release, device, accessibility, performance, sync/cloud, hosted AI, TestFlight/App Store, or global train completion claim is made.

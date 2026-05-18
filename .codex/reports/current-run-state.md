# Current Run State

Date: 2026-05-18
Active train: Manifest-faithful rerun reconciliation
Current batch: SA30 Freshness Broker Manifest Contract
Next eligible batch: SA31 Official Source Adapter Contracts

FCP27 is blocked.

Read first:

```text
docs/codex/SA28_LDI15_AOS24_MANIFEST_RERUN_DIRECTIVE.md
```

SA28-SA32, LDI15-LDI22, and AOS24-AOS30 must be rerun or truthfully reclassified against their manifests before FCP27 or later global queue work can proceed.

Existing commits are retained as historical/supporting evidence. They are not reverted by default and are not sufficient Green proof unless the manifest criteria are satisfied.
SA30 rerun validation is now Green after the repair pass preserved explicit Source Atlas freshness state buckets, accepted upstream SA28 camelCase diff flags, and kept canonical manifest output state names. The next eligible batch is SA31 Official Source Adapter Contracts.

Frontend-touching rerun work must inherit the frontend encyclopedia from `frontend/README.md`.

No release, device, accessibility, performance, sync/cloud, hosted AI, TestFlight/App Store, or global train completion claim is made.

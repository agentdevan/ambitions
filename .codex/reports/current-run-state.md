# Current Run State

Date: 2026-05-15
Active train: Manifest-faithful rerun reconciliation
Current batch: SA28-LDI15-AOS24 Manifest Rerun Directive / Active
Next eligible batch: SA29 Hash / Signature / Revocation Tooling

FCP27 is blocked.

Read first:

```text
docs/codex/SA28_LDI15_AOS24_MANIFEST_RERUN_DIRECTIVE.md
```

SA28-SA32, LDI15-LDI22, and AOS24-AOS30 must be rerun or truthfully reclassified against their manifests before FCP27 or later global queue work can proceed.

Existing commits are retained as historical/supporting evidence. They are not reverted by default and are not sufficient Green proof unless the manifest criteria are satisfied.
SA28 rerun validation is now Green; the next eligible batch is SA29 Hash / Signature / Revocation Tooling.

Frontend-touching rerun work must inherit the frontend encyclopedia from `frontend/README.md`.

No release, device, accessibility, performance, sync/cloud, hosted AI, TestFlight/App Store, or global train completion claim is made.

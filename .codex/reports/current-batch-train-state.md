# Current Batch Train State

Date: 2026-05-18
Active train: Manifest-faithful rerun reconciliation
Current batch: SA29 Hash / Signature / Revocation Tooling
Next eligible batch: SA30 Freshness Broker Manifest Contract

Active directives:
- `docs/codex/SA28_LDI15_AOS24_MANIFEST_RERUN_DIRECTIVE.md`
- `docs/audits/sa28-ldi15-aos30-manifest-rerun-audit.md`

SA29 is Green after local validation of deterministic SHA-256 hashing, explicit non-production signature status, quarantine on invalid/revoked/corrupt packs, and verified last-known-good pack availability after failed replacement attempts. FCP27 remains blocked until the rerun sequence continues through later manifest batches.

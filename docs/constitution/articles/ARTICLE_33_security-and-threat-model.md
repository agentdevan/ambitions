# Article 33 — Security and threat model

## SECURITY-001 — Threat model coverage

The active threat model covers local stores, files, App Group, extensions, deep links, imports, attachments, notification actions, App Intents, EventKit, CloudKit, diagnostics, backups, account, Source Atlas, and dependencies.

## SECURITY-002 — Hostile input

ICS, URLs, deep links, files, scans, text, metadata, and external records are untrusted. Parsers enforce size, recursion, decompression, path, encoding, and resource limits.

## SECURITY-003 — Sensitive surface protection

App-switcher snapshots, notification previews, widgets, Spotlight, clipboard, screen capture, diagnostics, and exports follow explicit sensitive-content policy.

## SECURITY-004 — Secrets and keys

Secrets do not live in source, logs, fixtures, or public artifacts. Keychain/file-protection ownership, rotation, development/production separation, and recovery are documented.

## SECURITY-005 — Dependency security

Dependencies require license, maintenance, privacy, security, update, SBOM, vulnerability-response, and removal review.

## SECURITY-006 — Abuse-case proof

Security acceptance includes malformed input, replay, spoofed routes/actions, duplicate commands, tampered backups, corrupted snapshots, compromised external records, and privacy-egress attempts.

---

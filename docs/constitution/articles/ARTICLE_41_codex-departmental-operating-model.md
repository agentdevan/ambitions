# Article 41 — Codex departmental operating model

## CODEX-DEPT-001 — Role separation

Ambitions work is reviewed through applicable independent roles:

- Product architecture,
- Design system/frontend,
- Runtime/domain,
- Persistence,
- Privacy/security,
- QA/reliability,
- Accessibility,
- Performance,
- Release,
- Repo governance.

## CODEX-DEPT-002 — Author cannot self-accept

The authoring implementation pass may produce Source, Runtime, or Interaction evidence. Independent review is required for Visual, security-sensitive, data-migration, and release acceptance.

## CODEX-DEPT-003 — Required handoff

Every handoff contains laws, source owners, current source readback, changed files, invariants, tests, proof, unsupported claims, risks, and rollback.

## CODEX-DEPT-004 — Stop conditions

Codex stops and reports Red for data-loss risk, privacy-boundary breach, unresolved duplicate authority, failing required lane, unreviewable visual evidence, unapproved destructive migration, or unsupported release claim.

---

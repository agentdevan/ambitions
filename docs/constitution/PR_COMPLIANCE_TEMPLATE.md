# Ambitions Constitutional PR Compliance Manifest

Use this manifest for every substantive Ambitions PR. Remove sections only when explicitly inapplicable and state why.

## Scope identity

```text
PR:
Branch:
Base:
Head commit:
Authoring role:
Independent reviewers required:
```

## Constitutional coverage

```text
Laws implemented or affected:
P0/P1 opportunities implemented or affected:
Canonical scenarios affected:
Primary Project / Parent Feature / Codex leaf:
```

## Product and architecture

```text
User outcome:
Product law preserved:
Canonical source owners touched:
Old authority deleted, moved, or demoted:
Compatibility debt retained and removal plan:
New architecture nouns introduced and justification:
```

## Domain, runtime, and persistence

```text
Objects and state axes affected:
Commands:
Events:
Transactions / write sets:
Projection invalidations or rebuilds:
Receipts / history / replay:
Schema or persisted identifier changes:
Migration required:
Backup / restore / rollback behavior:
Crash-consistency behavior:
```

## Concurrency and lifecycle

```text
Isolation owners:
MainActor impact:
Tasks and cancellation:
Reentrancy risks:
Background / foreground / termination behavior:
Clock or time-zone behavior:
```

## Privacy and security

```text
Data classifications touched:
Network or external-system egress:
Redaction / minimum payload:
Permissions or sensitive actions:
Threat / abuse cases:
Security review required:
```

## Frontend and accessibility

```text
Rendered states affected:
Navigation / focus / restoration:
Dynamic Type:
VoiceOver / Voice Control / Switch Control:
Reduce Motion / Reduce Transparency / contrast:
Keyboard / safe area / one-hand behavior:
Positive visual target:
Screenshot matrix:
Independent visual review required:
```

## Performance and reliability

```text
Budgets affected:
Measurement environment and data scale:
Before / after measurements:
Failure injection:
Diagnostics / logging:
Incident or rollback considerations:
```

## Validation and proof

```text
Validation run:
Validation result:
Validation not run and why:
Expected failures:
Skipped required lanes:
Proof artifacts:
Known-issue rows updated:
Residual risks:
```

## Claim ceiling

```text
Source Green:
Runtime Green:
Interaction Green:
Ready for Visual Review:
Visual Green: independent review only
Release Green: release authority only
Unsupported claims:
```

## Rollback

```text
Rollback trigger:
Rollback procedure:
Data migration rollback limits:
External-effect reconciliation:
```

## Closeout block

```text
Status: Green / Yellow / Red
Scope completed:
Files changed:
Product law preserved:
Validation run:
Validation not run:
Proof artifacts:
Known risks:
Follow-up required:
Rollback plan:
```

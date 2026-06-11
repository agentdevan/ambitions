# UIQL Issue Template

Status: Active UIQL issue template
Authority: Required template for future Ambitions Flagship UI Quality Lockdown issue execution and closeout

Use this template for every UIQL issue before edits and again at closeout. Replace bracketed text with current evidence. Do not remove sections because a section is inconvenient; mark it `not applicable` only with a reason.

## Issue Header

```markdown
Actual Linear issue: AMB-___
UIQL sequence label: UIQL-___
Title:
Project: Ambitions Flagship UI Quality Lockdown
Branch policy: main only, no branches
Issue type: docs/process / read-only proof / source repair / visual proof / accessibility proof
```

## Required Mapping Check

```markdown
Fetched Linear using actual AMB ID: yes / no
Synthetic UIQL label used for Linear operation: no
Current Linear status:
Project:
Milestone:
Blocking comments:
```

## Active Root / Source Dependency

```markdown
Active root/source dependency:
- App entry:
- Root shell:
- Surface route:
- Capture route:
- Source ownership proof command:
- Source ownership result:
```

## Product Object

```markdown
Product object:
- Surface:
- Primary object:
- Primary user action:
- Trust/source/receipt path:
- Why this is not a generic card/list/dashboard/form/calendar/chatbot pattern:
```

## Surface Owner

```markdown
Surface owner:
- Source files:
- Test files:
- Artifact files:
- Existing proof:
```

## Existing Primitives To Inspect First

```markdown
Existing primitives inspected:
- Shared primitive:
- Feature primitive:
- No-card taxonomy reference:
- Reuse decision:
- New primitive created: no / yes with explicit reason
```

Default: no new primitive. Extend or reuse an existing owner unless the missing capability is proven.

## Red Conditions

```markdown
Red conditions checked:
- screenshot path treated as proof:
- focused tests treated as visual proof:
- unreadable dock:
- safe-area collision:
- clipped text:
- card/list/dashboard/settings/form anatomy:
- implementation/spec/debug/admin language:
- stale IA:
- Capture as tab:
- Pulse as current tab:
- missing accessibility semantics:
- missing trust/source/receipt path:
- owner approval claimed before AMB-969:
- release/TestFlight/App Store readiness claimed:
```

## Screenshot Paths

```markdown
Screenshot paths required:
- default:
- source unavailable / empty / recovery / selected variant:
- Dynamic Type:
- Reduce Motion:
- Reduce Transparency:
- Increase Contrast:
- Capture activated / keyboard if applicable:

Visual evaluation summary:
- what is visible:
- what is readable:
- what is clipped:
- dock/safe-area state:
- why Green is or is not honest:
```

Screenshot path existence is not proof. Every screenshot used for Green must be visually evaluated.

## Accessibility Variants

```markdown
Accessibility evidence:
- VoiceOver labels/order:
- Dynamic Type:
- Reduce Motion:
- Reduce Transparency:
- Increase Contrast:
- Differentiate Without Color:
- 44pt tap targets:
- Keyboard/Capture seam:
- Not verified:
```

No UI surface Green without accessibility variant evidence for the touched surface. If a variant is blocked by tooling, record Yellow only when the product UI itself is not Red.

## Copy / Canon Scan

```markdown
Copy/canon scan:
- Command:
- Exit code:
- Artifact:
- Active violations:
- Classified historical/support-only hits:
```

Forbidden active UI copy includes generic task language, implementation/spec/debug/admin copy, AI-wrapper language, stale IA, `Begin Focus`, `best next move`, `next best move`, and shame/productivity-guilt language.

## Candidate Green Closeout Block

```markdown
UIQL firewall verdict: Green / Yellow / Red
Actual Linear issue:
UIQL sequence label:
Active root/source dependency:
Product object:
Surface owner:
Existing primitives inspected:
Screenshot visual evaluation:
Accessibility variant evidence:
Copy/canon scan:
Card/list/dashboard anatomy scan:
Shell/safe-area/dock proof:
Focused validation:
Changed files:
Proof artifacts:
Red blockers:
Yellow tooling/device limits:
No-claim boundary:
Next dependency:
```

## Linear Comment Template

```markdown
AMB-___ / UIQL-___ closeout: [title]

Status: Green / Yellow / Red
Pushed to main: yes / no
Commit:
Artifacts:
Screenshots:

Validation:
- command: status, artifact

No-claim boundary:
- No owner approval claimed.
- No release/TestFlight/App Store readiness claimed.
- No accessibility certification claimed unless explicitly proven.
- No product completion claim.

Next dependency:
```

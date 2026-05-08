# Codex Evidence Standard

Status: Active evidence and claim-boundary standard.  
Date: 2026-05-07  
Scope: Required evidence for Codex OS reports, gates, batch trains, and implementation claims.

## Evidence Packet

A valid evidence packet contains:

```text
- task
- scope
- files touched
- commands run
- exit codes
- raw log paths when commands ran
- summarized output
- validation tier
- Green / Yellow / Red classification
- unsupported or deferred claims
- next eligible action
```

## Raw Logs

Summarized output is acceptable for navigation and routine summaries. Raw logs are mandatory for:

- failed builds
- failed tests
- failed gates
- hard Reds
- release-readiness claims
- TestFlight/App Store claims
- device proof
- public accessibility proof
- legal/privacy compliance claims
- destructive or migration operations

## Claim Matrix

| Claim | Minimum evidence |
| --- | --- |
| Docs file created/updated | File path plus diff or GitHub commit evidence. |
| Script syntax checked | `python3 <script> --help` or equivalent exit code. |
| Script preserves failure | A deliberately failing local validation command with nonzero exit code. |
| Build passes | Raw `xcodebuild` or documented build command log for current commit. |
| Tests pass | Raw test log for current commit. |
| UI looks correct | Fresh screenshot/rendered proof plus visual QA notes. |
| Accessibility reviewed | VoiceOver/Dynamic Type/Reduce Motion proof or explicit Yellow. |
| Device verified | Physical-device operator evidence. |
| Release-ready | Release checklist evidence plus human/operator signoff. |

## Forbidden Claim Shortcuts

Do not claim any of the following from docs-only work, summarized logs, or intent:

- production-ready
- release-ready
- fully tested
- fully accessible
- App Store ready
- TestFlight ready
- device verified
- privacy compliant
- legally approved
- performance safe

## Evidence Location

Generated local logs stay under:

```text
.codex/logs/
```

Committed audit and handoff evidence should use:

```text
docs/audits/
docs/handoff/
.codex/reports/
```

Commit generated logs only when explicitly requested and scrubbed.

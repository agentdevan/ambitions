# Codex Evidence Standard

Status: Active Codex OS evidence standard; not release or compliance proof.
Date: 2026-05-07

## Evidence Packet Required Fields

- task
- scope
- files touched
- files intentionally not touched
- commands run
- exit codes
- raw logs
- validation tier
- gates
- screenshots/rendered proof when UI is touched
- human/device proof when claimed
- claims not made
- Green / Yellow / Red result
- next eligible action

## Proof States

| State | Meaning | Required proof |
| --- | --- | --- |
| Planned | Future work is described. | Owner doc or roadmap entry. |
| Canonized | Source truth has accepted the concept. | Canon owner doc. |
| Scaffolded | Structural placeholder, prompt, model, or docs exist. | Files and boundaries. |
| Implemented | App/source behavior exists. | Source evidence and relevant tests/build as scoped. |
| Built | Build command completed. | Raw build log and exit code. |
| Tested | Test command completed. | Raw test log and exit code. |
| Device verified | Physical device proof exists. | Human/operator device evidence. |
| Accessible | Accessibility claim has proof. | Scope-specific accessibility evidence and limitations. |
| Privacy/legal reviewed | Human review completed. | Human/legal/privacy review artifact. |
| Release-ready | Release checklist and human approvals complete. | Matching release evidence; Codex cannot infer it. |

## Forbidden Claim Shortcuts

Do not say production-ready, release-ready, fully tested, fully accessible, App Store ready, TestFlight ready, device verified, privacy compliant, legally approved, or performance safe unless matching evidence exists.

## Raw Log Policy

Raw command output is the durable proof. Summaries help humans, but they do not replace raw logs. ACX Local logs are local-only under `.codex/logs/`; committed reports should reference paths when useful without committing noisy raw files.

## Green / Yellow / Red

- Green: required proof exists and claims are bounded.
- Yellow: gap is owned, safe, and nonblocking with no-claim boundary.
- Red: proof is missing for a required claim, scope is unsafe, source truth conflicts, or validation fails.
- Hard Red: Red that must stop continuation.

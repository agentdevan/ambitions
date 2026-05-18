# AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01 Review Board

Status: supporting review board
Authority: subordinate to `docs/truth/*`

This board records the review posture for the UI Studio installer. It is a control-plane artifact, not a source-truth or release artifact.

## Review Lanes

| Lane | Question | Evidence expected | Status |
| --- | --- | --- | --- |
| Authority | Does the install stay subordinate to truth files and the active frontend portal? | Links to the operating system doc and authority index | Pending |
| IA | Does it preserve `Today / Goals / Capture / Time / You` and keep Plan compatibility-only? | README and authority index updates | Pending |
| Prompt hygiene | Do all generated prompts carry the runner metadata header and batch ID? | `make prompt-audit` | Pending |
| State coverage | Do the prompt files cover the required empty/normal/dense/recovery/error states? | Screen-state matrix | Pending |
| Anti-generic | Does the install reject dashboard, chatbot, task-list, and calendar-clone defaults? | Operating system doc and red-team prompt | Pending |
| Proof posture | Does the install treat preview/screenshot matrices as proof requirements instead of proof claims? | Matrix and review board | Pending |

## Review Notes

- This board is intentionally narrow.
- It supports future UI work by defining the review questions up front.
- It does not authorize a broader redesign.

## Non-Claims

This review board does not claim app implementation, screenshot validation, accessibility conformance, or release readiness.

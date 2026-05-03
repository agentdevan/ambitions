# Yellow Owner Ledger

Status: Active accepted-Yellow ledger
Date: 2026-05-03

Accepted Yellow is allowed only when it is explicitly safer than Red, has an
owner, and does not support an unsupported release, accessibility, device, or
production claim.

| Yellow ID | Accepted by batch | Why Yellow, not Red | Owner future batch / lane | Required proof to turn Green | Category | Blocks release claims |
| --- | --- | --- | --- | --- | --- | --- |
| Y-DAV-SCREENSHOT-001 | DAV14 / DAV15 | DAV12 preview fixtures exist and no screenshot proof claim was made. | Screenshot automation or human visual QA | Named rendered screenshots for DAV scenarios. | Visual proof | Yes |
| Y-DAV-HUMAN-VISUAL-001 | DAV14 / DAV15 | Source, preview, and scorecard evidence exist; human visual review was not claimed. | Visual QA board | Human inspection notes for DAV surfaces. | Visual proof | Yes |
| Y-DAV-DEVICE-001 | DAV14 / DAV15 | Simulator build/source evidence passed; physical device was not claimed. | Device QA / release evidence lane | Device model, OS, build, scenario, and result. | Device proof | Yes |
| Y-DAV-VOICEOVER-001 | DAV11 / DAV15 | Source and focused accessibility evidence exist; manual traversal was not claimed. | Accessibility QA | Manual VoiceOver traversal by surface. | Accessibility proof | Yes |
| Y-DAV-CONTRAST-001 | DAV11 / DAV15 | Non-color meaning evidence exists; measured contrast was not claimed. | Accessibility / visual QA | Contrast measurements and repair notes. | Accessibility proof | Yes |
| Y-DAV-PERF-001 | DAV13 / DAV15 | Rendering risk ledger exists; measured energy safety was not claimed. | Performance QA | Instruments or equivalent profiling evidence. | Performance proof | Yes |
| Y-DOC-QA-001 | DAV14 / DAV15 | Findings are known docs backlog, guardrails, or historical terms. | Docs hygiene lane | Reduced/classified markdownlint and deprecated-language logs. | Docs-only | No |

## Rules

- A Yellow cannot be used to claim production readiness.
- A Yellow cannot be erased by silence in a later closeout.
- If a Yellow affects user-facing behavior, accessibility, privacy, release,
  or compatibility, the owner must be a named future batch or QA lane.
- A repeated Yellow becomes Red only when a later batch depends on the missing
  proof and still tries to claim Green.

# Frontend Open Question Ledger

Status: Frontend freeze open questions / Implemented Yellow
Date: 2026-07-05
Scope: AMB-1733
Baseline SHA: `e30f3f40043ab995f295643c8d054343b86d15a8`

## Ledger

| ID | Question | Current answer | Blocks Ready For Codex? | Follow-up |
| --- | --- | --- | --- | --- |
| FQ-001 | What is the canonical raw deep-research report artifact? | Current repo search found durable summaries and bridge docs, especially `docs/audits/amb-1746-frontend-research-extension-gate.md`, but no separate raw frontend deep-research report path was identified in this pass. | no, if the leaf uses current repo truth and AMB-1746/AMB-1751 summaries | If a raw report exists outside repo, add it as a linked evidence input without treating it as implementation proof. |
| FQ-002 | Which screenshot packet is current for `main`? | None produced by AMB-1733 or AMB-1751. Historical packets remain evidence only. | yes for visual claims | Use AMB-1749/AMB-1750 lanes when testing is re-enabled. |
| FQ-003 | Which route proofs can be source-only? | Registry and shell-route classification can be source-only Yellow; rendered journey, accessibility, device, and release claims cannot. | yes for Green claims | Keep source-only work Yellow and attach exact proof follow-ups. |
| FQ-004 | Are widget/share/App Intent external surfaces in frontend recovery scope? | They are active targets and route inputs, but current registry classifies them as partial/external proof-limited. | yes for release claims | Use a scoped external-route proof leaf before any release claim. |
| FQ-005 | Can parent features close without child runtime proof? | Registry/freeze parents can close Yellow when their required docs exist; runtime/visual parents cannot claim Green without current proof. | yes for runtime parents | Keep AMB-1736 through AMB-1744 proof-limited until scoped implementation/proof exists. |
| FQ-006 | What is the owner acceptance standard? | Current repo law requires linked evidence, explicit non-claims, and proof ceiling. Owner visual acceptance is still separate. | yes for Visual Green | Attach owner review only to visual/device proof leaves. |

## Non-Blocking Decision

AMB-1733 may close as a freeze/intake parent because it installs durable intake,
freeze, question, and validation artifacts. The open questions above constrain
later implementation leaves and do not authorize UI work or Green claims.

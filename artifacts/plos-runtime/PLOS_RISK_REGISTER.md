# PLOS Risk Register

Status: Active readiness-control risk register
Updated: 2026-06-12

| Risk | Class | Why it matters | Gate / mitigation | Current status |
|---|---|---|---|---|
| Synthetic issue drift | Red | PLOS labels can look like issue identifiers but Linear writes require real `AMB-*` IDs. | `PLOS_LINEAR_ISSUE_MAP.json`, `plos-readiness-validate.py`, closeout validator, Red stop for PLOS label writes. | Controlled for phase parents; child labels must live-resolve before use. |
| False Green | Red | Governance or heading checks can pass while runtime, privacy, safety, or owner proof is absent. | Expanded phase gates, reviewer prompts, closeout fields, explicit proof boundary in run-state. | Controlled for readiness; runtime proof still future. |
| Phase-order violation | Red | Later runtime work can invalidate foundations if M00/M01/M10 gates are bypassed. | Strict `M00..M26` queue and phase-gate validator. | Controlled by queue; execution remains blocked for owner review. |
| Runtime implementation during readiness hardening | Red | The current task is control-plane hardening only. | Allowed path scope excludes app source and project files; preflight blocks dirty source paths. | Controlled in current run. |
| Private user data in R2 | Red | Source Atlas may use public reference distribution, not user-private data storage. | Source Atlas hardening plan, R2 boundary standard, Source Atlas validator. | Controlled as policy; future implementation must prove. |
| Required cloud LLM/core server drift | Red | Ambitions core intelligence must remain local-first and inspectable. | Truth-file authority, PLOS red gates, reviewer prompts. | Controlled as policy; future implementation must prove. |
| Source Atlas duplicate architecture | Yellow/Red | New pack tooling could bypass existing Source Atlas scripts, receipts, or rollback paths. | Source Atlas Factory hardening plan and validator require reuse, source binding, release receipt, rollback. | Yellow until future source mapping is completed under M01/M04/M05/M06. |
| Child issue map incompleteness | Yellow | Phase parent map is complete, but a future child run can still drift if it uses a PLOS child label directly. | Child execution requires live Linear resolution to `AMB-*` and run-state recording before work. | Yellow by design; fail-closed at child execution. |
| Context churn across compaction | Yellow | Long PLOS execution can lose phase, issue, validation, and proof state. | Expanded run-state, execution queue, closeout template, validator support. | Controlled for current handoff. |
| Release/readiness overclaim | Red | Local simulator or docs proof is not release proof. | Release truth, closeout validator, audit proof boundary. | Controlled by closeout requirements. |
| Validator blind spot | Yellow | Validators can check structure, not product truth or visual/runtime behavior. | Reviewer prompts and focused validation remain mandatory for source-changing phases. | Yellow; owned by phase-specific execution. |

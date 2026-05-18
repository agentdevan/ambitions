# AMB-FE-BE Implementation Manifest

Status: Installed docs-only manifest
Scope: Train installer and prompt registry only

## Train summary

This manifest is registry and sequencing support only. It does not claim implementation, release readiness, or proof, and it cannot widen the train beyond the contract boundary recorded in the companion contract note.

| Batch | Stage | Objective | Main scope | Next dependency |
| --- | --- | --- | --- | --- |
| AMB-FE-BE-PREFLIGHT-00 | docs/governance | Re-ground repo authority, detect duplicates/obsoletes, and confirm safe runner posture. | Registry, prompt, truth, and readiness inspection. | AMB-FE-BE-CONTRACT-FREEZE-01 |
| AMB-FE-BE-CONTRACT-FREEZE-01 | docs/governance | Freeze the product/design and source contracts for the train. | IA, local-only/no-claim boundaries, source freshness, protected time, receipts, and replay/restoration contracts. | BE-01-RUNTIME-BASELINE |
| BE-01-RUNTIME-BASELINE | docs + implementation | Bound the private-life runtime around existing local runtime/container/persistence/repository seams. | Runtime boundaries and local-only source wiring. | BE-02-LEDGER-REPLAY |
| BE-02-LEDGER-REPLAY | docs + implementation | Formalize ledger taxonomy, idempotency, replay, and double-apply protection. | Command, event, side-effect, and receipt ledgers. | BE-03-REALITY-MERIDIAN-CAPACITY |
| BE-03-REALITY-MERIDIAN-CAPACITY | docs + implementation | Make Reality Meridian and capacity projection backend-owned and UI-consumable. | Protected time, pressure, conflicts, and time-fit proof. | BE-04-RECOMMENDATION-DETERMINISM |
| BE-04-RECOMMENDATION-DETERMINISM | docs + implementation | Keep recommendations deterministic and inspectable. | Fixed clocks/IDs and no LLM dependency. | BE-05-PROOF-FRESHNESS-RECEIPTS |
| BE-05-PROOF-FRESHNESS-RECEIPTS | docs + implementation | Add durable proof, receipts, closure, recovery, and source freshness. | Lineage and proof trails. | BE-06-PROTECTED-TIME-PRIVACY |
| BE-06-PROTECTED-TIME-PRIVACY | docs + implementation | Enforce protected-time and privacy boundaries. | Local-only posture and export/delete handling. | BE-07-VERTICAL-SLICE-PROOF |
| BE-07-VERTICAL-SLICE-PROOF | docs + implementation | Prove one local end-to-end moat slice. | Capture to placement, receipt, closure, replay, report. | BE-08-DIAGNOSTICS-MIGRATION-HARDENING |
| BE-08-DIAGNOSTICS-MIGRATION-HARDENING | docs + implementation | Harden diagnostics, migration, and rollback notes. | SLO proof, schema notes, and failure classification. | FE-01-CANON-FREEZE |
| FE-01-CANON-FREEZE | docs/governance | Freeze final IA, root ownership, and migration map. | Frontend doc classification and deprecated terminology. | FE-02-DESIGN-LANGUAGE |
| FE-02-DESIGN-LANGUAGE | docs/governance | Freeze the Ambitions design language. | One-primary-object rule, native iOS rules, proof language, recovery tone. | FE-03-TOKENS |
| FE-03-TOKENS | docs + implementation | Define token architecture for the shared visual system. | Color, material, typography, motion, accessibility, proof, freshness. | FE-04-PRIMITIVES |
| FE-04-PRIMITIVES | docs + implementation | Define the primitive system for the flagship objects. | Graphite Recess, Quiet Glass, receipt, source, and closure primitives. | FE-05-GEOMETRY-REALITY-MERIDIAN |
| FE-05-GEOMETRY-REALITY-MERIDIAN | docs + implementation | Lock Reality Meridian geometry/topology. | NOW marker, current-time glow, proof trail, Dynamic Type. | FE-06-SHELL-MIGRATION |
| FE-06-SHELL-MIGRATION | docs + implementation | Lock the five-tab shell migration. | Today / Goals / Capture / Time / You. | FE-07-ROOT-SURFACES |
| FE-07-ROOT-SURFACES | docs + implementation | Build the five flagship root surfaces around one dominant object. | Surface ownership and drill-down seams. | FE-08-PROOF-RECEIPTS-TRUST |
| FE-08-PROOF-RECEIPTS-TRUST | docs + implementation | Build receipts, proof, freshness, and trust surfaces. | Trust & Automation and recovery states. | FE-09-COMPONENT-SYSTEM |
| FE-09-COMPONENT-SYSTEM | docs + implementation | Define the component system and preview matrix. | Shared UI primitives and fixtures. | FE-10-INTERACTION-ACCESSIBILITY |
| FE-10-INTERACTION-ACCESSIBILITY | docs + implementation | Lock motion, haptics, Dynamic Type, VoiceOver, and non-color meaning. | Accessibility and interaction guardrails. | FE-11-PREVIEWS-VISUAL-QA |
| FE-11-PREVIEWS-VISUAL-QA | docs + implementation | Install preview, screenshot, and honest visual QA infrastructure. | Visual proof reporting. | FE-12-CHROME-CONTRACTS-HARDENING |
| FE-12-CHROME-CONTRACTS-HARDENING | docs/handoff | Harden final chrome and contract binding. | Visual anti-generic checks and rollback notes. | AMB-FE-BE-INTEGRATED-PROOF-99 |
| AMB-FE-BE-INTEGRATED-PROOF-99 | docs/handoff | Prove the local FE/BE integration themes. | Exact IA, protected time, replay, privacy/local-only posture. | Train closeout |

## Execution gate

Do not run later implementation stages if earlier contract/foundation stages are Red, unless the later stage is explicitly a repair batch.

## Validation baseline

- `git status --short`
- `git diff --check`
- `make runner-access-check`
- `make batch-self-check`
- `make prompt-audit`
- `scripts/ambitions-codex-train.sh --help`
- `python3 scripts/ambitions-swift6-modernization-scan.py --help`

## Non-claims

This manifest does not claim the train is active queue truth, implemented, validated, or release-ready. It does not authorize hosted AI, hosted sync, or cloud user-data claims for any downstream batch.

# Ambitions Master Build Execution Queue

Status: Active Goal Mode queue for the new master-build project
Generated: 2026-06-14
Scope: Ambitions Personal Life OS Runtime + Native iPhone App Master Build Program

## Queue Rules

- Work on `main`.
- Use actual `AMB-*` Linear identifiers.
- Refresh live Linear state before each train.
- Execute in milestone/train order unless live Linear dependencies require a different earlier unblocked control-plane train.
- Do not claim full project Green until M11 certification passes with current proof.
- Source-changing trains require source ownership proof, focused validation, proof artifacts, commit, push, and Linear reconciliation.

## Ordered Queue

| Rank | Train | Linear issue | Title | Gate command | Current state |
|---:|---|---|---|---|---|
| 0 | CONTROL | AMB-1126 | Rebuild Linear as the Ambitions execution control plane | `scripts/codex/program-phase-gate.sh amb-master M00` | Done in Linear |
| 1 | M00.T00 | AMB-1046 | Program umbrella: master build authority and execution run | `scripts/codex/program-phase-gate.sh amb-master M00` | Done / pushed (`004a258378a92a21ad384c6ce239b2fb36c94e7d`) |
| 2 | M00.T01 | AMB-1047 | Canon authority and IA lock: Today / Goals / Time / Motion / You | `scripts/codex/program-phase-gate.sh amb-master M00` | Done / pushed (`8f5cfc1dae8c684571e17dabba765eb937ab2169`) |
| 3 | M00.T02 | AMB-1048 | Live repository wiring and quarantine proof | `scripts/codex/program-phase-gate.sh amb-master M00` | Done / pushed (`b0f9305aff9ce5b44ef17e6d1ebe4a2414955f30`) |
| 4 | M01.T01 | AMB-1049 | Data lifecycle and replay foundation | `scripts/codex/program-phase-gate.sh amb-master M01` | In Progress |
| 5 | M01.T02 | AMB-1050 | Migration and versioned schema foundation | `scripts/codex/program-phase-gate.sh amb-master M01` | Backlog |
| 6 | M01.T03 | AMB-1051 | Privacy and security storage boundary | `scripts/codex/program-phase-gate.sh amb-master M01` | Backlog |
| 7 | M01.T04 | AMB-1052 | Support bundle and diagnostics | `scripts/codex/program-phase-gate.sh amb-master M01` | Backlog |
| 8 | M01.T05 | AMB-1053 | Source Atlas cache and failure-safe runtime consumption | `scripts/codex/program-phase-gate.sh amb-master M01` | Backlog |
| 9 | M01.T06A | AMB-1127 | Source Atlas Pack / Seed Foundry | `scripts/codex/program-phase-gate.sh amb-master M01` | Backlog |
| 10 | M01.T06B | AMB-1128 | Source Authority Mesh | `scripts/codex/program-phase-gate.sh amb-master M01` | Backlog |
| 11 | M02.T00 | AMB-1113 | Runtime core umbrella | `scripts/codex/program-phase-gate.sh amb-master M02` | Backlog |
| 12 | M02.T01 | AMB-1111 | Step Quality Firewall | `scripts/codex/program-phase-gate.sh amb-master M02` | Backlog |
| 13 | M02.T02 | AMB-1112 | Any Goal Runtime | `scripts/codex/program-phase-gate.sh amb-master M02` | Backlog |
| 14 | M02.T03 | AMB-1129 | Multi-Path Lattice | `scripts/codex/program-phase-gate.sh amb-master M02` | Backlog |
| 15 | M02.T04 | AMB-1130 | Step Graph Compiler | `scripts/codex/program-phase-gate.sh amb-master M02` | Backlog |
| 16 | M02.T05 | AMB-1131 | Step Elasticity Engine | `scripts/codex/program-phase-gate.sh amb-master M02` | Backlog |
| 17 | M02.T06 | AMB-1132 | Schedule Install Kernel | `scripts/codex/program-phase-gate.sh amb-master M02` | Backlog |
| 18 | M02.T07 | AMB-1133 | Life Consequence Engine | `scripts/codex/program-phase-gate.sh amb-master M02` | Backlog |
| 19 | M02.T08 | AMB-1117 | High-risk safety and jurisdiction handling | `scripts/codex/program-phase-gate.sh amb-master M02` | Backlog |
| 20 | M03.T01 | AMB-1114 | Golden vertical slice | `scripts/codex/program-phase-gate.sh amb-master M03` | Backlog |
| 21 | M03.T02 | AMB-1115 | First-run activation | `scripts/codex/program-phase-gate.sh amb-master M03` | Backlog |
| 22 | M04 | live AMB issue set | Native Shell + Design System Foundation | `scripts/codex/program-phase-gate.sh amb-master M04` | Blocked pending M03 |
| 23 | M05 | live AMB issue set | Today + Step Execution Surface | `scripts/codex/program-phase-gate.sh amb-master M05` | Blocked pending M04 |
| 24 | M06 | live AMB issue set | Goals, Paths, Capture, and Time | `scripts/codex/program-phase-gate.sh amb-master M06` | Blocked pending M05 |
| 25 | M07 | live AMB issue set | Motion, Proof, Recovery, Sharing, Year | `scripts/codex/program-phase-gate.sh amb-master M07` | Blocked pending M06 |
| 26 | M08 | live AMB issue set | You, Privacy, Diagnostics, Export, Support | `scripts/codex/program-phase-gate.sh amb-master M08` | Blocked pending M07 |
| 27 | M09 | live AMB issue set | Apple System Surfaces | `scripts/codex/program-phase-gate.sh amb-master M09` | Blocked pending M08 |
| 28 | M10 | live AMB issue set | Commerce, Demo, Review, Compliance | `scripts/codex/program-phase-gate.sh amb-master M10` | Blocked pending M09 |
| 29 | M11 | live AMB issue set | Accessibility, Performance, Polish, Certification | `scripts/codex/program-phase-gate.sh amb-master M11` | Blocked pending M10 |

## Next Eligible Action

Execute `AMB-1049` / `M01.T01` from live Linear: prove source ownership, run the M01 gate, implement deterministic receipt/replay persistence, validate, push, and reconcile Linear.

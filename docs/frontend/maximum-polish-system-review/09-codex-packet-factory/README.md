# 09 — Codex Execution-Packet Factory

Each packet is a bounded execution contract, not a new program. It names authority, protected decisions, exact evidence, stop conditions, proof order, and non-goals. The template separates context required to decide from context required to implement.

## Packets included

- `EXECUTION_PACKET_TEMPLATE.md`
- `packets/goals-r03-native-candidate.md`
- `packets/you-maximum-polish.md`
- `packets/search-capture-maximum-polish.md`
- `packets/trust-recovery-maximum-polish.md`
- `packets/fr2-entry.md`

## Usage law

Do not run a packet until its entry gate is true. Do not broaden scope because adjacent files are interesting. Read source index once, then only the packet’s named authority/evidence. Stop at the packet’s decision gate rather than automatically producing every possible proof artifact.

---
name: ambitions-anti-pattern-detection
description: Use before Ambitions implementation to identify and gate likely product-quality failures such as card stacks, report panels, duplicate ownership, fake intelligence, and screenshot-path proof.
---

# Ambitions Anti-Pattern Detection Skill

Before implementing, list the top risks for regression into:

- card stack
- report panel
- duplicate shell ownership
- internal vocabulary
- fake intelligence
- screenshot-path proof
- lexical test proof
- generic SwiftUI controls
- old fallback reachability
- non-native chrome

For each risk, create a test, audit, script, target rubric, or explicit Yellow note.

If no test/audit/proof is created for a risk, the risk remains Yellow.

## Hard Stops

- A vertical stack of canonical components as a root product object is Red.
- A report panel as the primary object is Red.
- Duplicate crown/Capture/Search/dock ownership is Red.
- Fabricated minimum-count intelligence is Red.
- Codex self-certified Visual Green is Red.

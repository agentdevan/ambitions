---
name: ambitions-skill-compatibility-router
description: Compatibility router from legacy .codex Ambitions skill wrappers to canonical .agents/skills lanes.
---

# Ambitions Skill Compatibility Router

This folder is a compatibility router only. It is not a separate active skill system and does not override `docs/truth/*`.

Use canonical `.agents/skills/*/SKILL.md` lanes for active Ambitions work:

| Need | Canonical lane |
|---|---|
| Authority/source truth | `.agents/skills/ambitions-source-truth-authority/SKILL.md` |
| Runner/batch execution | `.agents/skills/ambitions-batch-runner-operator/SKILL.md` |
| iOS/Xcode validation | `.agents/skills/ambitions-ios-validation-xcode-wrapper/SKILL.md` |
| Release proof honesty | `.agents/skills/ambitions-release-proof-honesty/SKILL.md` |
| Privacy/local-first | `.agents/skills/ambitions-privacy-local-first/SKILL.md` |
| Accessibility proof | `.agents/skills/ambitions-accessibility-proof/SKILL.md` |
| Visual/product quality | `.agents/skills/ambitions-visual-product-quality/SKILL.md` |
| Runtime/persistence | `.agents/skills/ambitions-runtime-persistence/SKILL.md` |
| External surfaces | `.agents/skills/ambitions-external-surfaces/SKILL.md` |
| Repo hygiene/rollback | `.agents/skills/ambitions-repo-hygiene-rollback/SKILL.md` |

Legacy wrappers in this folder may provide historical extraction clues only when compatible with the canonical lanes and `docs/truth/*`.

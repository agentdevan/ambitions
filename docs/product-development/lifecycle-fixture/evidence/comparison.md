# Lifecycle Fixture repository-drift comparison evidence

## Purpose

This file is repository evidence for the synthetic `Lifecycle Fixture` initiative. It documents how the installed lifecycle package distinguishes relevant repository drift from unrelated drift without proposing Ambitions product behavior, changing canon, authorizing implementation, or issuing a review verdict.

## Repository and package baseline

- Repository: `agentdevan/ambitions`
- Branch inspected: `codex/product-development-lifecycle`
- Pre-authoring remote branch HEAD: `2199f8de3b19dddf16cb42d995f77a581ddee03d`
- Pre-authoring comparison result: the named branch and the supplied remote HEAD were identical.
- Active skill version: `1.0.0`
- Active package hash: `sha256:b810179fdc59fb037091b03502b226d996d9ea128cde7118d60eee46e7e178cf`
- Research template: `research-v1`
- Research template hash: `sha256:ea95f88f1bcfc75898f5cb32e7a7151a8c094b9791439f7fa4a0cf1466afb39a`

The package manifest binds the operational skill files and supports schema version 1 with `research-v1`, `scope-v1`, and `design-v1`. The research template fixes the document headings and draft metadata shape.

## Evidence inspected

The comparison is supported by these committed repository paths at the pre-authoring remote HEAD:

- `AGENTS.md`
- `.agents/skills/ambitions-product-development-lifecycle/package-manifest.json`
- `.agents/skills/ambitions-product-development-lifecycle/SKILL.md`
- `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/research.md`
- `.agents/skills/ambitions-product-development-lifecycle/references/producer-contract.md`
- `.agents/skills/ambitions-product-development-lifecycle/references/research-review-rubric.md`
- `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/constants.py`
- `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/models.py`
- `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/toml_codec.py`
- `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py`
- `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py`
- `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/repository.py`
- `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/package_identity.py`
- `.agents/skills/ambitions-product-development-lifecycle/tests/test_ambitions_product_docs.py`
- `docs/canon/generated/CODEX_START_HERE.md`
- `docs/canon/CONSTITUTION.md`

No lifecycle design specification, lifecycle implementation plan, SDD workspace, SDD ledger, prior lifecycle conversation, baseline scoring packet, or post-skill expected answer was used.

## Relevant-versus-unrelated drift contract

The installed package derives a sealed document's freshness paths from the union of its declared canon targets, source owners, test owners, dependencies, additional freshness paths, upstream inputs, evidence files, active package manifest, and active template. Generated canon paths are added only when canon targets are declared.

At consumption time, the package compares the document baseline commit with current HEAD. A changed path is relevant when it exactly matches a freshness path or is a descendant of a declared freshness directory. All other changed paths are classified as unrelated.

Relevant drift produces the `semantic-review-required` blocker and must receive an explicit path assessment before a consumer review can pass. Unrelated drift is reported separately and does not by itself create that blocker. This classification does not prove that a document is valid, reviewed, sealed, passed, mergeable, or releasable; those remain separate checks and authority boundaries.

## Installed acceptance fixture comparison

The installed acceptance test provides two synthetic comparison cases:

| Case | Changed path | Declared relationship | Expected classification | Expected consequence |
|---|---|---|---|---|
| Unrelated drift | `notes/unrelated.md` | Outside the lifecycle document's freshness paths | Unrelated | Listed in `unrelated_paths`; no drift blocker from that path |
| Relevant drift | `Sources/Feature.swift` | Declared source owner | Relevant | Listed in `relevant_paths`; `semantic-review-required` blocks consumption until assessed |

The same test constructs a committed Research → Scope → Design chain, binds each downstream lifecycle document to the passed adjacent upstream revision and commit, and checks that relevant drift cannot be silently ignored.

## Lifecycle Fixture application

For this repository-only initiative:

- `canon_targets` remains empty because the fixture does not propose a canon change.
- Lifecycle package source, package identity, producer instructions, rubric, owning canon entry points, and the installed acceptance test are declared as dependencies or owner paths in the Research document.
- This comparison file is declared as hashed evidence.
- Any later change to a declared path is intended to be relevant drift.
- A later change outside the derived freshness union is intended to be unrelated drift.
- The Research document remains a draft. This evidence does not seal it, review it, pass it, or authorize Scope, Design, implementation, merge, or release.

## Limits and recheck triggers

This comparison must be rechecked when the active package hash, selected template hash, drift-classification implementation, installed acceptance test, declared Research owner paths, or repository baseline changes. Unknown future drift must remain explicit and must not be pre-classified without comparing the changed path against the exact sealed freshness set.

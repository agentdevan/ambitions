# Ambitions Repo Intake Gate

Status: ACTIVE

## Purpose

Every new non-generated file must declare why it exists, who owns it, and where it belongs in the authority hierarchy.

This prevents real-time repo sprawl.

## Required Metadata For New Governance / Canon / Prompt Files

Every new active Markdown, JSON, YAML, or prompt file should be classifiable by:

- authority tier: active / supporting / historical / archive-candidate / generated
- owner train or owner system
- supersedes / superseded-by, if applicable
- proof expectation
- cleanup destination
- expected lifetime

## Required Header Pattern

Use this block near the top of new human-authored operational files:

```md
Status: ACTIVE
Owner: <train-or-system>
Authority Tier: <active|supporting|historical|archive-candidate|generated>
Supersedes: <none|path-or-train>
Superseded By: <none|path-or-train>
Proof Expectation: <none|docs-only|implementation|tests|screenshots|device|manual-review>
Cleanup Destination: <none|docs/archive|docs/history|delete-candidate>
Expected Lifetime: <permanent|until-train-closeout|until-replaced|temporary>
```

## Hard Rule

Files that cannot answer these questions are not allowed to become active authority.

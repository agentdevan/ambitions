# Program Adapter Standard

Status: Active Codex OS v2 standard
Authority: Process standard, subordinate to `docs/truth/*`

## What It Is

A program adapter binds one registry entry to one GOAL file, one run-state file, one skill, one artifact root, deterministic scripts, reviewer prompts, proof ledger behavior, and Linear closeout rules.

## What It Is Not

It is not product implementation, a roadmap promise, release proof, or permission to skip source ownership.

## Required Components

Registry entry, GOAL file, run-state file, skill path, script-output and reviewer-output roots, changelog, repair log, decisions file, risk/proof ledger when relevant, deterministic scripts, and closeout template.

## Required Answers

Each adapter must state what it is, what it is not, authority level, when to use, when not to use, inputs, outputs, Green/Yellow/Red, repair/reframe, rollback/failure, Linear closeout, no-claim boundaries, registry interaction, run-state interaction, and proof ledger interaction.

## Gates

Green: adapter can run real future work subject to gates.
Yellow: usable but external authority, Linear, or source truth refresh remains.
Red: conflicts with truth files, duplicates active adapter, leaves thin placeholders, or enables claims without proof.

## Repair / Rollback / Linear

Extend existing adapters. Merge or demote duplicates. Roll back incorrect paths only. Linear closeout names program, issue, hash, proof, validation, non-claims, and next gate.

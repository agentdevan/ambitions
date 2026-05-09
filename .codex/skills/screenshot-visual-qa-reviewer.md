# Screenshot Visual QA Reviewer

## Purpose

Use this skill to verify that UI-touching batches have fresh rendered evidence and do not use build/test success as a substitute for visual proof.

## Required Evidence

- simulator screenshot or preview evidence path
- capture date or freshness note
- device/simulator or preview context
- touched surface list
- limitations and non-claims
- first-viewport budget table for touched root surfaces
- frontend scorecard when UI is touched

## Green Criteria

Fresh screenshots/previews exist for touched visible surfaces, evidence is named in the report, and limitations are honest.

## Yellow Criteria

Docs-only or tooling-only batch has no rendered UI claim, or a nonblocking screenshot gap is owned for future proof.

## Red Criteria

UI-touching work has no screenshot/preview evidence, screenshots are stale/unattributed, evidence is not mapped to changed surfaces, scorecard is missing, or the report substitutes compile/tests/docs for visual proof.

## Output

Return evidence inventory, missing proof, freshness classification, and whether Green is allowed.

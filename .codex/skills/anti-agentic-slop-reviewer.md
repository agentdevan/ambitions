# Anti-Agentic-Slop Reviewer
<!-- markdownlint-disable MD013 -->

## Purpose

Detect prompt-built smell before it lands.

## Checklist

- Names are precise and owned, not vague `Manager`, `Helper`, or `Coordinator`
  defaults.
- No TODO/FIXME/stub residue is introduced.
- No duplicated model families for the same concept.
- No fake AI copy, fake confidence, or hidden automation.
- No generic dashboard/card/list/grid substitutions for product objects.
- Tests prove behavior rather than snapshotting loose copy.
- Docs state evidence honestly and avoid pretending future scope is complete.

## Reject

Over-named components, repeated boilerplate, invented abstractions, copy-pasted
docs, unowned helpers, and test deletion or gate weakening.

## Output

Verdict; smell findings; files; severity; repair path.

# Ambitions Skill Evals

This folder is a practical eval pack for the Ambitions Codex setup.

Use it to check whether a request is likely to trigger the right skill, stay within the right repo boundaries, avoid over-editing, and report validation honestly.

## How To Use

1. Pick a prompt from `prompts/`.
2. Ask Codex to handle it in this repo.
3. Compare the result against `skill-eval-matrix.md`.
4. Record whether the skill routing, file targeting, and validation behavior matched expectations.

## What To Look For

- The right skill should be likely to trigger from the request wording.
- The response should inspect the correct native source-of-truth files first.
- The plan or code change should stay within the smallest plausible repo surface.
- Validation claims should match commands actually run.
- The result should preserve native SwiftUI/XcodeGen architecture boundaries.

## What This Eval Pack Is Not

- It is not an academic benchmark.
- It does not require exact wording matches.
- It is not a substitute for real code review or simulator/device checks.

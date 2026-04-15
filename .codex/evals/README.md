# Ambitions Skill Evals

This folder is a practical eval pack for the Ambitions Codex setup.

Use it to check whether a request is likely to trigger the right skill, stay within the right repo boundaries, avoid over-editing, execute in bounded slices, recover narrowly when needed, and report validation honestly.
Use `improvement-loop-matrix.md` when the question is not just "did the run go well?" but also "would the current system know how to improve after a weak run?"

## How To Use

1. Pick a prompt from `prompts/`.
2. Ask Codex to handle it in this repo.
3. Compare the result against `skill-eval-matrix.md`.
4. Record whether the skill routing, planning gate, bounded execution, retry behavior, stop conditions, file targeting, and validation behavior matched expectations.

## What To Look For

- The right skill should be likely to trigger from the request wording.
- Chained follow-on skills should appear when the task naturally requires them.
- The response should inspect the correct native source-of-truth files first.
- The plan or code change should stay within the smallest plausible repo surface.
- Risky tasks should begin with a plan before edits.
- Retries should get narrower instead of repeating the same failed step.
- Blocked work should stop honestly instead of widening the diff.
- Validation claims should match commands actually run.
- Wrong-skill starts should recover into the correct narrower workflow instead of bluffing forward.
- The result should preserve native SwiftUI/XcodeGen architecture boundaries.
- When a run is weak, the review should point to a concrete refinement target in `.codex/improvement/`, `.codex/templates/`, `.codex/operations/`, or the affected skill.

## What This Eval Pack Is Not

- It is not an academic benchmark.
- It does not require exact wording matches.
- It is not a substitute for real code review or simulator/device checks.
- It is also not automatic learning. The eval pack only helps decide which files in `.codex/` should be updated next.

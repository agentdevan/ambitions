# Task Width Gate Protocol

## When To Use

Use before every non-trivial Ambitions 3.0 task.

## Required Inputs

- User request.
- Active 3.0 read order.
- Target primitive/surface docs.
- Current `git status --short`.

## Exact Steps

1. Classify XS/S/M/L/XL/XXL.
2. Name owning primitive and surface.
3. Count surfaces, primitives, state machines, navigation changes,
   persistence/model migrations, external surfaces, release claims, and visual
   redesign scope.
4. Apply hard split rules.
5. Select required role passes from the FAANG Team Operating Model.
6. Select context pack, skill, operation, and validation pack.
7. Stop before edits if the task is XXL or must split.

## Commands

```bash
git status --short
rg -n "Ambitions_3_0|primitive|surface|validation" docs/codex docs/canon | head -80
```

## Output Artifacts

- Task width statement in plan/closeout.
- Split report when needed.

## Stop Conditions

- Task is XXL.
- Scope includes a disallowed combination.
- Required human approval is missing.

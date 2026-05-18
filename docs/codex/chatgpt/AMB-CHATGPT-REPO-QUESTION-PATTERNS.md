# AMB-CHATGPT-REPO-QUESTION-PATTERNS

Status: supporting question bank

Use these question patterns when ChatGPT needs repo-grounded answers before
writing a Codex prompt.

## Truth questions

- What does `docs/truth/README.md` require me to inspect first?
- Which truth file owns this decision?
- Does this claim belong to product/design, implementation, release, or Codex
  process truth?

## Scope questions

- Which exact files own this seam?
- What is the smallest safe patch boundary?
- What is explicitly out of scope?
- What existing material should be linked rather than duplicated?

## Claim questions

- Is this active, supporting, historical, obsolete, or unresolved?
- What current source or proof backs this claim?
- What would make this a false release claim?
- What would make this a false implementation claim?

## Canon questions

- Does this preserve Today / Goals / Capture / Time / You?
- Does this accidentally revive Plan as top-level IA?
- Does this introduce generic productivity language?
- Does this weaken the local-first posture?

## Validation questions

- What evidence is required before calling this Green?
- Which commands are appropriate for this change class?
- What should remain unverified if the batch is docs-only?

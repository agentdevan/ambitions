# ChatGPT ScenarioSpec Review Template

Review the provided Ambitions Source Atlas Coverage Universe ScenarioSpec JSON objects.

Flag:
- duplicates
- genericness
- weak edge-case value
- missing proof expectation
- missing local-only boundary
- missing receipt expectation
- missing closure/recovery expectation
- unsafe or overconfident behavior
- non-Ambitions language
- poor promotion value

Constraints:
- Do not treat generated scenarios as proof.
- Do not invent canon or new top-level IA.
- Preserve `Today / Goals / Capture / Time / You`.
- Preserve `Step`, `Recommended step`, `Start here`, `Start now`, and `Open step`.
- Reject cloud-runtime, API-key, or external-LLM dependency assumptions.

Output:
Return a JSON object with `accepted_ids`, `rejected_ids`, `quarantined_ids`, `duplicate_groups`, `risks`, and `recommended_repairs`.

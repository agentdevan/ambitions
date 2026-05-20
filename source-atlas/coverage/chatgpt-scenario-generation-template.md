# ChatGPT ScenarioSpec Generation Template

Generate ScenarioSpec JSON objects for Ambitions Source Atlas Coverage Universe.

Constraints:
- Do not generate source packs directly.
- Do not invent canon.
- Do not mark any generated scenario as proof.
- Use only the provided dimension values.
- Every scenario must be Ambitions-specific.
- Every scenario must include expected bad recommendation and expected Ambitions behavior.
- Every scenario must include Start Here receipt expectations.
- Every scenario must include Reality Meridian expectations.
- Every scenario must include closure/recovery behavior.
- Every scenario must include privacy/local-only boundary.
- Every scenario must include validation expectations.
- Every scenario must set `generated_derivative_notice=true`.
- Every scenario must set `cannot_satisfy_proof_alone=true`.
- Avoid generic productivity-app language.
- Use `Step`, `Recommended step`, `Start here`, `Start now`, and `Open step`.

Input:
- recipe_id:
- desired_count:
- target_dimensions:
- edge_case_classes:
- severity:
- known_gaps:

Output:
Strict JSON array of ScenarioSpec objects.

# Visual Recipe Schema Contract

Status: Active recipe schema contract

This contract defines what every priority recipe must say.

## Rules

- Every required section must be present.
- Every required section must be specific to the surface, not generic to the product class.
- Every required section must explain what it must contain, the minimum acceptable specificity, a bad example, a good example, a validator hint, and a tier requirement.
- Every P0 recipe must include source/proof/receipt behavior and a visible correction path.
- Every P0 recipe must include a bad example and a good example.
- Every P0 recipe must name its implementation-proof boundary.
- No P0 recipe may be accepted if any required section is present only as a heading or boilerplate paraphrase.

## Validator

- `scripts/ambitions-visual-100-recipe-contract-check.py`

## Notes

- The schema contract is a design-control document, not implementation proof.
- The short-form template is a starting point; the validator checks for actual section depth.

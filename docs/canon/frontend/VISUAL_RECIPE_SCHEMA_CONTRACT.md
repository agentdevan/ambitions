# Visual Recipe Schema Contract

Status: Active recipe schema contract

This contract defines what every priority recipe must say.

## Rules

- Every required section must be present.
- Every section must be specific to the surface.
- Every P0 recipe must include source/proof/receipt behavior and a visible correction path.
- Every P0 recipe must include a bad example and a good example.
- Every P0 recipe must name its implementation-proof boundary.

## Validator

- `scripts/ambitions-visual-100-recipe-contract-check.py`

## Notes

- The schema contract is a design-control document, not implementation proof.

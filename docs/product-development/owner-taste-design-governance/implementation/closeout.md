# Closeout

The initial owner-taste design-governance implementation was published in
`4e15c67560b6be0f50435b7b3d7dbc198dbc821f` and originally closed with Visual
Closure above Owner Taste. The owner explicitly rejected that relationship on
2026-08-08. The corrected authority model is implemented in
`5c5456dd7a30334d425532bbf2f62299fb26b2de`.

The corrected implementation:

- makes Owner Taste the supreme design authority and gives it the exact
  conflict rule `owner_taste_supersedes_all_other_design_authority`;
- separates product truth, safety, privacy, correctness, accessibility,
  platform requirements, and verified usability limits as non-design
  constraints;
- demotes the VC input contract and every Wave 1–3 and VC-14 closure package to
  `subordinate_implementation_calibration`;
- projects separate `supreme_design_authority` and
  `implementation_calibration` structures into the generated manifest; and
- makes the compiler reject a subordinate Owner Taste status, VC controller
  claims, or a closure package without the subordinate role.

Fresh verification on the correction passed canon build/check, all 48 compiler
tests, Python compilation, lifecycle required-file/status and generated
authority assertions, `git diff --check`, and the range-only secrets scan. The
skill-referenced `scripts/ambitions_product_docs.py` helper is not present in
this checkout, so no helper result is claimed.

This is the owner's design-authority decision plus source/canon/compiler
evidence. It does not prove production implementation, rendered UI,
accessibility behavior, simulator behavior, physical-device behavior, or
release readiness.

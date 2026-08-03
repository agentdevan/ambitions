from __future__ import annotations

from dataclasses import replace
from pathlib import Path
import sys
import unittest


SCRIPTS_DIRECTORY = Path(__file__).resolve().parents[1] / "scripts"
if str(SCRIPTS_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIRECTORY))

from product_docs.documents import parse_document, render_document, write_document_atomic
from product_docs.errors import ProductDocsError
from product_docs.markdown import parse_markdown_table
from product_docs.models import InputBinding, InputKind


SKILL_ROOT = Path(__file__).resolve().parents[1]
TEMPLATE_DIRECTORY = SKILL_ROOT / "assets" / "templates" / "v1"


class DocumentIOTests(unittest.TestCase):
    def test_templates_round_trip_with_ordered_sections(self) -> None:
        for template_path in TEMPLATE_DIRECTORY.glob("*.md"):
            original = template_path.read_text(encoding="utf-8")
            document = parse_document(template_path, repository_root=SKILL_ROOT.parents[2])

            self.assertEqual([section.heading for section in document.sections][0], "Agent handoff summary")
            self.assertEqual([section.heading for section in document.sections][-1], "Review history")
            self.assertEqual(render_document(document), original)

    def test_parses_markdown_table_into_named_rows(self) -> None:
        rows = parse_markdown_table(
            "| ID | Result |\n|---|---|\n| FIND-001 | Supported |\n"
        )

        self.assertEqual(rows, ({"ID": "FIND-001", "Result": "Supported"},))

    def test_rejects_table_width_mismatch(self) -> None:
        with self.assertRaises(ProductDocsError) as raised:
            parse_markdown_table("| ID | Result |\n|---|---|\n| FIND-001 |\n")

        self.assertEqual(raised.exception.diagnostics[0].code, "table-width-mismatch")

    def test_rejects_duplicate_toml_key(self) -> None:
        contents = TEMPLATE_DIRECTORY.joinpath("research.md").read_text(encoding="utf-8")
        duplicate = contents.replace("schema_version = 1", "schema_version = 1\nschema_version = 1", 1)

        with self.assertRaises(ProductDocsError) as raised:
            parse_document(duplicate, repository_root=SKILL_ROOT.parents[2])

        self.assertEqual(raised.exception.diagnostics[0].code, "toml-parse-error")

    def test_rejects_unterminated_frontmatter(self) -> None:
        with self.assertRaises(ProductDocsError) as raised:
            parse_document("+++\nschema_version = 1\n", repository_root=SKILL_ROOT.parents[2])

        self.assertEqual(raised.exception.diagnostics[0].code, "unterminated-frontmatter")

    def test_rejects_unknown_frontmatter_field(self) -> None:
        contents = TEMPLATE_DIRECTORY.joinpath("research.md").read_text(encoding="utf-8")
        unknown = contents.replace('skill_version = "1.0.0"', 'skill_version = "1.0.0"\nunknown_field = "no"', 1)

        with self.assertRaises(ProductDocsError) as raised:
            parse_document(unknown, repository_root=SKILL_ROOT.parents[2])

        self.assertEqual(raised.exception.diagnostics[0].code, "unknown-frontmatter-field")

    def test_rejects_absolute_and_traversal_binding_paths(self) -> None:
        template = TEMPLATE_DIRECTORY.joinpath("research.md").read_text(encoding="utf-8")
        input_record = (
            "\n[[inputs]]\nkind = \"canon\"\nauthority_id = \"CANON-001\"\n"
            'path = "/outside.md"\ncommit = "0123456789abcdef0123456789abcdef01234567"\n'
        )
        with self.assertRaises(ProductDocsError) as absolute:
            parse_document(template.replace("+++\n\n## Agent", input_record + "+++\n\n## Agent", 1), repository_root=SKILL_ROOT.parents[2])
        self.assertEqual(absolute.exception.diagnostics[0].code, "absolute-path")

        traversal_record = input_record.replace('"/outside.md"', '"docs/../outside.md"')
        with self.assertRaises(ProductDocsError) as traversal:
            parse_document(template.replace("+++\n\n## Agent", traversal_record + "+++\n\n## Agent", 1), repository_root=SKILL_ROOT.parents[2])
        self.assertEqual(traversal.exception.diagnostics[0].code, "path-traversal")

    def test_rejects_noncanonical_repository_path_spellings(self) -> None:
        template = TEMPLATE_DIRECTORY.joinpath("research.md").read_text(encoding="utf-8")
        for path in ("docs/./source.md", "docs//source.md", ".", ""):
            with self.subTest(path=path):
                input_record = (
                    "\n[[inputs]]\nkind = \"canon\"\nauthority_id = \"CANON-001\"\n"
                    f'path = "{path}"\ncommit = "0123456789abcdef0123456789abcdef01234567"\n'
                )
                candidate = template.replace("+++\n\n## Agent", input_record + "+++\n\n## Agent", 1)
                with self.assertRaises(ProductDocsError) as raised:
                    parse_document(candidate, repository_root=SKILL_ROOT.parents[2])
                self.assertEqual(raised.exception.diagnostics[0].code, "noncanonical-path")

    def test_rejects_boolean_integer_fields(self) -> None:
        template = TEMPLATE_DIRECTORY.joinpath("research.md").read_text(encoding="utf-8")
        for field in ("schema_version", "revision"):
            with self.subTest(field=field):
                candidate = template.replace(f"{field} = 1", f"{field} = true", 1)
                with self.assertRaises(ProductDocsError) as raised:
                    parse_document(candidate, repository_root=SKILL_ROOT.parents[2])
                self.assertEqual(raised.exception.diagnostics[0].code, "invalid-frontmatter-type")

        document = parse_document(TEMPLATE_DIRECTORY / "research.md", repository_root=SKILL_ROOT.parents[2])
        with self.assertRaises(ProductDocsError):
            render_document(replace(document, metadata=replace(document.metadata, schema_version=True)))

    def test_input_bindings_require_and_render_commit_identity(self) -> None:
        with self.assertRaises(TypeError):
            InputBinding(InputKind.CANON, "CANON-001", "docs/canon/example.md")

        document = parse_document(TEMPLATE_DIRECTORY / "research.md", repository_root=SKILL_ROOT.parents[2])
        binding = InputBinding(
            InputKind.CANON,
            "CANON-001",
            "docs/canon/example.md",
            commit="0123456789abcdef0123456789abcdef01234567",
        )
        rendered = render_document(replace(document, metadata=replace(document.metadata, inputs=(binding,))))
        self.assertIn('commit = "0123456789abcdef0123456789abcdef01234567"', rendered)

    def test_input_binding_preserves_six_field_positional_order(self) -> None:
        binding = InputBinding(
            InputKind.LIFECYCLE_DOCUMENT,
            "PD-001",
            "docs/product-development/example.md",
            2,
            "sha256:example",
            "0123456789abcdef0123456789abcdef01234567",
        )

        self.assertEqual(binding.revision, 2)
        self.assertEqual(binding.contract_hash, "sha256:example")
        self.assertEqual(binding.commit, "0123456789abcdef0123456789abcdef01234567")

    def test_render_preserves_trailing_blank_lines_and_normalizes_one_final_newline(self) -> None:
        template = TEMPLATE_DIRECTORY.joinpath("research.md").read_text(encoding="utf-8")
        body_start = template.index("+++\n", 4) + len("+++\n")
        contents = template[:body_start] + template[body_start:].rstrip("\n") + "\n\n\n"

        rendered = render_document(parse_document(contents, repository_root=SKILL_ROOT.parents[2]))

        self.assertEqual(rendered, contents)

        crlf_contents = template[:body_start] + template[body_start:].replace("\n", "\r\n")
        crlf_rendered = render_document(parse_document(crlf_contents, repository_root=SKILL_ROOT.parents[2]))
        self.assertEqual(crlf_rendered, crlf_contents[:-2] + "\n")

    def test_path_based_parsing_preserves_body_crlf_bytes(self) -> None:
        from tempfile import TemporaryDirectory

        template = TEMPLATE_DIRECTORY.joinpath("research.md").read_text(encoding="utf-8")
        crlf_contents = template.replace("\n", "\r\n")
        source_body_start = crlf_contents.index("+++\r\n", 4) + len("+++\r\n")
        with TemporaryDirectory() as temporary_directory:
            document_path = Path(temporary_directory) / "research.md"
            document_path.write_bytes(crlf_contents.encode("utf-8"))
            rendered = render_document(parse_document(document_path, repository_root=SKILL_ROOT.parents[2]))

        rendered_body_start = rendered.index("+++\n", 4) + len("+++\n")
        self.assertEqual(rendered[rendered_body_start:], crlf_contents[source_body_start:-2] + "\n")
        self.assertIn("\r\n## Agent handoff summary", rendered)

    def test_atomic_write_preserves_target_when_candidate_is_invalid(self) -> None:
        with self.subTest("candidate validation"):
            from tempfile import TemporaryDirectory

            with TemporaryDirectory() as temporary_directory:
                root = Path(temporary_directory)
                target = root / "document.md"
                original = TEMPLATE_DIRECTORY.joinpath("research.md").read_text(encoding="utf-8")
                target.write_text(original, encoding="utf-8")
                invalid = original.replace('document_type = "research"', 'document_type = "unsupported"', 1)

                with self.assertRaises(ProductDocsError):
                    write_document_atomic(target, invalid, repository_root=root)

                self.assertEqual(target.read_text(encoding="utf-8"), original)

    def test_diagnostic_serialization_is_stable(self) -> None:
        from product_docs.errors import Diagnostic

        diagnostic = Diagnostic("invalid", "Bad input", path="docs/example.md", section="Findings")
        self.assertEqual(
            list(diagnostic.as_dict()),
            ["code", "message", "path", "section", "identifier", "remediation"],
        )


if __name__ == "__main__":
    unittest.main()

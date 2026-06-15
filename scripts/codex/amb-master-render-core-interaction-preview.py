#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


ROOT = Path(__file__).resolve().parents[2]
SCREENSHOT_DIR = ROOT / "artifacts" / "ambitions-master-build" / "screenshots" / "AMB-1061"

PACKAGE_SWIFT = """// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AMB1061Renderer",
    platforms: [.macOS(.v26)],
    dependencies: [
        .package(path: "%s")
    ],
    targets: [
        .executableTarget(
            name: "AMB1061Renderer",
            dependencies: [
                .product(name: "AmbitionsDesignSystem", package: "ambitions")
            ]
        )
    ]
)
"""

MAIN_SWIFT = """import AmbitionsDesignSystem
import AppKit
import SwiftUI

@main
struct AMB1061Renderer {
    @MainActor
    static func main() throws {
        let output = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

        try render(
            name: "core-reusable-interaction-primitives.png",
            output: output
        )
        try render(
            name: "core-reusable-interaction-primitives-dynamic-type.png",
            output: output,
            dynamicTypeSize: .xxxLarge
        )
        print("Rendered 2 AMB-1061 SwiftUI preview screenshots")
    }

    @MainActor
    private static func render(
        name: String,
        output: URL,
        dynamicTypeSize: DynamicTypeSize = .large
    ) throws {
        let width = 1170.0
        let height = 1800.0
        let view = CoreReusableInteractionPrimitivePreviewGallery(scrolls: false)
            .frame(width: width, height: height)
            .environment(\\.colorScheme, .dark)
            .environment(\\.dynamicTypeSize, dynamicTypeSize)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 1
        renderer.proposedSize = ProposedViewSize(width: width, height: height)
        guard let image = renderer.nsImage,
              let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
            throw RendererError.failedToRender(name)
        }
        try png.write(to: output.appendingPathComponent(name))
    }
}

enum RendererError: Error {
    case failedToRender(String)
}
"""


def write_renderer_package(package_dir: Path) -> None:
    source_dir = package_dir / "Sources" / "AMB1061Renderer"
    source_dir.mkdir(parents=True)
    (package_dir / "Package.swift").write_text(PACKAGE_SWIFT % ROOT.as_posix(), encoding="utf-8")
    (source_dir / "main.swift").write_text(MAIN_SWIFT, encoding="utf-8")


def render_snapshots() -> None:
    SCREENSHOT_DIR.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="ambitions-amb1061-renderer-") as tmp:
        package_dir = Path(tmp) / "renderer"
        output_dir = Path(tmp) / "screenshots"
        package_dir.mkdir()
        output_dir.mkdir()
        write_renderer_package(package_dir)
        result = subprocess.run(
            ["swift", "run", "--package-path", str(package_dir), "AMB1061Renderer", str(output_dir)],
            cwd=ROOT,
            text=True,
            capture_output=True,
        )
        if result.returncode != 0:
            sys.stderr.write(result.stdout)
            sys.stderr.write(result.stderr)
            raise SystemExit(result.returncode)

        rendered_pngs = sorted(output_dir.glob("*.png"))
        if len(rendered_pngs) != 2:
            sys.stderr.write(f"Expected 2 AMB-1061 PNGs, rendered {len(rendered_pngs)}\n")
            raise SystemExit(1)

        for old_png in SCREENSHOT_DIR.glob("core-reusable-interaction-primitives*.png"):
            old_png.unlink()
        for rendered_png in rendered_pngs:
            shutil.copy2(rendered_png, SCREENSHOT_DIR / rendered_png.name)

        print(result.stdout.strip())


def main() -> int:
    render_snapshots()
    png_count = len(list(SCREENSHOT_DIR.glob("core-reusable-interaction-primitives*.png")))
    print(f"Wrote {png_count} AMB-1061 SwiftUI screenshots to {SCREENSHOT_DIR.relative_to(ROOT)}/")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

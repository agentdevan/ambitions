#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


ROOT = Path(__file__).resolve().parents[1]
SCREENSHOT_DIR = ROOT / "docs" / "audits" / "visual-evidence" / "fe11" / "screenshots"

PACKAGE_SWIFT = """// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FE11Renderer",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: "%s")
    ],
    targets: [
        .executableTarget(
            name: "FE11Renderer",
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
struct FE11Renderer {
    @MainActor
    static func main() throws {
        let output = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

        for fixture in SI16PreviewFixtureCatalog.fixtures {
            let view = SI16VisualQAFixtureSnapshotCard(fixture: fixture)
                .frame(width: 1200, height: 800)
                .environment(\\.colorScheme, .dark)
            let renderer = ImageRenderer(content: view)
            renderer.scale = 1
            guard let image = renderer.nsImage,
                  let tiff = image.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: tiff),
                  let png = bitmap.representation(using: .png, properties: [:]) else {
                throw RendererError.failedToRender(fixture.screenshotName)
            }
            try png.write(to: output.appendingPathComponent(fixture.screenshotName))
        }

        print("Rendered \\(SI16PreviewFixtureCatalog.fixtures.count) FE-11 SwiftUI snapshots")
    }
}

enum RendererError: Error {
    case failedToRender(String)
}
"""


def write_renderer_package(package_dir: Path) -> None:
    (package_dir / "Sources" / "FE11Renderer").mkdir(parents=True)
    (package_dir / "Package.swift").write_text(PACKAGE_SWIFT % ROOT.as_posix(), encoding="utf-8")
    (package_dir / "Sources" / "FE11Renderer" / "main.swift").write_text(MAIN_SWIFT, encoding="utf-8")


def render_snapshots() -> None:
    SCREENSHOT_DIR.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="ambitions-fe11-renderer-") as tmp:
        package_dir = Path(tmp) / "renderer"
        output_dir = Path(tmp) / "screenshots"
        package_dir.mkdir()
        output_dir.mkdir()
        write_renderer_package(package_dir)
        result = subprocess.run(
            ["swift", "run", "--package-path", str(package_dir), "FE11Renderer", str(output_dir)],
            cwd=ROOT,
            text=True,
            capture_output=True,
        )
        if result.returncode != 0:
            sys.stderr.write(result.stdout)
            sys.stderr.write(result.stderr)
            raise SystemExit(result.returncode)
        rendered_pngs = sorted(output_dir.glob("*.png"))
        if len(rendered_pngs) != 21:
            sys.stderr.write(f"Expected 21 FE-11 PNGs, rendered {len(rendered_pngs)}\n")
            raise SystemExit(1)
        for old_png in SCREENSHOT_DIR.glob("*.png"):
            old_png.unlink()
        for rendered_png in rendered_pngs:
            shutil.copy2(rendered_png, SCREENSHOT_DIR / rendered_png.name)
        print(result.stdout.strip())


def main() -> int:
    render_snapshots()
    png_count = len(list(SCREENSHOT_DIR.glob("*.png")))
    print(f"Wrote {png_count} FE-11 SwiftUI snapshot PNGs to {SCREENSHOT_DIR.relative_to(ROOT)}/")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

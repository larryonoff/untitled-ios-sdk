#!/usr/bin/env python3
"""Explicit Swift checks and formatting; independent of cwd and Xcode configuration."""
import argparse
import configparser
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
DIRECTORIES = ("Sources", "Tests")
MANIFESTS = ("Package.swift",)


def source_file(path):
    return (path.suffix == ".swift" and not path.name.endswith(".generated.swift")
            and not any(part in (".build", ".swiftpm") for part in path.parts))


def selected_files(arguments):
    if not arguments:
        files = [p for directory in DIRECTORIES for p in (ROOT / directory).rglob("*.swift")]
        files += [ROOT / name for name in MANIFESTS]
        return sorted({p.resolve() for p in files if p.is_file() and source_file(p)})
    files = []
    for argument in arguments:
        path = Path(argument).resolve()
        if not path.is_relative_to(ROOT) or not path.is_file() or path.suffix != ".swift":
            raise ValueError(f"Expected an existing Swift file inside {ROOT}: {argument}")
        if source_file(path):
            files.append(path)
    return sorted(set(files))


def formatting_options():
    config = configparser.ConfigParser(interpolation=None)
    config.read_string("[editorconfig]\n" + (ROOT / ".editorconfig").read_text())
    style = config["*"]
    if style.get("indent_style") != "space" or not style.get("indent_size", "").isdigit():
        raise ValueError("Expected space indentation and numeric indent_size in .editorconfig [*]")
    if style.get("end_of_line") not in ("lf", "crlf", "cr"):
        raise ValueError("Expected explicit end_of_line in .editorconfig [*]")
    if style.get("trim_trailing_whitespace") != "true" or style.get("insert_final_newline") != "true":
        raise ValueError("Swift formatting requires trimming whitespace and a final newline")
    return ["--indent", style["indent_size"], "--linebreaks", style["end_of_line"],
            "--trim-whitespace", "always"]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("lint", "format-check", "format"))
    parser.add_argument("--optional-tool", action="store_true", help="Xcode-only missing-tool warning")
    parser.add_argument("files", nargs="*", help="Explicit file paths relative to your cwd; directories are rejected")
    args = parser.parse_intermixed_args()
    if args.optional_tool and args.command != "lint":
        parser.error("--optional-tool is only valid for lint")
    if args.command == "format" and not args.files:
        parser.error("format requires explicit files; repository-wide writes are disabled")
    files = selected_files(args.files)
    if not files:
        print("No handwritten Swift files selected.")
        return 0
    tool_name = "swiftlint" if args.command == "lint" else "swiftformat"
    tool = shutil.which(tool_name)
    if tool is None:
        if args.optional_tool:
            print("warning: SwiftLint is not installed; run brew install swiftlint")
            return 0
        raise ValueError(f"{tool_name} is not installed; run brew install {tool_name}")
    if args.command == "lint":
        command = [tool, "lint", "--config", str(ROOT / ".swiftlint.yml"),
                   "--strict", "--no-cache", "--force-exclude"]
    else:
        command = [tool, "--config", str(ROOT / ".swiftformat"), "--cache", "ignore"]
        command += formatting_options()
        if args.command == "format-check":
            command.append("--lint")
    # Individual file arguments avoid SwiftLint's included/directory ambiguity.
    return subprocess.run(command + [str(p) for p in files], cwd=ROOT).returncode


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, configparser.Error) as error:
        print(f"error: {error}", file=sys.stderr)
        sys.exit(2)

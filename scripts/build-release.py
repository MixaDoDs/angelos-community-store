#!/usr/bin/env python3
"""Build a complete, installable Community Store release ZIP."""

import argparse
import importlib.util
import json
import zipfile
from pathlib import Path


def build_release(root, destination):
    root = Path(root)
    destination = Path(destination)
    manifest = json.loads((root / "manifest.json").read_text(encoding="utf-8"))
    if manifest.get("id") != "community-store" or not manifest.get("version"):
        raise ValueError("Invalid Community Store manifest")

    spec = importlib.util.spec_from_file_location("community_store_installer", root / "install-community-store.py")
    installer = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(installer)
    files = ("manifest.json",) + installer.REQUIRED_FILES + ("README.md", "README.ru.md")
    with zipfile.ZipFile(destination, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for name in files:
            path = root / name
            if not path.is_file():
                raise FileNotFoundError(path)
            zf.write(path, "community-store/" + name)
    return destination


def main():
    root = Path(__file__).resolve().parents[1]
    version = json.loads((root / "manifest.json").read_text(encoding="utf-8"))["version"]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", nargs="?", type=Path, default=root / ("community-store-v" + version + ".zip"))
    args = parser.parse_args()
    print(build_release(root, args.output))


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Small, dependency-free registry and installer for Community Store."""
import json, os, shutil, sys, tempfile, urllib.request, zipfile
from pathlib import Path

MAX_REGISTRY = 2 * 1024 * 1024
MAX_ARCHIVE = 64 * 1024 * 1024
ID = __import__('re').compile(r"^[a-z0-9][a-z0-9_-]{1,63}$")

def fail(message):
    print(message, file=sys.stderr)
    return 1

def fetch(url):
    if not url.startswith("https://"):
        return fail("Registry URL must use HTTPS")
    request = urllib.request.Request(url, headers={"User-Agent": "angelos-community-store/0.1"})
    with urllib.request.urlopen(request, timeout=20) as response:
        data = response.read(MAX_REGISTRY + 1)
    if len(data) > MAX_REGISTRY:
        return fail("Registry is too large")
    payload = json.loads(data.decode("utf-8"))
    if payload.get("version") != 1 or not isinstance(payload.get("plugins"), list):
        return fail("Unsupported registry format")
    for entry in payload["plugins"]:
        if not isinstance(entry, dict) or not ID.fullmatch(str(entry.get("id", ""))) or not str(entry.get("source", "")).startswith("https://"):
            return fail("Registry contains an invalid plugin entry")
    print(json.dumps(payload, ensure_ascii=False))
    return 0

def install(source, expected_id, expected_version):
    if not ID.fullmatch(expected_id) or not source.startswith("https://"):
        return fail("Invalid plugin id or source")
    request = urllib.request.Request(source, headers={"User-Agent": "angelos-community-store/0.1"})
    with urllib.request.urlopen(request, timeout=60) as response:
        data = response.read(MAX_ARCHIVE + 1)
    if len(data) > MAX_ARCHIVE:
        return fail("Plugin archive is too large")
    home = Path(os.environ.get("HOME", "")).expanduser()
    destination = home / ".config/angelos/plugins" / expected_id
    trash = home / ".local/state/angelos/plugin-trash"
    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix=".community-store-", dir=destination.parent) as work:
        archive = Path(work) / "plugin.zip"
        archive.write_bytes(data)
        root = Path(work) / "unpacked"
        root.mkdir()
        with zipfile.ZipFile(archive) as zf:
            if len(zf.infolist()) > 2000 or sum(item.file_size for item in zf.infolist()) > MAX_ARCHIVE:
                return fail("Plugin archive expands beyond allowed limits")
            for member in zf.infolist():
                mode = member.external_attr >> 16
                if __import__('stat').S_ISLNK(mode):
                    return fail("Archive contains a symbolic link")
                target = (root / member.filename).resolve()
                if not str(target).startswith(str(root.resolve()) + os.sep):
                    return fail("Archive contains an unsafe path")
            zf.extractall(root)
        manifests = list(root.glob("manifest.json")) + list(root.glob("*/manifest.json"))
        if len(manifests) != 1:
            return fail("Archive must contain one manifest.json")
        source_dir = manifests[0].parent
        try:
            manifest = json.loads(manifests[0].read_text(encoding="utf-8"))
        except (OSError, ValueError) as exc:
            return fail("Invalid manifest: " + str(exc))
        if not isinstance(manifest, dict) or manifest.get("id") != expected_id or not ID.fullmatch(expected_id):
            return fail("Manifest id does not match registry")
        if str(manifest.get("version", "")) != expected_version:
            return fail("Manifest version does not match registry")
        if not isinstance(manifest.get("name"), str) or not manifest["name"].strip():
            return fail("Manifest name is required")
        staging = destination.parent / ("." + expected_id + ".new-" + str(os.getpid()))
        if staging.exists():
            shutil.rmtree(staging)
        shutil.copytree(source_dir, staging)
        backup = None
        try:
            if destination.exists():
                trash.mkdir(parents=True, exist_ok=True)
                backup = trash / ("community-store-" + expected_id + "-" + str(os.getpid()))
                os.replace(destination, backup)
            os.replace(staging, destination)
        except Exception:
            if backup is not None and backup.exists() and not destination.exists():
                os.replace(backup, destination)
            raise
    print("Installed " + expected_id + " " + expected_version)
    return 0

if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise SystemExit(fail("Usage: community-store.py fetch URL | install SOURCE ID VERSION"))
    if sys.argv[1] == "fetch" and len(sys.argv) == 3:
        raise SystemExit(fetch(sys.argv[2]))
    if sys.argv[1] == "install" and len(sys.argv) == 5:
        raise SystemExit(install(sys.argv[2], sys.argv[3], sys.argv[4]))
    raise SystemExit(fail("Invalid arguments"))

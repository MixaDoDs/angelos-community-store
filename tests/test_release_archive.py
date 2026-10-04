"""Release ZIPs must include everything the Store's QML imports and scripts use."""

import importlib.util
import json
import tempfile
import unittest
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("store_installer", ROOT / "install-community-store.py")
installer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(installer)

REQUIRED = (
    "Main.qml",
    "Settings.qml",
    "Launcher.qml",
    "qmldir",
    "components/PluginCard.qml",
    "components/InstalledPluginCard.qml",
    "services/Registry.qml",
    "services/qmldir",
    "scripts/community-store.py",
    "scripts/community-store-tui.py",
)


class ReleaseArchiveTests(unittest.TestCase):
    def archive(self, path, missing=()):
        with zipfile.ZipFile(path, "w") as zf:
            zf.writestr("community-store/manifest.json", json.dumps({
                "id": "community-store", "version": "0.6.1",
                "settings": "Settings.qml", "main": "Main.qml", "launcher": "Launcher.qml",
            }))
            for name in REQUIRED:
                if name not in missing:
                    zf.writestr("community-store/" + name, "fixture")

    def test_rejects_archive_missing_imported_component(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "broken.zip"
            self.archive(path, missing=("components/PluginCard.qml",))
            with self.assertRaisesRegex(RuntimeError, r"components/PluginCard.qml"):
                installer.unpack_checked(path, Path(temp) / "unpacked")

    def test_rejects_archive_missing_launcher_script(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "broken.zip"
            self.archive(path, missing=("scripts/community-store.py",))
            with self.assertRaisesRegex(RuntimeError, r"scripts/community-store.py"):
                installer.unpack_checked(path, Path(temp) / "unpacked")

    def test_accepts_complete_archive(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "complete.zip"
            self.archive(path)
            source, manifest = installer.unpack_checked(path, Path(temp) / "unpacked")
            self.assertEqual(manifest["id"], "community-store")
            self.assertTrue((source / "components/PluginCard.qml").is_file())

    def test_packaged_release_contains_imports(self):
        builder_spec = importlib.util.spec_from_file_location("build_release", ROOT / "scripts/build-release.py")
        builder = importlib.util.module_from_spec(builder_spec)
        builder_spec.loader.exec_module(builder)
        with tempfile.TemporaryDirectory() as temp:
            archive = Path(temp) / "release.zip"
            builder.build_release(ROOT, archive)
            source, _ = installer.unpack_checked(archive, Path(temp) / "unpacked")
            for name in REQUIRED:
                with self.subTest(name=name):
                    self.assertEqual((source / name).read_bytes(), (ROOT / name).read_bytes())


if __name__ == "__main__":
    unittest.main()

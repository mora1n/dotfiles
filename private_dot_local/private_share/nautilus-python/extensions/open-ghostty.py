import subprocess

import gi

gi.require_version("Nautilus", "4.0")
from gi.repository import GObject, Nautilus


class OpenGhosttyExtension(GObject.GObject, Nautilus.MenuProvider):
    def _open(self, item, path):
        subprocess.Popen([
            "/usr/bin/ghostty",
            "--window-inherit-working-directory=false",
            "--working-directory=" + path,
        ])

    def _items(self, location):
        path = location.get_path()
        if path is None:
            return []
        item = Nautilus.MenuItem(
            name="OpenGhostty::Open",
            label="Open in Ghostty",
            tip="Open this folder in Ghostty",
        )
        item.connect("activate", self._open, path)
        return [item]

    def get_background_items(self, current_folder):
        return self._items(current_folder.get_location())

    def get_file_items(self, files):
        if len(files) != 1 or not files[0].is_directory():
            return []
        return self._items(files[0].get_location())

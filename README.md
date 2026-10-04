# AngelOS Community Store

An independent AngelOS plugin that uses the native plugin directory and
`Plugins` service. It is installed like any other user plugin and does not
modify AngelOS upstream.

## Install

From a terminal, download the reviewed installer and run it:

```bash
curl -fsSL -o /tmp/install-community-store.py \
  https://raw.githubusercontent.com/futureUnd1ground/angelos-community-store/main/install-community-store.py
python3 /tmp/install-community-store.py
```

Fish users can run the native Fish entry point:

```fish
curl -fsSL -o /tmp/install-community-store.fish \
  https://raw.githubusercontent.com/futureUnd1ground/angelos-community-store/main/install-community-store.fish
and fish /tmp/install-community-store.fish
```

It downloads the same verified Python installer to a temporary file, installs
the Store, adds `~/.local/bin` to Fish's PATH, and removes the temporary file.
The two steps are kept separate so the downloaded installer can be inspected
before running it.

The installer downloads the pinned release over HTTPS, validates its archive
and manifest, installs it atomically in `~/.config/angelos/plugins`, creates
the `community-store` command, and restarts AngelOS. Use
`--no-restart` when restarting manually. Review the script before running it;
it never executes a shell pipeline.

Copy this directory to `~/.config/angelos/plugins/community-store/`, or use
AngelOS Plugin Studio to install the files. Then reload the shell and open
**Settings -> Plugins -> Community Store**.

## Terminal interface

The store also has a standalone TUI and does not require the Settings GUI:

```bash
python3 ~/.config/angelos/plugins/community-store/scripts/community-store-tui.py
```

The first run creates `~/.local/bin/community-store`, so later runs are:

```bash
community-store
```

Keys: `j/k` or arrows move, `Enter` installs or updates the selected plugin,
`d` removes it to AngelOS plugin-trash, `U` updates all community plugins,
`s` updates the Store itself, `r` refreshes the registry, `/` searches, `a`
shows all, `i` shows installed, `v` shows updates, and `q` exits. Changes
restart AngelOS after the TUI closes.

The default registry is the raw `plugins.json` in
`https://github.com/futureUnd1ground/angelos-community-registry`. The URL can
be changed in the page.

## Registry entries

Use an HTTPS ZIP release with a top-level `manifest.json` (or one directory
containing it). The registry `id` and `version` must match that manifest. The
installer rejects path traversal, malformed manifests, mismatched IDs or
versions, non-HTTPS sources, and archives over 64 MiB.

## Publish a plugin to the catalog

1. Keep the plugin source in its own GitHub repository. Its AngelOS
   `manifest.json` must have a unique `id` and a `version` matching the
   release you publish.
2. Create a ZIP containing the plugin folder and publish it as an asset on a
   GitHub Release. The ZIP must contain exactly one `manifest.json`, either
   at its root or one directory below it.
3. Fork
   [angelos-community-registry](https://github.com/futureUnd1ground/angelos-community-registry),
   add an entry to `plugins.json` with `status` set to `pending`, and open a
   pull request. Include the source URL, repository, author, description,
   tags, license, dependencies, and requested permissions.
4. The registry maintainer reviews the code, license, ZIP, and compatibility.
   After approval, the maintainer changes `status` to `approved` and merges
   the pull request. Approved entries appear after **Refresh** in Community
   Store.

The registry owner moderates listings through GitHub pull requests. Pending
entries are not shown in the Store; changing an approved entry back to
`pending` hides it on the next registry refresh.

## Browse installed plugins

The **Installed plugins** section lists plugins discovered by AngelOS,
including built-in and user plugins. From a row you can enable or disable the
plugin, open its details or directory, and remove a user plugin. Built-in
plugins are hidden using AngelOS's native remove behavior; their files remain
part of the AngelOS installation.

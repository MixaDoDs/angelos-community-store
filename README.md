# AngelOS Community Store

An independent AngelOS plugin that uses the native plugin directory and
`Plugins` service. It is installed like any other user plugin and does not
modify AngelOS upstream.

## Install

Copy this directory to `~/.config/angelos/plugins/community-store/`, or use
AngelOS Plugin Studio to install the files. Then reload the shell and open
**Settings -> Plugins -> Community Store**.

The default registry is the raw `plugins.json` in
`https://github.com/futureUnd1ground/angelos-community-registry`. The URL can
be changed in the page.

## Registry entries

Use an HTTPS ZIP release with a top-level `manifest.json` (or one directory
containing it). The registry `id` and `version` must match that manifest. The
installer rejects path traversal, malformed manifests, mismatched IDs or
versions, non-HTTPS sources, and archives over 64 MiB.

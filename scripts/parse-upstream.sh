#!/usr/bin/env bash
#
# Parse an upstream Google SPM Package.swift and emit the binaryTarget's
# url, checksum, and version (as derived from the URL filename).
#
# Usage:
#   parse-upstream.sh <path/to/Package.swift>
#
# Outputs (stdout) as three lines:
#   url=<url>
#   sha256=<checksum>
#   version=<semver>
#
# Exits non-zero if the package manifest doesn't match the expected shape.

set -euo pipefail

pkg=${1:?missing Package.swift path}
[ -f "$pkg" ] || { echo "not found: $pkg" >&2; exit 2; }

# Extract the binaryTarget block. The target we care about is the one whose
# name matches the repo's main product — there's only one binaryTarget in
# each of Google's GMA / UMP Package.swift manifests, so match greedy.
url=$(awk '
  /\.binaryTarget\(/ { in_target = 1 }
  in_target && /url:/ { getline; gsub(/[[:space:]",]/, ""); print; exit }
' "$pkg")

sha=$(awk '
  /\.binaryTarget\(/ { in_target = 1 }
  in_target && /checksum:/ {
    sub(/.*checksum:[[:space:]]*"/, "")
    sub(/".*/, "")
    print
    exit
  }
' "$pkg")

# The SPM zip filename encodes the version, e.g.
#   googlemobileadsios-spm-13.0.0.zip
#   googleusermessagingplatformios-spm-3.1.0.zip
version=$(echo "$url" | sed -nE 's|.*-spm-([0-9.]+)\.zip$|\1|p')

[ -n "$url" ]     || { echo "failed to parse url from $pkg" >&2; exit 3; }
[ -n "$sha" ]     || { echo "failed to parse checksum from $pkg" >&2; exit 3; }
[ -n "$version" ] || { echo "failed to parse version from $pkg url=$url" >&2; exit 3; }

printf 'url=%s\nsha256=%s\nversion=%s\n' "$url" "$sha" "$version"

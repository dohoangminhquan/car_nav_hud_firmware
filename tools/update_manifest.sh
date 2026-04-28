#!/usr/bin/env bash
# Regenerate manifest.json for a firmware binary in the repo root.
# Usage: tools/update_manifest.sh <bin-filename> <version> "<release notes>"
# Example: tools/update_manifest.sh carnavhud-1.0.0.1.bin 1.0.0.1 "Initial release"
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 <bin-filename> <version> \"<release notes>\"" >&2
  echo "example: $0 carnavhud-1.0.0.1.bin 1.0.0.1 \"Initial release\"" >&2
  exit 2
fi

BIN_NAME="$1"
VERSION="$2"
NOTES="$3"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$REPO_ROOT/$BIN_NAME"
MANIFEST="$REPO_ROOT/manifest.json"
URL="https://raw.githubusercontent.com/dohoangminhquan/car_nav_hud_firmware/main/$BIN_NAME"

if [[ ! -f "$BIN" ]]; then
  echo "error: $BIN not found" >&2
  exit 1
fi

SHA256="$(shasum -a 256 "$BIN" | awk '{print $1}')"
SIZE="$(wc -c < "$BIN" | tr -d ' ')"
RELEASED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

python3 - "$MANIFEST" "$VERSION" "$URL" "$SHA256" "$SIZE" "$RELEASED_AT" "$NOTES" <<'PY'
import json, sys
path, version, url, sha256, size, released_at, notes = sys.argv[1:]
data = {
    "version": version,
    "url": url,
    "sha256": sha256,
    "size": int(size),
    "released_at": released_at,
    "notes": notes,
}
with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY

echo "Updated $MANIFEST"
echo "  version:     $VERSION"
echo "  url:         $URL"
echo "  sha256:      $SHA256"
echo "  size:        $SIZE bytes"
echo "  released_at: $RELEASED_AT"

#!/usr/bin/env bash
# Ship Secure: build ship-secure.zip with the ship-secure/ folder at the zip root.
# Usage: bash scripts/package.sh [output-dir]   (default: parent of the skill folder)
# Excludes tests/vulnerable-sample (it holds deliberately fake secrets) and junk files.
set -eu
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
[ "$(basename "$SKILL_DIR")" = "ship-secure" ] || { echo "error: skill folder must be named 'ship-secure' (is '$(basename "$SKILL_DIR")')" >&2; exit 1; }
OUT_DIR="$(cd "${1:-$SKILL_DIR/..}" && pwd)"
OUT="$OUT_DIR/ship-secure.zip"

python3 "$SKILL_DIR/scripts/validate.py" "$SKILL_DIR" || { echo "validation failed; not packaging" >&2; exit 1; }

rm -f "$OUT"
( cd "$SKILL_DIR/.." && zip -rq "$OUT" ship-secure \
    -x 'ship-secure/.git/*' -x '*/.DS_Store' -x '*/__pycache__/*' -x '*.pyc' -x '*.zip' \
    -x 'ship-secure/tests/vulnerable-sample/*' )

python3 - "$OUT" <<'PY'
import sys, zipfile
z = zipfile.ZipFile(sys.argv[1]); names = z.namelist()
roots = {n.split("/")[0] for n in names}
assert roots == {"ship-secure"}, f"zip root must be only ship-secure/, got {roots}"
assert "ship-secure/SKILL.md" in names, "SKILL.md missing at ship-secure/SKILL.md"
print(f"OK: {sys.argv[1]} ({len(names)} entries, root = ship-secure/)")
PY

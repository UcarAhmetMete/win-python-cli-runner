#!/usr/bin/env bash
set -euo pipefail

# Simple cross-platform shell runner for Unix-like systems
NAME="${1:-ASML}"
OUT="${2:-out}"

python3 -m venv .venv
# shellcheck disable=SC1091
. .venv/bin/activate
if [ -f requirements.txt ]; then
  pip install -r requirements.txt
else
  echo "requirements.txt not found, skipping pip install"
fi

python app.py --name "$NAME" --out "$OUT"
echo "Done."

#!/usr/bin/env bash
# Prints, one per line, editors on the community counter that editors.yaml doesn't list.
# Usage: scripts/missing-from-counter.sh <counter.csv inside this repo>
#   DATA  default /data/editors.yaml (relative to the repo root)
#   SKIP  default /data/counter-skip.yaml (relative to the repo root)
set -euo pipefail
cd "$(dirname "$0")/.."

csv=${1:?usage: missing-from-counter.sh <counter.csv>}
root=$(pwd)
case "$csv" in
  "$root"/*) rel="/${csv#"$root"/}" ;;
  /*) echo "the CSV must be inside the repo: $csv" >&2; exit 1 ;;
  *) rel="/$csv" ;;
esac

typst eval 'query(<missing>).first().value' --in scripts/missing-from-counter.typ --root . --format json \
  --input counter="$rel" --input data="${DATA:-/data/editors.yaml}" \
  --input skip="${SKIP:-/data/counter-skip.yaml}" | jq -r '.[]'

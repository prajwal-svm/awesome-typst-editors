#!/usr/bin/env bash
# Runs every tests/test_*.sh file and reports which ones failed.
set -uo pipefail
cd "$(dirname "$0")/.."
shopt -s nullglob

files=(tests/test_*.sh)
if [ ${#files[@]} -eq 0 ]; then
  echo "No test files found."
  exit 1
fi

failed=()
for t in "${files[@]}"; do
  if bash "$t"; then
    echo "PASS $t"
  else
    echo "FAIL $t"
    failed+=("$t")
  fi
done

if [ ${#failed[@]} -gt 0 ]; then
  echo "${#failed[@]} of ${#files[@]} test files failed: ${failed[*]}"
  exit 1
fi
echo "All ${#files[@]} test files passed."

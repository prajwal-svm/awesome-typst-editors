#!/usr/bin/env bash
# The real editor list compiles, and a few hand-checked facts hold.
source "$(dirname "$0")/helpers.sh"

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
OUT="$T/site"
if ! typst compile site/main.typ "$OUT" "${TYPST_BUNDLE[@]}" --input today=2026-10-17 2>"$T/err"; then
  fail "the real data did not compile: $(cat "$T/err")"
fi

assert_file "$OUT/editors/oleafly/index.html"
assert_contains "$OUT/editors/oleafly/index.html" "Arrived 5 Jul 2026"
assert_no_file "$OUT/editors/leftblank"
grep -qE 'Arrived [0-9]+ [A-Z][a-z]{2} 2024' "$OUT/editors/typstwriter/index.html" 2>/dev/null ||
  fail "Typstwriter should show an arrival in 2024"

finish

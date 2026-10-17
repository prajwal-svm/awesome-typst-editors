#!/usr/bin/env bash
# The awesome-style README generated from the data.
source "$(dirname "$0")/helpers.sh"

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
OUT="$T/site"
build_fixture_site "$OUT" || fail "fixture site did not build"
README="$OUT/README.md"
assert_file "$README"

assert_eq "$(head -1 "$README")" '# Awesome Typst Editors [![Awesome](https://awesome.re/badge.svg)](https://awesome.re)' "first line"

contents=$(awk '/^## Contents/{f=1; next} /^## /{f=0} f && NF' "$README" | paste -sd'|' -)
assert_eq "$contents" '- [Desktop](#desktop)|- [Web](#web)' "Contents"

assert_contains "$README" '- [Aurora](https://github.com/example/aurora) - A calm desktop editor for Typst.'
assert_contains "$README" '- [Echo \[Beta\] \& Co](https://github.com/example/echo) - Edits Typst in two places at once.'
assert_contains "$README" '- [Foxglove](https://tangled.org/example/foxglove) - A Typst web editor.'
assert_eq "$(grep -c 'Echo' "$README")" "1" "Echo appears once"

for name in Delta Cinder bramble; do
  assert_not_contains "$README" "$name"
done

while IFS= read -r line; do
  grep -qE '^- \[.+\]\(https?://[^)]+\) - [A-Z].*\.$' <<<"$line" || fail "item line has the wrong shape: $line"
done < <(grep -F '](http' "$README" | grep -E '^- \[')

assert_contains "$README" "## Contributing"
assert_contains "$README" "## License"
assert_contains "$README" "Screenshots belong to their projects"

finish

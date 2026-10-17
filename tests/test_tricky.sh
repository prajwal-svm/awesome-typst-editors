#!/usr/bin/env bash
# Hostile names and descriptions, blank fields: escaped everywhere, never a crash.
source "$(dirname "$0")/helpers.sh"

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
OUT="$T/site"
typst compile site/main.typ "$OUT" "${TYPST_BUNDLE[@]}" --input data=/tests/fixtures/editors-tricky.yaml \
  --input screenshots=/tests/fixtures/screenshots-empty.yaml --input today=2026-10-17 2>"$T/err" ||
  fail "tricky fixture did not build: $(cat "$T/err")"

# Prints the JSON-LD script's contents, but only when they hold no raw "<": a raw "<!--<script"
# there makes HTML parsers swallow the rest of the page. (In quoted attributes it's harmless.)
ld_json() { sed -n 's/.*<script type="application\/ld+json">\([^<]*\)<\/script>.*/\1/p' "$1"; }

# JSON-LD: no raw "<" inside the script, and it still decodes to the literal text.
assert_contains "$OUT/editors/tricky/index.html" '<!--<script'
ld_json "$OUT/index.html" >"$T/index-ld.json"
assert_eq "$(jq -r '.itemListElement[] | select(.url | endswith("/tricky/")) | .name' "$T/index-ld.json")" \
  'Tricky <b>Bold</b> *Star* [x] & Co' "JSON-LD name decodes literally"
ld_json "$OUT/editors/tricky/index.html" >"$T/tricky-ld.json"
jq -e '.description | startswith("Ends the script <!--<script>")' "$T/tricky-ld.json" >/dev/null || fail "JSON-LD description should decode literally"

# README: Markdown punctuation is escaped in names and descriptions.
README="$OUT/README.md"
for piece in 'Tricky \<b\>Bold\</b\> \*Star\* \[x\] \& Co' '\<!--\<script\>' '\[link\](http://x.example)' '\_under\_' '\`code\`'; do
  assert_contains "$README" "$piece"
done

# Blank optional fields count as missing.
assert_contains "$README" '- [Blank](https://github.com/example/blank) - A Typst web editor.'
assert_contains "$OUT/editors/blank/index.html" '<title>Blank: a Typst editor | Awesome Typst Editors</title>'
assert_not_contains "$OUT/editors/blank/index.html" 'class="editor-by"'

finish

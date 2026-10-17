#!/usr/bin/env bash
# Editor pages, the giscus embed, social images, head tags, JSON-LD, sitemap and 404.
source "$(dirname "$0")/helpers.sh"

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
OUT="$T/site"
build_fixture_site "$OUT" || fail "fixture site did not build"
build_fixture_site "$T/noids" --input generated=/tests/fixtures/generated-no-ids.json || fail "no-ids site did not build"

ld_json() { # file -> the JSON-LD block
  sed -n 's/.*<script type="application\/ld+json">\([^<]*\)<\/script>.*/\1/p' "$1"
}

for slug in aurora bramble delta echo foxglove; do
  assert_file "$OUT/editors/$slug/index.html"
done
assert_no_file "$OUT/editors/cinder"

AURORA="$OUT/editors/aurora/index.html"
for attr in 'src="https://giscus.app/client.js"' 'data-repo="prajwal-svm/awesome-typst-editors"' \
  'data-repo-id="R_test"' 'data-category="Editors"' 'data-category-id="DIC_test"' \
  'data-mapping="specific"' 'data-term="aurora"' 'data-strict="1"' 'data-reactions-enabled="1"' \
  'data-input-position="top"' 'data-theme="preferred_color_scheme"' 'data-loading="lazy"'; do
  assert_contains "$AURORA" "$attr"
done
assert_contains "$AURORA" 'https://github.com/prajwal-svm/awesome-typst-editors/discussions/1'
assert_contains "$AURORA" '<link rel="canonical" href="https://prajwal-svm.github.io/awesome-typst-editors/editors/aurora/">'
assert_contains "$AURORA" 'content="https://prajwal-svm.github.io/awesome-typst-editors/editors/aurora/og.png"'
assert_contains "$AURORA" 'name="twitter:card" content="summary_large_image"'

assert_contains "$AURORA" '<figure class="editor-shot"><img src="/awesome-typst-editors/screenshots/aurora.png" alt="Screenshot of Aurora"'
assert_contains "$AURORA" 'Screenshot from <a href="https://github.com/example/aurora">'
assert_contains "$OUT/editors/bramble/index.html" 'class="editor-image" src="/awesome-typst-editors/editors/bramble/og.png"'

NOIDS="$T/noids/editors/aurora/index.html"
assert_not_contains "$NOIDS" "giscus.app"
assert_contains "$NOIDS" "Hearts and comments show up on the live site."

ECHO="$OUT/editors/echo/index.html"
assert_contains "$ECHO" "Arrived 1 Aug 2026"
assert_contains "$ECHO" "<title>Echo [Beta] &amp; Co"
assert_contains "$ECHO" 'property="og:title" content="Echo [Beta] &amp; Co'
ld_json "$ECHO" >"$T/echo-ld.json"
jq -e '.["@type"] == "SoftwareApplication" and .name == "Echo [Beta] & Co" and (has("aggregateRating") | not)' "$T/echo-ld.json" >/dev/null ||
  fail "echo JSON-LD should be a SoftwareApplication named 'Echo [Beta] & Co' with no aggregateRating"

BRAMBLE="$OUT/editors/bramble/index.html"
assert_contains "$BRAMBLE" ">Website<"
assert_not_contains "$BRAMBLE" ">Code<"
assert_not_contains "$BRAMBLE" ">Typst forum post<"
assert_not_contains "$BRAMBLE" ">Reddit post<"
assert_not_contains "$BRAMBLE" ">none<"

file "$OUT/editors/aurora/og.png" | grep -q "1200 x 630" || fail "editors/aurora/og.png should be 1200 x 630"
assert_file "$OUT/og.png"

ld_json "$OUT/index.html" >"$T/index-ld.json"
jq -e '.["@type"] == "ItemList" and (.itemListElement | length) == 5' "$T/index-ld.json" >/dev/null ||
  fail "index.html JSON-LD should be an ItemList with 5 entries"

assert_eq "$(grep -o '<loc>' "$OUT/sitemap.xml" | wc -l | tr -d ' ')" "8" "sitemap URLs"
assert_eq "$(grep -o '<lastmod>2026-10-17</lastmod>' "$OUT/sitemap.xml" | wc -l | tr -d ' ')" "8" "sitemap lastmod"

assert_file "$OUT/404.html"
assert_contains "$OUT/404.html" 'href="/awesome-typst-editors/"'

finish

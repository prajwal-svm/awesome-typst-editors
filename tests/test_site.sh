#!/usr/bin/env bash
# The page shell, the cards and the three views, built from the fixture.
source "$(dirname "$0")/helpers.sh"

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
OUT="$T/site"
build_fixture_site "$OUT" || fail "fixture site did not build"

# Prints one card's HTML: the anchor whose href points at the given slug.
card() { # slug file
  local html nl=$'\n'
  html=$(<"$2")
  printf '%s\n' "${html//<\/a>/</a>$nl}" | grep -F "href=\"/awesome-typst-editors/editors/$1/\"" | head -1
}

for f in index.html timeline/index.html kind/index.html style.css favicon.svg; do
  assert_file "$OUT/$f"
done

INDEX="$OUT/index.html"
assert_contains "$INDEX" '5 Typst editors and <span class="mark">counting</span>'
assert_contains "$INDEX" 'class="eyebrow"'
assert_contains "$INDEX" 'href="/awesome-typst-editors/kind/#desktop"'
assert_contains "$INDEX" 'href="/awesome-typst-editors/kind/#terminal"'
order=$(grep -o 'class="card" href="[^"]*"' "$INDEX" | sed 's/.*editors\///; s/\/"$//' | paste -sd' ' -)
assert_eq "$order" "aurora bramble delta echo foxglove" "A to Z card order"

card aurora "$INDEX" >"$T/aurora.html"
assert_contains "$T/aurora.html" '<img class="card-shot" src="/awesome-typst-editors/screenshots/aurora.png" alt="Screenshot of Aurora"'
assert_not_contains "$T/aurora.html" 'card-banner'
assert_file "$OUT/screenshots/aurora.png"
assert_contains "$T/aurora.html" "<li>Open source</li>"
assert_contains "$T/aurora.html" "by example"
assert_contains "$T/aurora.html" 'aria-label="3 hearts"'
assert_contains "$T/aurora.html" 'aria-label="2 comments"'
assert_contains "$T/aurora.html" 'class="icon icon-heart"'
assert_contains "$T/aurora.html" '<span class="card-icon" aria-hidden="true">A</span>'
assert_contains "$T/aurora.html" 'class="icon icon-comment"'
assert_not_contains "$INDEX" "💬"
assert_not_contains "$INDEX" "♥"

card bramble "$INDEX" >"$T/bramble.html"
assert_contains "$T/bramble.html" 'class="card-banner kind-web"'
assert_not_contains "$T/bramble.html" 'card-shot'
assert_contains "$T/bramble.html" 'class="card-name">bramble<'
assert_not_contains "$T/bramble.html" "card-by"
assert_not_contains "$T/bramble.html" "card-desc"

card echo "$INDEX" >"$T/echo.html"
assert_contains "$T/echo.html" "Echo [Beta] &amp; Co"

for f in index.html timeline/index.html kind/index.html; do
  assert_not_contains "$OUT/$f" ">none<"
  assert_not_contains "$OUT/$f" 'href="none"'
done

TIMELINE="$OUT/timeline/index.html"
months=$(grep -o 'class="month">[^<]*' "$TIMELINE" | sed 's/.*>//' | paste -sd'|' -)
assert_eq "$months" "September 2026|August 2026|March 2026|May 2025" "timeline month order"
assert_contains "$TIMELINE" "Arrived 17 Sep 2026"
card bramble "$TIMELINE" >"$T/bramble-timeline.html"
assert_contains "$T/bramble-timeline.html" "Arrived 17 Sep 2026"

assert_eq "$(head -c 31 "$INDEX")" '<!DOCTYPE html><html lang="en">' "document start"
assert_contains "$INDEX" '<link rel="canonical" href="https://prajwal-svm.github.io/awesome-typst-editors/">'
assert_contains "$INDEX" 'property="og:title"'

KIND="$OUT/kind/index.html"
assert_contains "$KIND" 'id="desktop"'
assert_contains "$KIND" 'id="web"'
assert_contains "$KIND" 'id="terminal"'
assert_not_contains "$KIND" 'id="mobile"'

assert_contains "$INDEX" 'aria-current="page">A to Z<'
assert_not_contains "$INDEX" 'aria-current="page">Timeline<'
assert_contains "$TIMELINE" 'aria-current="page">Timeline<'

assert_contains "$INDEX" "Made by Prajwal (prajwal-svm). Every editor gets the same card, and nothing is sorted by hearts."
assert_not_contains "$INDEX" "who also builds Oleafly"
assert_contains "$INDEX" "https://github.com/prajwal-svm/awesome-typst-editors/issues/new?template=add-editor.yml"
assert_contains "$INDEX" "https://github.com/prajwal-svm/awesome-typst-editors/issues/new?template=fix-or-remove.yml"

CSS="$OUT/style.css"
assert_eq "$(grep -n 'outline' "$CSS" | grep -v 'outline: none' || true)" "" "no outlines in CSS"
grep -A4 ':focus-visible' "$CSS" | grep -qE 'background|border-color' || fail "style.css needs a :focus-visible rule with a background or border colour"

finish

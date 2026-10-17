#!/usr/bin/env bash
# The weekly counter check script, its workflow, and the issue forms.
source "$(dirname "$0")/helpers.sh"

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

out=$(DATA=/tests/fixtures/editors.yaml bash scripts/missing-from-counter.sh tests/fixtures/counter.csv 2>"$T/err") ||
  fail "missing-from-counter.sh failed: $(cat "$T/err")"
assert_eq "$(paste -sd'|' - <<<"$out")" "Typsastra (formerly Typstry)|Zephyr" "editors missing from our list"

ev() { typst eval "$1" --root . --format json 2>&1; }

assert_eq "$(ev 'yaml("/.github/ISSUE_TEMPLATE/add-editor.yml").body.len() > 0')" "true" "add-editor form parses"
assert_eq "$(ev 'yaml("/.github/ISSUE_TEMPLATE/add-editor.yml").body.find(b => b.at("id", default: none) == "kinds").attributes.options.map(o => o.label)')" \
  '["Desktop","Web","Mobile","Terminal"]' "add-editor kinds"
assert_eq "$(ev 'yaml("/.github/ISSUE_TEMPLATE/add-editor.yml").labels')" '["add-editor"]' "add-editor label"
assert_eq "$(ev 'yaml("/.github/ISSUE_TEMPLATE/fix-or-remove.yml").body.find(b => b.at("id", default: none) == "request").attributes.options')" \
  '["Fix something","Remove this editor"]' "fix-or-remove request options"
assert_eq "$(ev 'yaml("/.github/ISSUE_TEMPLATE/fix-or-remove.yml").labels')" '["fix-or-remove"]' "fix-or-remove label"

WF=/.github/workflows/counter-check.yml
assert_eq "$(ev "yaml(\"$WF\").on.schedule.first().cron")" '"23 6 * * 1"' "counter check cron"
assert_eq "$(ev "yaml(\"$WF\").permissions")" '{"contents":"read","issues":"write"}' "counter check permissions"
assert_contains ".github/workflows/counter-check.yml" "https://raw.githubusercontent.com/sermuns/days-since-last-typst-editor/main/data.csv"

finish

#!/usr/bin/env bash
# The weekly counter check script, its workflow, and the issue forms.
source "$(dirname "$0")/helpers.sh"

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

out=$(DATA=/tests/fixtures/editors.yaml bash scripts/missing-from-counter.sh tests/fixtures/counter.csv 2>"$T/err") ||
  fail "missing-from-counter.sh failed: $(cat "$T/err")"
assert_eq "$(paste -sd'|' - <<<"$out")" "Typsastra (formerly Typstry)|Zephyr" "editors missing from our list"

skipped=$(DATA=/tests/fixtures/editors.yaml SKIP=/tests/fixtures/counter-skip.yaml bash scripts/missing-from-counter.sh tests/fixtures/counter.csv 2>"$T/err") ||
  fail "missing-from-counter.sh with a skip list failed: $(cat "$T/err")"
assert_eq "$skipped" "Typsastra (formerly Typstry)" "ruled-out editors are skipped"

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

# Run the workflow's check for real, against the fake gh and curl.
block=$(ev "yaml(\"$WF\").jobs.check.steps.find(s => s.at(\"name\", default: none) == \"Compare with the counter\").run" | jq -r .)
[ -n "$block" ] || fail "no 'Compare with the counter' step"
run_check() { # counter.csv open-issue-number -> the gh calls end up in $T/gh.log
  : >"$T/gh.log"
  # GH_REPO points nowhere real, in case the real gh ever runs instead of the stub.
  GH_REPO=test-owner/test-repo STUB_COUNTER=$1 STUB_OPEN_ISSUE=$2 STUB_LOG="$T/gh.log" PATH="$PWD/tests/stubs:$PATH" \
    DATA=/tests/fixtures/editors.yaml SKIP=/tests/fixtures/counter-skip.yaml bash -c "$block" >"$T/check.out" 2>&1 ||
    fail "counter check failed: $(cat "$T/check.out")"
}

run_check tests/fixtures/counter.csv 7
assert_contains "$T/gh.log" "issue edit 7"
assert_contains "$T/gh.log" "- Typsastra (formerly Typstry)"
assert_not_contains "$T/gh.log" "Zephyr"

# Everything listed or ruled out: the open issue gets closed.
printf 'date,name,source_code_url,reddit_url,typst_forum_url\n2026-03-01,Aurora,,,\n' >"$T/listed.csv"
run_check "$T/listed.csv" 7
assert_contains "$T/gh.log" "issue close 7"
assert_not_contains "$T/gh.log" "issue edit"

finish

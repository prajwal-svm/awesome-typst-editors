#!/usr/bin/env bash
# scripts/ensure-discussions.sh against the fake gh.
source "$(dirname "$0")/helpers.sh"

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
export PATH="$PWD/tests/stubs:$PATH"
export DATA=/tests/fixtures/editors.yaml
export STUB_LOG="$T/log"
: >"$STUB_LOG"

STUB_GRAPHQL=tests/fixtures/api/graphql_discussions.json bash scripts/ensure-discussions.sh >"$T/out" 2>"$T/err" ||
  fail "ensure-discussions.sh failed: $(cat "$T/err")"

assert_eq "$(jq -r .title "$STUB_LOG" | paste -sd' ' -)" "bramble cinder foxglove" "created discussions"
assert_eq "$(paste -sd'|' - <"$T/out")" "created bramble|created cinder|created foxglove" "script output"
assert_eq "$(jq -r .repositoryId "$STUB_LOG" | sort -u)" "R_test" "repository id"
assert_eq "$(jq -r .categoryId "$STUB_LOG" | sort -u)" "DIC_test" "category id"

body=$(jq -r 'select(.title == "foxglove") | .body' "$STUB_LOG")
hash=$(bash -c 'source scripts/lib.sh && sha1_hex foxglove')
[[ "$body" == *"<!-- sha1: $hash -->" ]] || fail "foxglove body should end with its sha1 marker, got: $body"
[[ "$body" == *"https://prajwal-svm.github.io/awesome-typst-editors/editors/foxglove/"* ]] ||
  fail "foxglove body should link to its page"

# Every hourly run would call this again: nothing exists twice.
: >"$STUB_LOG"
STUB_GRAPHQL=tests/fixtures/api/graphql_discussions_all.json bash scripts/ensure-discussions.sh >/dev/null 2>&1
code=$?
assert_eq "$code" "0" "exit code when every discussion exists"
assert_eq "$(wc -c <"$STUB_LOG" | tr -d ' ')" "0" "nothing created when every discussion exists"

STUB_GRAPHQL=tests/fixtures/api/graphql_no_category.json bash scripts/ensure-discussions.sh >/dev/null 2>"$T/err-cat"
code=$?
assert_eq "$code" "1" "exit code without the Editors category"
assert_contains "$T/err-cat" 'create the "Editors" discussion category'

finish

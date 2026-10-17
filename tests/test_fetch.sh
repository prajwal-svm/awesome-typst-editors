#!/usr/bin/env bash
# scripts/fetch-data.sh against the fake gh and curl.
source "$(dirname "$0")/helpers.sh"

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
export PATH="$PWD/tests/stubs:$PATH"
export DATA=/tests/fixtures/editors.yaml
export STUB_GRAPHQL=tests/fixtures/api/graphql_discussions.json

J=$(bash scripts/fetch-data.sh 2>"$T/err") || fail "fetch-data.sh failed: $(cat "$T/err")"

assert_eq "$(jq -r .editors.aurora.stars <<<"$J")" "120" "aurora stars"
assert_eq "$(jq -r .editors.aurora.license <<<"$J")" "MIT" "aurora license"
assert_eq "$(jq -r .editors.aurora.owner <<<"$J")" "example" "aurora owner"
assert_eq "$(jq -r .editors.delta.stars <<<"$J")" "49" "delta stars, through the Codeberg API"
assert_eq "$(jq -r .editors.delta.license <<<"$J")" "null" "Codeberg license is left to the YAML"
assert_eq "$(jq -r '.editors | has("foxglove")' <<<"$J")" "false" "tangled.org isn't fetched"
assert_eq "$(jq -r '.editors | has("bramble")' <<<"$J")" "false" "no source, nothing fetched"
assert_eq "$(jq -r .discussions.echo.hearts <<<"$J")" "10" "only HEART reactions count"
assert_eq "$(jq -r .discussions.echo.comments <<<"$J")" "1" "echo comments"
assert_eq "$(jq -r .discussions.delta.hearts <<<"$J")" "0" "no reactions means 0 hearts"
assert_eq "$(jq -r '.discussions | has("cinder")' <<<"$J")" "false" "other categories don't count"
assert_eq "$(jq -r .repo_id <<<"$J")" "R_test" "repo id"
assert_eq "$(jq -r .category_id <<<"$J")" "DIC_test" "category id"

# A failed API call fails the script and prints nothing, so no zeroed data reaches the build.
F=$(STUB_FAIL_ON=repos/example/echo bash scripts/fetch-data.sh 2>/dev/null)
code=$?
assert_eq "$code" "1" "exit code on API failure"
assert_eq "$F" "" "stdout on API failure"

# The same when the discussions query fails, so hearts never reach the build as zeros.
F=$(STUB_FAIL_ON=categoryId bash scripts/fetch-data.sh 2>/dev/null)
code=$?
assert_eq "$code" "1" "exit code when the discussions query fails"
assert_eq "$F" "" "stdout when the discussions query fails"

# More than one page of discussions: every page is read.
P=$(STUB_GRAPHQL=tests/fixtures/api/graphql_page1.json STUB_GRAPHQL_NEXT=tests/fixtures/api/graphql_page2.json bash scripts/fetch-data.sh 2>"$T/err-pages") ||
  fail "paged fetch failed: $(cat "$T/err-pages")"
assert_eq "$(jq -r .discussions.aurora.hearts <<<"$P")" "3" "page 1 read"
assert_eq "$(jq -r .discussions.echo.hearts <<<"$P")" "10" "page 2 read"

assert_eq "$(bash -c 'source scripts/lib.sh && sha1_hex echo')" "b2d21e771d9f86865c5eff193663574dd1796c8f" "sha1_hex"

finish

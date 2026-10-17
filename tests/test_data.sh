#!/usr/bin/env bash
# Data rules: who's included, orderings, merging with fetched data, and validation.
source "$(dirname "$0")/helpers.sh"

query() {
  typst eval 'query(<result>).first().value' --in tests/query-data.typ --root . --format json "$@"
}

R=$(query "${FIXTURE_INPUTS[@]}" 2>/dev/null) || fail "tests/query-data.typ did not evaluate"

assert_eq "$(jq -c .site <<<"$R")" '["aurora","bramble","delta","echo","foxglove"]' "site editors (30-day rule)"
assert_eq "$(jq -c .readme <<<"$R")" '["aurora","echo","foxglove"]' "README editors (50 stars)"
assert_eq "$(jq -c .timeline <<<"$R")" '["bramble","echo","foxglove","aurora","delta"]' "timeline order"
assert_eq "$(jq -c '[.kinds[].kind]' <<<"$R")" '["desktop","web","terminal"]' "kinds present"
assert_eq "$(jq -c '.kinds[1].editors' <<<"$R")" '["bramble","echo","foxglove"]' "web editors"
assert_eq "$(jq -c .open <<<"$R")" '["aurora","foxglove"]' "open source"
assert_eq "$(jq -r .desc.echo <<<"$R")" 'Edits Typst in two places at once' "YAML description wins"
assert_eq "$(jq -r .builder.aurora <<<"$R")" 'example' "builder falls back to fetched owner"
assert_eq "$(jq -r .stars.foxglove <<<"$R")" '75' "YAML stars"
assert_eq "$(jq -r .hearts.bramble <<<"$R")" '0' "no discussion means 0 hearts"

# Hearts never change the order.
assert_eq "$(jq -r .hearts.foxglove <<<"$R")" '99' "fixture gives foxglove the most hearts"
assert_eq "$(jq -c .az <<<"$R")" '["aurora","bramble","delta","echo","foxglove"]' "A to Z ignores hearts"

# Without fetched data, everything still works with zero counts.
R0=$(query --input data=/tests/fixtures/editors.yaml --input today=2026-10-17 2>/dev/null) || fail "query without generated data failed"
assert_eq "$(jq -c .site <<<"$R0")" '["aurora","bramble","delta","echo","foxglove"]' "site without generated data"
assert_eq "$(jq -c '[.hearts[]] | unique' <<<"$R0")" '[0]' "all hearts are 0 without generated data"

# Bad data stops the build with a message naming the editor.
bad_files=(duplicate-slug bad-kind missing-arrived bad-date bad-slug)
bad_msgs=(
  'duplicate slug "aurora"'
  'unknown kind "tablet" for "aurora"'
  '"aurora" is missing arrived'
  'bad date "2026-13-40" for "aurora"'
  'bad slug "Aurora Editor"'
)
for i in "${!bad_files[@]}"; do
  assert_fails_with "query --input data=/tests/fixtures/bad/${bad_files[$i]}.yaml --input today=2026-10-17" "${bad_msgs[$i]}"
done

finish

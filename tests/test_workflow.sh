#!/usr/bin/env bash
# The site workflow: triggers, pinned versions, step order, and the README commit logic,
# which runs here for real against a throwaway bare repo.
source "$(dirname "$0")/helpers.sh"

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

W=$(typst eval 'yaml("/.github/workflows/site.yml")' --root . --format json 2>"$T/err") || fail "site.yml did not parse: $(cat "$T/err")"

assert_eq "$(jq -r '.on.schedule[0].cron' <<<"$W")" "17 * * * *" "cron"
assert_eq "$(jq -c '.on.push.branches' <<<"$W")" '["main"]' "push branches"
assert_eq "$(jq -c '.on | has("workflow_dispatch")' <<<"$W")" "true" "manual runs"
assert_eq "$(jq -cS '.permissions' <<<"$W")" '{"contents":"write","discussions":"write","id-token":"write","pages":"write"}' "permissions"
assert_eq "$(jq -c '.concurrency' <<<"$W")" '{"group":"pages","cancel-in-progress":false}' "concurrency"
assert_eq "$(jq -c '[.jobs.build.steps[].uses // empty] + [.jobs.deploy.steps[].uses // empty]' <<<"$W")" \
  '["actions/checkout@v7","typst-community/setup-typst@v5","actions/upload-pages-artifact@v5","actions/deploy-pages@v5"]' "pinned actions"
assert_eq "$(jq -r '.jobs.build.steps[] | select(.uses == "typst-community/setup-typst@v5") | .with["typst-version"]' <<<"$W")" "0.15.1" "Typst version"
assert_eq "$(jq -r '.jobs.build["runs-on"]' <<<"$W")" "ubuntu-24.04" "runner"
assert_eq "$(jq -r '.jobs.deploy.needs' <<<"$W")" "build" "deploy needs build"
assert_eq "$(jq -r '.jobs.deploy.environment.name' <<<"$W")" "github-pages" "deploy environment"
assert_eq "$(jq -r '[.jobs.build.steps[].run // empty | startswith("set -euo pipefail")] | all' <<<"$W")" "true" "every run block is strict"

step_index() { # jq condition -> index of the first matching build step
  jq -r "[.jobs.build.steps | to_entries[] | select(.value | $1) | .key][0] // -1" <<<"$W"
}
i_tests=$(step_index '(.run // "") | contains("tests/run.sh")')
i_discussions=$(step_index '(.run // "") | contains("scripts/ensure-discussions.sh")')
i_fetch=$(step_index '(.run // "") | contains("scripts/fetch-data.sh")')
i_compile=$(step_index '(.run // "") | contains("typst compile site/main.typ _site")')
i_readme=$(step_index '.name == "Commit README if changed"')
i_upload=$(step_index '.uses == "actions/upload-pages-artifact@v5"')
order="$i_tests<$i_discussions<$i_fetch<$i_compile<$i_readme<$i_upload"
if ! { [ "$i_tests" -ge 0 ] && [ "$i_tests" -lt "$i_discussions" ] && [ "$i_discussions" -lt "$i_fetch" ] &&
  [ "$i_fetch" -lt "$i_compile" ] && [ "$i_compile" -lt "$i_readme" ] && [ "$i_readme" -lt "$i_upload" ]; }; then
  fail "build steps out of order (tests<discussions<fetch<compile<readme<upload): $order"
fi

# Run the README step for real. Isolate git from this machine's config and any hook env.
block=$(jq -r '.jobs.build.steps[] | select(.name == "Commit README if changed") | .run' <<<"$W")
[ -n "$block" ] || fail "no 'Commit README if changed' step"
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE
export GIT_CONFIG_GLOBAL="$T/gitconfig" GIT_CONFIG_NOSYSTEM=1
: >"$GIT_CONFIG_GLOBAL"
g() { git -c user.name=test -c user.email=test@example.com -c init.defaultBranch=main "$@"; }

new_remote() { # name file-to-seed -> path of a bare repo with one commit
  local bare="$T/$1.git" seed="$T/$1-seed"
  g init -q --bare "$bare"
  g clone -q "$bare" "$seed" 2>/dev/null
  printf '%s\n' "$3" >"$seed/$2"
  g -C "$seed" add "$2"
  g -C "$seed" commit -q -m "seed"
  g -C "$seed" push -q origin HEAD:main 2>/dev/null
  echo "$bare"
}
run_block_in() { # bare readme-content -> runs the block in a fresh clone
  local work="$T/work-$RANDOM"
  g clone -q "$1" "$work" 2>/dev/null
  mkdir -p "$work/_site"
  printf '%s\n' "$2" >"$work/_site/README.md"
  (cd "$work" && bash -c "$block") >"$T/block.log" 2>&1 || fail "README step failed: $(cat "$T/block.log")"
}
commits() { git --git-dir="$1" rev-list --count main; }

bare=$(new_remote unchanged README.md "# Same")
run_block_in "$bare" "# Same"
assert_eq "$(commits "$bare")" "1" "unchanged README: no new commit"

bare=$(new_remote changed README.md "# Old")
run_block_in "$bare" "# New"
assert_eq "$(commits "$bare")" "2" "changed README: one new commit"
message=$(git --git-dir="$bare" log -1 --format=%B main)
assert_eq "$(head -1 <<<"$message")" "docs: regenerate README" "commit message"
if grep -qi "co-authored-by" <<<"$message"; then fail "commit message must not carry co-author lines"; fi

bare=$(new_remote first other.txt "x")
run_block_in "$bare" "# First"
assert_eq "$(commits "$bare")" "2" "untracked README on the first run: one commit"
assert_eq "$(git --git-dir="$bare" show main:README.md)" "# First" "README content committed"

finish

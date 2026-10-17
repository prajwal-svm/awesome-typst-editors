#!/usr/bin/env bash
# Prints the build-time data as JSON: stars, descriptions, owners and licenses from
# each editor's code host, and heart and comment counts from its GitHub Discussion.
# Any failed call exits non-zero with nothing on stdout, so a bad fetch never
# reaches the build as zeros.
#   REPO      default prajwal-svm/awesome-typst-editors
#   CATEGORY  default Editors
#   DATA      default /data/editors.yaml (relative to the repo root)
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/lib.sh

REPO=${REPO:-prajwal-svm/awesome-typst-editors}
CATEGORY=${CATEGORY:-Editors}
DATA=${DATA:-/data/editors.yaml}

editors=$(editors_json "$DATA")
slugs_and_sources=$(jq -r '.[] | [.slug, (.source // "")] | @tsv' <<<"$editors")

fetched='{}'
while IFS=$'\t' read -r slug source; do
  [ -n "$slug" ] || continue
  gh_repo=$(github_repo "$source")
  cb_repo=$(codeberg_repo "$source")
  if [ -n "$gh_repo" ]; then
    repo_json=$(gh api "repos/$gh_repo")
    item=$(jq -c '{stars: .stargazers_count, description: .description, owner: .owner.login,
      license: (.license.spdx_id // null), archived: .archived}' <<<"$repo_json")
  elif [ -n "$cb_repo" ]; then
    repo_json=$(curl -fsS "https://codeberg.org/api/v1/repos/$cb_repo")
    item=$(jq -c '{stars: .stars_count, description: .description, owner: .owner.login,
      license: null, archived: .archived}' <<<"$repo_json")
  else
    continue
  fi
  fetched=$(jq -c --arg slug "$slug" --argjson item "$item" '. + {($slug): $item}' <<<"$fetched")
done <<<"$slugs_and_sources"

discussions=$(discussions_json "$REPO")

jq --arg category "$CATEGORY" --argjson editors "$fetched" '
  .data.repository as $repo
  | {
      repo_id: $repo.id,
      category_id: ([$repo.discussionCategories.nodes[] | select(.name == $category) | .id] | first),
      editors: $editors,
      discussions: (
        [ $repo.discussions.nodes[]
          | select(.category.name == $category)
          | { key: .title,
              value: { number, url,
                hearts: ([.reactionGroups[] | select(.content == "HEART") | .reactors.totalCount] | first // 0),
                comments: .comments.totalCount } } ]
        | from_entries)
    }' <<<"$discussions"

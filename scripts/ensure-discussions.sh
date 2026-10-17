#!/usr/bin/env bash
# Creates a GitHub Discussion for every editor that doesn't have one yet, so each card
# has a place for hearts and comments from day one. Safe to run every hour: an editor
# whose slug already titles a discussion in the category is skipped.
# The body ends with the SHA-1 marker giscus looks for with strict matching.
#   REPO      default prajwal-svm/awesome-typst-editors
#   CATEGORY  default Editors
#   DATA      default /data/editors.yaml (relative to the repo root)
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/lib.sh

REPO=${REPO:-prajwal-svm/awesome-typst-editors}
CATEGORY=${CATEGORY:-Editors}
DATA=${DATA:-/data/editors.yaml}
SITE_URL="https://prajwal-svm.github.io/awesome-typst-editors/"

discussions=$(discussions_json "$REPO" "$CATEGORY")
repo_id=$(jq -r '.data.repository.id' <<<"$discussions")
category_id=$(jq -r --arg c "$CATEGORY" \
  '[.data.repository.discussionCategories.nodes[] | select(.name == $c) | .id] | first // empty' <<<"$discussions")
if [ -z "$category_id" ]; then
  echo "create the \"$CATEGORY\" discussion category (announcement format) first" >&2
  exit 1
fi
existing=$(jq -r --arg c "$CATEGORY" \
  '.data.repository.discussions.nodes[] | select(.category.name == $c) | .title' <<<"$discussions")
rows=$(editors_json "$DATA" | jq -r '.[] | [.slug, .name] | @tsv')

while IFS=$'\t' read -r slug name; do
  [ -n "$slug" ] || continue
  if grep -qxF -- "$slug" <<<"$existing"; then
    continue
  fi
  body="Hearts and comments for $name on Awesome Typst Editors: ${SITE_URL}editors/$slug/

Leave a heart on this post to show $name some love.

<!-- sha1: $(sha1_hex "$slug") -->"
  gh api graphql -f repositoryId="$repo_id" -f categoryId="$category_id" -f title="$slug" -f body="$body" -f query='
    mutation($repositoryId: ID!, $categoryId: ID!, $title: String!, $body: String!) {
      createDiscussion(input: {repositoryId: $repositoryId, categoryId: $categoryId, title: $title, body: $body}) {
        discussion { number url }
      }
    }' >/dev/null
  echo "created $slug"
done <<<"$rows"

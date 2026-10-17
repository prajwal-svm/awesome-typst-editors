# Shared helpers for the scripts in this folder. Source it from the repo root.
set -euo pipefail

# Prints editors.yaml as JSON. The path is relative to the repo root, with a leading slash.
editors_json() {
  typst eval "yaml(\"${1:-/data/editors.yaml}\")" --root . --format json
}

# Prints owner/repo for a GitHub URL, or nothing.
github_repo() {
  if [[ "${1:-}" =~ ^https://github\.com/([^/]+)/([^/#?]+) ]]; then
    local repo=${BASH_REMATCH[2]}
    printf '%s/%s\n' "${BASH_REMATCH[1]}" "${repo%.git}"
  fi
}

# Prints owner/repo for a Codeberg URL, or nothing.
codeberg_repo() {
  if [[ "${1:-}" =~ ^https://codeberg\.org/([^/]+)/([^/#?]+) ]]; then
    local repo=${BASH_REMATCH[2]}
    printf '%s/%s\n' "${BASH_REMATCH[1]}" "${repo%.git}"
  fi
}

# Prints the lowercase SHA-1 of a string, as giscus computes it for strict matching.
sha1_hex() {
  if command -v sha1sum >/dev/null 2>&1; then
    printf '%s' "$1" | sha1sum | cut -d' ' -f1
  else
    printf '%s' "$1" | shasum -a 1 | cut -d' ' -f1
  fi
}

# Prints the repo id, its discussion categories, and every discussion in one category with
# its counts, shaped like a single GraphQL response. Reads that category 100 discussions at
# a time, so discussions in other categories never count. Prints nothing and fails if any
# call fails: callers run it inside $(...), where set -e doesn't reach.
discussions_json() {
  local owner=${1%%/*} name=${1#*/} category=$2 repo category_id page nodes='[]'
  local after=()
  repo=$(gh api graphql -f owner="$owner" -f name="$name" -f query='
    query($owner: String!, $name: String!) {
      repository(owner: $owner, name: $name) {
        id
        discussionCategories(first: 25) { nodes { id name } }
      }
    }') || return 1
  category_id=$(jq -r --arg c "$category" \
    '[.data.repository.discussionCategories.nodes[] | select(.name == $c) | .id] | first // empty' <<<"$repo") || return 1
  while [ -n "$category_id" ]; do
    page=$(gh api graphql -f owner="$owner" -f name="$name" -f category="$category_id" "${after[@]}" -f query='
      query($owner: String!, $name: String!, $category: ID!, $cursor: String) {
        repository(owner: $owner, name: $name) {
          discussions(first: 100, after: $cursor, categoryId: $category) {
            pageInfo { hasNextPage endCursor }
            nodes {
              title number url
              category { name }
              reactionGroups { content reactors { totalCount } }
              comments { totalCount }
            }
          }
        }
      }') || return 1
    nodes=$(jq -c --argjson seen "$nodes" '$seen + .data.repository.discussions.nodes' <<<"$page") || return 1
    [ "$(jq -r '.data.repository.discussions.pageInfo.hasNextPage' <<<"$page")" = "true" ] || break
    after=(-f cursor="$(jq -r '.data.repository.discussions.pageInfo.endCursor' <<<"$page")")
  done
  jq -c --argjson nodes "$nodes" '.data.repository.discussions = {nodes: $nodes}' <<<"$repo"
}

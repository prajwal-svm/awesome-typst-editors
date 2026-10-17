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

# Prints the repo id, its discussion categories, and up to 100 discussions with their counts.
discussions_json() {
  local owner=${1%%/*} name=${1#*/} out
  out=$(gh api graphql -f owner="$owner" -f name="$name" -f query='
    query($owner: String!, $name: String!) {
      repository(owner: $owner, name: $name) {
        id
        discussionCategories(first: 25) { nodes { id name } }
        discussions(first: 100) {
          pageInfo { hasNextPage }
          nodes {
            title number url
            category { name }
            reactionGroups { content reactors { totalCount } }
            comments { totalCount }
          }
        }
      }
    }')
  if [ "$(jq -r '.data.repository.discussions.pageInfo.hasNextPage' <<<"$out")" = "true" ]; then
    echo "more than 100 discussions: add pagination" >&2
    return 1
  fi
  printf '%s\n' "$out"
}

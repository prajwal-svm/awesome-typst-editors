# Shared helpers for tests/test_*.sh. Source this file; it moves to the repo root.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

FAILURES=0

fail() {
  echo "  FAIL: $*" >&2
  FAILURES=$((FAILURES + 1))
}

assert_eq() { # actual expected [message]
  [ "$1" == "$2" ] || fail "${3:-values differ}: expected [$2], got [$1]"
}

assert_contains() { # file text
  grep -qF -- "$2" "$1" 2>/dev/null || fail "$1 should contain: $2"
}

assert_not_contains() { # file text
  if grep -qF -- "$2" "$1" 2>/dev/null; then fail "$1 should not contain: $2"; fi
}

assert_file() { [ -f "$1" ] || fail "missing file: $1"; }

assert_no_file() { [ ! -e "$1" ] || fail "unexpected file: $1"; }

assert_fails_with() { # "command" "text expected in its output"
  local out
  if out=$(eval "$1" 2>&1); then
    fail "expected this to fail: $1"
    return
  fi
  grep -qF -- "$2" <<<"$out" || fail "expected [$2] in the output of: $1"$'\n'"$out"
}

finish() {
  if [ "$FAILURES" -gt 0 ]; then
    echo "  $FAILURES assertion(s) failed" >&2
    exit 1
  fi
}

# The fixture data set, compiled as if today were 2026-10-17.
FIXTURE_INPUTS=(
  --input data=/tests/fixtures/editors.yaml
  --input generated=/tests/fixtures/generated.json
  --input today=2026-10-17
  --input base=/awesome-typst-editors/
  --input screenshots=/tests/fixtures/screenshots.yaml
)
TYPST_BUNDLE=(--format bundle --features bundle,html --root .)

build_fixture_site() { # outdir [extra typst args...], later --input values win
  local out=$1
  shift
  if ! typst compile site/main.typ "$out" "${TYPST_BUNDLE[@]}" "${FIXTURE_INPUTS[@]}" "$@" 2>"$out.log"; then
    cat "$out.log" >&2
    return 1
  fi
}

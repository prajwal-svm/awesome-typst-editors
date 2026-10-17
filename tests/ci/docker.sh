#!/usr/bin/env bash
# Runs the test suite in CI's image and architecture (ubuntu:24.04, linux/amd64)
# with the same Typst version the workflow pins, before anything is pushed.
set -euo pipefail
cd "$(dirname "$0")/../.."

docker run --rm --platform linux/amd64 -v "$PWD":/work -w /work ubuntu:24.04 bash -c '
  set -euo pipefail
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq >/dev/null
  apt-get install -y -qq jq git curl file xz-utils ca-certificates >/dev/null
  curl -fsSL https://github.com/typst/typst/releases/download/v0.15.1/typst-x86_64-unknown-linux-musl.tar.xz | tar -xJ -C /tmp
  mv /tmp/typst-x86_64-unknown-linux-musl/typst /usr/local/bin/typst
  echo "$(uname -m) | $(. /etc/os-release && echo "$PRETTY_NAME") | $(typst --version) | $(jq --version)"
  git config --global user.name ci
  git config --global user.email ci@example.com
  git config --global --add safe.directory /work
  bash tests/run.sh
'

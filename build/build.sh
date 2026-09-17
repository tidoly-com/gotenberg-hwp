#!/usr/bin/env bash
# Local single-arch build + smoke test. Publishing is CI only
# (.github/workflows/publish.yml, native amd64/arm64 runners) — under emulation
# `unopkg add` aborts (Java), so a laptop cannot build the other architecture.
set -euo pipefail
cd "$(dirname "$0")/.."
IMG=$(build/tag.sh)
docker build -t "$IMG" .
build/smoke.sh "$IMG"

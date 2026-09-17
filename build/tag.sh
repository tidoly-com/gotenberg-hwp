#!/usr/bin/env bash
# Print the image reference built from this repo. Single source for the tag
# rule (<gotenberg>-h2o<h2orestart>) — the CI workflow and build.sh both call it.
set -euo pipefail
cd "$(dirname "$0")/.."
REGISTRY="${REGISTRY:-ghcr.io/tidoly-com}"
arg() { sed -n "s/^ARG $1=//p" Dockerfile | head -1; }
echo "$REGISTRY/gotenberg-hwp:$(arg GOTENBERG_VERSION)-h2o$(arg H2ORESTART_VERSION)"

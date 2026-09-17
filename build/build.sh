#!/usr/bin/env bash
# Build ghcr.io/tidoly-com/gotenberg-hwp for amd64+arm64 and push, then read the
# manifest back from the registry. Tag is derived from the Dockerfile ARGs.
set -euo pipefail

cd "$(dirname "$0")/.."
REGISTRY="${REGISTRY:-ghcr.io/tidoly-com}"
BUILDER="${BUILDER:-gotenberg-hwp}"

arg() { sed -n "s/^ARG $1=//p" Dockerfile | head -1; }
GV=$(arg GOTENBERG_VERSION); HV=$(arg H2ORESTART_VERSION)
IMG="$REGISTRY/gotenberg-hwp:${GV}-h2o${HV}"

if [[ "${1:-}" == "--load" ]]; then
  docker build -t "$IMG" .
  echo "loaded $IMG"; exit 0
fi

# Tags are never reused — nodes pull IfNotPresent and would keep the old image.
if docker buildx imagetools inspect "$IMG" >/dev/null 2>&1; then
  echo "refuse: $IMG already exists in the registry — bump a version in Dockerfile" >&2
  exit 1
fi

# The docker driver cannot push multi-platform manifests; use a container builder.
docker buildx inspect "$BUILDER" >/dev/null 2>&1 \
  || docker buildx create --name "$BUILDER" --driver docker-container >/dev/null

docker buildx build --builder "$BUILDER" \
  --platform linux/amd64,linux/arm64 \
  -t "$IMG" --push .

echo "--- registry read-back"
docker buildx imagetools inspect "$IMG"

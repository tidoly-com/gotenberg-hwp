#!/usr/bin/env bash
# Smoke-test a locally loaded image: the extension is registered in LibreOffice
# and the LibreOffice route still converts an ordinary document.
# No HWP sample here — this repo is public and real HWP files are not ours to
# publish. HWP conversion itself is verified on a node after deploy.
set -euo pipefail
IMG="$1"
NAME="gotenberg-hwp-smoke-$$"
PORT="${SMOKE_PORT:-3000}"
trap 'docker rm -f "$NAME" >/dev/null 2>&1 || true' EXIT

echo "--- extension registered"
docker run --rm --entrypoint unopkg "$IMG" list --shared | grep -i 'identifier' | grep -i 'h2orestart'

echo "--- gotenberg starts"
docker run -d --name "$NAME" -p "$PORT:3000" "$IMG" gotenberg --api-timeout=60s >/dev/null
for _ in $(seq 1 60); do
  curl -sf localhost:$PORT/health >/dev/null && break
  sleep 1
done
curl -sf localhost:$PORT/health

echo; echo "--- LibreOffice route converts (.odt from a flat ODF text)"
tmp=$(mktemp -d)
cat > "$tmp/smoke.fodt" <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<office:document xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  office:version="1.3" office:mimetype="application/vnd.oasis.opendocument.text">
  <office:body><office:text><text:p>gotenberg-hwp smoke 한글</text:p></office:text></office:body>
</office:document>
XML
code=$(curl -s -o "$tmp/out.pdf" -w '%{http_code}' --max-time 90 \
  -F "files=@$tmp/smoke.fodt" localhost:$PORT/forms/libreoffice/convert)
echo "HTTP $code, $(wc -c < "$tmp/out.pdf") bytes"
[[ "$code" == 200 ]] && head -c 5 "$tmp/out.pdf" | grep -q '%PDF-'
echo "smoke ok"

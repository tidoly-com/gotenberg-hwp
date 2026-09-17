# gotenberg-hwp

[Gotenberg](https://github.com/gotenberg/gotenberg) with the
[H2Orestart](https://github.com/ebandal/H2Orestart) LibreOffice extension, so the
LibreOffice route converts **HWP** (Hancom Hangul) documents to PDF.

```
ghcr.io/tidoly-com/gotenberg-hwp:8.37.0-h2o0.7.14      linux/amd64, linux/arm64
```

Drop-in replacement for `gotenberg/gotenberg:8.37.0` — same entrypoint, flags and API.

## Why

Stock Gotenberg has no HWP import filter. Sending one `.hwp` to
`/forms/libreoffice/convert` keeps LibreOffice at 100% CPU until the API timeout,
and conversions queued behind it fail as well — while `/health` still reports
`{"libreoffice":"up"}`. One HWP upload stalls every Office conversion on the instance.

Measured (arm64, 5 real-world HWP files, `--api-timeout=120s`):

| image | docx | HWP | docx after HWP |
|---|---|---|---|
| `gotenberg:8.37.0` | 200, 0.36s | 503, 120s (timeout) | 503, 120s |
| this image | 200, 0.46s | 200 ×5, 0.10–0.71s | 200, 0.08s |

Text re-extracted from the output PDFs matched the source HWP character-for-character.

## Tags

`<gotenberg version>-h2o<H2Orestart version>`. Tags are never reused — bump either
version and a new tag is built.

## Build

```sh
build/build.sh              # build + push both architectures, then verify the manifest
build/build.sh --load       # local single-arch build, no push
```

Versions and the extension checksum are `ARG`s in the `Dockerfile`; `build/build.sh`
reads them from there.

## Licenses

Files in this repository: MIT (`LICENSE`). The image contains GPL-3.0-or-later
software (H2Orestart); its corresponding source is kept in `sources/`.
See `THIRD-PARTY-NOTICES`.

# Gotenberg + H2Orestart — LibreOffice route converts HWP.
#
# Why: stock Gotenberg's LibreOffice has no HWP import filter. A single .hwp
# pins soffice at 100% CPU until the API timeout and every conversion queued
# behind it fails too, while /health keeps answering 200.
# H2Orestart adds the import filter; with it HWP converts in <1s.
#
# Tag = <gotenberg>-h2o<h2orestart>. Never reuse a tag: nodes pull IfNotPresent.
ARG GOTENBERG_VERSION=8.37.0
FROM gotenberg/gotenberg:${GOTENBERG_VERSION}

ARG GOTENBERG_VERSION
ARG H2ORESTART_VERSION=0.7.14
ARG H2ORESTART_SHA256=cbea23bc37861361bbc534bc0675e5bc67b36f712072490f82a9bf410d7c04d8

LABEL org.opencontainers.image.title="gotenberg-hwp" \
      org.opencontainers.image.description="Gotenberg ${GOTENBERG_VERSION} with the H2Orestart ${H2ORESTART_VERSION} LibreOffice extension (HWP import)" \
      org.opencontainers.image.source="https://github.com/tidoly-com/gotenberg-hwp" \
      org.opencontainers.image.licenses="MIT AND GPL-3.0-or-later AND MPL-2.0" \
      org.opencontainers.image.version="${GOTENBERG_VERSION}-h2o${H2ORESTART_VERSION}"

USER root

# H2Orestart is a Java UNO extension. The base image ships a JRE (/opt/java)
# but not LibreOffice's Java bridge. LibreOffice in the base image comes from
# trixie-backports, so the bridge must come from the same suite to match.
RUN apt-get update \
 && apt-get install -y --no-install-recommends -t trixie-backports libreoffice-java-common \
 && rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/opt/java

ADD --checksum=sha256:${H2ORESTART_SHA256} \
    https://github.com/ebandal/H2Orestart/releases/download/v${H2ORESTART_VERSION}/H2Orestart.oxt \
    /tmp/H2Orestart.oxt
RUN unopkg add --shared --suppress-license /tmp/H2Orestart.oxt \
 && unopkg list --shared | grep -q 'H2Orestart' \
 && rm /tmp/H2Orestart.oxt \
 && mkdir -p /usr/share/doc/gotenberg-hwp

COPY LICENSE THIRD-PARTY-NOTICES /usr/share/doc/gotenberg-hwp/

USER gotenberg

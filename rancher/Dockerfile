# Upstream Rancher Manager image. Tag synced manually or via CI; not hassio-addons base.
ARG RANCHER_TAG=stable
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

FROM rancher/rancher:${RANCHER_TAG}

ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION
ARG RANCHER_TAG

# Static Caddy (reverse proxy on :8099) and jq (read /data/options.json).
# Fully static glibc binaries — no package manager in rancher/rancher (BCI micro).
RUN set -eux; \
    case "${BUILD_ARCH}" in \
        amd64) arch="amd64" ;; \
        aarch64) arch="arm64" ;; \
        *) echo "Unsupported BUILD_ARCH: ${BUILD_ARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/caddyserver/caddy/releases/download/v2.10.0/caddy_2.10.0_linux_${arch}.tar.gz" \
        | tar -xz -C /usr/bin caddy; \
    curl -fsSL "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-${arch}" \
        -o /usr/bin/jq; \
    chmod +x /usr/bin/caddy /usr/bin/jq

COPY rootfs/ /

RUN chmod +x /usr/local/bin/haos-entrypoint.sh /usr/local/lib/haos-rancher/options.sh

LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Byte Bridge <https://github.com/byte-bridge>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/rancher/DOCS.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION} \
    org.opencontainers.image.base.name="docker.io/rancher/rancher:${RANCHER_TAG}"

ENTRYPOINT ["/usr/local/bin/haos-entrypoint.sh"]
CMD ["--no-cacerts"]

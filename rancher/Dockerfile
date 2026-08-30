# Upstream Rancher Manager image. Tag synced manually or via CI; not hassio-addons base.
ARG RANCHER_TAG=stable
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# rancher/rancher (BCI micro) has no CA bundle for curl; fetch static tools elsewhere.
FROM alpine:3.21 AS tools
ARG BUILD_ARCH
RUN set -eux; \
    case "${BUILD_ARCH}" in \
        amd64) arch="amd64" ;; \
        aarch64) arch="arm64" ;; \
        *) echo "Unsupported BUILD_ARCH: ${BUILD_ARCH}" >&2; exit 1 ;; \
    esac; \
    apk add --no-cache curl; \
    curl -fsSL "https://github.com/caddyserver/caddy/releases/download/v2.10.0/caddy_2.10.0_linux_${arch}.tar.gz" \
        | tar -xz -C /tmp caddy; \
    curl -fsSL "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-${arch}" \
        -o /tmp/jq; \
    chmod +x /tmp/caddy /tmp/jq

FROM rancher/rancher:${RANCHER_TAG}

ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION
ARG RANCHER_TAG

# Static glibc binaries (official linux_amd64 / linux_arm64 releases).
COPY --from=tools /tmp/caddy /tmp/jq /usr/bin/

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

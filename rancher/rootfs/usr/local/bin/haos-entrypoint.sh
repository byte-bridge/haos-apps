#!/bin/bash
set -euo pipefail

# shellcheck source=/usr/local/lib/haos-rancher/options.sh
source /usr/local/lib/haos-rancher/options.sh

DATA_DIR="/data/rancher"

haos_require_unprotected

haos_log "Initializing Rancher on Home Assistant OS (upstream rancher/rancher image)..."

if haos_option_true 'reset_data'; then
    haos_log "WARNING: reset_data is enabled — wiping ${DATA_DIR}"
    rm -rf "${DATA_DIR:?}/"*
    mkdir -p "${DATA_DIR}"
    haos_log "Reset complete — turning off reset_data in app options"
    haos_clear_option 'reset_data' 'false' || \
        haos_log "WARNING: Could not clear reset_data automatically; disable it in app options"
fi

mkdir -p "${DATA_DIR}"
if ! mountpoint -q /var/lib/rancher; then
    mount --bind "${DATA_DIR}" /var/lib/rancher
fi

haos_log "Clearing leftover k3s cluster-reset flag (if present)..."
rm -f /var/lib/rancher/k3s/server/db/reset-flag

if haos_option_true 'k3s_haos_compat'; then
    haos_log "HAOS k3s compatibility: CONTAINERD_SNAPSHOTTER=native"
    export CONTAINERD_SNAPSHOTTER=native
fi

if haos_option_has_value 'bootstrap_password'; then
    export CATTLE_BOOTSTRAP_PASSWORD="$(haos_option 'bootstrap_password')"
fi

if haos_option_has_value 'server_url'; then
    export CATTLE_SERVER_URL="$(haos_option 'server_url')"
fi

haos_log "Starting Ingress reverse proxy on :8099..."
nohup caddy run --config /etc/caddy/Caddyfile --adapter caddyfile >>/proc/1/fd/1 2>&1 &
disown -h $!

haos_log "Starting Rancher (upstream entrypoint)..."
exec /usr/local/bin/rancher-entrypoint.sh "$@"

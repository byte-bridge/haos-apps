#!/usr/bin/with-contenv bashio
# ==============================================================================
# HAOS Rancher - initialization
# ==============================================================================
bashio::log.info "Initializing Rancher app..."

bashio::require.unprotected

bashio::log.info "Ensuring Docker volume for Rancher data exists..."
if ! docker volume inspect hassio_addon_rancher_data >/dev/null 2>&1; then
    docker volume create hassio_addon_rancher_data
    bashio::log.info "Created Docker volume hassio_addon_rancher_data"
fi

bashio::log.info "Rancher initialization complete."

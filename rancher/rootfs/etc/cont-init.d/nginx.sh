#!/usr/bin/with-contenv bashio
# ==============================================================================
# HAOS Rancher - configure nginx upstream for Rancher
# ==============================================================================
declare http_port

http_port="$(bashio::config 'http_port')"

sed -i "s/__RANCHER_HTTP_PORT__/${http_port}/g" /etc/nginx/http.d/rancher.conf

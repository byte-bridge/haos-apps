#!/usr/bin/with-contenv bashio
# ==============================================================================
# HAOS Rancher - configure nginx upstream for Rancher
# ==============================================================================
declare http_port

http_port="$(bashio::config 'http_port')"

# Alpine nginx default site binds :80; that fails under host_network on HAOS.
rm -f /etc/nginx/http.d/default.conf

sed -i "s/__RANCHER_HTTP_PORT__/${http_port}/g" /etc/nginx/http.d/rancher.conf

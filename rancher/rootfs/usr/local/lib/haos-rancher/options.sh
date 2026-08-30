#!/bin/bash
# shellcheck shell=bash
# Read Home Assistant app options and call the Supervisor API when needed.

OPTIONS_FILE="/data/options.json"
SUPERVISOR="http://supervisor"

haos_log() {
    echo "[$(date -Iseconds)] $*"
}

haos_option() {
    local key="${1}"
    local default="${2:-}"
    if [[ ! -f "${OPTIONS_FILE}" ]]; then
        printf '%s' "${default}"
        return 0
    fi
    jq -r --arg key "${key}" --arg default "${default}" \
        '.[$key] // $default | if type == "boolean" then tostring else . end' \
        "${OPTIONS_FILE}" 2>/dev/null || printf '%s' "${default}"
}

haos_option_true() {
    [[ "$(haos_option "${1}" "false")" == "true" ]]
}

haos_option_has_value() {
    local value
    value="$(haos_option "${1}" "")"
    [[ -n "${value}" ]]
}

haos_require_unprotected() {
    local protected token
    token="${SUPERVISOR_TOKEN:-}"
    if [[ -z "${token}" ]]; then
        haos_log "WARNING: SUPERVISOR_TOKEN not set; skipping protection mode check"
        return 0
    fi
    protected="$(curl -sf -H "Authorization: Bearer ${token}" \
        "${SUPERVISOR}/addons/self/info" | jq -r '.data.protected // true')"
    if [[ "${protected}" == "true" ]]; then
        haos_log "ERROR: Protection mode is enabled. Disable it on the app configuration page."
        exit 1
    fi
}

haos_clear_option() {
    local key="${1}"
    local value="${2}"
    local token options payload
    token="${SUPERVISOR_TOKEN:-}"
    if [[ -z "${token}" ]]; then
        return 1
    fi
    options="$(curl -sf -H "Authorization: Bearer ${token}" \
        "${SUPERVISOR}/addons/self/options" | jq -c '.data // .')"
    if [[ -n "${value}" ]]; then
        if [[ "${value}" == "true" || "${value}" == "false" || "${value}" == "null" ]]; then
            options="$(jq --arg key "${key}" --argjson value "${value}" \
                '.[$key] = $value' <<<"${options}")"
        else
            options="$(jq --arg key "${key}" --arg value "${value}" \
                '.[$key] = $value' <<<"${options}")"
        fi
    else
        options="$(jq --arg key "${key}" 'del(.[$key])' <<<"${options}")"
    fi
    payload="$(jq -n --argjson options "${options}" '{options: $options}')"
    curl -sf -X POST \
        -H "Authorization: Bearer ${token}" \
        -H "Content-Type: application/json" \
        -d "${payload}" \
        "${SUPERVISOR}/addons/self/options" >/dev/null
}

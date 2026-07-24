#!/usr/bin/env bash
set -euo pipefail

log() {
    echo "[flatpak] $*" >&2
}

die() {
    echo "ERROR: $*" >&2
    exit 1
}

sign_ostree_with_gpg() {
    local repo_dir="$1"
    local key_id="$2"
    command flatpak build-update-repo --gpg-sign="$key_id" "$repo_dir"
}

sync_repo_via_rsync() {
    local src="$1"
    local target="$2"
    command rsync -avz --delete "$src/" "$target"
}

deploy_flatpak() {
    local repo_dir="${FLATPAK_REPO_DIR:-/tmp/flatpak-repo}"
    local app_id="${FLATPAK_APP_ID:-${1:-}}"
    local key_id="${FLATPAK_GPG_KEY_ID:-}"
    local suite="${FLATPAK_SUITE:-forky}"
    local remote_target="${FLATPAK_REMOTE_TARGET:-flatpak.furilabs.io:/repo/$suite}"

    if [[ -z "$app_id" ]]; then
        log "FLATPAK_APP_ID not set and no argument provided"
        return 1
    fi

    if [[ ! -d "$repo_dir" ]]; then
        log "Repo directory not found: $repo_dir"
        return 1
    fi

    log "Deploying $app_id"
    log "  repo_dir: $repo_dir"
    log "  key_id: ${key_id:+set}"
    log "  suite: $suite"
    log "  target: $remote_target"

    if [[ -n "$key_id" ]]; then
        log "Signing ostree repo with GPG key: $key_id"
        sign_ostree_with_gpg "$repo_dir" "$key_id"
    else
        log "No GPG key set — skipping signing"
    fi

    log "Syncing repo to $remote_target"
    sync_repo_via_rsync "$repo_dir" "$remote_target"

    log "Deploy complete"
}

deploy_flatpak

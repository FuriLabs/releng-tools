build_flatpak() {
    local manifest="${FLATPAK_MANIFEST:-${1:-}}"
    local arch="${ARCH:-${2:-amd64}}"
    local build_dir="${FLATPAK_BUILD_DIR:-/tmp/flatpak-build}"
    local repo_dir="${FLATPAK_REPO_DIR:-/tmp/flatpak-repo}"
    local suite="${FLATPAK_SUITE:-forky}"

    if [[ -z "$manifest" ]]; then
        log "FLATPAK_MANIFEST not set and no argument provided"
        return 1
    fi

    if [[ ! -f "$manifest" ]]; then
        log "Manifest not found: $manifest"
        return 1
    fi

    local app_id
    app_id=$(grep -m1 '^id:' "$manifest" | awk '{print $2}')
    if [[ -z "$app_id" ]]; then
        log "Could not parse app ID from manifest: $manifest"
        return 1
    fi

    log "Building $app_id for $arch"
    log "  manifest: $manifest"
    log "  build_dir: $build_dir"
    log "  repo_dir: $repo_dir"
    log "  suite: $suite"

    mkdir -p "$repo_dir" "$build_dir"

    invoke_flatpak_builder \
        "$manifest" \
        --arch="$arch" \
        --repo="$repo_dir" \
        --install-deps-from=flathub \
        "$build_dir"
}

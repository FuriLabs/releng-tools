invoke_flatpak_builder() {
    local manifest="$1"
    local build_dir="$2"
    shift 2
    command flatpak-builder --force-clean "$@" "$build_dir" "$manifest"
}

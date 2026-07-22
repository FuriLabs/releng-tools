invoke_flatpak_builder() {
    local manifest="$1"
    shift
    command flatpak-builder --force-clean "$@"
}

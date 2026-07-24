invoke_flatpak_builder() {
    local manifest="$1"
    local build_dir="$2"
    shift 2
    echo "[mock] invoke_flatpak_builder: manifest=$manifest build_dir=$build_dir args=$*" >&2
    mkdir -p /tmp/flatpak-test/build
    return 0
}

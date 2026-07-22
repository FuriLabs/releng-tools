invoke_flatpak_builder() {
    local manifest="$1"
    shift
    echo "[mock] invoke_flatpak_builder: manifest=$manifest args=$*" >&2
    mkdir -p /tmp/flatpak-test/build
    return 0
}

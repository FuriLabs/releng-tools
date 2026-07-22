sign_ostree_with_gpg() {
    local repo_dir="$1"
    local key_id="$2"
    command flatpak build-update-repo --gpg-sign="$key_id" "$repo_dir"
}

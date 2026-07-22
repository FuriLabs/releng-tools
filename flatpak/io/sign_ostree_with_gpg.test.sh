sign_ostree_with_gpg() {
    local repo_dir="$1"
    local key_id="$2"
    echo "[mock] sign_ostree_with_gpg: repo=$repo_dir key=$key_id" >&2
    mkdir -p "$repo_dir"
    return 0
}

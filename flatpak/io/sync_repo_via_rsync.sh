sync_repo_via_rsync() {
    local src="$1"
    local target="$2"
    command rsync -avz --delete "$src/" "$target"
}

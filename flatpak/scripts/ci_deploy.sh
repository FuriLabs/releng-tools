#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLATPAK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$FLATPAK_DIR/common.sh"
source "$FLATPAK_DIR/io/sign_ostree_with_gpg.sh"
source "$FLATPAK_DIR/io/sync_repo_via_rsync.sh"
source "$FLATPAK_DIR/deploy_flatpak.sh"

deploy_flatpak

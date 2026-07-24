#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLATPAK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$FLATPAK_DIR/common.sh"
source "$FLATPAK_DIR/io/sign_ostree_with_gpg.sh"
source "$FLATPAK_DIR/io/sync_repo_via_rsync.sh"
source "$FLATPAK_DIR/deploy_flatpak.sh"

read_or_env FLATPAK_APP_ID "Flatpak application ID"
read_or_env FLATPAK_GPG_KEY_ID "GPG key ID for signing (leave empty to skip)"
read_or_env FLATPAK_SUITE "Suite (default: forky)"
read_or_env FLATPAK_REMOTE_TARGET "Remote rsync target (default: flatpak.furilabs.io:/repo/forky)"

deploy_flatpak

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLATPAK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$FLATPAK_DIR/common.sh"
source "$FLATPAK_DIR/io/invoke_flatpak_builder.sh"
source "$FLATPAK_DIR/build_flatpak.sh"

build_flatpak

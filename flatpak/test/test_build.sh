#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
FLATPAK_DIR="$(cd "$TEST_DIR/.." && pwd)"
EXIT_CODE=0

source "$FLATPAK_DIR/common.sh"
source "$FLATPAK_DIR/io/invoke_flatpak_builder.test.sh"
source "$FLATPAK_DIR/build_flatpak.sh"

cleanup() {
    rm -rf /tmp/flatpak-test
}

test_valid_manifest() {
    cleanup
    echo 'id: org.test.App' > /tmp/flatpak-test-manifest.yml
    local rc=0
    FLATPAK_MANIFEST=/tmp/flatpak-test-manifest.yml \
        build_flatpak || rc=$?
    assert_equals 0 "$rc" "valid manifest succeeds" || EXIT_CODE=$?
}

test_missing_manifest_env() {
    local rc=0
    FLATPAK_MANIFEST="" \
        build_flatpak || rc=$?
    assert_equals 1 "$rc" "missing manifest fails" || EXIT_CODE=$?
}

test_nonexistent_manifest_file() {
    local rc=0
    FLATPAK_MANIFEST=/tmp/flatpak-test/nonexistent.yml \
        build_flatpak || rc=$?
    assert_equals 1 "$rc" "nonexistent manifest fails" || EXIT_CODE=$?
}

test_manifest_without_id() {
    echo 'runtime: org.gnome.Platform' > /tmp/flatpak-test-bad.yml
    local rc=0
    FLATPAK_MANIFEST=/tmp/flatpak-test-bad.yml \
        build_flatpak || rc=$?
    assert_equals 1 "$rc" "manifest without ID fails" || EXIT_CODE=$?
}

main() {
    log "=== Build tests ==="
    test_valid_manifest
    test_missing_manifest_env
    test_nonexistent_manifest_file
    test_manifest_without_id
    cleanup
    exit "$EXIT_CODE"
}

main

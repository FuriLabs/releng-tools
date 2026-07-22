#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
FLATPAK_DIR="$(cd "$TEST_DIR/.." && pwd)"
EXIT_CODE=0

source "$FLATPAK_DIR/common.sh"
source "$FLATPAK_DIR/io/sign_ostree_with_gpg.test.sh"
source "$FLATPAK_DIR/io/sync_repo_via_rsync.test.sh"
source "$FLATPAK_DIR/deploy_flatpak.sh"

cleanup() {
    rm -rf /tmp/flatpak-test-repo
}

test_deploy_with_valid_params() {
    cleanup
    mkdir -p /tmp/flatpak-test-repo
    local rc=0
    FLATPAK_REPO_DIR=/tmp/flatpak-test-repo \
    FLATPAK_APP_ID=org.test.App \
    FLATPAK_GPG_KEY_ID=testkey \
        deploy_flatpak || rc=$?
    assert_equals 0 "$rc" "deploy with valid params succeeds" || EXIT_CODE=$?
}

test_deploy_missing_app_id() {
    local rc=0
    FLATPAK_APP_ID="" \
        deploy_flatpak || rc=$?
    assert_equals 1 "$rc" "deploy without app_id fails" || EXIT_CODE=$?
}

test_deploy_missing_repo_dir() {
    local rc=0
    FLATPAK_REPO_DIR=/nonexistent \
    FLATPAK_APP_ID=org.test.App \
        deploy_flatpak || rc=$?
    assert_equals 1 "$rc" "deploy without repo dir fails" || EXIT_CODE=$?
}

test_deploy_without_skips_signing() {
    cleanup
    mkdir -p /tmp/flatpak-test-repo
    local rc=0
    FLATPAK_REPO_DIR=/tmp/flatpak-test-repo \
    FLATPAK_APP_ID=org.test.App \
    FLATPAK_GPG_KEY_ID="" \
        deploy_flatpak || rc=$?
    assert_equals 0 "$rc" "deploy without signing key succeeds" || EXIT_CODE=$?
}

main() {
    log "=== Deploy tests ==="
    test_deploy_with_valid_params
    test_deploy_missing_app_id
    test_deploy_missing_repo_dir
    test_deploy_without_skips_signing
    cleanup
    exit "$EXIT_CODE"
}

main

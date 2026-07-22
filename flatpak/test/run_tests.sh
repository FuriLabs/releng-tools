#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
EXIT_CODE=0

run_test() {
    local test_script="$1"
    local test_name
    test_name="$(basename "$test_script" .sh)"

    echo ""
    echo "=== Running $test_name ==="

    if bash "$test_script"; then
        echo "  $test_name: ALL PASS"
    else
        echo "  $test_name: FAIL"
        EXIT_CODE=1
    fi
}

for test_script in "$TEST_DIR"/test_*.sh; do
    [[ -f "$test_script" ]] || continue
    [[ "$(basename "$test_script")" != "run_tests.sh" ]] || continue
    run_test "$test_script"
done

echo ""
if [[ "$EXIT_CODE" -eq 0 ]]; then
    echo "All tests passed."
else
    echo "Some tests failed."
fi

exit "$EXIT_CODE"

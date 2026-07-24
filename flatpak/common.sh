read_or_env() {
    local VAR_NAME="$1"
    local PROMPT="$2"

    local EXISTING="${!VAR_NAME:-}"

    if [[ -n "$EXISTING" ]]; then
        printf -v "$VAR_NAME" "%s" "$EXISTING"
        echo "$VAR_NAME=$EXISTING (from environment)" >&2
        return 0
    fi

    local VALUE
    read -r -p "$PROMPT: " VALUE
    if [[ -n "$VALUE" ]]; then
        printf -v "$VAR_NAME" "%s" "$VALUE"
    fi
}

die() {
    echo "ERROR: $*" >&2
    exit 1
}

log() {
    echo "[flatpak] $*" >&2
}

require_vars() {
    local missing=()
    for var in "$@"; do
        if [[ -z "${!var:-}" ]]; then
            missing+=("$var")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        die "Required variables not set: ${missing[*]}"
    fi
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local label="${3:-}"
    if [[ "$expected" != "$actual" ]]; then
        echo "  FAIL${label:+ ($label)}: expected '$expected', got '$actual'" >&2
        return 1
    fi
    echo "  PASS${label:+ ($label)}" >&2
    return 0
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local label="${3:-}"
    if [[ "$haystack" != *"$needle"* ]]; then
        echo "  FAIL${label:+ ($label)}: expected to contain '$needle'" >&2
        return 1
    fi
    echo "  PASS${label:+ ($label)}" >&2
    return 0
}

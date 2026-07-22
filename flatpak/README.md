# Flatpak CI/CD for FuriOS

Build and deploy flatpaks to `flatpak.furilabs.io` from any git repo, on CircleCI or your laptop.

## Architecture

Three layers with testable boundaries:

```
  scripts/ci_build.sh    scripts/local_build.sh
  scripts/ci_deploy.sh   scripts/local_deploy.sh
  ────────────────────   ────────────────────────
        HIGH                       HIGH
  (wires real IO)           (interactive prompts)


       │ calls                      │ calls
       ▼                            ▼

  build_flatpak.sh / deploy_flatpak.sh
  ──────────────────────────────────────
                  MID
        (pure logic, no IO calls)
        expects functions to exist in env


       │ invoke_flatpak_builder     │ sign_ostree_with_gpg
       │                            │ sync_repo_via_rsync
       ▼                            ▼

  io/invoke_flatpak_builder.sh    io/sign_ostree_with_gpg.sh
  io/invoke_flatpak_builder.test.sh  io/sign_ostree_with_gpg.test.sh
                                   io/sync_repo_via_rsync.sh
                                   io/sync_repo_via_rsync.test.sh
  ─────────────────────────────    ─────────────────────────────────
             LOW                             LOW
     (touches filesystem,             (signs, deploys)
      runs flatpak-builder)
```

- **LOW** (`io/*.sh`) — Each file defines one function that talks to the outside world. No logic, no validation.
- **LOW test doubles** (`io/*.test.sh`) — Define the same function, but log calls and return canned success.
- **MID** (`build_flatpak.sh`, `deploy_flatpak.sh`) — Orchestrate. Validate inputs, construct args, call IO functions, check results. Sourceable — the IO functions must already be loaded in the shell environment.
- **HIGH** (`scripts/*.sh`) — Strategies that wire real or mock IO into the MID. Entry points for different contexts (CI, local, test).

Test doubles replace the real IO by sourcing `.test.sh` **instead** of the real `.sh` file. The MID never knows the difference.

## Directory layout

```
flatpak/
├── common.sh                           # shared: read_or_env, die, log, assert_*
├── build_flatpak.sh                    # MID: validates manifest, builds
├── deploy_flatpak.sh                   # MID: validates params, signs, deploys
├── io/
│   ├── invoke_flatpak_builder.sh       # LOW: runs flatpak-builder
│   ├── invoke_flatpak_builder.test.sh  # test double
│   ├── sign_ostree_with_gpg.sh         # LOW: signs ostree with GPG
│   ├── sign_ostree_with_gpg.test.sh    # test double
│   ├── sync_repo_via_rsync.sh          # LOW: rsyncs to remote
│   └── sync_repo_via_rsync.test.sh     # test double
├── scripts/
│   ├── ci_build.sh                     # HIGH: build in CircleCI
│   ├── ci_deploy.sh                    # HIGH: deploy in CircleCI
│   ├── local_build.sh                  # HIGH: build locally (interactive)
│   └── local_deploy.sh                 # HIGH: deploy locally (interactive)
└── test/
    ├── test_build.sh                   # unit tests for build_flatpak
    ├── test_deploy.sh                  # unit tests for deploy_flatpak
    └── run_tests.sh                    # test runner
```

## How to use

### Run tests

```bash
cd releng-tools/flatpak
bash test/run_tests.sh
```

Tests never touch flatpak-builder, GPG, or the network. They run against test doubles in `io/*.test.sh`.

### Build a flatpak locally

```bash
bash scripts/local_build.sh
```

Prompts for manifest path and arch. For deploy:

```bash
bash scripts/local_deploy.sh
```

Prompts for app ID, GPG key, suite, and remote target.

It will prompt for manifest path, arch, GPG key, target, etc.

### Use in CircleCI

A consumer repo adds a `.circleci/config.yml`:

```yaml
version: 2.1
orbs:
  buildd: furilabs-buildd/furilabs-buildd-orb@volatile

workflows:
  build-and-deploy:
    jobs:
      - buildd/flatpak-build:
          manifest: io.github.shinyvision.Circadia.yml
          arch: amd64
          name: flatpak-build-amd64
```

The orb runs `ci_build.sh` / `ci_deploy.sh` inside the `quay.io/furilabs/flatpak-builder:forky` Docker image on a CircleCI machine executor.

CircleCI context `furilabs-buildd` provides:
- `FLATPAK_MANIFEST` — path to manifest in repo
- `GPG_STAGINGPRODUCTION_SIGNING_KEYID` — GPG key for signing
- (deploy SSH key configured in CircleCI project)

## How to modify / extend

### Add a new LOW function (new IO verb)

1. Create `io/<verb>.sh` with one function:

   ```bash
   # io/fetch_sdk.sh
   fetch_sdk() {
       local url="$1" dest="$2"
       command wget -q "$url" -O "$dest"
   }
   ```

2. Create `io/<verb>.test.sh` with a test double:

   ```bash
   # io/fetch_sdk.test.sh
   fetch_sdk() {
       echo "[mock] fetch_sdk: url=$1 dest=$2" >&2
       touch "$2"
       return 0
   }
   ```

3. Use the function in a MID script — it expects `fetch_sdk` to exist in env.

4. Wire it in the HIGH strategies (`scripts/ci_build.sh`, `scripts/ci_deploy.sh`, etc.).

### Modify a MID script (`build_flatpak.sh`, `deploy_flatpak.sh`)

These are plain bash. They:
- Read config from env vars (with defaults)
- Validate inputs
- Call IO functions
- Return exit code

To add new behavior: add new env var reads, add validation, call your IO function.

### Add a new HIGH strategy

Create `scripts/<name>.sh` that:

1. Sources `common.sh`
2. Sources the needed real `io/*.sh` files
3. Sources the MID script(s)
4. Calls the MID functions with appropriate config

```bash
# scripts/my_strategy.sh
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLATPAK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$FLATPAK_DIR/common.sh"
source "$FLATPAK_DIR/io/invoke_flatpak_builder.sh"
source "$FLATPAK_DIR/build_flatpak.sh"

build_flatpak
```

For tests: source `io/*.test.sh` instead.

### Add a new test

Create `test/test_<name>.sh`:

```bash
# test/test_build_sdk.sh
#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
FLATPAK_DIR="$(cd "$TEST_DIR/.." && pwd)"

source "$FLATPAK_DIR/common.sh"
source "$FLATPAK_DIR/io/invoke_flatpak_builder.test.sh"
source "$FLATPAK_DIR/build_flatpak.sh"

# test cases
# ...

main
```

`run_tests.sh` auto-discovers all `test_*.sh` scripts.

## Design rules

| Rule | Why |
|---|---|
| A LOW file defines exactly one function | Easy to test, easy to double |
| A LOW function never contains logic (no `if`, no validation) | Logic belongs in MID |
| A MID file never runs a command directly | All IO goes through injected LOW functions |
| A HIGH file is the only place real IO is sourced | One place to change when wiring changes |
| `.test.sh` files have the same function signature as real | MID can't tell the difference |

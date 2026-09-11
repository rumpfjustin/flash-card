#!/usr/bin/env bash
# Build (if needed) and run Flash Cards from a local Meson build directory.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

build_dir="build"

if [ ! -d "$build_dir" ]; then
    meson setup "$build_dir"
fi

meson compile -C "$build_dir"

exec "$build_dir/src/flash-card" "$@"

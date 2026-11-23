#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/env.sh"
[ -d "$WORK/emsdk" ] || git clone https://github.com/emscripten-core/emsdk.git "$WORK/emsdk"
cd "$WORK/emsdk"
./emsdk install "$EMSDK_VERSION"
./emsdk activate "$EMSDK_VERSION"
. ./emsdk_env.sh
emcc --version | head -n 1 | tee "$SPIKE_ROOT/upstream/emscripten-version.txt"

#!/usr/bin/env bash
# Build with -k 0 so every independent error is collected, not just the first.
. "$(dirname "$0")/env.sh"
if [ ! -f "$WORK/build/build.ninja" ]; then
  echo "configure did not produce build.ninja; skipping build (see logs/configure.log)"
  printf 'build\tSKIPPED\t-\n' >>"$LOGS/status.tsv"; exit 0
fi
build_qemu() { cd "$WORK/build" && emmake ninja -k 0 -j"$JOBS"; }
run_stage build build_qemu || true
exit 0

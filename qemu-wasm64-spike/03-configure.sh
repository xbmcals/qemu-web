#!/usr/bin/env bash
# Try to configure upstream QEMU for wasm64 + the TCG interpreter (TCI).
# Stock QEMU has no wasm host in configure, so an early failure here is EXPECTED.
# The log tells us exactly which patch 0001 needs to add.
. "$(dirname "$0")/env.sh"
configure_qemu() {
  rm -rf "$WORK/build"; mkdir -p "$WORK/build"; cd "$WORK/build"
  export CFLAGS="-sMEMORY64=1 -pthread -O2 -I$PREFIX/include"
  export LDFLAGS="-sMEMORY64=1 -pthread -L$PREFIX/lib"
  emconfigure "$WORK/qemu/configure" \
    --cc=emcc --cxx=em++ --host-cc=gcc \
    --cpu=wasm64 \
    --target-list=x86_64-softmmu \
    --without-default-features \
    --enable-tcg-interpreter \
    --disable-kvm --disable-docs --disable-tools --disable-guest-agent \
    --disable-coroutine-pool --disable-werror --disable-containers \
    --extra-cflags="$CFLAGS" --extra-ldflags="$LDFLAGS"
}
[ -d "$WORK/qemu" ] || { echo "run 00-fetch.sh first"; exit 1; }
run_stage configure configure_qemu || true
exit 0

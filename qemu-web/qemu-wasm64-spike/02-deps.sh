#!/usr/bin/env bash
# Build QEMU's library dependencies as wasm64. Each stage may fail; failures are the data.
. "$(dirname "$0")/env.sh"
SRC="$WORK/src"; mkdir -p "$SRC"; cd "$SRC"
FLAGS="-sMEMORY64=1 -pthread -O2"
fetch() { [ -f "$(basename "$1")" ] || curl -fsSLO "$1"; }

build_zlib() {
  fetch "https://zlib.net/zlib-$ZLIB_VERSION.tar.gz"
  rm -rf "zlib-$ZLIB_VERSION"; tar xf "zlib-$ZLIB_VERSION.tar.gz"
  cd "zlib-$ZLIB_VERSION"
  CFLAGS="$FLAGS" emconfigure ./configure --static --prefix="$PREFIX"
  emmake make -j"$JOBS" install
}
build_libffi() {
  fetch "https://github.com/libffi/libffi/releases/download/v$LIBFFI_VERSION/libffi-$LIBFFI_VERSION.tar.gz"
  rm -rf "libffi-$LIBFFI_VERSION"; tar xf "libffi-$LIBFFI_VERSION.tar.gz"
  cd "libffi-$LIBFFI_VERSION"
  CFLAGS="$FLAGS" emconfigure ./configure --host=wasm64-unknown-emscripten \
    --disable-shared --enable-static --disable-docs --prefix="$PREFIX"
  emmake make -j"$JOBS" install
}
build_pixman() {
  fetch "https://cairographics.org/releases/pixman-$PIXMAN_VERSION.tar.gz"
  rm -rf "pixman-$PIXMAN_VERSION"; tar xf "pixman-$PIXMAN_VERSION.tar.gz"
  cd "pixman-$PIXMAN_VERSION"
  meson setup _b --cross-file "$SPIKE_ROOT/wasm64-cross.ini" --prefix="$PREFIX" \
    --default-library=static -Dtests=disabled -Ddemos=disabled -Dopenmp=disabled
  ninja -C _b -j"$JOBS" install
}
build_glib() {
  local major="${GLIB_VERSION%.*}"
  fetch "https://download.gnome.org/sources/glib/$major/glib-$GLIB_VERSION.tar.xz"
  rm -rf "glib-$GLIB_VERSION"; tar xf "glib-$GLIB_VERSION.tar.xz"
  cd "glib-$GLIB_VERSION"
  meson setup _b --cross-file "$SPIKE_ROOT/wasm64-cross.ini" --prefix="$PREFIX" \
    --default-library=static --wrap-mode=default \
    -Dtests=false -Dnls=disabled -Dlibmount=disabled -Dselinux=disabled -Dxattr=false
  ninja -C _b -j"$JOBS" install
}

run_stage deps-zlib   bash -c "$(declare -f fetch build_zlib);   . '$SPIKE_ROOT/env.sh'; SRC='$SRC'; FLAGS='$FLAGS'; cd '$SRC'; build_zlib"   || true
run_stage deps-libffi bash -c "$(declare -f fetch build_libffi); . '$SPIKE_ROOT/env.sh'; SRC='$SRC'; FLAGS='$FLAGS'; cd '$SRC'; build_libffi" || true
run_stage deps-pixman bash -c "$(declare -f fetch build_pixman); . '$SPIKE_ROOT/env.sh'; SRC='$SRC'; FLAGS='$FLAGS'; cd '$SRC'; build_pixman" || true
run_stage deps-glib   bash -c "$(declare -f fetch build_glib);   . '$SPIKE_ROOT/env.sh'; SRC='$SRC'; FLAGS='$FLAGS'; cd '$SRC'; build_glib"   || true
exit 0

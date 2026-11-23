# Shared settings. Override any of these from the environment.
export SPIKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export QEMU_REPO="${QEMU_REPO:-https://gitlab.com/qemu-project/qemu.git}"
export QEMU_TAG="${QEMU_TAG:-v11.1.3}"          # pinned; try v11.2.0-rc1 only after it exists
export EMSDK_VERSION="${EMSDK_VERSION:-latest}" # pin an exact version once one works
export ZLIB_VERSION="${ZLIB_VERSION:-1.3.1}"
export LIBFFI_VERSION="${LIBFFI_VERSION:-3.4.6}"
export PIXMAN_VERSION="${PIXMAN_VERSION:-0.43.4}"
export GLIB_VERSION="${GLIB_VERSION:-2.80.5}"
export WORK="${WORK:-$SPIKE_ROOT/work}"
export PREFIX="$WORK/prefix"
export LOGS="$WORK/logs"
export JOBS="${JOBS:-$(nproc 2>/dev/null || echo 4)}"
mkdir -p "$WORK" "$PREFIX" "$LOGS" "$SPIKE_ROOT/upstream"
[ -f "$WORK/emsdk/emsdk_env.sh" ] && . "$WORK/emsdk/emsdk_env.sh" >/dev/null 2>&1
export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"
export PKG_CONFIG_PATH=""

# run_stage NAME CMD...: log output, record status, never abort the whole spike.
run_stage() {
  local name="$1"; shift
  local log="$LOGS/$name.log"
  echo "== $name"
  if "$@" >"$log" 2>&1; then
    printf '%s\tok\t%s\n' "$name" "$log" >>"$LOGS/status.tsv"
  else
    printf '%s\tFAIL\t%s\n' "$name" "$log" >>"$LOGS/status.tsv"
    echo "   FAILED (log: $log)"
    return 1
  fi
}

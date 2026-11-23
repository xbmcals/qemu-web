#!/usr/bin/env bash
# Summarize all logs into REPORT.md. Send that file back for the next step.
. "$(dirname "$0")/env.sh"
OUT="$SPIKE_ROOT/REPORT.md"
all="$LOGS"/*.log
{
  echo "# wasm64 feasibility spike report"
  echo; echo "Generated: $(date -u +%FT%TZ)"
  echo "- QEMU: $(cat "$SPIKE_ROOT/upstream/qemu-version.txt" 2>/dev/null) @ $(cat "$SPIKE_ROOT/upstream/qemu-commit.txt" 2>/dev/null)"
  echo "- Emscripten: $(cat "$SPIKE_ROOT/upstream/emscripten-version.txt" 2>/dev/null)"
  echo; echo "## Stage status"; echo '```'; cat "$LOGS/status.tsv" 2>/dev/null; echo '```'
  echo; echo "## First errors per stage (max 15 each)"
  for f in $all; do
    echo; echo "### $(basename "$f")"; echo '```'
    grep -Ein 'error|fatal|undefined symbol|unsupported|not found|cannot|failed' "$f" | awk '!s[$0]++' | head -n 15
    echo '```'
  done
  echo; echo "## Blocker indicators (match counts across all logs)"
  echo '| Indicator | Matches |'; echo '|---|---|'
  for pat in 'Unsupported CPU|unsupported host|cpu.*wasm64' 'ucontext|makecontext|swapcontext|coroutine' \
             'sigaltstack|signal' 'mmap|MAP_|mprotect|madvise' 'pthread|futex|atomic' \
             'TCI|tcg/.*host|tcg-target' 'libffi|ffi_' 'glib|pixman|zlib' '32-bit|wasm32|sizeof.*4'; do
    n=$(cat $all 2>/dev/null | grep -Eic "$pat")
    echo "| \`$pat\` | $n |"
  done
  echo; echo "## Files with most compiler errors"; echo '```'
  cat $all 2>/dev/null | grep -E '^[^ ]+\.[ch]:[0-9]+:[0-9]+: error' | cut -d: -f1 | sort | uniq -c | sort -rn | head -n 20
  echo '```'
} > "$OUT"
echo "Wrote $OUT"

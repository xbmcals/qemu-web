#!/usr/bin/env bash
# Pin an exact upstream commit and clone it. Fails loudly if the tag does not exist.
set -euo pipefail
. "$(dirname "$0")/env.sh"

peeled=$(git ls-remote "$QEMU_REPO" "refs/tags/${QEMU_TAG}^{}" | cut -f1)
direct=$(git ls-remote "$QEMU_REPO" "refs/tags/${QEMU_TAG}" | cut -f1)
commit="${peeled:-$direct}"
if [ -z "$commit" ]; then
  echo "Tag $QEMU_TAG not found in $QEMU_REPO. Recent tags:" >&2
  git ls-remote --tags "$QEMU_REPO" "${QEMU_TAG%%.*}.*" | sed 's#.*refs/tags/##' | grep -v '\^{}' | tail -n 15 >&2
  exit 1
fi
if [ ! -d "$WORK/qemu/.git" ]; then
  git clone --depth 1 --branch "$QEMU_TAG" "$QEMU_REPO" "$WORK/qemu"
fi
head=$(git -C "$WORK/qemu" rev-parse HEAD)
if [ "$head" != "$commit" ]; then
  echo "Checkout $head does not match tag commit $commit" >&2; exit 1
fi
echo "$QEMU_TAG" > "$SPIKE_ROOT/upstream/qemu-version.txt"
echo "$commit"   > "$SPIKE_ROOT/upstream/qemu-commit.txt"
echo "Pinned $QEMU_TAG at $commit"

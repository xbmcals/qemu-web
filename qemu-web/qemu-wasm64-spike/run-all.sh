#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")"
rm -f work/logs/status.tsv
bash 00-fetch.sh || { echo "fetch failed; fix tag/network first"; exit 1; }
bash 01-emsdk.sh || { echo "emsdk failed"; exit 1; }
bash 02-deps.sh
bash 03-configure.sh
bash 04-build.sh
bash 05-report.sh

#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

need curl
need unzip

version="v0.14.10"
arch="$(uname -m)"
case "$arch" in
  x86_64|amd64) asset_pat="x86_64-linux.zip" ;;
  *)
    echo "Unsupported arch for procs: ${arch}. Falling back to x86_64 as requested in the link, but it may fail." >&2
    asset_pat="x86_64-linux.zip"
    ;;
esac

url="https://github.com/dalance/procs/releases/download/${version}/procs-${version}-${asset_pat}"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

zipfile="${tmpdir}/procs.zip"
curl -fsSL -o "${zipfile}" "${url}"

unzip -q "${zipfile}" -d "${tmpdir}"

# procs zip usually contains the procs binary at root
install_binary "${tmpdir}/procs" "procs"

echo "procs installation complete."
echo "Tip: reload with: source ~/.bashrc"

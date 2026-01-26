#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

need curl
need tar

version="0.9.1"
arch="$(uname -m)"
case "$arch" in
  x86_64|amd64) asset_pat="0.9.1_linux_x86_64.tar.gz" ;;
  *)
    echo "Unsupported arch for duf: ${arch}. Falling back to x86_64 as requested in the link, but it may fail." >&2
    asset_pat="0.9.1_linux_x86_64.tar.gz"
    ;;
esac

url="https://github.com/muesli/duf/releases/download/v${version}/duf_${asset_pat}"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

tarball="${tmpdir}/duf.tar.gz"
curl -fsSL -o "${tarball}" "${url}"

tar -xzf "${tarball}" -C "${tmpdir}"

# duf tarball contains the binary at root
install_binary "${tmpdir}/duf" "duf"

echo "duf installation complete."
echo "Tip: reload with: source ~/.bashrc"

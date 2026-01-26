#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

need curl
need tar

version="0.12.3"
arch="$(uname -m)"
case "$arch" in
  x86_64|amd64) asset_pat="x86_64-unknown-linux-gnu.tar.gz" ;;
  *)
    echo "Unsupported arch for btm: ${arch}. Falling back to x86_64 as requested in the link, but it may fail." >&2
    asset_pat="x86_64-unknown-linux-gnu.tar.gz"
    ;;
esac

url="https://github.com/ClementTsang/bottom/releases/download/${version}/bottom_${asset_pat}"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

tarball="${tmpdir}/btm.tar.gz"
curl -fsSL -o "${tarball}" "${url}"

tar -xzf "${tarball}" -C "${tmpdir}"

# bottom tarball usually has btm at root
install_binary "${tmpdir}/btm" "btm"

# Handle optional files if they exist (sometimes in subdirs)
# completions or man pages are not always in the binary tarball for bottom
# but let's check common locations

echo "bottom installation complete."
echo "Tip: reload with: source ~/.bashrc"

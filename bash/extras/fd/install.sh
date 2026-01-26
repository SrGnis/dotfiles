#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

need curl
need tar

version="v10.3.0"
arch="$(uname -m)"
case "$arch" in
  x86_64|amd64) asset_pat="x86_64-unknown-linux-gnu.tar.gz" ;;
  aarch64|arm64) asset_pat="aarch64-unknown-linux-gnu.tar.gz" ;;
  armv7l|armv7*) asset_pat="arm-unknown-linux-gnueabihf.tar.gz" ;;
  *)
    echo "Unsupported arch for fd: ${arch}. Falling back to x86_64 as requested in the link, but it may fail." >&2
    asset_pat="x86_64-unknown-linux-gnu.tar.gz"
    ;;
esac

url="https://github.com/sharkdp/fd/releases/download/${version}/fd-${version}-${asset_pat}"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

tarball="${tmpdir}/fd.tar.gz"
curl -fsSL -o "${tarball}" "${url}"

tar -xzf "${tarball}" -C "${tmpdir}"

# The tarball contains a single top-level directory like fd-v10.3.0-x86_64-...
pkgdir="$(find "${tmpdir}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
[[ -n "${pkgdir}" ]] || { echo "Unexpected archive layout" >&2; exit 1; }

install_binary "${pkgdir}/fd" "fd"
install_man_page "${pkgdir}/fd.1" "fd.1"
install_completion "${pkgdir}/autocomplete/fd.bash" "fd.bash"
install_alias "${SCRIPT_DIR}/alias" "fd"

echo "fd installation complete."
echo "Tip: reload with: source ~/.bashrc"

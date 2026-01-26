#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

need curl
need tar

version="15.1.0"
arch="$(uname -m)"
case "$arch" in
  x86_64|amd64) asset_pat="x86_64-unknown-linux-musl.tar.gz" ;;
  aarch64|arm64) asset_pat="aarch64-unknown-linux-gnu.tar.gz" ;;
  armv7l|armv7*) asset_pat="arm-unknown-linux-gnueabihf.tar.gz" ;;
  *)
    echo "Unsupported arch for rg: ${arch}. Falling back to x86_64 as requested in the link, but it may fail." >&2
    asset_pat="x86_64-unknown-linux-musl.tar.gz"
    ;;
esac

url="https://github.com/BurntSushi/ripgrep/releases/download/${version}/ripgrep-${version}-${asset_pat}"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

tarball="${tmpdir}/rg.tar.gz"
curl -fsSL -o "${tarball}" "${url}"

tar -xzf "${tarball}" -C "${tmpdir}"

# The tarball contains a directory like ripgrep-15.1.0-x86_64-...
pkgdir="$(find "${tmpdir}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
[[ -n "${pkgdir}" ]] || { echo "Unexpected archive layout" >&2; exit 1; }

install_binary "${pkgdir}/rg" "rg"
install_man_page "${pkgdir}/doc/rg.1" "rg.1"
install_completion "${pkgdir}/complete/rg.bash" "rg.bash"
install_alias "${SCRIPT_DIR}/alias" "rg"

echo "ripgrep installation complete."
echo "Tip: reload with: source ~/.bashrc"

#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

need curl
need tar

version="v1.2.4"
arch="$(uname -m)"
case "$arch" in
  x86_64|amd64) asset_pat="x86_64-unknown-linux-gnu.tar.gz" ;;
  *)
    echo "Unsupported arch for dust: ${arch}. Falling back to x86_64 as requested in the link, but it may fail." >&2
    asset_pat="x86_64-unknown-linux-gnu.tar.gz"
    ;;
esac

url="https://github.com/bootandy/dust/releases/download/${version}/dust-${version}-${asset_pat}"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

tarball="${tmpdir}/dust.tar.gz"
curl -fsSL -o "${tarball}" "${url}"

tar -xzf "${tarball}" -C "${tmpdir}"

# The tarball contains a directory like dust-v1.2.4-x86_64-...
pkgdir="$(find "${tmpdir}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
[[ -n "${pkgdir}" ]] || { echo "Unexpected archive layout" >&2; exit 1; }

install_binary "${pkgdir}/dust" "dust"
install_man_page "${pkgdir}/dust.1" "dust.1"
install_completion "${pkgdir}/completions/dust.bash" "dust.bash"

echo "dust installation complete."
echo "Tip: reload with: source ~/.bashrc"

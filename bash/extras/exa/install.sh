#!/usr/bin/env bash

# exa is often unmaintained, but the user specifically requested it.
# Note: eza is the community fork if you want a more modern version.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

need curl
need unzip

version="v0.10.1"
arch="$(uname -m)"
case "$arch" in
  x86_64|amd64) asset_arch='linux-x86_64' ;;
  *)
    echo "Unsupported arch for exa: ${arch}. Falling back to x86_64 as requested in the link, but it may fail." >&2
    asset_arch='linux-x86_64'
    ;;
esac

url="https://github.com/ogham/exa/releases/download/${version}/exa-${asset_arch}-${version}.zip"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

zipfile="${tmpdir}/exa.zip"
curl -fsSL -o "${zipfile}" "${url}"

unzip -q "${zipfile}" -d "${tmpdir}"

install_binary "${tmpdir}/bin/exa" "exa"
install_man_page "${tmpdir}/man/exa.1" "exa.1"
install_man_page "${tmpdir}/man/exa_colors.5" "exa_colors.5"
install_completion "${tmpdir}/completions/exa.bash" "exa.bash"
install_alias "${SCRIPT_DIR}/alias" "exa"

echo "exa installation complete."
echo "Tip: reload with: source ~/.bashrc"

#!/usr/bin/env bash
set -euo pipefail

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 1; }; }

need curl
need tar

BIN_DIR="${HOME}/.bin"
MAN_DIR="${HOME}/.local/share/man/man1"
BASH_CFG_DIR="${HOME}/.config/bash"
COMPL_DIR="${BASH_CFG_DIR}/completions"
BASH_ALIAS_DIR="${HOME}/.config/bash/alias"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BAT_EXTRAS_DIR="${HOME}/.config/bash/extras/bat"

mkdir -p "${BIN_DIR}" "${MAN_DIR}" "${COMPL_DIR}" "${BASH_CFG_DIR}" "${BASH_ALIAS_DIR}" "${BAT_EXTRAS_DIR}"

arch="$(uname -m)"
case "$arch" in
  x86_64|amd64) asset_pat='x86_64-unknown-linux-gnu.tar.gz' ;;
  aarch64|arm64) asset_pat='aarch64-unknown-linux-gnu.tar.gz' ;;
  armv7l|armv7*) asset_pat='arm-unknown-linux-gnueabihf.tar.gz' ;;
  *)
    echo "Unsupported arch: ${arch} (add a mapping in extras/bat/install.sh)" >&2
    exit 1
    ;;
esac

api="https://api.github.com/repos/sharkdp/bat/releases/latest"

# Extract the browser_download_url for our asset
url="$(
  curl -fsSL "$api" \
    | grep -oE '"browser_download_url"\s*:\s*"[^"]+' \
    | sed -E 's/"browser_download_url"\s*:\s*"//' \
    | grep "${asset_pat}" \
    | head -n 1
)"

if [[ -z "${url}" ]]; then
  echo "Could not find a bat release asset matching: ${asset_pat}" >&2
  echo "API: ${api}" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

tarball="${tmpdir}/bat.tar.gz"
curl -fsSL -o "${tarball}" "${url}"

tar -xzf "${tarball}" -C "${tmpdir}"

# The tarball contains a single top-level directory like bat-v0.xx.x-...
pkgdir="$(find "${tmpdir}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
[[ -n "${pkgdir}" ]] || { echo "Unexpected archive layout" >&2; exit 1; }

# Install binary
install -m 0755 "${pkgdir}/bat" "${BIN_DIR}/bat"

# Install man page if present
if [[ -f "${pkgdir}/bat.1" ]]; then
  install -m 0644 "${pkgdir}/bat.1" "${MAN_DIR}/bat.1"
fi

# Install bash completion if present
if [[ -f "${pkgdir}/autocomplete/bat.bash" ]]; then
  install -m 0644 "${pkgdir}/autocomplete/bat.bash" "${COMPL_DIR}/bat.bash"
fi

# Install alias file
if [[ -f "${SCRIPT_DIR}/alias" ]]; then
  install -m 0644 "${SCRIPT_DIR}/alias" "${BAT_EXTRAS_DIR}/alias"
fi

echo "bat installed:"
echo "  - ${BIN_DIR}/bat"
echo "  - man: ${MAN_DIR}/bat.1 (if present)"
echo "  - bash completion: ${COMPL_DIR}/bat.bash (if present)"
echo "  - alias: ${BAT_EXTRAS_DIR}/alias (if present)"
echo "Tip: reload with: source ~/.bashrc"

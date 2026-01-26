SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

need curl
need tar

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

install_binary "${pkgdir}/bat" "bat"
install_man_page "${pkgdir}/bat.1" "bat.1"
install_completion "${pkgdir}/autocomplete/bat.bash" "bat.bash"
install_alias "${SCRIPT_DIR}/alias" "bat"

echo "bat installation complete."
echo "Tip: reload with: source ~/.bashrc"


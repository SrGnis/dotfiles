#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
EXTRAS_DIR="${SCRIPT_DIR}/extras"

die() { echo "Error: $*" >&2; exit 1; }

[[ -d "${EXTRAS_DIR}" ]] || die "Missing extras dir: ${EXTRAS_DIR}"

# Discover extras = subdirs containing install.sh
mapfile -t EXTRA_DIRS < <(find "${EXTRAS_DIR}" -mindepth 1 -maxdepth 1 -type d -print | sort)

choices=()
for d in "${EXTRA_DIRS[@]}"; do
  [[ -x "${d}/install.sh" || -f "${d}/install.sh" ]] || continue
  name="$(basename "$d")"
  desc="Install ${name}"
  [[ -f "${d}/README.md" ]] && desc="$(head -n 1 "${d}/README.md")"
  choices+=("${name}" "${desc}" "OFF")
done

if [[ ${#choices[@]} -eq 0 ]]; then
  die "No extras found (expected extras/<name>/install.sh)"
fi

selected=()

if command -v whiptail >/dev/null 2>&1; then
  # Default dimensions
  h=15 w=60 lh=8

  # Adjust dimensions if terminal is large enough
  if [[ -t 1 ]]; then
    h=$(tput lines 2>/dev/null || echo 15)
    w=$(tput cols 2>/dev/null || echo 60)
    (( h -= 4 ))  # Leave some space for title and buttons
    (( w -= 4 ))  # Leave some margin
    lh=$(( h - 6 ))  # List height should be less than dialog height
  fi

  # Ensure minimum sizes
  [[ $h -lt 10 ]] && h=10
  [[ $w -lt 40 ]] && w=40
  [[ $lh -lt 5 ]] && lh=5

  # Use whiptail to show the checklist
  sel="$(whiptail --title "Extras Installer" \
    --checklist "Select extras to install:" $h $w $lh \
    "${choices[@]}" 3>&1 1>&2 2>&3)" || exit 0

  # Parse the selection
  eval "selected=($sel)"
else
  echo "whiptail not found; falling back to simple prompt."
  echo "Available extras:"
  for d in "${EXTRA_DIRS[@]}"; do
    [[ -f "${d}/install.sh" ]] || continue
    echo "  - $(basename "$d")"
  done
  read -r -p "Type extras to install (space-separated): " -a selected
fi

if [[ ${#selected[@]} -eq 0 ]]; then
  echo "Nothing selected."
  exit 0
fi

export MYCONFIGS_ROOT="${SCRIPT_DIR}"

for name in "${selected[@]}"; do
  inst="${EXTRAS_DIR}/${name}/install.sh"
  [[ -f "$inst" ]] || { echo "Skipping unknown extra: $name" >&2; continue; }
  echo "==> Installing extra: ${name}"
  bash "$inst"
done

echo
echo "Done. Reload your shell or run:"
echo "  source ~/.bashrc"

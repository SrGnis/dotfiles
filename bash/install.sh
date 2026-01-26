#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

REPO_BASHRC="${SCRIPT_DIR}/bashrc"
REPO_INPUTRC="${SCRIPT_DIR}/inputrc"
REPO_CONFIG_DIR="${SCRIPT_DIR}/config"

TARGET_BASHRC="${HOME}/.bashrc"
TARGET_INPUTRC="${HOME}/.inputrc"
TARGET_CONFIG_DIR="${HOME}/.config/bash"

BASH_BEGIN="# >>> bash-config managed block >>>"
BASH_END="# <<< bash-config managed block <<<"

INPUT_BEGIN="# >>> inputrc managed block >>>"
INPUT_END="# <<< inputrc managed block <<<"

die() { echo "Error: $*" >&2; exit 1; }

[[ -f "${REPO_BASHRC}" ]] || die "Missing ${REPO_BASHRC}"
[[ -f "${REPO_INPUTRC}" ]] || die "Missing ${REPO_INPUTRC}"
[[ -d "${REPO_CONFIG_DIR}" ]] || die "Missing ${REPO_CONFIG_DIR}"

mkdir -p "${TARGET_CONFIG_DIR}"

# ---- Copy bash config tree ----
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete --exclude='extras/' "${REPO_CONFIG_DIR}/" "${TARGET_CONFIG_DIR}/"
else
  cp -a "${REPO_CONFIG_DIR}/." "${TARGET_CONFIG_DIR}/"
fi

update_managed_block() {
  local target="$1"
  local begin="$2"
  local end="$3"
  local source_file="$4"

  touch "${target}"

  local tmp
  tmp="$(mktemp)"
  trap 'rm -f "${tmp}"' RETURN

  if grep -Fq "${begin}" "${target}" && grep -Fq "${end}" "${target}"; then
    # Copy everything except the old block, and insert the new block contents verbatim.
    awk -v begin="$begin" -v end="$end" -v src="$source_file" '
      function emit_block() {
        print begin
        # Insert src file verbatim
        while ((getline line < src) > 0) print line
        close(src)
        print end
      }
      BEGIN { inblock=0; done=0 }
      $0 == begin { emit_block(); inblock=1; done=1; next }
      $0 == end   { inblock=0; next }
      inblock==0  { print }
      END {
        if (!done) emit_block()
      }
    ' "${target}" > "${tmp}"
  else
    # Append new block to end
    cat "${target}" > "${tmp}"
    printf "\n%s\n" "${begin}" >> "${tmp}"
    cat "${source_file}" >> "${tmp}"
    printf "\n%s\n" "${end}" >> "${tmp}"
  fi

  chmod --reference="${target}" "${tmp}" 2>/dev/null || true
  mv "${tmp}" "${target}"
}

# ---- Install bashrc block ----
update_managed_block \
  "${TARGET_BASHRC}" \
  "${BASH_BEGIN}" \
  "${BASH_END}" \
  "${REPO_BASHRC}"

# ---- Install inputrc block ----
update_managed_block \
  "${TARGET_INPUTRC}" \
  "${INPUT_BEGIN}" \
  "${INPUT_END}" \
  "${REPO_INPUTRC}"

echo "Installed:"
echo "  - ~/.config/bash updated"
echo "  - ~/.bashrc managed block updated"
echo "  - ~/.inputrc managed block updated"
echo
echo "Reload:"
echo "  source ~/.bashrc"

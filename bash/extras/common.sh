#!/usr/bin/env bash

# Common configuration and functions for installing extras

BIN_DIR="${HOME}/.bin"
MAN_DIR="${HOME}/.local/share/man/man1"
BASH_CFG_DIR="${HOME}/.config/bash"
COMPL_DIR="${BASH_CFG_DIR}/completions"
BASH_ALIAS_DIR="${BASH_CFG_DIR}/alias"
EXTRAS_BASE_DIR="${BASH_CFG_DIR}/extras"

mkdir -p "${BIN_DIR}" "${MAN_DIR}" "${COMPL_DIR}" "${BASH_CFG_DIR}" "${BASH_ALIAS_DIR}"

need() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 1; }
}

# Usage: install_binary <src_path> <name>
install_binary() {
  local src="$1"
  local name="$2"
  echo "Installing binary: ${name}"
  install -m 0755 "${src}" "${BIN_DIR}/${name}"
}

# Usage: install_man_page <src_path> <name>
install_man_page() {
  local src="$1"
  local name="$2"
  if [[ -f "${src}" ]]; then
    echo "Installing man page: ${name}"
    install -m 0644 "${src}" "${MAN_DIR}/${name}"
  fi
}

# Usage: install_completion <src_path> <name>
install_completion() {
  local src="$1"
  local name="$2"
  if [[ -f "${src}" ]]; then
    echo "Installing completion: ${name}"
    install -m 0644 "${src}" "${COMPL_DIR}/${name}"
  fi
}

# Usage: install_alias <src_path> <pkg_name>
install_alias() {
  local src="$1"
  local pkg_name="$2"
  local pkg_extras_dir="${EXTRAS_BASE_DIR}/${pkg_name}"
  mkdir -p "${pkg_extras_dir}"
  if [[ -f "${src}" ]]; then
    echo "Installing alias for ${pkg_name}"
    install -m 0644 "${src}" "${pkg_extras_dir}/alias"
  fi
}

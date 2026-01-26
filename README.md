# dotfiles

A clean, modular dotfiles management system focusing on Bash and CLI tools.

## Features

- **Modular Configuration**: All configurations are synced to `~/.config/bash/` and automatically sourced.
- **Better Mode Toggle**: A unified way to replace standard commands with modern alternatives (`cat` -> `bat`, `ls` -> `lsd`, etc.) via a toggle or keybinding.
- **Interactive Extras**: Easily install optional tools and configurations via an interactive menu.

## Directory Structure

```text
.
└── bash/
    ├── bashrc             # Main config sourced by ~/.bashrc
    ├── inputrc            # Readline settings sourced by ~/.inputrc
    ├── install.sh         # Core installation script
    ├── extras.sh          # Interactive installer for optional extras
    ├── config/            # Modular config files (synced to ~/.config/bash)
    │   ├── better         # 'Better Mode' toggle logic and keybindings
    │   ├── ps1            # Prompt customization
    │   ├── history        # History settings
    │   └── alias/         # Directory for command aliases
    └── extras/            # Optional components with their own installers
        └── bat/           # Example: bat configuration and installer
```

## Installation

### 1. Prerequisites

Ensure you have the following installed:
- `bash`
- `rsync` (recommended for faster syncing)
- `whiptail` (for the interactive extras menu)

### 2. Run the Core Installer

This will set up the base Bash environment:

```bash
cd bash
./install.sh
```

### 3. Install Extras (Optional)

To install additional tools and their specific configurations:

```bash
cd bash
./extras.sh
```

## Better Mode

"Better Mode" is a feature that replaces standard Unix commands with modern, feature-rich alternatives if they are installed on your system.

### How to use
- **Toggle Command**: Run `better` in your terminal to turn the mode on or off.
- **Keybinding**: Press `Ctrl+B` to toggle quickly.
- **Indicator**: When Better Mode is active, you'll see a purple `[B]` in your prompt.

### Included Replacements (if installed)
- `cat` ➜ `bat`
- `ls` ➜ `lsd` or `exa`
- `grep` ➜ `rg`
- `find` ➜ `fd`

## Customization

To add your own configurations:
1. Create a new file in `bash/config/` (e.g., `bash/config/my_custom_aliases`).
2. Run `./install.sh` to sync it to `~/.config/bash/`.
3. Source your bashrc: `source ~/.bashrc`.

## License

MIT

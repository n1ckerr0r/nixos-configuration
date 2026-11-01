# NixOS laptop configuration

Reproducible NixOS configuration for the `laptop` host and user `n1ckerr0r`.
The flake builds the operating system, desktop, development environment,
services and the embedded Home Manager profile as one configuration.

## Quick start

The checkout path is intentionally fixed. Clone the repository together with
all nested repositories:

```sh
git clone --recurse-submodules \
  git@github.com:n1ckerr0r/nixos-configuration.git \
  /home/n1ckerr0r/nixos-config
cd /home/n1ckerr0r/nixos-config
```

Evaluate and build before switching the running system:

```sh
nix flake check path:.
nix build 'path:.#nixosConfigurations.laptop.config.system.build.toplevel'
sudo nixos-rebuild switch --flake 'path:.#laptop'
```

Format tracked Nix files with:

```sh
nix fmt
```

## Architecture

`flake.nix` pins external inputs and exports `nixosConfigurations.laptop`.
`hosts/laptop/default.nix` is the composition root. It imports hardware and
network settings, reusable system modules and the Home Manager profile.

```text
flake.nix
├── hosts/laptop/                 host hardware, network and module imports
├── modules/
│   ├── apps/                     desktop/CLI apps and external integrations
│   ├── desktop/                  Niri, Noctalia, GTK, portals and SDDM
│   ├── dev/                      editors, tools and language toolchains
│   ├── input/                    keyboard, keyd and tablet
│   ├── services/                 audio, databases, Docker, monitoring, etc.
│   ├── boot.nix
│   ├── core.nix
│   └── users/
└── home/n1ckerr0r/
    ├── profile.nix              Home Manager packages and MIME defaults
    ├── desktop/                 user-session modules and helper programs
    ├── dotfiles.nix             map from repository files to $HOME
    └── dotfiles/                nested dotfiles repository
```

System packages and services stay in Nix modules. Editable application settings
live in the dotfiles repository and are exposed with Home Manager
`mkOutOfStoreSymlink`, so editing the live config edits the repository file.

The `path:.` form is intentional. A normal Git-flake source omits submodule
contents, while this configuration reads a few initialized dotfile assets during
evaluation. The path-flake includes the complete checked-out tree. Initialize
all submodules before evaluating or rebuilding.

## Four repositories

The tree contains exactly four Git repositories:

| Repository | Local path | Parent |
| --- | --- | --- |
| `nixos-configuration` | repository root | — |
| `dotfiles` | `home/n1ckerr0r/dotfiles` | `nixos-configuration` |
| `vscode-configuration` | `home/n1ckerr0r/dotfiles/vscode` | `dotfiles` |
| `nvim-configuration` | `home/n1ckerr0r/dotfiles/nvim` | `dotfiles` |

VS Code and Neovim are submodules of `dotfiles`; `dotfiles` is a submodule of
the NixOS repository. Commit from the deepest repository outward:

```sh
git -C home/n1ckerr0r/dotfiles/vscode add -A
git -C home/n1ckerr0r/dotfiles/vscode commit

git -C home/n1ckerr0r/dotfiles add vscode nvim
git -C home/n1ckerr0r/dotfiles commit

git add home/n1ckerr0r/dotfiles
git commit
```

After pulling changes, synchronize nested repositories with:

```sh
git submodule update --init --recursive
```

## Important decisions

### Fixed checkout path

The repository must remain at `/home/n1ckerr0r/nixos-config`.
`home/n1ckerr0r/dotfiles.nix` deliberately uses that location for editable
out-of-store links. Moving or renaming the checkout will break those links even
if the Nix configuration itself still evaluates.

### Programs outside Nix

All integration for intentionally manual software is centralized in
`modules/apps/manual.nix`:

- AdGuard VPN CLI must exist at `/opt/adguardvpn_cli/adguardvpn-cli`.
- Live System Captions must exist at
  `/home/n1ckerr0r/bin/live-system-captions`.

Nix supplies checked wrappers and the desktop integration, but does not install
or update these two programs. New manual prerequisites must be added to the same
module and documented here.

Yandex Browser and Claude Desktop are different: their flakes repackage the
official DEB releases into Nix derivations, so they remain declarative and do
not use host `apt` or `dpkg`.

### DEB packages

The NixOS host does not support installing packages directly with `apt` or
`dpkg`. Use the Debian Distrobox helper instead:

```sh
debbox install ~/Downloads/package.deb
debbox enter
```

Packages installed this way live inside the `debian` container, not in the
NixOS root filesystem. Prefer a path under `$HOME`; host `/tmp` is not a stable
shared package location.

### AdGuard VPN routing

`adguardvpn-sites` keeps only explicit domain bypasses. The former RU-wide
address-list downloader, marker, timer and cached routes were removed because
country-wide routing is unnecessary.

Yandex Browser uses an independent direct route. It connects to a loopback-only
Dante SOCKS proxy; connections owned by the dedicated `dante` user match a
higher-priority `uidrange` rule and select the normal `main` routing table before
AdGuard VPN's catch-all rule. Dante and its `wlp2s0` binding must remain for this
browser-specific route on the laptop.

### Generated and mutable files

Runtime caches, logs, Zsh completion dumps, Home Manager backups and application
state do not belong in Git. GTK settings are generated by Home Manager. OBS
state is intentionally unmanaged because OBS replaces its configuration file
atomically and would break an editable symlink.

### Start command

There is one `start` command, defined in `modules/start.nix`. It mutes the
default audio sink, then opens the normal application set and moves to the
configured Niri workspace.

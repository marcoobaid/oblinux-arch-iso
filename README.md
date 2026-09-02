<div align="center">

<img src="airootfs/etc/calamares/branding/oblinux/welcome.svg" alt="OBLinux" width="520">

### A polished, practical GNOME desktop on an Arch Linux foundation

[![License: MIT](https://img.shields.io/badge/License-MIT-FF8A00.svg)](LICENSE)
[![Base: Arch Linux](https://img.shields.io/badge/Base-Arch%20Linux-1E4D8C.svg)](https://archlinux.org/)
[![Desktop: GNOME](https://img.shields.io/badge/Desktop-GNOME-1E4D8C.svg)](https://www.gnome.org/)
[![Installer: Calamares](https://img.shields.io/badge/Installer-Calamares-0B1118.svg)](https://calamares.io/)

</div>

OBLinux is an independent Linux distribution project focused on delivering a
cohesive, approachable desktop without giving up the flexibility of its
underlying platform. This repository contains the development Arch edition: an
[`archiso`](https://gitlab.archlinux.org/archlinux/archiso)-based live system
with the GNOME desktop and a graphical Calamares installer.

## What is OBLinux?

The Arch edition turns a rolling Arch Linux base into a complete live and
installable desktop. It combines standard Arch tools and repositories with a
curated application set, system-wide defaults, installer integration, and the
shared OBLinux visual identity.

The result is a practical starting point for everyday use: familiar graphical
tools are present from the first boot, while `pacman`, Flatpak, and `paru` keep
the wider Arch and Linux software ecosystems within reach.

## Why OBLinux?

OBLinux is built around a few deliberate choices:

- **Cohesion from boot to desktop.** The boot menus, Plymouth splash, login
  screen, installer, desktop, and terminal share one recognizable identity.
- **Useful defaults without unnecessary layers.** The image provides a focused
  desktop and application set while retaining stock GNOME behavior and native
  GNOME settings.
- **Upstream technologies first.** Arch Linux, GNOME, Calamares, systemd, and
  their supported configuration mechanisms remain the foundation.
- **Freedom after installation.** System defaults remain user-configurable,
  and the Arch package ecosystem stays available through familiar tools.

## Highlights

- Rolling Arch Linux base with standard `pacman` package management
- Stock GNOME desktop with OBLinux wallpapers, icons, fonts, and R5 branding
- BIOS and UEFI live boot support through branded Syslinux and GRUB paths
- Branded Plymouth startup, GDM login, and Calamares installation experience
- Automatic live-session login and a graphical path from evaluation to install
- Firefox, Ptyxis, Flatpak, Flathub, and a curated set of GNOME applications
- Multimedia codecs plus NetworkManager, Bluetooth, printing, firmware, and
  UFW/GUFW firewall tooling
- Signed OBLinux package repository with optional Chaotic-AUR access
- Zsh, Starship, Fastfetch, `paru`, and a focused modern command-line toolset

## The OBLinux experience

```text
Boot → Live environment → Installer → Login → GNOME desktop → Terminal → Installed system
```

OBLinux treats that path as one continuous experience rather than a collection
of unrelated screens. Released assets from the OBLinux Brand Master provide the
shared R5 identity across the boot chain, Calamares, GDM, desktop artwork,
system icons, and terminal presentation. The Arch edition supplies the native
configuration that carries those assets from the live medium into the installed
system.

## Technology

| Component | Selection |
|---|---|
| Foundation | Arch Linux, rolling release |
| ISO framework | `archiso` |
| Desktop | GNOME |
| Installer | Calamares |
| Package management | `pacman`, Flatpak, `paru` |
| Terminal | Ptyxis |
| Shell and prompt | Zsh and Starship |
| Boot support | BIOS/Syslinux and UEFI/GRUB |

## Getting OBLinux

This repository provides the source profile for building the OBLinux Arch live
and installation image. Build the image on an up-to-date Arch Linux system; the
result is written to `out/`.

```bash
sudo pacman -S --needed archiso
sudo mkarchiso -v .
```

Packages supplied by the signed
[`oblinux_repo`](https://github.com/marcoobaid/oblinux_repo)—currently
Calamares, `paru`, `ckbcomp`, and the OBLinux icon theme—must already be
published before the build begins. See the
[custom repository workflow](docs/CUSTOM_REPO.md) and
[package-signing guide](docs/PACKAGE_SIGNING.md) before preparing a build
machine.

After building, validation should cover live boot, the GNOME session, a full
Calamares installation, and the installed system. BIOS and UEFI paths should be
tested separately. The documented test history and subsystem notes distinguish
source checks from actual build, boot, and installation results.

## Repository guide

| Path | Purpose |
|---|---|
| `airootfs/` | Files overlaid onto the live system and carried into an installation |
| `packages.x86_64` | Packages included in the ISO |
| `profiledef.sh` | Archiso profile metadata and boot modes |
| `pacman.conf` | Package repositories and build-time package configuration |
| `grub/` and `syslinux/` | UEFI and BIOS live-boot configuration |
| `docs/` | Design decisions, implementation notes, and validation records |

## Documentation

| Topic | Document |
|---|---|
| Build and verification history | [`docs/TESTING.md`](docs/TESTING.md) |
| Calamares architecture and configuration | [`docs/CALAMARES.md`](docs/CALAMARES.md) |
| Brand system and integration | [`docs/BRANDING.md`](docs/BRANDING.md) |
| GNOME and desktop theming | [`docs/THEMING.md`](docs/THEMING.md) |
| Default applications | [`docs/DEFAULT_APPS.md`](docs/DEFAULT_APPS.md) |
| Custom package repository | [`docs/CUSTOM_REPO.md`](docs/CUSTOM_REPO.md) |
| Package signing and Chaotic-AUR | [`docs/PACKAGE_SIGNING.md`](docs/PACKAGE_SIGNING.md) |
| GDM, Plymouth, and autologin integration | [`docs/GDM_PLYMOUTH_AUTOLOGIN_FIX.md`](docs/GDM_PLYMOUTH_AUTOLOGIN_FIX.md) |

## Contributing

Contributions should be focused, technically justified, and consistent with the
documented architecture. Before proposing a change, read the relevant document
above, prefer supported upstream mechanisms, and update documentation alongside
meaningful configuration changes. Validation reports should state clearly
whether a change was checked statically, built with `mkarchiso`, boot-tested, or
installed and tested.

Brand artwork is maintained in the separate OBLinux Brand Master project and is
consumed here from released versions. Shared visual assets should not be
redesigned or patched in this repository.

## License

The OBLinux project files are available under the [MIT License](LICENSE).
Bundled and derived third-party assets retain their respective licenses and
attributions.

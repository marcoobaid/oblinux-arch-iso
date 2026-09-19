<div align="center">

<img src="airootfs/etc/calamares/branding/oblinux/welcome.svg" alt="OBLinux" width="520">

### A polished, practical GNOME desktop on an Arch Linux foundation

[![License: GPL-3.0-or-later](https://img.shields.io/badge/License-GPL--3.0--or--later-FF8A00.svg)](LICENSE)
[![Base: Arch Linux](https://img.shields.io/badge/Base-Arch%20Linux-1E4D8C.svg)](https://archlinux.org/)
[![Desktop: GNOME](https://img.shields.io/badge/Desktop-GNOME-1E4D8C.svg)](https://www.gnome.org/)
[![Installer: Calamares](https://img.shields.io/badge/Installer-Calamares-0B1118.svg)](https://calamares.io/)

</div>

OBLinux is an independent Linux distribution project focused on a cohesive,
approachable desktop. This repository, **oblinux-arch-iso**, contains the
Stable Arch implementation: an `archiso`-based live and installable Arch Linux
system with GNOME and the graphical Calamares installer.

## What is OBLinux?

The Arch edition turns a rolling Arch Linux base into a complete live and
installable desktop. It combines standard Arch tools and repositories with a
curated application set, system-wide defaults, installer integration, and the
shared OBLinux visual identity.

The result is a practical starting point for everyday use: familiar graphical
tools are present from the first boot, while `pacman`, Flatpak, and `paru` keep
the wider Arch and Linux software ecosystems within reach.

## Highlights

- Rolling Arch Linux base with standard `pacman` package management
- Stock GNOME desktop with OBLinux wallpapers, icons, fonts, and R5 visual identity
- BIOS and UEFI live boot support through branded Syslinux and GRUB paths
- Branded Plymouth startup, GDM login, and Calamares installation experience
- Automatic live-session login and a graphical path from evaluation to install
- Firefox, Ptyxis, Flatpak, Flathub, and a curated set of GNOME applications
- Multimedia codecs plus NetworkManager, Bluetooth, printing, firmware, and
  UFW/GUFW firewall tooling
- Signed OBLinux package repository with optional Chaotic-AUR access
- Zsh, Starship, Fastfetch, `paru`, and a focused modern command-line toolset

Released assets from **OBLinux Brand Master** provide the shared R5 visual
identity across OBLinux editions, from boot and login to the installer, desktop,
and terminal. Arch supplies its own native integration while retaining stock
GNOME behavior and user-configurable defaults. Shared artwork is maintained
upstream and consumed from immutable releases.

## Release status

OBLinux Arch **26.3.0 is released**. The following Stable artifact passed
final regression testing on both virtual machines and a physical laptop.

- Git tag: `v26.3.0`
- Certified source commit (tagged release): `67394522ded4b50b05ef150d8b71decddba2d824`
- ISO: `oblinux-arch-26.3.0-20260916-2053-x86_64.iso`
- BUILD_ID: `20260916-2053`
- SHA-256: `047a1480bdd3040482b8a6d099da7471e775878a09174932de05650b43a9e499`
- ISO and SHA256 file published on SourceForge: `OBLinux-Arch-ISO/26.3.0/`
- Public SourceForge download: **verified**; downloaded-ISO `sha256sum -c`: **OK**

The certified release code is frozen. Later documentation updates do not change
the certified source commit or immutable release tag. GNOME Shell's native
screenshot functionality is the default; Flameshot removal is complete in this
release.

See the [release verification record](docs/TESTING.md#stable-2630-release-verification-2026-09-17)
for the recorded results and the [hardware compatibility notes](docs/HARDWARE_TARGETS.md)
for tested hardware and known limitations. Release status does not imply broad
hardware compatibility.

## Technology

| Component | Selection |
|---|---|
| Foundation | Arch Linux, rolling release, `x86_64` |
| ISO framework | [`archiso`](https://gitlab.archlinux.org/archlinux/archiso) |
| Desktop | GNOME |
| Installer | Calamares |
| Package management | `pacman`, Flatpak, `paru` |
| Terminal | Ptyxis |
| Shell and prompt | Zsh and Starship |
| Boot support | BIOS/Syslinux and UEFI/GRUB |

## Building and trying OBLinux

This repository provides the source profile for building the OBLinux Arch live
and installation image. Build the image on an up-to-date Arch Linux system; the
result is written to `out/`.

```bash
sudo pacman -S --needed archiso
cat VERSION
./scripts/build-iso.sh
```

The wrapper gives every image one exact build identity and produces an ISO
named from the repository release version and that build identity. See the
[versioning and build-identification policy](docs/VERSIONING.md).

Packages supplied by the signed
[`oblinux_repo`](https://github.com/marcoobaid/oblinux_repo)—currently
Calamares, `paru`, `ckbcomp`, and the OBLinux icon theme—must already be
published before the build begins. See the
[custom repository workflow](docs/CUSTOM_REPO.md) and
[package-signing guide](docs/PACKAGE_SIGNING.md) before preparing a build
machine.

Start testing in a VM with a disposable disk. Validation should cover live
boot, the GNOME session, a full Calamares installation, and the installed system.
BIOS/Syslinux and UEFI/GRUB live-boot paths should be tested separately. Disk
encryption is not supported by the current installer configuration. Review the
[installer documentation](docs/CALAMARES.md) and [testing records](docs/TESTING.md)
before installing on physical hardware.

Calamares copies the live filesystem onto the target disk, then configures the
installed system and removes live-only components. The live environment's
packages and defaults therefore form the basis of a fresh installation.

### Repository guide

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
| Release versioning and build identification | [`docs/VERSIONING.md`](docs/VERSIONING.md) |
| Build and verification history | [`docs/TESTING.md`](docs/TESTING.md) |
| Hardware compatibility notes | [`docs/HARDWARE_TARGETS.md`](docs/HARDWARE_TARGETS.md) |
| Calamares architecture and configuration | [`docs/CALAMARES.md`](docs/CALAMARES.md) |
| Brand system and integration | [`docs/BRANDING.md`](docs/BRANDING.md) |
| GNOME and desktop theming | [`docs/THEMING.md`](docs/THEMING.md) |
| Default applications | [`docs/DEFAULT_APPS.md`](docs/DEFAULT_APPS.md) |
| Custom package repository | [`docs/CUSTOM_REPO.md`](docs/CUSTOM_REPO.md) |
| Package signing and Chaotic-AUR | [`docs/PACKAGE_SIGNING.md`](docs/PACKAGE_SIGNING.md) |
| GDM, Plymouth, and autologin integration | [`docs/GDM_PLYMOUTH_AUTOLOGIN_FIX.md`](docs/GDM_PLYMOUTH_AUTOLOGIN_FIX.md) |

## Contributing

Keep contributions focused and consistent with the documented Arch architecture.
Active development and integration happen in
[`oblinux-arch-iso-dev`](https://github.com/marcoobaid/oblinux-arch-iso-dev);
Stable receives validated changes through separately approved promotions.
Prefer supported upstream mechanisms, preserve user choices, and update relevant
documentation when behavior changes. Validation reports should distinguish
static checks, ISO builds, live boot, installation, and hardware testing.

Brand artwork is maintained in the separate OBLinux Brand Master project and is
consumed here from released versions. Shared visual assets should not be
redesigned or patched in this repository.

## License

OBLinux Arch is licensed under [GPL-3.0-or-later](LICENSE). Bundled and
derived third-party assets retain their respective licenses and
attributions.

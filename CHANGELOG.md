# Changelog

## Unreleased

- Give the visible GRUB menu a five-second countdown before automatically
  booting the normal OBLinux entry on live, loopback, and installed systems.
- Restrict SquashFS XZ branch conversion to the x86 filter appropriate for the
  x86_64 ISO, fixing reproducible `xz uncompress failed with error code 9`
  build failures caused by also evaluating the unrelated ARM64 filter.
- Align the Arch Zsh experience with the Debian edition: enable packaged
  autosuggestions and syntax highlighting, add persistent deduplicated history,
  familiar editing/navigation keys, top-level-only Fastfetch startup, and the
  same Starship prompt layout and palette.
- Enable GNOME's one-time first-login welcome and Tour flow for newly created
  installed users while suppressing it for the Live session.
- Add Manual partitioning alongside the existing Calamares Erase disk flow.
- Align Calamares password handling with Debian's six-character minimum and
  remove the weak-password override.
- Add GIMP, Impression, Flameshot, and Document Scanner to the default
  Live ISO and installed-system application set.
- Configure the fresh installed-user GNOME dash with Firefox, Ptyxis, Files,
  Software, Text Editor, Calculator, and Help; Ptyxis replaces Evolution.
- Remove Flameshot from the default package set: it did not provide a
  reliably functional/default experience under the OBLinux GNOME Wayland
  environment. OBLinux relies on GNOME Shell's native screenshot
  functionality instead.

# AGENTS.md — OBLinux operating guide for coding agents

Persistent operating guide for any coding agent (Claude Code or otherwise)
working in this repository. Read this first. It is a map and a set of
rules, not a tutorial — detailed specs live in the other `docs/` files
this points to.

## Project overview

OBLinux is an Arch Linux-based Linux distribution: GNOME desktop, Calamares
graphical installer, built with `archiso`. It ships as a live/install ISO
with a curated (not minimal, not maximal) default application set, and a
consistent "Slate & Amber" visual identity applied from GRUB through GDM,
the desktop, the terminal, and the installer.

The project is presented as a public GitHub project, not an individual's
personal build — project documentation and commit messages must stay
free of any personal name and must never list an AI tool as a
contributor/author (see Development Rules).

## Repository responsibility

This repository (`oblinux`) **is** the archiso profile: everything that
becomes the live ISO and, by extension (via Calamares' `unpackfs`), the
installed system. It owns package
selection, live-environment configuration, GNOME/GDM defaults, boot
theming (Plymouth/GRUB/syslinux), and the Calamares installer
configuration.

Two sibling repositories, both real and referenced from this one — do not
invent others:

- **[`oblinux_repo`](https://github.com/marcoobaid/oblinux_repo)** — a
  signed pacman repository (hosted on GitHub Pages) for packages this
  project needs that aren't in the official Arch repos: `calamares`,
  `paru`, `ckbcomp`, `oblinux-icon-theme`. Built with `makepkg`, published
  with that repo's own `x86_64/update_repo.sh`. **Packages must be built
  and published there before a `mkarchiso` build that references them —
  `pacstrap` will fail to resolve them otherwise.** This is a genuinely
  separate step this repository cannot trigger.
- **[`oblinux-icon-theme`](https://github.com/marcoobaid/oblinux-icon-theme)**
  — the amber-recolored Papirus-derivative icon theme, packaged and
  published through `oblinux_repo` the same way.

## Repository map

```
packages.x86_64          Full package list: unmodified archiso releng base,
                          then OBLinux additions below a clear comment
                          boundary (search for "## OBLinux:").
pacman.conf               Build-time pacman config (used by mkarchiso's
                          pacstrap). Mirrored, not symlinked, into
                          airootfs/etc/pacman.conf for the live/installed
                          system — edit both if changing repos/signing.
profiledef.sh             archiso profile metadata: ISO name/label, boot
                          modes (BIOS+UEFI), squashfs compression, file
                          permission overrides.
bootstrap_packages        Minimal package set for the bootstrap tarball
                          (separate from the ISO's own packages.x86_64).
airootfs/                 Root of the live filesystem overlay — see
                          "Filesystem and live environment" below.
docs/                     All project documentation; see Documentation Map.
docs/branding/            Design *sources* (SVG wallpapers, the mark,
                          GNOME Shell theme SCSS) — not shipped on the
                          image; compiled/rasterized output lives under
                          airootfs/.
scripts/                  Standalone verification scripts
                          (verify-shell-theme.sh) — dev tooling, not part
                          of the built image.
```

Inside `airootfs/`, the paths that matter most:

```
airootfs/etc/calamares/                 Installer config (see Calamares section)
airootfs/etc/dconf/                     GDM-specific dconf profile/database
airootfs/etc/xdg/fastfetch/             System-wide fastfetch config + logo
airootfs/etc/xdg/starship.toml          System-wide Starship prompt config
airootfs/etc/skel/                      Template for newly created users' homes
airootfs/home/liveuser/                 Live-session-only account config
airootfs/etc/systemd/system/            Live-session systemd unit overrides
airootfs/usr/share/glib-2.0/schemas/    GSettings/dconf compiled-default overrides
airootfs/usr/share/themes/OBLinux/      GNOME Shell theme (compiled CSS + assets)
airootfs/usr/share/fonts/OBLinux-jetbrains-mono-nerd/  Vendored font subset
airootfs/usr/share/backgrounds/oblinux/ Shipped wallpapers (PNG, not SVG)
airootfs/usr/share/plymouth/themes/oblinux/  Boot splash theme
airootfs/usr/share/pacman/keyrings/     oblinux_repo + Chaotic-AUR trust keys
airootfs/etc/pacman.d/hooks/            Custom pacman hooks (live-session only)
```

## Architecture

Live medium build: `mkarchiso` (this repo's profile) → `pacstrap` installs
`packages.x86_64` into a chroot → `airootfs/` is overlaid on top → squashfs
+ bootloaders assembled into the ISO. Booting the ISO: GRUB/syslinux →
Plymouth splash → GDM (autologin as `liveuser`) → GNOME session. Installing:
Calamares's `unpackfs` module clones the **live squashfs itself** onto the
target disk (not a separate package-installation pass), then a sequence of
Calamares modules configure the target (bootloader, users, locale, etc.)
and a `shellprocess-final` step strips live-only artifacts. This means:
**whatever is true of the live session is true of a fresh install, unless
something explicitly changes or removes it post-install.** This is the
single most important architectural fact in this repo — most "why does
this exist" questions trace back to it.

Deeper detail lives in `docs/CALAMARES.md`, `docs/THEMING.md`,
`docs/BRANDING.md` — read those before changing the relevant subsystem
rather than re-deriving behavior from source alone.

## ISO build process

**Build machine is not this Mac.** Development in this repo happens on
macOS (file edits, research, syntax validation); the actual `mkarchiso`
build, boot test, and install test always happen on a separate Linux
build machine, driven by the user. An agent working here should assume it
**cannot** run a real build/boot/install cycle itself and must ask for
that verification rather than claim it.

Primary entry point (on the Linux build machine, from the repo root):
```bash
sudo mkarchiso -v .
```
Output ISO lands in `out/` (gitignored, along with `work/`, mkarchiso's
build workspace — neither is source-controlled).

**Prerequisite**: any package sourced from `oblinux_repo` must already be
built and published there — a stale/missing package there fails
`pacstrap`, not this repo's config. See `docs/CUSTOM_REPO.md` and
`docs/PACKAGE_SIGNING.md`.

**Validation after a build**: boot the ISO (BIOS and UEFI both supported —
`profiledef.sh`'s `bootmodes`), confirm autologin reaches the desktop, run
a Calamares install, boot the installed system. `docs/TESTING.md` (Phase
1/2) and `docs/THEMING.md`/`docs/CALAMARES.md` (Phase 3/4) are the
historical logs of what's been checked and how — see Testing and
Validation below. `scripts/verify-shell-theme.sh` automates one specific
mechanism check (the GNOME Shell theme extension).

## Package management

- **Official Arch repos** (`core`/`extra`): the overwhelming majority of
  `packages.x86_64`. Just add the name.
- **`oblinux_repo`** (this project's own signed repo): packages that only
  exist in the AUR, pre-built there so `pacstrap` can install them like
  any other package — currently `calamares`, `paru`, `ckbcomp`,
  `oblinux-icon-theme`. See build-order prerequisite above.
- **AUR, at runtime only**: `paru` is installed specifically so *end
  users* (not this repo's build process) can pull AUR packages after
  install. Nothing in this repo builds AUR packages directly.
- **Chaotic-AUR**: wired into `pacman.conf`/`airootfs/etc/pacman.conf`
  and trusted (keyring + mirrorlist copied verbatim from Chaotic's own
  packages), but **not** currently added to `packages.x86_64` — available
  for users, not part of the curated default set yet.
- **Vendored files, not a package**: `ttf-jetbrains-mono-nerd` was
  deliberately replaced with 4 hand-picked font files under
  `airootfs/usr/share/fonts/OBLinux-jetbrains-mono-nerd/` — the full
  package is 90 files/228MB for one style actually used, and was also the
  exact git-bisected trigger of a severe boot regression (see Known
  Pitfalls). Don't re-add that package without re-reading
  `docs/THEMING.md` item 1.

`packages.x86_64` itself is the authoritative source of truth for what's
installed — read its `## OBLinux:` comment blocks before adding anything;
almost every addition has a documented rationale and a doc cross-reference.

## Filesystem and live environment

`airootfs/` is overlaid onto the pacstrap chroot verbatim by `mkarchiso` —
there is no separate "customize_airootfs.sh" build hook in this profile;
pacman hooks (`glib-compile-schemas`, `dconf-update`) already fire
correctly during `pacstrap` itself. Two account configs exist side by
side and are **not** the same file:

- `airootfs/home/liveuser/` — the live session's own account (autologin,
  its own `.zshrc`). **Not** carried over to installs.
- `airootfs/etc/skel/` — template copied into any **new** account
  `useradd -m` creates, i.e. what a Calamares-created user actually gets.

When adding user-facing shell config (a prompt, a banner, an alias),
usually both need the change, and they will legitimately differ (e.g. the
live session's greeting text vs. a real user's).

Calamares' `shellprocess-final.conf` is what strips live-only artifacts
(passwordless sudo, autologin, the automated-script rescue mechanism, the
ephemeral pacman-gnupg mount, the installer's own config tree) from the
installed system — see its own comments and `docs/CALAMARES.md`'s
"Live-artifact cleanup" table for the authoritative list of what's
removed and why. If you add a new live-only file, add its cleanup step
there too.

## GNOME configuration

Layered, in order of what actually wins:

1. **Compiled gschema override** —
   `airootfs/usr/share/glib-2.0/schemas/50_oblinux-gdm.gschema.override`.
   Sets the *compiled default* for `org.gnome.desktop.background`,
   `org.gnome.desktop.interface` (accent color, fonts, icon theme),
   `org.gnome.login-screen` (logo), and `org.gnome.shell`/`org.gnome.
   shell.extensions.user-theme` (Shell theme). Applies to every account
   that hasn't set its own value, including GDM itself, unless overridden
   below.
2. **GDM-specific dconf profile/database** —
   `airootfs/etc/dconf/profile/gdm` + `airootfs/etc/dconf/db/gdm.d/` —
   takes priority over (1) for the `gdm` user only. Currently used for
   GDM's own background gradient, deliberately different from the
   desktop session's wallpaper (see Branding).
3. **Per-user dotfiles** (`~/.zshrc`, `~/.config/starship.toml`) — a
   real user can always override defaults; (1)/(2) only set what a
   fresh account sees.

GNOME Shell itself is styled via the **User Themes** extension
(`gnome-shell-extensions` package, only that one component enabled) — a
deliberate, one-time exception to the otherwise "stock GNOME, no
extensions" policy, justified because it's an official GNOME-maintained
extension, not third-party. See `docs/THEMING.md` item 5 for the full
reasoning and the real config search path if this ever needs revisiting.

## Branding

Palette and full design system: `docs/BRANDING.md`. Core values used
throughout the codebase (search for these hexes if tracing a color):
Ink `#151a22`, Slate `#2c3a4e`, Primary `#3f6690`, Slate Light `#a9b8c8`,
Amber `#d68a3c` (reserved for actions/alerts, never decorative), Cloud
`#f2f3f5`.

Design sources (SVG, SCSS) live under `docs/branding/`; compiled/shipped
output lives under `airootfs/`. This split matters: **editing a shipped
PNG or compiled CSS directly will be silently overwritten the next time
someone regenerates it from source** — always edit the source and
regenerate (see each subsystem's own README under `docs/branding/`).

Per-surface mechanism (all real constraints, verified against upstream,
not assumed — see `docs/THEMING.md` for the verification detail on each):
- **Wallpaper**: pre-rendered PNG (not live SVG — a sandboxed-renderer
  crash was traced to SVG `<text>` elements; see Known Pitfalls), set via
  the gschema override.
- **GDM login background**: solid/gradient color only, via the GDM
  dconf database (mechanism above) — a real background *image* on GDM
  requires patching `gnome-shell-theme.gresource` directly, which
  upstream itself flags as reverted by every `gnome-shell` update.
  Deliberately not done.
- **GDM logo**: `org.gnome.login-screen logo`, points at the mark+wordmark
  lockup SVG.
- **Icon theme**: `oblinux-icon-theme` package (separate repo), an
  *inheriting* theme — only recolors `places` icons, inherits everything
  else from `papirus-icon-theme`.
- **GNOME Shell**: forked/recolored from `Graphite-gtk-theme`'s
  `gnome-shell` module only (not its GTK theme).
- **Terminal**: `fastfetch` (ASCII-only logo — Ptyxis's underlying VTE has
  Sixel support compiled out on Arch's build, verified in VTE's own
  source, not assumed) + Starship prompt, both configured system-wide
  under `airootfs/etc/xdg/`.
- **Boot**: Plymouth theme + GRUB theme, both under `airootfs/usr/share/`.

## Calamares

Config lives entirely under `airootfs/etc/calamares/` as plain files (not
packaged — see `docs/CUSTOM_REPO.md`'s "Why not a
oblinux-calamares-config package" for why: packaging would force a full
build cycle for every config tweak during active iteration).

- **`settings.conf`** — the module sequence. Currently: `show` pages
  (welcome, locale, keyboard, partition, users, summary) → `exec`
  pipeline (partition, mount, unpackfs, machineid, fstab, locale,
  keyboard, localecfg, `shellprocess@before`, initcpio, removeuser,
  users, displaymanager, networkcfg, hwclock, services-systemd, packages,
  grubcfg, bootloader, `shellprocess@final`, preservefiles, umount) →
  `show` finished. Deliberately dropped from the reference sequence:
  `luksbootkeyfile`/`luksopenswaphookcfg` (no disk encryption support
  yet), `plymouthcfg` (theme is already baked into the live squashfs),
  `initcpiocfg` (can't express exact HOOKS ordering — `shellprocess
  @before` does it with `sed` instead).
- **`modules/*.conf`** — per-module config, one file per module named in
  `settings.conf`.
- **`branding/oblinux/`** — `branding.desc` (strings, palette, window
  behavior), `logo.png`, `show.qml` (the installation-progress
  slideshow — a real multi-slide QML `Presentation`, not a static image;
  first content draft landed 2026-08-22, see `docs/CALAMARES.md`).
- **`shellprocess-before.conf`** / **`shellprocess-final.conf`** — arbitrary
  shell commands run against the target root before/after the main exec
  sequence. `before` fixes things the standard modules can't express
  precisely (exact mkinitcpio HOOKS ordering); `final` strips live-only
  artifacts and does post-install keyring population.

**Areas that easily break installation** (each cost real debugging time —
see `docs/TESTING.md` for the full incident, `docs/CALAMARES.md` for the
distilled lesson):
- `mount.conf`'s `extraMounts` `options:` **must** be a YAML list
  (`[ bind ]`), not a bare string (`bind`) — Calamares does
  `",".join(options)`, so a bare string gets iterated character-by-character.
- Anything touching `HOOKS=` in mkinitcpio config must preserve exact
  ordering (`base`, `udev`, then `plymouth` right after) — the built-in
  `initcpiocfg` module's prepend/append can't express this, hence the
  `shellprocess@before` `sed` approach.
- The real Calamares install log is `~/.cache/calamares/session.log`, not
  `/var/log/Calamares.log` — a wrong earlier answer in this project's own
  history, corrected in `docs/CALAMARES.md`. Use `session.log` when
  diagnosing an install failure.

## Boot and installation

Both BIOS (syslinux) and UEFI (systemd-boot for the live medium, GRUB for
the installed system) are supported and have each been verified on both
VirtualBox and real hardware (see `docs/TESTING.md`). No disk-encryption
support yet (deliberately dropped from the Calamares sequence, see
above). `cow_spacesize`/`copytoram` live-medium boot parameters have each
had a real, root-caused bug in this project's history — see Known
Pitfalls before touching syslinux/EFI boot parameters.

## Testing and validation

`docs/TESTING.md` is the chronological build-verification log for Phase
1/2 (base system + installer), 20 rounds through 2026-08-12 — it has not
been updated since. Verification since then (the Phase 3/4 theming and
Calamares slideshow work) is logged inline in `docs/THEMING.md` and
`docs/CALAMARES.md` instead, each with its own dated entries. Check both
sources — don't assume `docs/TESTING.md` alone reflects current
verification status. There is no separate formal test suite; validation is
build → boot → (install →) boot-installed, done manually on real
VirtualBox/hardware by the user, since this repo's own development
environment (macOS) cannot run `mkarchiso` or boot the result.

Minimum validation expected after a change:
- **Package list change**: full build + live boot.
- **GNOME/dconf/theming change**: build + boot + visually confirm the
  specific surface changed (screenshot or direct inspection) — do not
  assume a schema/config change "worked" from syntax validity alone.
- **Calamares change**: build + boot + a full install + boot the
  installed system. Partition/mount/mkinitcpio-adjacent changes
  specifically need `session.log` inspected, not just "did it finish."
- **Anything touching GDM/autologin/Plymouth/systemd units**: multiple
  reboots (8–10+), not 2–3 — this class of bug has repeatedly turned out
  to be probabilistic rather than deterministic in this project's
  history (see Known Pitfalls).

`scripts/verify-shell-theme.sh` automates the GNOME Shell theme
extension's activation check specifically; run it on the built system,
not the build machine (needs a live GNOME session's D-Bus, and must be
run without `sudo` for the same reason).

## Hardware targets

No formal hardware-target document exists in this repo. What's actually
been verified, per `docs/TESTING.md`: VirtualBox (BIOS and UEFI), and one
physical laptop (UEFI, real Wi-Fi/graphics hardware). Treat any hardware
claim beyond that as unverified, not as an established support matrix.

## Important architectural decisions

Do not casually reverse these without re-reading the linked reasoning:

- **Stock GNOME, no extensions** — except User Themes (Shell styling),
  a deliberate, documented one-time exception. Adding another extension
  needs the same bar: official/upstream-maintained, not third-party.
- **No custom GTK theme** — GNOME's native accent-color system only.
  The GNOME Shell theme fork explicitly excludes Graphite's GTK modules
  for this reason; don't pull them in.
- **Wallpapers ship as PNG, never SVG** — removes an entire sandboxed
  rendering pipeline that has already caused one real crash.
- **GDM background is solid/gradient color, never an image** — the image
  path requires an ongoing gresource-patching pacman hook that doesn't
  exist; don't add a background image without building that
  infrastructure first.
- **`oblinux_repo` packages are built/published externally, never at
  ISO-build time** — this repo only ever *consumes* that repo.
- **Calamares config is plain files, not a package** — keep it that way
  while iteration is active; packaging would slow every tweak.
- **Live-session config and installed-system config are separate files**
  (`liveuser`'s home vs. `/etc/skel`) — never assume editing one affects
  the other.
- **Commit messages and all project files never name a specific
  individual, and never list an AI tool as author/contributor** — see
  Development Rules.

## Known pitfalls and lessons learned

- **Symptom**: GDM shows the live-session login screen; clicking through
  eventually leads to instability, or (a related but distinct issue) a
  perfectly healthy autologin session simply never becomes visible.
  **Cause (first instance)**: SVG wallpapers with `<text>` elements
  triggered a sandboxed-renderer (`glycin-svg`) crash via a blocked
  `symlink()` syscall during fontconfig cache building. **Cause (the
  actual root cause of the visibility bug)**: an upstream GDM + Plymouth
  + autologin VT race — Plymouth's own delayed shutdown switched the
  active VT back to the greeter *after* the real session was already
  displayed on a different VT. **Correct approach**: ship wallpapers as
  PNG (removes the crash's rendering pipeline entirely, but does **not**
  by itself fix the VT race); fix the race itself via a `gdm.service.d`
  drop-in that makes GDM tell Plymouth to quit synchronously before its
  own startup proceeds (`ExecStartPre=-/usr/bin/plymouth quit
  --retain-splash`), plus masking `getty@tty1.service`/
  `autovt@tty1.service` so nothing else competes for that VT. Full
  investigation in `docs/THEMING.md` item 1.
- **Symptom**: a fix that looks confirmed on 2–3 test boots later turns
  out not to hold. **Cause**: some classes of bug in this stack
  (GDM/autologin/systemd-unit races) are probabilistic, not
  deterministic. **Correct approach**: use 8–10+ reboots before trusting
  a "clean" result for anything in this class, and re-verify a
  candidate fix against the *original* reported symptom, not just
  against whatever specific crash was found along the way — a real,
  separate bug can be fixed without being the cause of the symptom you
  were chasing.
- **Symptom**: `gnome-extensions info` reports an extension `Enabled: Yes`
  but `State: INACTIVE`, with no error anywhere. **Cause**: this can be a
  transient artifact of manual disable/enable/reload probing during
  diagnosis, not a real activation bug — `EnableExtension` is a no-op
  (by design) if the UUID is already in `enabled-extensions`, so toggling
  it doesn't necessarily retrigger the real activation path. **Correct
  approach**: check visually whether the change actually applied before
  trusting the reported state; confirm with a genuinely clean reboot
  (zero prior manual commands) before concluding there's a real bug.
- **Symptom**: `mkinitcpio: /dev must be mounted!` during a Calamares
  install. **Cause**: `mount.conf`'s bind-mount `options:` was a bare
  string (`bind`) instead of a YAML list (`[ bind ]`) — Calamares joins
  the options with commas, so a string gets iterated character-by-character.
  **Correct approach**: always use list syntax for `extraMounts` options.
- **Symptom**: a wallpaper or logo element gets cropped on some displays
  but not others. **Cause**: `picture-options='zoom'` crops the image
  proportional to how far the display's aspect ratio departs from the
  1920×1080 source. **Correct approach**: give any near-edge design
  element (like the wordmark) a margin generous enough to survive common
  non-16:9 aspect ratios (16:10, 3:2), not just enough to look right on
  the aspect ratio it was designed at.
- **Symptom**: shipping a large upstream package for one narrow use (a
  single font style, one extension out of a bundle). **Correct
  approach, applied twice in this project**: vendor only the files
  actually used (fonts) or enable only the specific component needed
  (User Themes out of `gnome-shell-extensions`) rather than installing
  the whole thing by default.

## Generated vs. authoritative files

| Generated (don't hand-edit) | Authoritative source |
|---|---|
| `airootfs/usr/share/backgrounds/oblinux/*.png` | `docs/branding/wallpapers/*.svg` |
| `airootfs/usr/share/themes/OBLinux/gnome-shell/gnome-shell.css` | `docs/branding/gnome-shell-theme-src/` (SCSS) |
| `out/`, `work/` (mkarchiso build artifacts) | this repo's config, at build time |
| `oblinux_repo`'s package database/`.pkg.tar.zst` files | that repo's own `PKGBUILD`s |

Everything else under `airootfs/` is itself the authoritative source —
there is no separate templating layer for config files, dconf overrides,
systemd units, or Calamares config in this repo.

## Development rules

- Inspect the existing implementation and the relevant `docs/` file
  before changing a subsystem — most decisions here have documented
  reasoning; don't re-litigate or silently reverse one without reading
  why it exists first.
- Prefer upstream Arch/GNOME/Calamares mechanisms over custom
  infrastructure (this project has repeatedly chosen "use the real
  official mechanism, verified against its actual source/docs" over
  guessing or reconstructing from a reference elsewhere).
- Verify, don't assume — this project's own standing practice is to
  check primary sources (upstream source code, real package file lists,
  official docs) for anything non-trivial rather than relying on
  general/remembered knowledge. Several real bugs in this project's
  history trace back to an unverified assumption.
- Never commit credentials or secrets. The `oblinux_repo` signing
  private key lives only on the build machine's own GnuPG keyring —
  never in this repo.
- **Never attribute an AI tool as author/contributor anywhere** — no
  `Co-Authored-By` trailers, no listing in `AUTHORS`/`README`/`PKGBUILD`
  files, in this repo or either sibling repo. Verified: zero such
  trailers exist in this repo's git history: keep it that way.
- **Never name a specific individual in project documentation, commit
  messages, or any user-visible file** — this is a public project
  repository, kept professional; use neutral phrasing.
- Avoid machine-specific paths in anything that ships on the image;
  build-machine-specific setup (keyring trust, signing) belongs in docs,
  not in `airootfs/`.
- Keep documentation synchronized with meaningful changes — a config
  change without an accompanying doc update is incomplete in this repo's
  own established practice.
- Don't claim a build/boot/install verification happened unless it
  actually did on real hardware/VM — this repo cannot self-verify from
  macOS.

## Documentation map

| Document | Authoritative for |
|---|---|
| `docs/BRANDING.md` | Palette, semantic color mapping, boot-chain branding (GDM/Plymouth/GRUB/os-release) |
| `docs/THEMING.md` | The 7-item GNOME theming pass (wallpaper, accent color, fonts, icon theme, Shell theme, fastfetch, Starship) — decisions, verification evidence, and the full GDM/Plymouth boot-regression investigation |
| `docs/CALAMARES.md` | Installer module sequence, branding, live-artifact cleanup, install-breaking gotchas |
| `docs/CUSTOM_REPO.md` | Why/how `oblinux_repo` exists, build/publish workflow |
| `docs/PACKAGE_SIGNING.md` | Signing key details, trust propagation (build machine / live session / installed system), Chaotic-AUR setup |
| `docs/DEFAULT_APPS.md` | Rationale for every package-list addition |
| `docs/GDM_PLYMOUTH_AUTOLOGIN_FIX.md` | Standalone writeup of the GDM/Plymouth VT-race fix (condensed version of the THEMING.md item 1 investigation) |
| `docs/TESTING.md` | Chronological build-verification log for Phase 1/2 only (20 rounds, through 2026-08-12) — later verification lives in `docs/THEMING.md`/`docs/CALAMARES.md` instead |

No `ARCHITECTURE.md`, `BUILDING.md`, `HARDWARE_TARGETS.md`,
`INSTALLER.md`, `ROADMAP.md`, `PROJECT_CHARTER.md`, `POC_SCOPE.md`, or
`DAILY_DRIVER_REQUIREMENTS.md` currently exist in this repo — don't
reference them as if they do. This file's Architecture, ISO Build
Process, Boot and Installation, and Hardware Targets sections are the
closest current equivalent for those topics.

## Agent start-of-task workflow

1. Read this file.
2. Check `git log`/`git status` for recent, possibly-uncommitted context.
3. Read the `docs/` file(s) relevant to the requested task (see
   Documentation Map) — don't rely on this file's summaries for
   subsystem detail.
4. Inspect the actual current implementation (config files, not just
   docs) — docs can lag behind a fast-moving repo like this one.
5. Determine ownership: does this change belong in this repo, or in
   `oblinux_repo`/`oblinux-icon-theme`?
6. Make the smallest complete change; match the existing style/comment
   density in the file being edited.
7. State plainly what validation would confirm the change works, and
   whether that validation actually happened (this repo can't
   self-verify builds/boots — say so rather than implying it did).
8. Update the relevant `docs/` file(s) when the change is
   architecturally meaningful (see Maintaining This File for the bar).
9. Summarize what changed and what still needs verification.

## Maintaining this file

Update `AGENTS.md` when a change materially affects: repository
responsibilities, the high-level architecture, the build workflow,
important file paths, package-sourcing strategy, GNOME configuration
strategy, Calamares module sequence/architecture, testing expectations,
or a development rule/lesson future agents need to not repeat. Don't
update it for routine implementation details already obvious from the
code, and don't let it grow into a second `TESTING.md` or `THEMING.md` —
point to those instead of duplicating them. Remove or correct sections
that become obsolete rather than leaving stale information alongside
new information.

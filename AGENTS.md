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
the desktop, the terminal, and the installer. **This repository
(`oblinux-arch-iso`) is the stable/production implementation** — see
Repository architecture below for how it relates to the other OBLinux
repositories.

The project is presented as a public GitHub project, not an individual's
personal build — project documentation and commit messages must stay
free of any personal name and must never list an AI tool as a
contributor/author (see Development Rules).

## Repository architecture

OBLinux's Arch implementation spans four repositories with a defined
promotion flow:

```
                 oblinux-brand-master
                Shared Visual Identity
                         │
                         ▼
                oblinux-arch-iso-dev
               Development / Staging
                         │
                  test + validate
                         │
                  owner approval
                         │
                         ▼
                  oblinux-arch-iso
                   Stable / Production
```

- **`oblinux-brand-master`** — owns shared OBLinux visual identity: the
  master logo/wordmark, brand colors, shared icons, shared wallpapers,
  GRUB branding, Plymouth branding, Calamares branding, and other common
  visual standards. Shared visual changes originate there and reach this
  repository only through released/versioned Brand Master output,
  normally via `oblinux-arch-iso-dev` first (see Brand Master below).
- **`oblinux-arch-iso-dev`** — the active development/staging repository.
  New features, integrations (including R5), fixes, experiments, major
  configuration changes, and ISO-level validation normally happen there
  first, not here.
- **`oblinux-arch-iso`** (this repository) — stable/production. Its job
  is to preserve the last owner-approved, tested, and validated OBLinux
  Arch implementation. See Stable repository safety below.

The legacy **`oblinux`** repository is separate from this flow: it is
read-only historical/reference material, populated this repo's and
`oblinux-arch-iso-dev`'s shared starting point. See Legacy `oblinux`
repository below.

Two further sibling repositories sit outside this promotion chain and are
consumed by whichever repo currently needs them (today, that's this repo
directly; see Package management):

- **[`oblinux_repo`](https://github.com/marcoobaid/oblinux_repo)** — a
  signed pacman repository (hosted on GitHub Pages) for packages that
  aren't in the official Arch repos: `calamares`, `paru`, `ckbcomp`,
  `oblinux-icon-theme`. Built with `makepkg`, published with that repo's
  own `x86_64/update_repo.sh`. **Packages must be built and published
  there before a `mkarchiso` build that references them** — `pacstrap`
  will fail to resolve them otherwise. This is a genuinely separate step
  no Arch-implementation repo can trigger itself.
- **[`oblinux-icon-theme`](https://github.com/marcoobaid/oblinux-icon-theme)**
  — the amber-recolored Papirus-derivative icon theme, packaged and
  published through `oblinux_repo` the same way.

Do not invent other repositories beyond the ones named above. As of the
most recent workspace inspection, `oblinux-brand-master` did not yet
exist in the local workspace and `oblinux-arch-iso-dev` had not yet
diverged from this repository's baseline — treat any Brand Master
consumption or dev-to-stable promotion as forward-looking, not yet
performed, unless the current `git log`/`git status` shows otherwise.

## This repository's role

`oblinux-arch-iso` **is** the archiso profile: everything that becomes the
live ISO and, by extension (via Calamares' `unpackfs`), the installed
system. It owns package selection, live-environment configuration,
GNOME/GDM defaults, boot theming (Plymouth/GRUB/syslinux), and the
Calamares installer configuration — for the **stable, owner-approved**
state of all of these. Day-to-day iteration on any of them belongs in
`oblinux-arch-iso-dev`, not here.

## Stable repository safety

Default behavior in this repository is: **inspect, understand, validate,
preserve.** This is not the normal development workspace. Unless the
owner explicitly instructs otherwise for a specific task, do not:

- integrate experimental changes or independently implement R5 changes
- consume unreleased Brand Master changes (Brand Master `main`/unreleased
  commits are not a production dependency — see Brand Master)
- merge from, cherry-pick from, or otherwise synchronize dev into this
  repository
- perform speculative cleanup or unrelated refactoring
- rewrite published git history
- create releases or tags (see Release and tagging policy)
- promote development changes on the assumption that a successful dev
  build implies approval (see Promotion policy)

## Promotion policy

Changes reach this repository only by flowing:

```
oblinux-arch-iso-dev → test/validation → owner approval → oblinux-arch-iso
```

Promotion into stable is always a separate, explicitly owner-authorized
task — never assume it because a dev build or dev validation succeeded.
Before a promotion, the change should normally have:

1. successful static/source validation
2. a successful ISO build
3. runtime/VM testing where applicable
4. manual/visual validation where applicable
5. explicit owner approval

See Validation integrity for the rules on reporting these truthfully.

## Force-push policy

**Do not force-push `oblinux-arch-iso`** unless the owner explicitly
authorizes it for a specific, named recovery situation. The force-push
used during this repository's initial migration from legacy `oblinux` was
a one-time action to replace a GitHub-generated placeholder commit — it
is not standing repository policy, and it does not imply force-push is
routine or acceptable going forward. Published stable history should be
preserved; do not rewrite it otherwise.

## Release and tagging policy

A release tag is always the **final** step of the release process, never
a routine or intermediate development action.

- Never create, move, delete, or push a release tag as part of normal
  development work.
- Required release sequence: **Change → Validate → Commit → Push `main`
  → CI passes → Tag.**
- Before a release can be tagged, all of the following must hold: all
  intended changes are committed; the working tree is clean; release/
  package metadata is internally consistent; repository validation
  passes; the changes are pushed to `main`; and CI on that final `main`
  commit passes.
- Once every condition above is met, stop and report the repository
  **"release-ready"** — do not create or push the tag yourself. Tagging
  requires the owner's explicit authorization, given after that report.
- Never tag an intermediate release-preparation commit while further
  validation, metadata, packaging, or corrective commits are still
  needed — "release-ready" means nothing further is expected to change.
- If a tag has already been published and a problem is discovered
  afterward, do not move, delete, or replace it automatically — stop
  and ask the owner how to proceed.

## Validation integrity

Never fabricate build, validation, runtime, VM, or visual test results.
If a test cannot actually be performed from this environment, say so
plainly rather than implying it happened. Distinguish clearly between:

- **static/source validation** — config/syntax review, no build performed
- **a successful ISO build** — `mkarchiso` completed, produced an image
- **automated VM/runtime validation** — an actual boot/install cycle was
  run and its result observed (see Testing and validation)
- **manual owner visual/runtime validation** — the owner personally
  confirmed a result (screenshot, direct inspection, a real boot)

Do not declare something production-ready, working, or safe to promote
based solely on configuration files existing in git — that is, at most,
static/source validation. This repository's own development environment
(macOS) cannot run `mkarchiso` or boot the result; see ISO build process.

## Legacy `oblinux` repository

`oblinux` is the legacy Arch repository this repository and
`oblinux-arch-iso-dev` were both populated from (shared baseline commit
`c65f5e2b861f761e8084fe46da065fe2296c695d` as of this repository's
initialization). It is now **reference-only**:

- do not push to it
- do not use it as an active development target
- do not rewrite it, or change its branches or tags
- do not treat it as, or promote it to, the new stable repository

It may be inspected when historical implementation context is genuinely
needed — most of the technical knowledge in this file originated there
and remains valid for the Arch implementation generally. Its eventual
retirement or deletion is a separate owner-controlled decision, not
something to act on unilaterally.

## Brand Master

Shared OBLinux visual identity (the master logo/wordmark, brand colors,
shared icons, shared wallpapers, and the shared standards behind GRUB,
Plymouth, and Calamares branding) belongs to `oblinux-brand-master`, not
to this repository. In this repository:

- do not independently redesign or maintain a competing version of
  shared OBLinux branding — see Branding for what this repo currently
  ships, which predates the Brand Master split and should be treated as
  the thing Brand Master output eventually replaces, not a parallel
  source of truth
- treat released/versioned Brand Master output as an immutable
  dependency once consumed
- Brand Master's `main` branch (or any unreleased commit) is not a
  production dependency and should not be pulled into this repository
  directly
- new Brand Master releases normally reach this repository only after
  being integrated and validated in `oblinux-arch-iso-dev` first — never
  as a direct stable-repo change

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
                          airootfs/. Pending Brand Master adoption, this
                          is still this repo's own source of truth for
                          branding (see Brand Master above).
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
build machine, driven by the owner. An agent working here should assume
it **cannot** run a real build/boot/install cycle itself and must ask for
that verification rather than claim it (see Validation integrity).

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
In this stable repository, package-list changes normally arrive already
validated from `oblinux-arch-iso-dev` (see Promotion policy) rather than
being authored here directly.

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
`#f2f3f5`. This is this repository's **current, shipped** branding — the
state Brand Master output is expected to eventually supersede (see Brand
Master above); until a Brand Master release is actually integrated and
promoted, this section remains authoritative for what's on the image.

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
VirtualBox/hardware by the owner, since this repo's own development
environment (macOS) cannot run `mkarchiso` or boot the result. See
Validation integrity for how to report validation status honestly.

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
- **Development and integration happen in `oblinux-arch-iso-dev`, not
  here** — this repository only receives owner-approved, validated
  changes (see Stable repository safety and Promotion policy).
- **Shared branding is owned by `oblinux-brand-master`, not forked or
  redesigned here** — see Brand Master.
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
systemd units, or Calamares config in this repo. Once `oblinux-brand-master`
releases are actually integrated (via dev, then promoted here — see Brand
Master), the `docs/branding/` sources listed above are expected to
themselves become generated from Brand Master output; that has not
happened yet as of this update.

## Development rules

- **This is the stable repository — default to inspect, understand,
  validate, preserve** (see Stable repository safety). Confirm a task is
  actually meant for this repository, not `oblinux-arch-iso-dev`, before
  making non-trivial changes.
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
  history trace back to an unverified assumption. The same standard
  applies to reporting validation status — see Validation integrity.
- Never commit credentials or secrets. The `oblinux_repo` signing
  private key lives only on the build machine's own GnuPG keyring —
  never in this or any other OBLinux repository.
- **Never attribute an AI tool as author/contributor anywhere** — no
  `Co-Authored-By` trailers, no listing in `AUTHORS`/`README`/`PKGBUILD`
  files, in this repository or any other OBLinux repository (dev,
  legacy `oblinux`, `oblinux_repo`, `oblinux-icon-theme`,
  `oblinux-brand-master`). Verified: zero such trailers exist in this
  repo's git history: keep it that way.
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
  macOS (see Validation integrity).
- Do not force-push, create releases/tags, or rewrite history in this
  repository without explicit owner authorization (see Force-push
  policy, Release and tagging policy, and Stable repository safety).

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

1. Read this file, including Repository architecture and Stable
   repository safety — confirm the requested task actually belongs in
   this repository rather than `oblinux-arch-iso-dev`.
2. Check `git log`/`git status` for recent, possibly-uncommitted context.
3. Read the `docs/` file(s) relevant to the requested task (see
   Documentation Map) — don't rely on this file's summaries for
   subsystem detail.
4. Inspect the actual current implementation (config files, not just
   docs) — docs can lag behind a fast-moving repo like this one.
5. Determine ownership: does this change belong in this repository at
   all, or in `oblinux-arch-iso-dev`, `oblinux-brand-master`,
   `oblinux_repo`, or `oblinux-icon-theme`? Most non-trivial changes
   belong in dev, not here — see Promotion policy.
6. Make the smallest complete change; match the existing style/comment
   density in the file being edited.
7. State plainly what validation would confirm the change works, and
   whether that validation actually happened (see Validation integrity)
   — this repo can't self-verify builds/boots — say so rather than
   implying it did.
8. Update the relevant `docs/` file(s) when the change is
   architecturally meaningful (see Maintaining This File for the bar).
9. Summarize what changed and what still needs verification.

## Maintaining this file

Update `AGENTS.md` when a change materially affects: repository
responsibilities or architecture, the promotion/approval model, the
high-level build/boot/install architecture, important file paths,
package-sourcing strategy, GNOME configuration strategy, Calamares
module sequence/architecture, testing expectations, or a development
rule/lesson future agents need to not repeat. Don't update it for
routine implementation details already obvious from the code, and don't
let it grow into a second `TESTING.md` or `THEMING.md` — point to those
instead of duplicating them. Remove or correct sections that become
obsolete rather than leaving stale information alongside new
information.

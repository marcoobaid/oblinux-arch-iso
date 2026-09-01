# OBLinux Branding

## Brand Master Calamares integration (Phase 2B: 2026-08-31)

Calamares now consumes the Brand Master R5 installer theme, matching the
known-good Debian OBLinux implementation wherever the two Calamares builds
share a branding mechanism. The complete shared payload lives under
`airootfs/etc/calamares/branding/oblinux/`: the R5 symbol and horizontal
lockups, responsive Welcome artwork, seven SVG slideshow panels, completion
panel, QML presentation, and navy/white/orange widget-sidebar palette.

The shared artwork and QML are byte-for-byte copies of Brand Master's current
`themes/calamares/oblinux/` payload. Only `branding.desc` is activated
downstream: `welcomeExpandingLogo` is enabled to keep the horizontal lockup
proportional and uncropped; release labels resolve to the distribution-neutral
`OBLinux` name; optional project URLs are empty because the Welcome module does
not expose those links and no non-legacy public project URL is configured.
The Arch installer keeps its existing `/etc/calamares` location, module
configuration, settings sequence, package handling, and installation behavior.

This replaces the legacy 256 px mark, 1050×700 geometry, Slate/Amber sidebar,
and locally authored five-slide presentation. Those retired files
(`logo.png` and `show.qml`) are no longer present or referenced. Static source
validation can establish correct payload wiring, but runtime visual parity
still requires an ISO build and an installer walkthrough on the Linux test
machine.

## Brand Master GDM and lock-screen integration (Phase 2A: 2026-08-31)

GDM and the GNOME session lock screen now consume the released OBLinux Brand
Master R5 identity. The integration uses assets verified byte-for-byte against
the released sources named below; it does not modify or regenerate the masters.

| Surface | File(s) in this repo | Brand Master source / mechanism |
|---|---|---|
| GDM background | `airootfs/etc/dconf/profile/gdm`, `airootfs/etc/dconf/db/gdm.d/01-oblinux-background` | GDM-only, image-free vertical gradient using Brand Master's near black `#0B1118` and derived navy `#0D2742`; the maintainable dconf mechanism matches the accepted Debian implementation |
| GDM product mark | `airootfs/usr/share/pixmaps/oblinux-gdm-logo.png`, selected by `airootfs/usr/share/glib-2.0/schemas/50_oblinux-gdm.gschema.override` | byte-for-byte copy of Brand Master v1.0.5 `assets/icons/hicolor/64x64/apps/oblinux-logo.png`, matching Debian's selected 64 px GDM vendor mark |
| GNOME lock screen | `airootfs/usr/share/backgrounds/oblinux/oblinux-dark-3840x2160.png`, selected by the same schema override under `org.gnome.desktop.screensaver` | byte-for-byte copy of Brand Master v1.0.5 `brand/wallpapers/3840x2160/oblinux-dark-3840x2160.png` |

The GDM profile applies only to the `gdm` service account. In addition to the
background, it restores the greeter's upstream blue accent so focus treatment
matches the accepted Debian implementation while user sessions remain orange.
The screensaver key
is an unlocked system default for every normal GNOME account, including the
live session and accounts created by Calamares; users can change it normally.
No file is seeded into `liveuser` or `/etc/skel`, and the existing desktop
wallpaper remains unchanged. Because Calamares installs the live squashfs with
`unpackfs` and does not remove these system-wide files, the same configuration
persists on the installed system.

This phase deliberately does not patch GNOME Shell's package-owned gresource or
apply a custom GDM Shell theme. Authentication, accessibility, account avatars,
and lock/unlock behavior remain owned by upstream GDM/GNOME.

The Slate & Amber material below documents the legacy/downstream design that
still applies to surfaces not yet migrated to Brand Master.

## Palette

| Name        | Hex       | Role |
|-------------|-----------|------|
| Ink         | `#151a22` | Darkest background / near-black surfaces (terminal body, deepest shadows) |
| Slate       | `#2c3a4e` | Secondary background / chrome (window titlebars, panels, sidebars) |
| Primary     | `#3f6690` | Leading brand color — logo, links, selection, focus states |
| Slate Light | `#a9b8c8` | Muted foreground — secondary text, inactive icons, borders |
| Amber       | `#d68a3c` | Accent — reserved for actions and alerts only, never decorative |
| Cloud       | `#f2f3f5` | Lightest foreground / light-mode background |

**Usage principle** (per the design system this came from): it's a cool blue-grey
system with a warm amber accent. **Blue (Primary) leads** — it's the brand color
everywhere. **Amber is reserved** for things that need to grab attention: primary
action buttons, alerts, progress/active states. Don't use amber decoratively (e.g.
as a general highlight color) or it stops meaning anything.

## Semantic mapping (proposed)

| Semantic role       | Color         | Where it shows up |
|----------------------|---------------|--------------------|
| Background (dark)     | Ink `#151a22`         | Boot splash, Plymouth, terminal background |
| Surface / chrome       | Slate `#2c3a4e`       | GDM panel, boot menu box, window titlebars |
| Brand / accent (leading) | Primary `#3f6690`  | Logo, boot menu selection, links, focus rings |
| Muted text/borders     | Slate Light `#a9b8c8` | Secondary text, dividers, inactive UI |
| Action / alert         | Amber `#d68a3c`       | Install button, warnings, active progress indicator |
| Light background/text  | Cloud `#f2f3f5`       | Light-mode surfaces, text on dark backgrounds |

**Decision: dark boot-to-login experience** (Ink/Slate dominant, matches the terminal
mockup) — the more common choice for boot splashes/login screens, and a good fit for
this palette.

## Logo mark — locked

The OBLinux mark: a ring left deliberately open, with an amber spark escaping
the gap. Primary blue ring, amber spark, no wordmark baked in (typography for
a "OBLinux"/"Linux" lockup is a separate decision, needed for the boot splash).

Source files:
- [`oblinux-mark.svg`](branding/oblinux-mark.svg) — full color (Primary ring,
  Amber spark), for dark surfaces (Ink/Slate)
- [`oblinux-mark-symbolic.svg`](branding/oblinux-mark-symbolic.svg) —
  single-color (`currentColor`), for GNOME symbolic icon contexts (top bar,
  notifications) where the shell recolors the icon itself

Both are 200×200 viewBox, ring centered with even margins, so they scale
cleanly from favicon size up to a boot-splash centerpiece.

## Asset checklist (boot → login, phase 1 scope)

| Asset | Path in repo | Format | Status |
|---|---|---|---|
| Logo mark | `docs/branding/oblinux-mark*.svg` | SVG source | **Done** — see above |
| BIOS boot menu background | `syslinux/splash.png` | PNG, 640×480 | **Superseded by Brand Master** — see "Brand Master boot-chain integration" below |
| UEFI boot menu | `grub/grub.cfg` + `grub/themes/oblinux/` | GRUB config + Brand Master theme payload | **Done** — live UEFI uses GRUB with the Brand Master theme; see "Brand Master boot-chain integration" below |
| Plymouth boot theme | `airootfs/usr/share/plymouth/themes/oblinux/` + `plymouth` package | `.plymouth` + `.script` + PNGs | **Superseded by Brand Master** — see "Brand Master boot-chain integration" below |
| GDM logo + background | `airootfs/usr/share/glib-2.0/schemas/50_oblinux-gdm.gschema.override` | GSettings override + SVG | **Superseded by Brand Master Phase 2A** — see above |
| OS logo (About panel, `LOGO=oblinux-logo` in os-release) | `airootfs/usr/share/pixmaps/oblinux-logo.{svg,png}` | SVG + PNG, plain mark | **Done** — see below |

## Brand Master boot-chain integration (Phase 1: 2026-08-30)

BIOS boot, UEFI boot, GRUB, and Plymouth now source their visual assets from
`oblinux-brand-master` (tagged release `v1.0.5`), replacing this repo's
original Slate & Amber boot artwork. The desktop and os-release remain on the
legacy identity described below. GDM and the GNOME lock screen were integrated
separately in Phase 2A, and Calamares in Phase 2B; Brand Master integration is
not assumed to extend to the remaining surfaces.

| Boot stage | File(s) in this repo | Brand Master source |
|---|---|---|
| BIOS boot menu (syslinux) | `syslinux/splash.png` | rasterized from `assets/iso/oblinux-media-lockup.svg`, composited onto Brand Master's near-black (`#0b1118`); Brand Master ships no pre-rendered syslinux-resolution asset, so this one raster/composite step is downstream integration, not a redesign of the master artwork |
| UEFI boot menu (GRUB) | `grub/grub.cfg` + `grub/themes/oblinux/` | theme payload copied verbatim from Brand Master's `themes/grub/oblinux/`; `grub.cfg` selects it from the live GRUB prefix and preserves the established OBLinux live boot parameters |
| GRUB (installed-system theme, wired via Calamares `airootfs/etc/calamares/modules/grubcfg.conf`) | `airootfs/usr/share/grub/themes/oblinux/` | copied verbatim from Brand Master's `themes/grub/oblinux/` (`theme.txt`, `background.png`, `logo.png`) |
| Plymouth | `airootfs/usr/share/plymouth/themes/oblinux/` | copied verbatim from Brand Master's `themes/plymouth/oblinux/` (`.plymouth`, `.script`, PNGs, and their SVG sources) |

Brand Master's GRUB theme uses a flat `selected_item_color` instead of the
old 9-slice `pixmap_style` highlight images, so the old `highlight_*.png`
files were removed as no longer referenced by `theme.txt`. The Calamares
wiring itself (`always_use_defaults: true`, `GRUB_TERMINAL_OUTPUT: gfxterm`,
`GRUB_THEME` pointing at this same path) did not need to change — only the
theme payload at that path did.

Treat every file copied from Brand Master exactly like any other Brand
Master payload (see `AGENTS.md`'s Pipeline role and governance): never
hand-edit it, never re-derive it from a screenshot or approximation, and
never regenerate it independently in this repo. A defect in the shared
asset itself belongs upstream in `oblinux-brand-master` and is re-consumed
here as a new released version.

## GDM login screen

**Historical implementation, superseded by Phase 2A above.** The mechanism
research remains relevant, but the legacy lockup and Ink-to-Slate values no
longer ship.

Not the mechanism originally assumed (a blurred desktop-background image) — a
reference screenshot of Ubuntu's login screen pointed at the right mechanism: GDM's `org.gnome.login-screen`
schema has a dedicated `logo` key ("small image ... to display branding"),
rendered crisp (not blurred) in its own slot, separate from the desktop
background. Verified against Arch's own `gdm` PKGBUILD, which sets this same
key for the default Arch logo via a GSettings **schema override** file at
`/usr/share/glib-2.0/schemas/30_org.archlinux.gdm.gschema.override` — not a
dconf database at all. `glib2` already ships the pacman hook
(`glib-compile-schemas.hook`) that recompiles the schema cache whenever any
`*.gschema.override` file changes, so no custom build hook is needed; the
OBLinux override just has to sort after Arch's (`50_` vs `30_`) to win.

Legacy assets/wiring (removed or superseded in Phase 2A):
- [`oblinux-lockup.svg`](branding/oblinux-lockup.svg) — the ring (vector) +
  "OBLinux" wordmark (embedded as the same `oblinux-wordmark.png` used by the
  boot splash/Plymouth, as a base64 raster `<image>`) side by side. The
  wordmark had to be raster, not SVG `<text>`: this file is rendered live by
  GDM on the built system, and Space Grotesk isn't installed there (not in
  official Arch repos) — unlike the boot splash/Plymouth PNGs, which are
  pre-rasterized during this design session and ship as plain pixels with no
  font dependency at all.
- Was copied to `airootfs/usr/share/pixmaps/oblinux-logo-text-dark.svg` — named
  to match Arch's own `archlinux-logo-text-dark.svg` (see the os-release
  section below for why this couldn't just be `oblinux-logo.svg`).
- The schema override set `org.gnome.login-screen`'s `logo` to that path and
  separately set
  `org.gnome.desktop.background` to solid Ink (`primary-color='#151a22'`,
  `picture-options='none'`) so the login (and default post-install desktop)
  background matches Plymouth/the boot splash instead of GNOME's default
  wallpaper. Note this changes the *system-wide* default background, not
  just GDM's — real user accounts default to solid Ink until they set their
  own wallpaper, same as how most distros ship a default wallpaper.

## os-release LOGO (About panel)

`airootfs/etc/os-release` has set `LOGO=oblinux-logo` since the very first
scaffold commit, but no file with that name existed until now — GNOME
Settings' About panel (and anything else reading `LOGO=`, which the
os-release spec defines as a freedesktop icon-theme name) fell back to a
generic icon.

Checked how Arch itself ships this (`filesystem` package's PKGBUILD) rather
than assume: it installs plain, wordmark-free logo files straight into
`/usr/share/pixmaps/` — **not** the hicolor icon-theme directory tree
originally planned — as `archlinux-logo.{svg,png}`, and its own `os-release`
sets `LOGO=archlinux-logo` to match. `/usr/share/pixmaps/` is itself part of
the freedesktop icon lookup spec (an unthemed fallback location every
icon-consuming app checks), so this needs no icon-cache rebuild at all,
unlike the hicolor route. Arch keeps this plain-mark file separate from its
GDM lockup (`archlinux-logo-text-dark.svg`, mark+wordmark) — the same separation
is retained after Phase 2A:

- `airootfs/usr/share/pixmaps/oblinux-logo.svg` / `.png` (256×256) — plain
  mark only, copied straight from `docs/branding/oblinux-mark.svg`, matching
  `LOGO=oblinux-logo` exactly.
- `airootfs/usr/share/pixmaps/oblinux-gdm-logo.png` — the Brand Master R5
  64 px full-color symbol, used only by GDM's `logo` key (see above).

The dedicated GDM raster therefore remains distinct from `oblinux-logo.svg`,
which is reserved for the legacy plain-mark `os-release` identity.

## Plymouth theme

`airootfs/usr/share/plymouth/themes/oblinux/` — same composition as the boot
splash (ring + wordmark on Ink), but animated: the amber spark orbits the
ring continuously as a boot-activity indicator, instead of a generic
throbber. Three transparent PNGs (`oblinux-ring.png`, `oblinux-spark.png`,
`oblinux-wordmark.png`, all sourced with the same canvas pipeline as the
boot splash) plus `oblinux.script` (Plymouth's scripting language —
verified against upstream's own `themes/script` example rather than
guessed, since the API is defined upstream, not within project control) drive the animation.

Wiring: `plymouth` package added; `/etc/plymouth/plymouthd.conf` sets
`Theme=oblinux` (equivalent to running `plymouth-set-default-theme`, done as
a static file since there's no build-time command-execution step anymore);
`plymouth` hook added to `mkinitcpio.conf.d/archiso.conf` (placed after
`kms`, per upstream's placement guidance); `quiet splash` added to the two
main boot entries (BIOS + UEFI) — deliberately **not** added to the
accessibility/speech boot entry, so screen-reader users still get console
text.

## Boot splash typography

`syslinux/splash.png` uses **Space Grotesk** (700 weight for "OB", 500 for
"Linux") — a geometric sans common in current tech/dev-tool branding, chosen
to match the "modern, trendy" brief. Since the wordmark is baked into a
static PNG at build-design time (not rendered on the built system), the font
doesn't need to be installed on the ISO — only the pixels ship. Same font
choice should carry over to the Plymouth theme and GDM background for
consistency.

Rendering method (for reuse on the next assets): an HTML page draws the mark
+ wordmark, served locally, then an in-page `<canvas>` (fixed pixel
dimensions, unaffected by browser zoom/DPR) rasterizes it and POSTs the PNG
bytes to a small local save endpoint — gives pixel-exact output without
needing ImageMagick/cairosvg/etc. installed on this machine.

**Layout revision (2026-08-06)**: the original composition (mark centered
around y=115–280, wordmark below it down to y≈345) visually clashed with
vesamenu's menu box, which — per `syslinux`'s own docs — renders starting
around `MENU VSHIFT 10` (≈ row 10 of 28, ~y=171px), a value inherited
unchanged from upstream's `archiso_head.cfg`. The lower half of the original
composition sat inside the box's territory. Re-rendered smaller (80px icon,
26px wordmark) and anchored to the top of the frame (y=12–137) so the whole
thing sits entirely above y=171, clear of the box, instead of overlapping
it. `MENU VSHIFT`/`ROWS`/row-position directives themselves were left
untouched — adjusting the artwork to fit the existing, already-tuned box
layout was the lower-risk fix.

## GRUB boot menu (installed system)

Phase 2 polish, not phase 1 scope — the live ISO's own boot menu
(`syslinux/splash.png`, above) was already branded; this is the
*installed* system's GRUB menu, which stayed the plain default text menu
through every Calamares round up to and including round 13.

First root cause identified: `grubcfg.conf` was explicitly setting
`GRUB_TERMINAL_OUTPUT: "console"`. That one setting alone means no
graphical theme can ever render, regardless of `GRUB_THEME` — GRUB
requires `gfxterm` output for any graphics at all. Fixed alongside adding
the theme itself: `GRUB_TERMINAL_OUTPUT` → `"gfxterm"`,
`GRUB_GFXMODE: "auto"`, `GRUB_GFXPAYLOAD_LINUX: "keep"` (avoids a
mode-switch flicker between GRUB and Plymouth, which already expects a
graphical framebuffer), `GRUB_THEME` pointing at the new theme file —
all set inside `grubcfg.conf`'s `defaults:` block.

**This alone wasn't enough — a second, bigger bug was hiding underneath
it**, only found after round 14's failed test by reading real target
system files (`/etc/default/grub`, `/boot/grub/grub.cfg`) rather than
just re-reading `theme.txt` again. Those files showed `GRUB_THEME` and
`GRUB_TERMINAL_OUTPUT` still sitting at their untouched stock values —
the `defaults:` block was never being written *at all*. Tracing this
through Calamares' `grubcfg/main.py` (pulled fully verbatim this time,
not summarized — an earlier read of the same file had missed this exact
detail) found the real mechanism:

```python
always_use_defaults = ...configuration.get("always_use_defaults", False)
if always_use_defaults or overwrite or not os.path.exists(default_grub):
    if "defaults" in ...configuration:
        for key, value in ...configuration["defaults"].items():
            grub_config_items[key] = ...
```

The entire `defaults:` block is only ever applied if `always_use_defaults`,
`overwrite`, or "the file doesn't exist yet" is true. `grubcfg.conf` had
`overwrite: false` and never set `always_use_defaults` at all (defaults
to `false`), and `/etc/default/grub` already exists (shipped by the
`grub` package) — so none of the three conditions were ever true, and
`defaults:` — all 8 keys in it, not just the GRUB_THEME-related ones —
was silently skipped in full, every single round. `GRUB_GFXMODE`/
`GRUB_GFXPAYLOAD_LINUX` only ever *looked* like they were working
because they happen to already be Arch's own stock values, unrelated to
our config entirely. Fixed with one line: `always_use_defaults: true`.

Assets: `airootfs/usr/share/grub/themes/oblinux/` — matches Arch's own
`grub` package convention of installing its bundled `starfield` theme at
`/usr/share/grub/themes/starfield/`, not under `/boot`.

- `background.png` (1920×1080) — the combined ring+spark mark
  (`airootfs/usr/share/pixmaps/oblinux-logo.png`, *not* Plymouth's
  ring-only asset, which exists only because Plymouth animates the spark
  separately) plus the wordmark, on solid Ink — same visual language as
  the boot splash/Plymouth, composited with Pillow rather than the
  HTML/canvas pipeline (no text/font rendering needed this time, just
  compositing already-rendered PNGs).
- `highlight_*.png` — a 9-piece sliced box image (GRUB's `pixmap_style`
  requires this exact slicing; a single plain image isn't supported,
  verified against GRUB's own theme-format reference). Flat Primary,
  fully solid, no border art — generated programmatically (draw one
  rounded-rect tile, crop into corners/edges/center) rather than
  hand-drawn, since the design itself is flat color, not decorative.
- `theme.txt` — no custom font referenced anywhere (`item_font`,
  `title-font`, etc. all left unset); GRUB falls back to its own already-
  loaded bundled font, same "no font dependency" approach as the boot
  splash/Plymouth PNGs. Verified structure against GRUB's own bundled
  `starfield` theme, not written from a remembered template.

Palette mapping used matches `docs/BRANDING.md`'s own semantic table,
written back in phase 1 before any of this existed: Primary for the
selection highlight ("boot menu selection" is literally Primary's
documented role above), Cloud for item text.

**Round 14 failed to render at all** (plain default GRUB menu, no error
— GRUB themes fail closed). `grub-install`/`grub-mkconfig` both ran
clean in `session.log`, so config-writing *looked* fine from the install
log alone — it wasn't; see `always_use_defaults` above, found only after
inspecting the actual installed target's files.

Two fixes went in together for the next round: the `always_use_defaults`
fix above (the real cause), and a `theme.txt` cleanup done in parallel
by self-audit rather than proof — `icon_width`/`icon_height: 0` (an
attempt to disable icons, never actually verified 0 is a valid value)
and `menu_pixmap_style` (a whole-menu frame, `panel_*.png`, on top of
the already-used `selected_item_pixmap_style`) were both only ever
schema-verified, not confirmed working. Checked a real, actively
maintained community theme
([rose-pine/grub](https://github.com/rose-pine/grub)): it doesn't zero
out icon dimensions, and doesn't use `menu_pixmap_style` at all — only
`desktop-image` + `selected_item_pixmap_style`. Trimmed to match
(`panel_*.png` deleted, no longer referenced) — this turned out not to
be the round 14 bug, but it's a legitimate reduction in unverified
surface area worth keeping regardless.

**Round 15 confirmed working**: mark + wordmark render correctly on the
Ink background, and the Primary highlight bar shows clearly on the
selected menu entry — screenshot evidence, `docs/TESTING.md`. The
installed-system GRUB theme is done.

**Post-menu gfxterm handoff fix (2026-08-30)**: suppressing Arch GRUB's
hardcoded `Loading Linux ...` / `Loading initial ramdisk ...` messages did
not remove the large black rectangle visible between the graphical menu and
Plymouth. BIOS and UEFI screenshots showed that the Brand Master desktop
remained intact around a sharply bounded black region: GRUB had closed
`gfxmenu` and cleared the now-visible `gfxterm` viewport to its default black
background. `GRUB_GFXPAYLOAD_LINUX=keep` preserves the graphics *mode* passed
to Linux; it does not preserve the theme's pixels, and Plymouth cannot draw
until its initramfs hook starts.

The installed system now records the shipped Brand Master image as
`GRUB_BACKGROUND` and ships an executable
`/etc/grub.d/09_oblinux_gfxterm_background` generator fragment. It runs after
`00_header` and before `10_linux`, emitting exactly:

```grub
insmod png
background_image -m stretch /usr/share/grub/themes/oblinux/background.png
```

The explicit fragment is necessary because upstream `00_header` treats
`GRUB_THEME` and `GRUB_BACKGROUND` as alternatives; setting both defaults
alone does not guarantee that the terminal background command appears in the
generated `/boot/grub/grub.cfg`. This keeps the authoritative theme background
behind the terminal viewport without altering Brand Master assets, the selected
graphics mode, `gfxpayload=keep`, kernel parameters, or the mkinitcpio/Plymouth
hook order. Both installed BIOS and UEFI paths use this same generated GRUB
configuration. The live ISO remains separate: BIOS uses syslinux and UEFI uses
the hand-authored `grub/grub.cfg`, so neither live path executes this fragment.

**Live UEFI GRUB integration (2026-08-31)**: the ArchISO boot mode is
`uefi.grub`, replacing `uefi.systemd-boot`. ArchISO consumes
`grub/grub.cfg`; that configuration enables `gfxterm` and selects
`/boot/grub/themes/oblinux/theme.txt` from the ISO filesystem. ArchISO's
standalone EFI binary keeps `${prefix}` on its embedded memdisk while its
bootstrap sets GRUB's `root` to the discovered ISO before loading the profile
configuration; using `${prefix}` for the theme therefore searches the embedded
binary instead of the ISO and fails. The complete theme directory is a
verbatim copy of the same released Brand Master `v1.0.5` payload used at
`airootfs/usr/share/grub/themes/oblinux/` for installed systems. Keeping the
live copy under `grub/` is required because the boot loader must render the
menu before the live squashfs under `airootfs/` is mounted. The live entries
retain `archisobasedir`, `archisosearchuuid`, `cow_spacesize=75%`, and
`copytoram=n`; the normal entry also retains `quiet splash`, while the speech
entry retains `accessibility=on`. The existing `efiboot/loader/` files remain
as inactive systemd-boot reference configuration and are not consumed by the
selected boot modes. The upstream profile's optional COM0 serial initialization
is omitted: probing a nonexistent COM0 emits a GRUB error and pauses startup on
UEFI systems without a serial port, while OBLinux's live menu uses the native
console and `gfxterm` graphical output.

## Next steps

1. ~~Logo/wordmark~~ — done, see above.
2. ~~Boot splash~~ (`syslinux/splash.png`) — done, see above.
3. ~~Plymouth theme~~ — done, see above.
4. ~~GDM logo + background~~ — done, see above.
5. ~~os-release `LOGO` asset~~ — done, see above.
6. ~~Installed-system GRUB theme~~ — done, see above (confirmed
   rendering, round 15).

That's the full boot→login checklist (phase 1) plus its phase 2
installed-system counterpart.

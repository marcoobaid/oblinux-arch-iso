# Default application package list (updated 2026-09-01)

Phase 3/4 item 1 (see `README.md`'s Status section for the full list and
sequencing). Previously `packages.x86_64` had no curated end-user apps at
all — just the archiso `releng` boot/rescue toolset and a minimal GNOME
core (`gdm`, `gnome-shell`, `gnome-control-center`, `nautilus`, portals).
This fills that in.

Goal: GNOME should be **functional and appealing** out of the box, with
a **solid terminal**, and the user should have everything they need for
a functional system without hitting a wall on day one.

## Decisions

- **Flatpak + Flathub: yes.** `xdg-desktop-portal`/`xdg-desktop-portal-gnome`
  were already shipped (added for Calamares/GNOME sandboxing), so the
  portal prerequisite was free. `flatpak` + `gnome-software` added;
  keeps the curated base list lean while still giving users a GUI app
  store for anything not shipped by default.
- **Browser: Firefox**, shipped in the base ISO. A **Calamares installer
  option to choose the default browser at install time** is also wanted
  — not yet designed, folded into the "enrich Calamares options"
  bucket-list item (item 2), tackled after this one.
- **Office suite: LibreOffice Fresh.** `libreoffice-fresh` is the official
  Arch package for the complete current suite (Writer, Calc, Impress, Draw,
  Base, and Math). It uses the GTK stack already present on this GNOME image;
  no duplicate office suite or Java runtime is added. The package itself is
  approximately 148 MB compressed / 423 MB installed as checked when selected,
  so the next ISO build must confirm the resulting image-size change.
- **Terminal: Ptyxis**, replacing `gnome-terminal`. Modern,
  GPU-accelerated, actively developed (what Fedora Workstation switched
  its own default to) — `gnome-terminal` is feature-frozen upstream.
- **Desktop feel: stock GNOME shell on installed systems.** `gnome-tweaks` is
  now included as a small, standard GNOME advanced-settings application. The
  Desktop Icons NG extension is packaged solely so the live session can show
  its installer shortcut; it is enabled only in `liveuser`'s ephemeral dconf
  state and Calamares removes its package from the installed system.
- **GNOME core apps**: calendar, calculator, characters, clocks,
  contacts, disk-utility, firmware (+ `fwupd`), online-accounts,
  software, system-monitor, text-editor, weather, plus `baobab`, `eog`,
  `evince`, `file-roller`, `sushi`, `totem`. `gnome-maps` deliberately
  left out (heavier, needs `geoclue`, least-used of the set) — easy to
  add later if wanted.
- **Shell experience**: `starship` + `zsh-autosuggestions` +
  `zsh-syntax-highlighting` on top of the already-default zsh — a modern
  out-of-the-box feel without the overhead of a full framework like
  oh-my-zsh.
- **Modern CLI tools**: `bat`, `btop`, `eza`, `fd`, `fzf`, `ripgrep`,
  `zoxide` — plus filling a real gap, `unzip`/`zip`/`p7zip`/`wget` (only
  `squashfs-tools` existed before, no general-purpose archive/download
  tools at all).
- **Codecs**: full `gst-plugins-base/good/bad/ugly` + `gst-libav`, not
  Fedora's conservative patent-conscious subset — matches the "just
  works" positioning over a cautious one.
- **Fonts**: `noto-fonts` + `noto-fonts-emoji` + `ttf-liberation`. Base
  ISO shipped zero desktop fonts before this. `noto-fonts-cjk`
  deliberately left out (large; can be added via Flatpak/AUR by users
  who need it).
- **Printing**: `cups` + `cups-pdf` provide the spooler and PDF test queue;
  `avahi` + `nss-mdns` provide mDNS resolution; `cups-browsed` discovers
  advertised remote CUPS queues and IPP printers; `ipp-usb` makes compatible
  USB devices available through the same driverless IPP path. `cups.service`,
  `avahi-daemon.service`, and `cups-browsed.service` are enabled in the live
  filesystem and explicitly enabled by Calamares for the installed system.
  `ipp-usb.service` is instead activated on demand by the package's
  `71-ipp-usb.rules` udev rule. No broad vendor-driver bundle is installed.
- **Lightweight games**: `quadrapassel` (GNOME's Tetris-style falling-block
  game, about 1.1 MB installed), `gnome-chess` plus `gnuchess` (polished GNOME
  chess UI and its optional local engine; UI about 2.8 MB), and `aisleriot`
  (GNOME's established card/patience collection, about 24.3 MB). All are in
  Arch's official `extra` repository. Quadrapassel and GNOME Chess reuse the
  GTK4/libadwaita GNOME stack already shipped; Aisleriot is older GTK3 and adds
  Guile, but gives a mature card collection at modest cost. This three-game set
  covers the requested categories without installing a bulk games group.
- **Editors**: Nano and Vim were already inherited from the releng base. Their
  system files now provide conservative OBLinux defaults: syntax highlighting,
  line numbers, four-space indentation, readable search/status feedback, and a
  restrained Slate & Amber terminal palette. Nano's shortcut keys are bold
  cyan while its function labels use the terminal's bold adaptive foreground,
  preserving contrast in both light and dark appearance modes. Nano reads
  `~/.nanorc` after `/etc/nanorc`; Vim reads `~/.vimrc` after `/etc/vimrc`, so
  users retain normal override behavior. Vim uses one local colorscheme and no
  plugins.
- **Bluetooth**: `bluez` + `bluez-utils`.
- **Firewall**: `ufw` + `gufw` over `firewalld` — simpler mental model,
  friendlier to users switching from macOS/Windows. Base packages only;
  actual ruleset/hardening is bucket-list item 5's job, not this one.

## Implemented since the initial draft

- **Flathub remote add** — wired into `shellprocess-final.conf` as a
  best-effort post-install step, same pattern as the pacman-keyring
  refresh. Verified the exact command against Flathub's own setup docs
  (`flathub.org/setup/Fedora`) rather than assumed —
  `flathub.org/setup/Arch` doesn't show a remote-add step at all (Arch's
  `flatpak` package doesn't appear to pre-configure it, unlike Fedora's),
  so this runs unconditionally with `--if-not-exists` to be safe either
  way:
  `flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo`

## Production-readiness additions (2026-09-01)

The printing service enablement, LibreOffice, GNOME Tweaks, three-game set,
Desktop Icons NG live-launcher support, and editor defaults above are statically
integrated but **not yet ISO-validated**. A new build, live boot, full install,
installed-system boot, and targeted visual/functional checks are required.

## Earlier status

**VM-confirmed 2026-08-13**: built and installed cleanly, all added
packages present and working. A real-hardware pass is deliberately
deferred to a comprehensive test sweep at the end of Phase 3/4 rather
than run per individual item.

During VM testing, a related gap surfaced: stock GNOME has no persistent
desktop dock (only the overview dash on Activities). Confirmed working:
`gnome-shell-extension-dash-to-dock` is prebuilt on **chaotic-aur**
(`1:106-1` as tested) — installs and works, needs manual enabling via
the Extensions app afterward. Not added to this package list (the
stock-GNOME decision above still holds for the base ISO) — earmarked for
the next phase (GNOME theming/tweaks) or the later Customization App, as
an opt-in.

## Not yet implemented — smaller items, not blocking

- **`gnome-software`'s Flatpak backend** — needs its exact
  package/plugin requirement on Arch confirmed at build time, not
  assumed here.
- **`eog`/`evince` vs newer replacements** — GNOME has floated newer
  image/PDF viewers (Loupe, Papers) in recent releases; defaulted to the
  established `eog`/`evince` as the safe, known-available choice rather
  than assume the newer ones are stable/available on Arch. Worth a
  quick check next time this list is revisited.
- **Vendor-specific printer drivers** — the driverless CUPS/IPP stack covers
  modern printers, but hardware requiring a manufacturer driver remains outside
  the default set until a concrete supported-device need justifies it.

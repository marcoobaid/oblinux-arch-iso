# Package signing & Chaotic-AUR

Originally introduced together on 2026-08-12, these infrastructure
features share the same mechanism: `oblinux_repo` packages are signed
(`SigLevel = Optional TrustedOnly` → `Required TrustedOnly`), and
Chaotic-AUR (`https://aur.chaotic.cx`) — community-maintained prebuilt AUR
packages — is wired in as a repo.

## The current OBLinux signing key

- **Ed25519**, generated during the September 2026 build-machine rebuild.
- Active fingerprint: `F83C29998D979B913298C40E7E0180391C821D13`
- UID: `OBLinux Repo Signing Key <repo@oblinux.local>`
- The private signing key stays in the build machine's GnuPG keyring;
  only its public key is shipped in this repository.
- The new portable private-key export and revocation certificate were
  backed up off-machine as recorded during the rotation. Private-key material and
  sensitive backup locations must never be included in Git.

### Required disaster-recovery artifacts

A **portable secret-key export is REQUIRED**, together with the matching
revocation certificate, in protected off-machine storage. A raw GnuPG
`private-keys-v1.d` file alone is not an adequate portable recovery backup:
restoration must not depend on the original machine's keybox/keygrip state.
The portable export supports recovery through GnuPG import; the revocation
certificate supports invalidating the key if necessary. Backup creation
and a controlled restoration check belong to a separate key-maintenance
procedure, never to ISO builds or ordinary documentation review.

The public key can be inspected without exporting any secret material:

```bash
gpg --show-keys --with-fingerprint airootfs/usr/share/pacman/keyrings/oblinux-repo.gpg
```

Verify the full fingerprint against the active fingerprint above before
trusting the key. Public-key material is safe to distribute; possession of
a downloaded key alone does not authenticate it.

### Previous key and September 2026 rotation

The previous Ed25519 key was generated on 2026-08-12:

- Previous fingerprint: `D0514F69650F2B9725E12E26297CB74B36C93A92`
- Previous long key ID: `297CB74B36C93A92`

Its private key became unavailable following the September 2026
build-machine rebuild, so the repository signing key was rotated to
`F83C29998D979B913298C40E7E0180391C821D13`. Earlier backup notes do not
establish that the old private key remained recoverable. These old-key
identifiers are historical only, not current operational values. Loss of
the private key does not itself revoke the public key or invalidate old
signatures; no revocation is asserted here.

The rotation was completed and pushed in `oblinux_repo` commit `75933ad`
and Dev (`oblinux-arch-iso-dev`) commit `4609674`: all four packages were re-signed,
the repository and files databases were rebuilt and signed, and the
Dev profile's public key and trusted fingerprint were replaced. The build
machine's pacman keyring was updated to trust the new key. Off-machine
backup completion is recorded from the rotation report; the documentation
review did not access backups or independently test their restoration.

## Signing packages (`oblinux_repo`)

`x86_64/update_repo.sh` now signs both layers pacman actually checks:

1. Each individual `.pkg.tar.zst` — `gpg --detach-sign`, producing a
   `.sig` file alongside it (this is what pacman fetches and checks per
   package; `repo-add -s` alone does **not** sign individual packages,
   only the database — verified against `repo-add`'s own manual, not
   assumed).
2. The repo database itself — `repo-add -s -k <KEYID> --include-sigs`.

The September 2026 rotation has already re-signed all published packages
and both databases with the current key. No package version change was
needed. `update_repo.sh` defaults to the active fingerprint above, unless
`OBLINUX_REPO_KEYID` overrides it; any intentional override must be reviewed.
The script skips an existing package signature when it is not older than
the package: it does **not** verify the signature or its signer before
skipping it. Verify signatures explicitly after publishing or rotating.

## Getting trust actually baked into the ISO

Dropping a `.gpg` file into `airootfs/usr/share/pacman/keyrings/` is *not*
enough on its own — confirmed against archiso's real `pacman-init.service`
unit, which only ever runs `pacman-key --populate archlinux`. It doesn't
scan and populate every keyring found in that directory automatically, so
without doing something more, the keys would be present on disk but never
imported into pacman's actual trust database. Three places needed
covering, matching the three moments trust actually gets used:

1. **Build time** (`mkarchiso`'s `pacstrap`) — uses the **build machine's
   own** system pacman keyring, not anything from the profile. One-time
   setup required on each build machine (already completed on the
   current machine; see below) — this is the one step this project's
   config cannot do on its own, since it's the host machine's own trust store.
2. **Live session** — a `pacman-init.service` drop-in
   (`airootfs/etc/systemd/system/pacman-init.service.d/50-oblinux-custom-keyrings.conf`)
   adds `pacman-key --populate chaotic oblinux-repo` as an extra
   `ExecStart=` (oneshot services run multiple `ExecStart=` lines in
   sequence, so this appends to the stock unit's own `--populate
   archlinux` rather than replacing it).
3. **Installed system** — `pacman-init.service` is masked post-install
   (it's live-only, see `shellprocess-final.conf`'s existing reasoning),
   so nothing from step 2 applies there. `shellprocess-final.conf`'s
   post-install keyring-refresh step (added when the archlinux-keyring
   trust bug was fixed — see `docs/TESTING.md`) now also populates
   `chaotic` and `oblinux-repo`.

### One-time setup for a new or rebuilt build machine

`pacstrap` verifies signatures against the **build machine's own**
`/etc/pacman.d/gnupg`, regardless of what's in the profile — the profile's
keyring files only ever affect the *built image*, never the machine doing
the building. The current build machine is already configured. On a new
build machine, authenticate the public key and its full fingerprint first, then use sudo:

```bash
sudo pacman-key --add /path/to/oblinux-repo.gpg
sudo pacman-key --lsign-key F83C29998D979B913298C40E7E0180391C821D13
```

(`oblinux-repo.gpg` is the same public key file now at
`airootfs/usr/share/pacman/keyrings/oblinux-repo.gpg` in this repo.)

Chaotic-AUR isn't in `packages.x86_64` yet, so this isn't required for a
build to succeed today — only needed on the build machine if/when it's
actually used there (e.g. testing a `paru -S chaotic-aur/...` pull, or
once a default-app-list package is sourced from it):

```bash
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
```

## Chaotic-AUR — verified against the real thing, not reconstructed

`airootfs/usr/share/pacman/keyrings/chaotic.{gpg,-trusted,-revoked}` and
`airootfs/etc/pacman.d/chaotic-mirrorlist` are extracted **verbatim** from
Chaotic's own `chaotic-keyring` and `chaotic-mirrorlist` packages
(downloaded from `cdn-mirror.chaotic.cx`, unpacked directly), not
hand-written from the setup instructions on
[aur.chaotic.cx/docs](https://aur.chaotic.cx/docs). Their own `.INSTALL`
script confirms the populate mechanism: `pacman-key --populate chaotic` —
matching the keyring name (`chaotic`, not `chaotic-aur`) used in the
`pacman-init.service` drop-in and `shellprocess-final.conf` above.

`chaotic-trusted` contents (trust level `4`, "full" — matches how a
distributed repo signing key should be trusted, not `6`/"ultimate", which
would only make sense on a machine that actually holds the private key):

```
EF925EA60F33D0CB85C44AD13056513887B78AEB:4:
67BF8CA6DA181643C9723B4ED6C9442437365605:4:
```

`pacman.conf` (both the build-time root file and
`airootfs/etc/pacman.conf`) got a `[chaotic-aur]` section pointing at the
shipped mirrorlist — same `Include =` line Chaotic's own docs recommend,
just backed by a file already on disk instead of a separate package
install. Not yet added to `packages.x86_64` — that's a curated-app-list
decision for later, this just makes the repo available and trusted.

## Historical validation: August 2026

Both prerequisites are done as of 2026-08-12: `oblinux_repo`'s three
packages were re-signed and republished via `update_repo.sh`
(`calamares-3.4.2-2-x86_64.pkg.tar.zst.sig`,
`ckbcomp-1.248-1-any.pkg.tar.zst.sig`, `paru-2.1.0-2-x86_64.pkg.tar.zst.sig`,
plus the signed database — commit `85a2258`), and the build machine's own
`pacman-key --add`/`--lsign-key` for `oblinux-repo` is done.

**Confirmed working (round 20, `docs/TESTING.md`)**: built, installed,
and booted successfully on both VirtualBox and real hardware.
`pacstrap` resolved the now-signed `oblinux_repo` packages correctly at
build time. On both platforms, post-boot: `oblinux_repo` verified
functional (reinstalled a package, now signature-checked rather than
just present), `chaotic-aur` verified functional (installed a
known-existing package). No manual keyring intervention needed on
either platform — the `pacman-init.service` drop-in (live session) and
`shellprocess-final.conf` step (installed system) both worked as
designed.

## September 2026 consistency review

The following records the Dev review before promotion to Stable.
Read-only inspection on the build machine confirmed the signing-script
default, exported public key, and `oblinux-repo-trusted` all identify
`F83C29998D979B913298C40E7E0180391C821D13`. GnuPG verified all four package
signatures and both database signatures against that fingerprint. The
host pacman trust database reports the new public key as fully trusted.

The propagation paths remain wired correctly at source level:

- **Build:** the installed `mkarchiso` invokes `pacstrap` with `-G`;
  package verification uses the host pacman keyring. The profile's public
  key does not provision host trust. Host trust is confirmed above.
- **Live:** the new public key and matching `-trusted` file ship in the
  overlay; the `pacman-init.service` drop-in populates `oblinux-repo`.
- **Installed:** Calamares `unpackfs` copies the shipped key files;
  `shellprocess-final.conf` initializes and populates `archlinux chaotic
  oblinux-repo` in the target. The ephemeral keyring mount is removed and
  the live-only initialization service is masked, leaving persistent trust.

This is configuration and signature validation, **not** a post-rotation
ISO build, live boot, or install test. The installer currently prefixes
its keyring commands with `-`, allowing failures to be ignored; therefore
successful installer completion alone does not prove trust population.
Inspect the installer log and verify the key's trust and a signed package
operation in both live and installed environments during the next test.
No configuration changes were made by this documentation review.

## Existing installations from the previously published ISO

The pre-rotation profile shipped the previous OBLinux public key and its
trusted fingerprint. Its live initialization and Calamares population
steps trusted that key, alongside the separate Arch and Chaotic keyrings.
An unchanged installation from that ISO therefore trusts only the old
**OBLinux** signing key, not the replacement. This assessment follows the
pre-rotation source and reported release baseline; the published ISO and
individual installed machines were not inspected during this review.

Both pacman configurations require `Required TrustedOnly` for
`oblinux_repo`, applying to packages **and databases**. Once the newly
signed database is fetched, an old-key-only client cannot authenticate it;
repository synchronization can fail and block a normal full-system update.
Newly signed OBLinux packages also fail verification, even if a previously
cached database is usable. Already-installed programs continue to run;
Arch and Chaotic signing trust is unchanged. A key import prompt or
keyserver download alone does not establish trust in the replacement.
See upstream [pacman.conf signature policy](https://pacman.archlinux.page/pacman.conf.5.html)
and [pacman-key operations](https://pacman.archlinux.page/pacman-key.8.html).

There is no automatic migration: these OBLinux keyring files are plain ISO
overlay files, not an updatable keyring package. Updating `archlinux-keyring`,
rebooting, or populating the unchanged old `oblinux-repo.gpg` cannot acquire
the replacement. New profile files do not retroactively update published
ISOs or existing installations.

### Recommended migration (proposal only; not implemented)

Use a small, reviewed manual bootstrap procedure distributed through an
authenticated project channel, with the full new fingerprint confirmed
through an independently trusted channel before granting local trust.
Obtain the public key from an immutable, reviewed project revision;
inspect it and require an exact full-fingerprint match. The approved
procedure should update the on-disk OBLinux public-key/trusted files and
import and locally trust the replacement in pacman's persistent keyring,
then verify database/package signatures and perform a full system update.
Keep `Required TrustedOnly` throughout; do not bypass signature checking.

A new-key-signed transitional package cannot bootstrap trust in its own
signer, and the unavailable old private key cannot sign a bridge package.
A one-time authenticated manual trust step is therefore required with the
current distribution mechanism. A special package or script is not required
for that step. A managed OBLinux keyring package could improve future
rotations, but would be a separate implementation after this bootstrap;
an optional helper must enforce the same fingerprint verification.
Old-key retirement/revocation is also a separate explicit decision.

Before publishing a migration procedure, test it on an old-ISO installation
and verify that it recovers repository synchronization and signed package
installation without weakening signature policy. No migration was executed
or implemented in this review.

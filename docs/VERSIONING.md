# Release versioning and build identification

This document is the authoritative policy for OBLinux release versions, build
identifiers, ISO filenames, and the corresponding `/etc/os-release` fields.

## Release version

The repository-root `VERSION` file is the single machine-readable source of
the current OBLinux release version. Its one line uses:

```text
YY.QUARTER.MAINTENANCE[-dev]
```

- `YY` is the two-digit release year.
- `QUARTER` is `1`, `2`, `3`, or `4`.
- `MAINTENANCE` starts at `0` for the quarterly release and increments for
  bug-fix releases in the same quarterly line.
- `-dev` marks development leading to a quarterly release. Stable releases
  never include `-dev`.

Examples:

| Version | Meaning |
|---|---|
| `26.3.0-dev` | Development toward the 2026 Q3 release |
| `26.3.0` | Stable 2026 Q3 release |
| `26.3.1` | First maintenance release for 2026 Q3 |
| `26.4.0-dev` | Development toward the 2026 Q4 release |
| `26.4.0` | Stable 2026 Q4 release |
| `27.1.0-dev` | Development toward the 2027 Q1 release |

Version changes are intentional release-management actions. Unrelated work
must not change `VERSION`, and its value must not be invented or duplicated in
other source files when it can be read or rendered from `VERSION`.

## Exact build identity

Every ISO build receives a `BUILD_ID` in local build time:

```text
YYYYMMDD-HHMM
```

For example, `20260902-1425` identifies a build started at 14:25 local time on
September 2, 2026. `BUILD_ID` distinguishes multiple builds of the same
release version; it does not change release numbering and is not part of a Git
tag.

Always build through `scripts/build-iso.sh`. The wrapper:

1. reads `VERSION` once;
2. calls `date` once to capture `BUILD_ID`;
3. copies the source profile to a temporary profile;
4. renders that temporary profile's `/etc/os-release` from
   `airootfs/etc/os-release.in`;
5. passes the captured `BUILD_ID` to `profiledef.sh`; and
6. invokes `mkarchiso` with the repository's normal `work/` and `out/`
   directories.

The temporary profile is removed when the wrapper exits. The tracked template
and the working tree are not rewritten by a build. Direct `mkarchiso -v .` is
intentionally rejected by `profiledef.sh`, because it has no single generated
`BUILD_ID` to propagate.

Run on the Arch Linux build machine from the repository root:

```bash
cat VERSION
./scripts/build-iso.sh
```

The script uses `sudo` for `mkarchiso` when it is not already running as root.
It prints the captured `VERSION`, `BUILD_ID`, and expected ISO filename before
the build begins.

## ISO filename

Archiso names the output `${iso_name}-${iso_version}-${arch}.iso`. The profile
sets `iso_name` from `VERSION` and `iso_version` from the one generated
`BUILD_ID`, producing:

```text
oblinux-arch-${VERSION}-${BUILD_ID}-x86_64.iso
```

Examples include:

```text
oblinux-arch-26.3.0-dev-20260902-1425-x86_64.iso
oblinux-arch-26.3.0-20260915-0900-x86_64.iso
oblinux-arch-26.3.1-20261001-1830-x86_64.iso
```

## Live and installed system identity

The build wrapper renders these fields into the temporary profile's
`airootfs/etc/os-release` before `mkarchiso` constructs the squashfs:

```text
NAME="OBLinux"
VERSION="26.3.0-dev"
VERSION_ID="26.3.0-dev"
PRETTY_NAME="OBLinux 26.3.0-dev"
BUILD_ID="20260902-1425"
```

The values above are illustrative. The actual values always come from the
current `VERSION` file and the current build's single captured `BUILD_ID`.
Other OBLinux metadata in the template is retained.

The rendered file is part of the live squashfs. Calamares' `unpackfs` module
clones that squashfs into the target system; no later configured module
generates, replaces, or removes `/etc/os-release`. The installed system
therefore retains the exact release and build identifiers from the ISO that
installed it.

After booting both the live environment and the installed system, run:

```bash
cat /etc/os-release
```

Confirm that `VERSION` and `VERSION_ID` equal the repository `VERSION`, and
that `BUILD_ID` exactly matches the timestamp component of the ISO filename.

## Development, promotion, maintenance, and tags

The current Stable release in `oblinux-arch-iso` is **26.3.0**. Promotion,
final VM and physical laptop regression testing, tagging, and publication are
complete. The immutable tag `v26.3.0` points to
`67394522ded4b50b05ef150d8b71decddba2d824`. Subsequent documentation commits on
Stable `main` do not move that tag or change `VERSION`. See `TESTING.md` for
the owner-confirmed release artifact and verification record.

The separate `oblinux-arch-iso-dev` repository has subsequently advanced to
`26.4.0-dev`. Earlier `26.3.0-dev` values in this document are examples of the
version/build format, not the current development state.

Future promotions require acceptance of the development state, separate owner
authorization to promote into Stable, the intended stable version, and full
release validation. Follow `AGENTS.md`'s release sequence: commit, push `main`,
wait for CI to pass, report release-ready, then obtain separate authorization
to tag. Advancing Dev afterward is another separately authorized operation.

A Q3 maintenance release increments the third field, for example `26.3.1`,
and uses tag `v26.3.1`. Stable Git tags are `v` followed by the stable release
version. Development builds are not stable release tags. `BUILD_ID` never
appears in these tags.

Promotion, tagging, and the post-promotion development-version advance are
separate authorized operations. A successful ISO build performs none of them.

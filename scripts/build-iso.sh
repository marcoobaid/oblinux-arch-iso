#!/usr/bin/env bash
# Build an OBLinux ISO with one VERSION and one BUILD_ID propagated to the
# filename and the live/installed system. See docs/VERSIONING.md.

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"
version="$(<"${repo_root}/VERSION")"
build_id="$(date +%Y%m%d-%H%M)"

if [[ ! "${version}" =~ ^[0-9]{2}\.[1-4]\.[0-9]+(-dev)?$ ]]; then
    echo "ERROR: VERSION is not YY.QUARTER.MAINTENANCE[-dev]: ${version}" >&2
    exit 1
fi

if [[ ! "${build_id}" =~ ^[0-9]{8}-[0-9]{4}$ ]]; then
    echo "ERROR: generated BUILD_ID is invalid: ${build_id}" >&2
    exit 1
fi

build_root="$(mktemp -d "${TMPDIR:-/tmp}/oblinux-build.XXXXXXXX")"
build_profile="${build_root}/profile"
cleanup() {
    rm -rf -- "${build_root}"
}
trap cleanup EXIT INT TERM

mkdir -p -- "${build_profile}"
tar -C "${repo_root}" \
    --exclude='./.git' \
    --exclude='./out' \
    --exclude='./work' \
    -cf - . | tar -C "${build_profile}" -xf -

sed \
    -e "s/@OBLINUX_VERSION@/${version}/g" \
    -e "s/@OBLINUX_BUILD_ID@/${build_id}/g" \
    "${build_profile}/airootfs/etc/os-release.in" \
    > "${build_profile}/airootfs/etc/os-release"
chmod 0644 "${build_profile}/airootfs/etc/os-release"
rm -- "${build_profile}/airootfs/etc/os-release.in"

echo "VERSION=${version}"
echo "BUILD_ID=${build_id}"
echo "ISO=oblinux-arch-${version}-${build_id}-x86_64.iso"

build_command=(
    env "OBLINUX_BUILD_ID=${build_id}"
    mkarchiso -v
    -w "${repo_root}/work"
    -o "${repo_root}/out"
    "${build_profile}"
)

if (( EUID == 0 )); then
    "${build_command[@]}"
else
    sudo "${build_command[@]}"
fi

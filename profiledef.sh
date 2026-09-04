#!/usr/bin/env bash
# shellcheck disable=SC2034

profile_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
oblinux_version="$(<"${profile_dir}/VERSION")"
: "${OBLINUX_BUILD_ID:?Build with scripts/build-iso.sh so BUILD_ID is generated once}"

iso_name="oblinux-arch-${oblinux_version}"
iso_label="OBL_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="OBLinux <https://github.com/marcoobaid/oblinux>"
iso_application="OBLinux GNOME Live/Install Medium"
iso_version="${OBLINUX_BUILD_ID}"
install_dir="oblinux"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.grub')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
# This profile produces x86_64 media. Limiting XZ's executable filter to x86
# also avoids reproducible mksquashfs data-corruption failures seen when the
# unrelated arm64 filter is evaluated against this filesystem.
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/sudoers.d"]="0:0:750"
  ["/etc/sudoers.d/g_wheel"]="0:0:440"
  ["/etc/grub.d/09_oblinux_gfxterm_background"]="0:0:755"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/home/liveuser"]="1000:100:750"
  ["/home/liveuser/Desktop/Install OBLinux.desktop"]="1000:100:755"
  ["/home/liveuser/.local"]="1000:100:755"
  ["/home/liveuser/.local/share"]="1000:100:755"
  ["/home/liveuser/.local/share/applications"]="1000:100:755"
  ["/home/liveuser/.local/share/applications/org.gnome.Tour.desktop"]="1000:100:644"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/usr/local/lib/oblinux-live-session-setup"]="0:0:755"
)
